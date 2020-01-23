
source configuration

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

t1=$(mktemp) 
t2=$(mktemp)  

cp deploy-template $t1
sed s/LEFT/$v1/ $t1 > $t2
cp $t2 $t1
sed s/RIGHT/$v2/ $t1 > $t2 
cp $t2 last-applied-yaml
rm $t1
rm $t2

kubectl get namespaces | grep tekton-pipelines  > /dev/null
if [ $? -eq 0 ] ; then
   NS=tekton-pipelines 
else
   NS=kabanero 
fi

echo Active Namespace is $NS 

kubectl apply  -f last-applied-yaml  -n $NS


