
V1_STATUS=$(kubectl get deployments -n kabanero demoservice-v1 -o yaml | yq r - spec.template.metadata.labels.status)
V2_STATUS=$(kubectl get deployments -n kabanero demoservice-v2 -o yaml | yq r - spec.template.metadata.labels.status)

V1_V=$(kubectl get deployments -n kabanero demoservice-v1 -o yaml | yq r - spec.template.metadata.labels.version)
V2_V=$(kubectl get deployments -n kabanero demoservice-v2 -o yaml | yq r - spec.template.metadata.labels.version)


echo $V1_STATUS
echo $V2_STATUS

if [ $V1_STATUS == "original" ] ; then
  echo move from v1 $V1_V to v2 $V2_V
  sh configure.sh 100 0
  sleep 5
  sh configure.sh 80 20
  sleep 5
  sh configure.sh 60 40
  sleep 5
  sh configure.sh 40 60
  sleep 5
  sh configure.sh 20 80
  sleep 5
  sh configure.sh 0  100
else
  echo move from v2 $V2_V to v1 $V1_V
  sh configure.sh 0  100
  sleep 5
  sh configure.sh 20 80
  sleep 5
  sh configure.sh 40 60
  sleep 5
  sh configure.sh 60 40
  sleep 5
  sh configure.sh 80 20
  sleep 5
  sh configure.sh 100 0
fi

 
