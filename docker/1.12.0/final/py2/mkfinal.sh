#!/bin/bash
# 27 Apr 2019
# Build Sagemaker container
# per instructions at https://github.com/aws/sagemaker-tensorflow-container#building-your-image
# 
# We're hardwire for 1.9.0 in this script.
# Dave Dickerson
#
export top="$HOME/sagemaker/sagemaker-tensorflow-container"
export frameworkdir="$top/tensorflow-binaries/1.12.0"
export frameworkdir="./"
mkdir -p ${frameworkdir}
export framework=$frameworkdir/tensorflow-1.12.0-cp27-cp27mu-manylinux1_x86_64.whl
export containerName=sagemaker-tf1-12-0
export containerVersion=latest
export ecr=428505257828.dkr.ecr.us-east-2.amazonaws.com
export debug=1
if [ $debug -gt 0 ] ; then
   echo ################################################################################
   echo ################################################################################
   echo "script environment:"
   echo top: $top
   ls -l $top
   echo frameworkdir: $frameworkdir
   ls -l $frameworkdir
   echo framework: $framework
   ls -l $framework
   echo ################################################################################
   echo ################################################################################
fi
echo "downloading tensorflow framework from files.pythonhosted.org"
pushd $frameworkdir
# Fet tensorflow ibits
if [ ! -f tensorflow-1.12.0-cp27-cp27mu-manylinux1_x86_64.whl ] ; then
   wget https://files.pythonhosted.org/packages/bd/68/ec26b2cb070a5760707ec8d9491a24e5be72f4885f265bb04abf70c0f9f1/tensorflow-1.12.0-cp27-cp27mu-manylinux1_x86_64.whl
else
   echo "download of tensorflow skipped"
fi
# Create the SageMaker TensorFlow Container Python package.
popd

pushd $top
python setup.py sdist
popd
#. Copy your Python package to “final” Dockerfile directory that you are building.
cp $top/dist/sagemaker_tensorflow_container-1.0.0.tar.gz .
docker build -t ${containerName}:${containerVersion}  --build-arg framework_installable=$framework -f Dockerfile.cpu .

echo "type y to push to ECR"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
   echo push to ECR
   $(aws ecr get-login --no-include-email --region us-east-2)
   # docker tag sagemaker-tf1-12-0:latest 428505257828.dkr.ecr.us-east-2.amazonaws.com/sagemaker-tf1-12-0:latest
   docker tag ${containerName}:${containerVersion} ${ecr}/${containerName}:${containerVersion}
   docker push ${ecr}/${containerName}:${containerVersion}
fi
