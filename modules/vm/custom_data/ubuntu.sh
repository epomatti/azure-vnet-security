#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# Update
apt update
apt upgrade -y

apt install nginx -y
