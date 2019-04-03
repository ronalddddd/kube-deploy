FROM alpine:3.9

# Ansible install scripts forked from: https://hub.docker.com/r/lexauw/ansible-alpine/dockerfile

ENV ANSIBLE_VERSION=2.7.8

RUN set -xe \
    && echo "****** Install system dependencies ******" \
    && apk add --no-cache --progress python3 openssl \
		ca-certificates git openssh sshpass \
	&& apk --update add --virtual build-dependencies \
		python3-dev libffi-dev openssl-dev build-base \
	\
	&& echo "****** Install ansible and python dependencies ******" \
    && pip3 install --upgrade pip \
	&& pip3 install ansible==${ANSIBLE_VERSION} boto3 \
    \
    && echo "****** Remove unused system librabies ******" \
	&& apk del build-dependencies \
	&& rm -rf /var/cache/apk/*

RUN set -xe \
    && mkdir -p /etc/ansible \
    && echo -e "[local]\nlocalhost ansible_connection=local" > \
        /etc/ansible/hosts

# Install openshift client to support k8s module
RUN pip install openshift

# Make and switch to default workdir
ADD playbook /playbook

WORKDIR /playbook
RUN chmod u+x /playbook/vault-password.sh
RUN mkdir /deployment

# Pretty-print Ansible output
ENV ANSIBLE_STDOUT_CALLBACK "debug"

ENTRYPOINT ["./entrypoint.sh"]
# Default to running playbook with --tags "deployment"
CMD ["deployment"]

