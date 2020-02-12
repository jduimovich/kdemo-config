
FILE=inprogress
if test -f "$FILE"; then
    echo "$FILE exist"
    exit
fi
echo inprogress > $FILE

V1_IMAGE=$(kubectl get deployments -n kabanero demoservice-v1 -o yaml | yq r - spec.template.spec.containers[0].image)
V2_IMAGE=$(kubectl get deployments -n kabanero demoservice-v2 -o yaml | yq r - spec.template.spec.containers[0].image)
V1_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[0].weight)
V2_WEIGHT=$(kubectl get vs -n kabanero demoservice -o yaml | yq r - spec.http[0].route[1].weight)


echo Running AB Roll Forward 
echo demoservice-v1 is $V1_IMAGE  
echo demoservice-v2 is $V2_IMAGE

TAG_V1=$(echo $V1_IMAGE | cut -f2 -d ':')
TAG_V2=$(echo $V2_IMAGE | cut -f2 -d ':')

if [ $TAG_V2 -gt $TAG_V1 ] ; then
  echo  "move to V2"   
  if [ $V2_WEIGHT == "100" ] ; then
    echo  V2 Completed 
  else  
    echo Moving Primary Service to V2 
    sh configure.sh 0 100
  fi
else
  echo  "move to  V1"      
  if [ $V1_WEIGHT == "100" ] ; then
    echo  V1 Completed 
  else  
    echo Moving Primary Service to V1   
    sh configure.sh 100 0
  fi
fi

rm $FILE
