import json
import logging
import os
import boto3

client = boto3.client('ecs')


def handler(event: dict, context):
    log = logging.getLogger('flash-shell')
    log.setLevel(logging.DEBUG)

    network_configuration = {
        'awsvpcConfiguration': {
            'assignPublicIp': os.environ.get('NETWORK_ASSIGN_PUBLIC_IP', 'DISABLED'),
            'securityGroups': os.environ.get('NETWORK_SECURITY_GROUPS').split(' '),
            'subnets': os.environ.get('NETWORK_SUBNETS').split(' '),
        }
    }

    log.debug('Network Configuration:')
    log.debug(network_configuration)

    # Check if event specifies a command or environment variables
    env = "environment" in event
    cmd = "command" in event
    container_overrides = []

    # Parse and enable container-specific overrides
    if env or cmd:
        container_override = {'name': os.environ.get('CONTAINER_NAME')}

        if env:
            environment = [{'name': k, 'value': v} for k, v in event.get('environment').items()]
            container_override['environment'] = environment
            log.debug('Environment overrides applied')
            log.debug(environment)
        if cmd:
            command = event.get('command')
            container_override['command'] = command
            log.debug(f"Command override: {command}")

        container_overrides = [container_override]

    try:
        log.info("Starting task...")
        result = client.run_task(
            taskDefinition=os.environ.get('TASK_DEFINITION'),
            cluster=os.environ.get('CLUSTER'),
            count=int(os.environ.get('TASK_COUNT', 1)),
            launchType=os.environ.get('LAUNCH_TYPE', 'FARGATE'),
            networkConfiguration=network_configuration,
            overrides={
                'containerOverrides': container_overrides
            },
        )
        log.info("Task started")

        task_result: dict = result.get('tasks')[0]

        return {
            'statusCode': 200,
            'body': json.dumps(task_result, default=str)
        }
    except Exception as e:
        log.error("Task failed to start")
        log.error(e)
        return {
            'statusCode': 400,
            'body': 'Error invoking task',
        }
