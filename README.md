# CI/CD with GitHub Actions for Kestra flows

This repository provides an end-to-end example of how you can use the [deploy](https://github.com/marketplace/actions/kestra-deploy-action) and [validate](https://github.com/marketplace/actions/kestra-validate-action) GitHub Actions. 

Make sure that the directory structure of your flows corresponds to the structure of your namespaces.

| Directory              | Namespace      |
| ---------------------- | -------------- |
| ./flows/prod           | prod           |
| ./flows/prod.marketing | prod.marketing |

