## 01 - tf_talos
terraform workspace new rancher
terraform init
terraform apply

terraform workspace new talos
terraform init
terraform apply

cp kubeconfig-rancher.yaml ~/.kube/config

## 02 - tf_rancher
terraform init
terraform apply