#!/bin/bash
##
## Auth: Michael.McDonald@FSU.edu
## Date: 2024-11-24
## Desc: for each NFS SR UUID... do the following
##

# +------------+--------------+--------------------+----------+
# | NFS Outage |     Time     |       timeo=       | retrans= |
# | (minutes)  | (in Seconds) | (1/10 of a second) |          |
# +------------+--------------+--------------------+----------+
# | 1          | 60           | 200                | 1        |
# | 2          | 120          | 200                | 1        |
# | 3          | 180          | 200                | 2        |
# | 4          | 240          | 200                | 2        |
# | 5          | 300          | 200                | 6        |
# | 6          | 360          | 200                | 6        |
# | 7          | 420          | 200                | 24       |
# | 8          | 480          | 200                | 24       |
# | 9          | 540          | 200                | 120      |
# | 10         | 600          | 200                | 120      |
# +------------+--------------+--------------------+----------+

TIMEO=200
## nfs config option "timeo" corresponds to the "nfs-timeout" value 

RETRANS=120 
## nfs config option "retrans" corresponds to the "nfs-retrans" value 

NFS_SR_UUIDS=( $( xe sr-list type=nfs | grep ^uuid | awk '{print $5}' ) )

## for each SR uuid do the following
for uuid in ${NFS_SR_UUIDS[@]}; do
  ## get/print the name-label of the SR uuid
  echo "`xe sr-list params=name-label  uuid=$uuid | grep ^name-label`"
  
  ## get the params
  NFS_PARAMS=( "nfs-timeout" "nfs-retrans" )
  for this_param in ${NFS_PARAMS[@]}; do
    PARAM_GET=$( xe sr-param-get param-name=other-config param-key=${this_param} uuid=$uuid )
    if [ $? -eq 0 ]; then
      echo "other-config:${this_param}=${PARAM_GET}"
    fi
  done
  
## set the params
  PARAM_SET=$( xe sr-param-set other-config:nfs-timeout=$TIMEO uuid=$uuid )
  if [ $? -eq 0 ]; then
    echo "[OK] setting nfs-timeout=$TIMEO"
  else
    echo "[ERROR] setting nfs-retrans=$RETRANS"
  fi
  PARAM_SET=$( xe sr-param-set other-config:nfs-retrans=$RETRANS uuid=$uuid )
  if [ $? -eq 0 ]; then
    echo "[OK] setting nfs-retrans=$RETRANS"
  else
    echo "[ERROR] setting nfs-retrans=$RETRANS"
  fi

  ## echo out a newline for formatting. 
  echo
done
