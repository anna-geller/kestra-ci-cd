# CI/CD with GitHub Actions for Kestra flows

This repository provides an end-to-end example of how you can use the [deploy](https://github.com/marketplace/actions/kestra-deploy-action) and [validate](https://github.com/marketplace/actions/kestra-validate-action) GitHub Actions. 

Make sure that the directory structure of your flows corresponds to the structure of your namespaces.

| Directory              | Namespace      |
| ---------------------- | -------------- |
| ./flows/prod           | prod           |
| ./flows/prod.marketing | prod.marketing |

## CI/CD from a flow
Alternatively, you can use a Kestra flow that will deploy production flows based on the current state of the default branch. You can either run this flow on schedule or in response to a GitHub webhook event.

```yaml
id: ci-cd
namespace: prod
tasks:
  - id: github-ci-cd
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
          - /app/kestra flow validate flows/
      - id: deployFlows
        type: io.kestra.core.tasks.scripts.Bash
        commands:
          - /app/kestra flow namespace update prod flows/prod/
          - /app/kestra flow namespace update prod.marketing flows/prod.marketing/
triggers:
  - id: github
    type: io.kestra.core.models.triggers.types.Webhook
    key: "{{secret(WEBHOOK_KEY)}}"
```

![meme](meme.jpg)