Example repository template for your flows

```bash
terraform import kestra_namespace.prod prod
terraform apply -auto-approve -var-file prod.tfvar
terraform destroy -var-file prod.tfvar
```

