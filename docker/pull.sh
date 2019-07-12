#!/bin/bash
[ -z "$set_e" ] && set -e

[ -z "$1" ] && { echo '$1 is not set';exit 2; }

if [ "$1" == search ];then
    shift
    which jq &> /dev/null || { echo 'search needs jq, please install the jq';exit 2; }
    img=${1%/}
    [[ $img == *:* ]] && img_name=${img/://} || img_name=$img
    if [[ "$img" =~ ^gcr.io|^k8s.gcr.io ]];then
        if [[ "$img" =~ ^k8s.gcr.io ]];then
            img_name=${img_name/k8s.gcr.io\//gcr.io/google_containers/}
        elif [[ "$img" == *google-containers* ]]; then
            img_name=${img_name/google-containers/google_containers}
        fi
        repository=gcr.io
    elif [[ "$img" =~ ^quay.io ]];then
            repository=quay.io 
    else 
        echo 'not sync the namespaces!';exit 0;
    fi
    curl -sX GET https://api.github.com/repos/sqeven/${repository}/contents/$img_name?ref=develop |
        jq -r 'length as $len | if $len ==2 then .message elif $len ==12 then .name else .[].name  end'
else
    img=$1
    name=${img%:*}
    [[ $img == *:* ]] && tag=${img##*:} || tag=latest

    if [[ "$img" =~ ^gcr.io|^quay.io ]];then
        repo=sqeven/${name//\//.}
        [[ "$img" == *google-containers* ]] && repo=${repo/google-containers/google_containers}
        docker pull $repo:$tag
        docker tag $repo:$tag $img
        docker rmi $repo:$tag

    elif [[ "$img" =~ ^k8s.gcr.io ]];then
        repo=sqeven/${name/k8s.gcr.io\//gcr.io.google_containers.}
        docker pull $repo:$tag
        docker tag $repo:$tag $img
        docker rmi $repo:$tag
    else
        echo 'not sync the namespaces!';exit 0;
    fi
fi
