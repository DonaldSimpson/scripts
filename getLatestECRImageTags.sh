#!/bin/bash

# Lists the most recent tag for each image in an AWS ECR
# Assumes your AWS_PROFILE and the AWS CLI are setup correctly
# Outputs a file ("latest_images") that could be used to Twistlock scan all tags via jenkins

REG_ADDRESS="<YOURREGISTRY>.amazonaws.com"
echo "Getting a list of all images in the currnet ECR"
aws ecr describe-repositories | grep repositoryName | awk -F\" {'print $4'} > allrepos
export COUNT=`cat allrepos | wc -l`
echo "done, $COUNT distinct image repos found"
sleep 2
COUNTER=0
EMPTY=0
> latest_images
echo "Finding the most recently pushed tag in each repo..."
for image in `cat allrepos`; do
  export LATEST=`aws ecr describe-images --repository-name ${image} --output text --query 'sort_by(imageDetails,& imagePushedAt)[*].imageTags[*]' | tr '\t' '\n' | tail -1`
  if [ -z "$LATEST" ];then
    echo "No tag found for $image"
    EMPTY=$[$EMPTY +1]
  else
    COUNTER=$[$COUNTER +1]
    echo "$COUNTER/$COUNT processed... latest tag for image $image is $LATEST."
    echo "doTwistlock('$REG_ADDRESS/$image:$LATEST')" >> latest_images
  fi
done
  echo " "
  echo "Done:"
  echo "$COUNTER of $COUNT latest image tags found and added to 'latest_images'."
  echo "$EMPTY of $COUNT repos have no tags."
  echo " "
  rm allrepos | :
