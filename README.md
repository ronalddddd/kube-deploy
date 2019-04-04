# Kubernetes Deployment

Deploy Kubernetes manifest templates using Ansible.

How it works:

- mount an Ansible role directory into `/deployment`
  - use the k8s Ansible module to template and apply manifests
- set these environment variables:
    - k8s cluster connection settings 
    - private docker registry credentials
    - namespace for deployment
    - optional variables that will get exposed to playbook variables
- the default playbook run will 
  - create the k8s namespace 
  - create the private registry secret
  - trigger the Ansible role you've mounted

## Usage

- Set these environment variables:
    - `CLUSTER_CA_CERT`: Cluster's CA Cert (base64 encoded)
    - `CLUSTER_SERVER`: Cluster's API entry point
    - `CLUSTER_TOKEN`: Service Account Token
    - `DOCKER_CONFIG_JSON`: Private registry credentials, can be obtained by:
        - generating the secret, replacing `USER`, `PASSWORD`, and `https://registry.gitlab.com/` as needed:
        
            ```bash
            kubectl create secret docker-registry regcred \
              --docker-username="USER" --docker-password="PASSWORD" \
              --docker-server="https://registry.gitlab.com/" \
              --dry-run -o yaml
            ```  
      - copy the value from the field `.dockerconfigjson` 
    - `DEPLOY_NAMESPACE`: Kubernetes namespace that will be created/deleted
    - `DEPLOY_STATE`: `present` | `absent`
    - `DEPLOY_IMAGE`: (optional) The docker image 
        - exposed in Ansible as `deploy_image`
        - e.g. "ronalddddd/foo" 
    - `DEPLOY_TAG`: (optional) The docker image tag 
        - exposed in Ansible as `deploy_tag`
        - it is recommended you don't use "latest" as Ansible will not know if this image has been updated and hence won't trigger a redeploy
    - `DEPLOY_HOST`: (optional) Used for setting your service's Ingress host
        - exposed in Ansible as `deploy_host`
    - `DEPLOY_CONFIG`: (optional) Used for identifying which set of configurations to use in your playbook role
        - exposed in Ansible as `deploy_config`
        - e.g. "staging" or "production"
    - `DEPLOY_VAULT_PASS`: (optional) Used to decrypt ansible-vault encrypted files
    - `EXTRA_VARS`: (optional) Variables for `ansible-playbook`'s `--extra-vars` command
        - e.g. `deploy_role=ingress acme_email=foo@example.com`

- Mount your Ansible role folder to `/deployment` and run the playbook:

    ```bash
    docker run --rm -it \
      -v /path/to/app-role:/deployment \
      --env-file=/path/to/.env
      ronalddddd/kube-deploy
    ```

- Optionally you can add ConfigMap and Secrets definitions into the `deployment/files` directory: 
  - `deployment/files/configmap-<DEPLOY_CONFIG>.yml`
  - `deployment/files/secrets-<DEPLOY_CONFIG>.yml`
    - these can be encrypted using `ansible-vault encrypt`
    - if you encrypt them, provide the decryption passphrase into `DEPLOY_VAULT_PASS`

### Deploying the included Ingress Nginx role

- Set `EXTRA_VARS` and run the playbook:

    ```
    docker run --rm -it \
      --env-file=/path/to/.env
      -e EXTRA_VARS="deploy_role=ingress acme_email=foo@example.com"
      -e DEPLOY_NAMESPACE=ingress-nginx
      -e DEPLOY_STATE=present
      ronalddddd/kube-deploy
    ```

### Deploying the included Gitlab (Kubernetes) Runner role 

- Set `EXTRA_VARS` and run the playbook:

    ```
    docker run --rm -it \
      --env-file=/path/to/.env
      -e EXTRA_VARS="deploy_role=gitlab_runner gitlab_runner_token=<YOUR TOKEN>"
      -e DEPLOY_NAMESPACE=gitlab
      -e DEPLOY_STATE=present
      ronalddddd/kube-deploy
    ```

- `gitlab_runner_token` can be obtained by:

  ```bash
  curl --request POST "https://gitlab.com/api/v4/runners" --form "token=<REGISTRATION TOKEN>" --form "description=dev-cluster-runner"
  ```
  
## Quick References

- [k8s module](https://docs.ansible.com/ansible/latest/modules/k8s_module.html#examples)
- [Ansible examples](https://github.com/ansible/ansible-examples)
- [Playbook best practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#directory-layout)
