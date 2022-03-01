FROM amd64/alpine

RUN apk add --no-cache \
    openssh \
    python3 \
    py3-pip

RUN pip3 install --upgrade pip && \
    pip3 install \
      awscli

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
CMD [ "sftp", "-v" ]
