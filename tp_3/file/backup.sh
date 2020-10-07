#!/bin/bash
# benji
# 07/10/2020
# Script de backup de thomas target_dir="${1}"

target_path="$(echo "${target_dir%/}" | awk -F "/" 'NF>1{print $NF}')"

date="$(date +%Y%m%d_%H%M%S)"
backup_name="${target_path}_${date}"
backup_dir="/opt/backup"
backup_path="${backup_dir}/${target_path}/${backup_name}.tar.gz"

backup_useruid="1001"
max_backup_number=7

backup_folder ()
{
    if [[ ! -d "${backup_dir}/${target_path}" ]]
    then
        mkdir "${backup_dir}/${target_path}"
    fi

    tar -czvf \
        ${backup_path} \
        ${target_dir} \
        1> /dev/null \
        2> /dev/null

    if [[ $(echo $?) -ne 0 ]]
    then
        echo "Une erreur est survenue lors de la compréssion" >&2
        exit 1
    else
        echo "La compréssion à réussi dans ${backup_dir}/${target_path}" >&1
    fi
}