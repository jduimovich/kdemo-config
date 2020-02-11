
FILE=inprogress
if test -f "$FILE"; then
    echo "$FILE exist"
    exit
fi
echo inprogress > $FILE

V1_STATUS=$(kubectl get deployments -n kabanero demoservice-v1 -o yaml | yq r - spec.template.metadata.labels.status)
V2_STATUS=$(kubectl get deployments -n kabanero demoservice-v2 -o yaml | yq r - spec.template.metadata.labels.status)

echo demoservice-v1 is $V1_STATUS
echo demoservice-v2 is $V2_STATUS

V1_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[0].weight)
V1_V=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[0].destinatin.subset)

V2_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[1].weight)
V2_V=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[1].destinatin.subset)

echo V1_WEIGHT $V1_WEIGHT
echo V1_V $V1_V
echo V2_WEIGHT $V2_WEIGHT
echo V2_V $V2_V

if [ $V1_STATUS == "original" ] ; then
  echo move from v1 $V1_V to v2 $V2_V  
  
  if [ $V2_WEIGHT == "100" ] ; then
    echo  V2 ALREADY DONE
  else  
    echo NEED TO MOVE TO V2echo move from v1 $V1_V to v2 $V2_V
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
  echo move from v2 $V2_V to v1 $V1_V  
    if [ $V1_WEIGHT == "100" ] ; then
    echo  V1 ALREADY DONE
  else  
    echo NEED TO MOVE TO V1
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

 
