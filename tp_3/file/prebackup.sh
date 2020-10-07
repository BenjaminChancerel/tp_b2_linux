#!/bin/bash
# Benjam
# 07/10/2020
# script backup de léo

## VARIABLES

# Colors :D
declare -r NC="\e[0m"
declare -r B="\e[1m"
declare -r RED="\e[31m"
declare -r GRE="\e[32m"

# Target directory : the one we want to backup
declare -r target_path="${1}"
declare -r target_dirname=$(awk -F'/' '{ print $NF }' <<< "${target_path%/}")

# Craft the backup full path and name
declare -r backup_destination_dir="/opt/backup/"
declare -r backup_date="$(date +%y%m%d_%H%M%S)"
declare -r backup_filename="${target_dirname}_${backup_date}.tar.gz"
declare -r backup_destination_path="${backup_destination_dir}/${backup_filename}"

# Informations about the User that must run this script
declare -r backup_user_name="backup"
declare -ri backup_user_uid=1001
declare -ri backup_user_umask=077

# The quantity of backup to keep for each directory
declare -i backups_quantity=7
declare -ri backups_quantity=$((backups_quantity+1))

## PREFLIGHT CHECKS

# Force a specific user to run te script
if [[ ${EUID} -ne ${backup_user_uid} ]]; then
  log "ERROR" "This script must be run as \"${backup_user_name}\" user, which UID is ${backup_user_uid}. Exiting."
  exit 1
fi

# Check that the target dir actually exists and is readable
if [[ ! -d "${target_path}" ]]; then
  log "ERROR" "The target path ${target_path} does not exist. Exiting."
  exit 1
fi
if [[ ! -r "${target_path}" ]]; then
  log "ERROR" "The target path ${target_path} is not readable. Exiting."
  exit 1
fi

# Check that the destination dir actually exists ans is writable
if [[ ! -d "${backup_destination_dir}" ]]; then
  log "ERROR" "The destination dir ${backup_destination_dir} does not exist. Exiting."
  exit 1
fi
if [[ ! -w "${backup_destination_dir}" ]]; then
  log "ERROR" "The destination dir ${backup_destination_dir} is not writable. Exiting."
  exit 1
fi
