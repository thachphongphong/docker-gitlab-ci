# docker-gitlab-ci

##GitLab Continuous Integration & Deployment

### GITLAB SERVER

## Enable Container Registry
- Install docker
- Deploy a registry server (with auth: basic or token).
   - ex: Basic auth (/auth/htpasswd)
```
    docker run -d  -p 5000:5000  --restart=always  --name registry  
    -v `pwd`/auth:/auth   
    -e "REGISTRY_AUTH=htpasswd"   
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm"   
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd  registry:2
```
- Edit gitlab config (/etc/gitlab/gitlab.rb) enable ssl (using letsencrypt)
```
    nginx['ssl_certificate'] = "/etc/letsencrypt/live/.../fullchain.pem"
    nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/.../privkey.pem"
```
- You can use a subdomain for registry (registry.abc.com). In my case i use git domain
```
    registry_external_url 'https://git.abc.com:4567'
    registry_nginx['ssl_certificate'] = "/etc/letsencrypt/live/git.abc.com/fullchain.pem"
    registry_nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/git.abc.com/privkey.pem"
```
- Reconfig gitlab
```
    sudo gitlab-ctl reconfigure
```
### GITLAB RUNNER SERVER

## Register gitlab-runner
- [Install gitlab runner](https://docs.gitlab.com/runner/install/index.html)
- [Registering Runners](https://docs.gitlab.com/runner/register/index.html)
- Open Project > Settings > Pipeline  to get token

## Create pipeline file
- Add project secret variables (Project > Settings > Pipeline)
  - ex: .gitlab-ci.yml
```
    CI_REGISTRY_URL : https://git.abc.com:4567
    CI_REGISTRY_USER: user in /auth/htpasswd file
    CI_REGISTRY_PASSWORD: pass in /auth/htpasswd file
    SSH_PRIVATE_KEY: generate ssh private key (cat .ssh/id_rsa | base64 -w0)
    DEPLOY_SERVER: user@ip-server (add public key to deploy server authentication_keys)
```

- Explain .gitlab-ci.yml step:
  - ex: we have 2 step (build and deploy, you can use test step if necessary)
  - build: we build docker image and push to our registry server we create above.
  - deploy: we ssh to deploy server, pull new docker image, stop current one and run new image (deploy.sh)
  - deploy.sh : we can put it in git but put it on remote server is safer
  - only (git refs for which job is created), tags ()which are used to select Runner)
  
- Make sure you can ssh to deploy server from gitlab runner server (edit firewall ...). 

**Good luck**