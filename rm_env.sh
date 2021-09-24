#!/bin/bash

env_name=vgg16

## remove
conda remove --name $env_name --all
jupyter kernelspec uninstall $env_name
