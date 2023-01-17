#!/bin/bash
set -e

echo "Restoring Valheim world data"

if [ -f "/home/${username}/.config/unity3d/IronGate/Valheim/worlds_local/${world_name}.fwl" ]; then
    echo "Removing the existing world"
    BACKUPS=$(aws s3api head-object --bucket ${bucket} --key "${world_name}.fwl" || true > /dev/null 2>&1)
    if [ -z "$${BACKUPS}" ]; then 
        echo "No backups found using world name \"${world_name}\". A new world will be created."
    else 
        echo "Backups found, restoring..."
        aws s3 cp "s3://${bucket}/${world_name}.fwl" "/home/${username}/.config/unity3d/IronGate/Valheim/worlds_local/${world_name}.fwl"
        aws s3 cp "s3://${bucket}/${world_name}.db" "/home/${username}/.config/unity3d/IronGate/Valheim/worlds_local/${world_name}.db"
    fi
fi

aws s3 cp "/home/${username}/.config/unity3d/IronGate/Valheim/worlds_local/${world_name}.fwl" s3://${bucket}/
aws s3 cp "/home/${username}/.config/unity3d/IronGate/Valheim/worlds_local/${world_name}.db" s3://${bucket}/
