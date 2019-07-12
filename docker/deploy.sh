#!/bin/bash
[ -z "$set_e" ] && set -e

[ -z "$1" ] && { echo '$1 is not set';exit 2; }

which docker &> /dev/null || { echo 'search needs docker, please install the docker';exit 2; }

img=$1
repo=${img%:*}
[[ $img == *:* ]] && tag=${img##*:} || tag=latest

if [[ "$repo" =~ ^icf ]];then
    if [[ "$img" == *icf/dc* ]];then
        case $tag in
		    latest)docker pull hub.icarephone.com/icarephone/dc && port=18001;;
		    dev)docker pull registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag && port=18002;;
		    test)docker pull registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag && port=18007;;
		    seven)docker pull registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag && port=18003;;
		    limj)docker pull registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag && port=18005;;
		    zhy)docker pull registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag && port=18004;;
		    icarebug)docker pull registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag && port=18006;;
		    *)echo 'not in branch to dc!';exit 0;;
		esac
    else
        echo 'only deploy to icf/dc now!';exit 0;
    fi
else 
    echo 'repository not in icf!';exit 0;
fi
docker rm -f icfdc-$tag || true
docker run -d -p $port:8002 --name icfdc-$tag registry.cn-shenzhen.aliyuncs.com/icarephone/dc:$tag
if [ "$?" -ne 0 ]; then echo "docker deploy failed, please tell to sqeven"; exit 1; fi
echo "icfdc-$tag deploy success ^_^"
docker rmi $(docker images --filter "dangling=true" -q --no-trunc) || true