import json
import os
import boto3

client = boto3.client('ecs')


def handler(event, context):
    network_configuration = {
        'awsvpcConfiguration': {
            'assignPublicIp': bool(os.environ.get('NETWORK_ASSIGN_PUBLIC_IP', 'DISABLED')),
            'securityGroups': os.environ.get('NETWORK_SECURITY_GROUPS').split(' '),
            'subnets': os.environ.get('NETWORK_SUBNETS').split(' '),
        }
    }
    container_overrides = []

    if event.command is not None or event.enviroment is not None:
        environments = [{'name': k, 'value': v} for k, v in event.environments.items()]

        container_overrides.append({
            'name': os.environ.get('CONTAINER_NAME'),
            'command': event.command,
            'environment': environments,
        })

    try:
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

        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 200,
            'body': 'Error invoking task',
        }

