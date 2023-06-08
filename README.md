# CI/CD with GitHub Actions for Kestra flows

This repository provides an end-to-end example of how you can use the [deploy](https://github.com/marketplace/actions/kestra-deploy-action) and [validate](https://github.com/marketplace/actions/kestra-validate-action) GitHub Actions. 

Make sure that the directory structure of your flows corresponds to the structure of your namespaces.

| Directory              | Namespace      |
| ---------------------- | -------------- |
| ./flows/prod           | prod           |
| ./flows/prod.marketing | prod.marketing |


## Full CI/CD example using a GitHub Actions workflow

```yaml
name: Kestra CI/CD
on: 
  push:
    branches:
      - main

jobs:
  prod:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: validate-all flows
        uses: kestra-io/validate-action@develop
        with:
          directory: ./flows/prod
          resource: flow
          server: ${{secrets.KESTRA_HOST}}
          user: ${{secrets.KESTRA_USER}}
          password: ${{secrets.KESTRA_PASSWORD}}
      
      - name: deploy-prod
        uses: kestra-io/deploy-action@develop
        with:
          namespace: prod
          directory: ./flows/prod
          resource: flow
          server: ${{secrets.KESTRA_HOST}}
          user: ${{secrets.KESTRA_USER}}
          password: ${{secrets.KESTRA_PASSWORD}}
          delete: false
      
      - name: deploy-prod-marketing
        uses: kestra-io/deploy-action@develop
        with:
          namespace: prod.marketing
          directory: ./flows/prod.marketing
          resource: flow
          server: ${{secrets.KESTRA_HOST}}
          user: ${{secrets.KESTRA_USER}}
          password: ${{secrets.KESTRA_PASSWORD}}
          delete: false
```


# CI/CD from a flow
Alternatively, you can use a Kestra flow that will deploy production flows based on the current state of the default branch. You can either run this flow on schedule or in response to a GitHub webhook event.

```yaml
id: ci-cd
namespace: prod
tasks:
  - id: deploy
    type: io.kestra.core.tasks.flows.Worker
    tasks:
      - id: cloneRepository
        type: io.kestra.plugin.git.Clone
        url: https://github.com/anna-geller/kestra-ci-cd
        branch: main
        username: anna-geller
        # password: "{{envs.github_access_token}}"
      - id: validateFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra flow validate flows/ 
      - id: deployFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra flow namespace update prod flows/prod/ --no-delete 
          - /app/kestra flow namespace update prod.marketing flows/prod.marketing/ --no-delete
```

## CI/CD from a flow with a self-hosted remote server

```yaml
id: ci-cd
namespace: prod
variables:
  host: "http://your_host_name:8080/" 
  auth: "username:password"
tasks:
  - id: deploy
    type: io.kestra.core.tasks.flows.Worker
    tasks:
      - id: cloneRepository
        type: io.kestra.plugin.git.Clone
        url: https://github.com/anna-geller/kestra-ci-cd
        branch: main
        username: anna-geller 
        # password: "{{secret('GITHUB_ACCESS_TOKEN')}}"
      - id: validateFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra flow validate flows/ --server={{vars.host}} --user={{vars.auth}}
      - id: deployFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra flow namespace update prod flows/prod/ --no-delete --server={{vars.host}} --user={{vars.auth}}
          - /app/kestra flow namespace update prod.marketing flows/prod.marketing/ --no-delete --server={{vars.host}} --user={{vars.auth}}
triggers:
  - id: github
    type: io.kestra.core.models.triggers.types.Webhook
    key: "yourSecretKey"
```

![meme](meme.jpg)


## CI/CD from a flow with Kestra Enterprise

For Kestra Enterprise, make sure to change `/app/kestra` to `/app/kestra-ee`.

```yaml
id: ci-cd
namespace: prod
variables:
  host: "https://demo.kestra.io/"
  auth: "cicd:{{secret('CICD_PASSWORD')}}" # cicd is a username - syntax is username:password
tasks:
  - id: deploy
    type: io.kestra.core.tasks.flows.Worker
    tasks:
      - id: cloneRepository
        type: io.kestra.plugin.git.Clone
        url: https://github.com/anna-geller/kestra-ci-cd
        branch: main
        username: anna-geller # password: "{{secret('GITHUB_ACCESS_TOKEN')}}"
      - id: validateFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra-ee flow validate flows/ --server={{vars.host}} --user={{vars.auth}}
      - id: deployFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra-ee flow namespace update prod flows/prod/ --no-delete --server={{vars.host}} --user={{vars.auth}}
          - /app/kestra-ee flow namespace update prod.marketing flows/prod.marketing/ --no-delete --server={{vars.host}} --user={{vars.auth}}
triggers:
  - id: github
    type: io.kestra.core.models.triggers.types.Webhook
    key: "yourSecretKey"
```