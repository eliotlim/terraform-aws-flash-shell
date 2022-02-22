ARG PYTHON_VERSION="3.9"
ARG BASE_IMAGE="amd64/alpine:latest"
ARG FUNCTION_DIR="/var/task"
ARG DEPENDENCIES_DIR="/opt/python"

# Stage 1 - Build base runtime image
FROM ${BASE_IMAGE} AS base
RUN apk upgrade --update --no-cache
RUN apk add --update --no-cache python3

# Stage 2 - Build and install dependencies in ephemeral container image
FROM base AS build-image
ARG FUNCTION_DIR
ARG DEPENDENCIES_DIR

RUN apk add --update --no-cache \
    bc \
    cargo \
    cmake \
    curl \
    g++ \
    gcc \
    git \
    libffi-dev \
    make \
    musl-dev \
    openssl-dev \
    postgresql-dev \
    py3-pip \
    python3-dev \
    rust

RUN pip install --upgrade pip
RUN mkdir ${DEPENDENCIES_DIR}
COPY requirements.txt .
RUN pip install --no-cache-dir --no-compile -t ${DEPENDENCIES_DIR} -r requirements.txt

# Stage 3 - Build container on runtime image
FROM base AS deployment-image
ARG FUNCTION_DIR
ARG DEPENDENCIES_DIR
ARG PYTHON_VERSION
WORKDIR ${FUNCTION_DIR}

# Copy installed and built dependencies
RUN mkdir -p ${FUNCTION_DIR}
RUN mkdir -p ${DEPENDENCIES_DIR}
ENV PATH=${PATH}:${DEPENDENCIES_DIR}/bin
ENV PYTHONPATH=${PYTHONPATH}:${DEPENDENCIES_DIR}
RUN apk add --update --no-cache openssh-client postgresql-client
COPY --from=build-image /usr/lib/python${PYTHON_VERSION}/site-packages/ /usr/lib/python${PYTHON_VERSION}/site-packages/
COPY --from=build-image ${DEPENDENCIES_DIR} ${DEPENDENCIES_DIR}

# Copy serverless code
COPY ./examples/* ${FUNCTION_DIR}/

# (Optional) Add Lambda Runtime Interface Emulator and use a script in the ENTRYPOINT for simpler local runs
# ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
CMD [ "ansible-playbook", "--version" ]
