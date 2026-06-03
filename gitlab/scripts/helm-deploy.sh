

SERVICE=$1
ENV=$2
VERSION=$3

helm upgrade --install $SERVICE-$ENV \
  ./charts/base-service \
  -f ./releases/$ENV/$SERVICE.yaml \
  --namespace $ENV \
  --create-namespace \
  --set image.tag=$VERSION \
  --wait