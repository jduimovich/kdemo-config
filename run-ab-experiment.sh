
FILE=inprogress
if test -f "$FILE"; then
    echo "$FILE exist"
    exit
fi
echo inprogress > $FILE

NS=kabanero 

V1_IMAGE=$(kubectl get deployments -n kabanero demoservice-v1 -o yaml | yq r - spec.template.spec.containers[0].image)
V2_IMAGE=$(kubectl get deployments -n kabanero demoservice-v2 -o yaml | yq r - spec.template.spec.containers[0].image)

kubectl get destinationrule -n $NS   >/dev/null
if [ $? -eq 0 ] ; then
echo run kubectl  
VERSION=$(kubectl get destinationrule -n $NS -o yaml | yq r - items[0].spec.subsets[0].labels.version)
else 
     echo  "No Service, run the default v1-v2 upgrade" 
     VERSION=v1
fi

echo Running AB Roll Forward 
echo demoservice-v1 is $V1_IMAGE  
echo demoservice-v2 is $V2_IMAGE

TAG_V1=$(echo $V1_IMAGE | cut -f2 -d ':')
TAG_V2=$(echo $V2_IMAGE | cut -f2 -d ':')

if [ $TAG_V2 -gt $TAG_V1 ] ; then
  echo  "Should be moved to V2"   
  if [ $VERSION == "v2" ] ; then
    echo  V2 already active 
  else  
    echo Moving Primary Service to V2 
    sh run-experiment.sh demoservice-v1 demoservice-v2
  fi
else
  echo  "move to  V1"      
  if [ $VERSION == "v1" ] ; then 
    echo  V1 already active 
  else  
    echo Moving Primary Service to V1   
    sh run-experiment.sh demoservice-v2 demoservice-v1
  fi
fi

rm $FILE
