
TAG=$(date +"%m%d%H%M%S")
TEMPLATE=experiments/experiment.yaml
ID=id-$TAG
STABLE=$1
CANDIDATE=$2
NS=kabanero 

if [ -z $STABLE ]
then 
  echo missing argument 1, baseline service name
exit
fi
if [ -z $CANDIDATE ]
then 
  echo missing argument 1, candidate service name
exit
fi

echo Running Experiment from baseline: $STABLE to candidate: $CANDIDATE

yq write --inplace $TEMPLATE metadata.name $ID
yq write --inplace $TEMPLATE  spec.targetService.baseline $STABLE
yq write --inplace $TEMPLATE  spec.targetService.candidate $CANDIDATE

echo "------- running this experiment ------------"
cat $TEMPLATE
echo "------- ^^^^^^ ------------"

kubectl apply -f $TEMPLATE -n $NS

