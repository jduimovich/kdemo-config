
V1_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[0].weight)
V2_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[1].weight)

echo '{ "left": ' $V1_WEIGHT ', "right":'  $V2_WEIGHT '}'
 


