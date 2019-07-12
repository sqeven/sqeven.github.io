#!/bin/bash
[ -z "$set_e" ] && set -e

[ -z "$1" ] && { echo '$1 is not set';exit 2; }

which docker &> /dev/null || { echo 'search needs docker, please install the docker';exit 2; }

img=$1
repo=${img%:*}
[[ $img == *:* ]] && tag=${img##*:} || tag=latest
docker build -t $repo:$tag .
if [ "$?" -ne 0 ]; then echo "docker build failed, please tell to sqeven"; exit 1; fi
docker push $repo:$tag
if [ "$?" -ne 0 ]; then echo "docker push failed, please tell to sqeven"; exit 1; fi
docker rmi $repo:$tag
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)