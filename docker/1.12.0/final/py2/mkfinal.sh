#!/bin/bash
export framework=~/sagemaker/sagemaker-tensorflow-container/tensorflow-binaries/1.12.0/tensorflow-1.12.0-cp27-cp27mu-manylinux1_x86_64.whl
docker build -t sagemaker-tf-1.12.0:1 --build-arg framework-installable=$framework -f Dockerfile.cpu .
