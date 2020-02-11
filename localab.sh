
FILE=inprogress
if test -f "$FILE"; then
    echo "$FILE exist"
    exit
fi
echo inprogress > $FILE

V1_STATUS=$(kubectl get deployments -n kabanero demoservice-v1 -o yaml | yq r - spec.template.metadata.labels.status)
V2_STATUS=$(kubectl get deployments -n kabanero demoservice-v2 -o yaml | yq r - spec.template.metadata.labels.status)

V1_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[0].weight)
V2_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[1].weight)

echo Running AB Roll Forward 
echo demoservice-v1 is $V1_STATUS  Weight $V1_WEIGHT 
echo demoservice-v2 is $V2_STATUS  Weight $V2_WEIGHT 

if [ $V1_STATUS == "original" ] ; then 
  if [ $V2_WEIGHT == "100" ] ; then
    echo  V2 Completed 
  else  
    echo Moving Primary Service to V2
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
  fi
else 
  if [ $V1_WEIGHT == "100" ] ; then
    echo  V1 Completed 
  else  
    echo Moving Primary Service to V1
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
fi
rm $FILE

 
