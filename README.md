# zfs-homeserver
A full server for your home using ZFS, Docker &amp; Ansible for setup.
This is supposed to be a very simple way for everyone to set up their own server at home.

## Overview
![homeserver](https://user-images.githubusercontent.com/9283757/133320832-d0ce6ca8-cc90-4f17-bb84-29a857386483.jpg)

## Features
This setup will
- automatically install itself via Ansible with minimal setup needed (details in the [Ansible post here](https://thesmarthomejourney.com/2021/09/06/home-server-basics-ansible/))
- pool a set of drives with ZFS providing a secure storage with buildin versioning
  - uses RAID Z (similar to RAID 5) by default but you can change it to your liking  
  - includes a backup solution vis ZFS snapshots
  - more details in my blog [post on ZFS backups](https://thesmarthomejourney.com/2021/09/12/home-server-zfs-backup/)
- make the storage available for the local network via samba shares 
  - including support for Windows "shadow copies" via the snapshots
  - including different users with private personal folders & shared folders
- run any software you want in a Docker container via docker-compose to make it available in the local network
  - including [Heimdall](https://heimdall.site/) as a start page
  - including [automatic updates via Watchtower](https://thesmarthomejourney.com/2021/03/01/watchtower-docker-auto-updates/) (if you want it)
- uses the Traefik reverse proxy to make select services available outside of your network, e.g. via example.com/yourservice (you need your own domain for that)
  - with automatically generated valid SSL certificates
  - simple to configure [(detailed guide here)](https://thesmarthomejourney.com/2021/11/08/traefik-1-reverse-proxy-setup/)

## Prerequisites
You need some hardware to run this on. I provide some more details [in my blog post here](https://thesmarthomejourney.com/2021/09/06/home-server-basics-ansible/) but I recommend some mid class PC hardware optimized for low energy usage and long runtimes. A Raspberry Pi might work but it a bit underpowered and makes it complicated to connect multiple drives. 

You will also need a set of drives big enough for your storage needs (times x if you want to use a RAID setup) and some additional storage for the system itself. Again more details on this in the blog post. As the operating system I recommend a free version of Linux (I used Ubuntu server).

Finally you need a Internet connection for the installation and your own domain if you want to make services available from the outside.

You DO NOT need super advanced IT knowlege, just some will to learn. I tried to automate the installation as much as possible and explain all the concepts in more detail in the series of blog posts.

## Installation
Installation is supposed to be quick and easy if you are looking for a similar setup.

First install your favorite Linux and connect the drives. During installation you can enable SSH and do the rest of the setup remotely.
```
sudo apt install git ansible
git clone https://github.com/OliverHi/zfs-homeserver.git
cd zfs-homeserver/ansible
// udpate the variables in the ./vars/main_vars.yml file to your liking 
ansible-playbook setup_playbook.yml -K
```
Now update the .env to your liking and start your services.

## Running services
The server is set up to run services as containers via Docker and docker-compose. Simply add docker-compose yaml files to your setup and run them via `docker-compose -f /path/to/yaml/file up -d`. Run this from the main directory of this repository to make use of the .env file that provides some common variables I use in my yaml files. I have added two example setups, [core](https://github.com/OliverHi/zfs-homeserver/tree/main/core) for some services needed to run the server, and [OpenHab](https://github.com/OliverHi/zfs-homeserver/tree/main/openhab) for a smart home controller called OpenHab, so that you can have a look at them.
You can find a detailed description how to set up these services [in my blog](https://thesmarthomejourney.com/2021/10/25/home-server-docker-compose/) but the most important part is to keep the data in the `${DATADIR}` directory so that it is part of the automatic backups.

## Something is missing or not working right
Please let me know! Create an issue here on GitHub (or better yet a Pull Request with the fix) or contact me via email.
