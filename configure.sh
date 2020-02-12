
# configure.sh LEFT RIGHT 

v1=$1
v2=$2
if [ -z "$v1" ]
then
echo "Need a left value" 
exit   
fi
if [ -z "$v2" ]
then
echo "Need a left value" 
exit   
fi

yq w -i demoservice.yaml spec.http[0].route[0].weight $v1
yq w -i demoservice.yaml spec.http[0].route[1].weight $v2

kubectl get namespaces | grep tekton-pipelines  > /dev/null
if [ $? -eq 0 ] ; then
   NS=tekton-pipelines 
else
   NS=kabanero 
fi

echo Active Namespace is $NS 

kubectl apply  -f demoservice.yaml  -n $NS

echo '{ "left": ' $v1 ', "right":'  $v2 '}' >lr

 


