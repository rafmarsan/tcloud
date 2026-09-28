#! /usr/bin/env bash

set -euo pipefail

set_name() {
  name=$(echo $1 | awk '{print tolower($0)}' | awk '{print $1}')
  surname=$(echo $1 | awk '{print tolower($0)}' | awk '{print $2}')
  echo "${name:0:1}$surname"
}

clean_text() {
  sed 's/[Áá]/a/g' | sed 's/[Éé]/e/g' | sed 's/[Íí]/i/g' | sed 's/[Óó]/o/g' | sed 's/[Úú]/u/g' | sed 's/[ñÑ]/n/g'
}

cat ./userlist.txt | clean_text | sort -f | while read LINE; do
  _USER=$(echo $LINE | cut -d',' -f1)
  #_USER=$(echo $LINE | cut -d',' -f1 | clean_text)
  #_USER=$(echo $LINE | cut -d',' -f1 | iconv -f UTF-8 -t ASCII//TRANSLIT)
  _PASS=$(echo $LINE | cut -d',' -f2)
  _SHELL=$(echo $LINE | cut -d',' -f3)

  i=1
  _USERNAME=$(set_name "${_USER}")

  if id "${_USERNAME}$i" &> /dev/null;then
    ((i++))
  fi
  
  sudo useradd -s ${_SHELL} -c "$_USER" -m ${_USERNAME}$i
  echo "${_USERNAME}$i:${_PASS}" | sudo chpasswd
  if [[ "$_SHELL" == *"fish"* ]];then
    sudo usermod -aG sudo ${_USERNAME}$i
    echo "[$(date)] ${_USERNAME}$i [$_USER] creado con SUDO" | tee -a creation.log
  else
    echo "[$(date)] ${_USERNAME}$i [$_USER] creado" | tee -a creation.log
  fi
  echo "PASS: ${_PASS}"
done
#done < ./userlist.txt

