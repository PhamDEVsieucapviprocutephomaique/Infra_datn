

ENV=$1

az login --service-principal \
  -u $AZURE_CLIENT_ID \
  -p $AZURE_CLIENT_SECRET \
  -t $AZURE_TENANT_ID

az aks get-credentials \
  --resource-group $AKS_RG_$(echo $ENV | tr '[:lower:]' '[:upper:]') \
  --name $AKS_NAME_$(echo $ENV | tr '[:lower:]' '[:upper:]') \
  --file kubeconfig-$ENV