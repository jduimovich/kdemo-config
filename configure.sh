
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

CONFIG=$(cat last-built) 
echo using $CONFIG for config image

t1=$(mktemp) 
t2=$(mktemp)  

echo $CONFIG

cp deploy-template $t1
sed "s!PIPELINE_REPLACE:latest!$CONFIG!" $t1 > $t2
cp $t2 $t1
sed s/DEMO_V1/${DEMO_V1////\\/}/ $t1 > $t2
cp $t2 $t1
sed s/DEMO_V2/${DEMO_V2////\\/}/ $t1 > $t2
cp $t2 $t1
sed s/LEFT/$v1/ $t1 > $t2
cp $t2 $t1
sed s/RIGHT/$v2/ $t1 > $t2 
cp $t2 last-applied-yaml
rm $t1
rm $t2

kubectl apply  -f last-applied-yaml 

cat last-applied-yaml


