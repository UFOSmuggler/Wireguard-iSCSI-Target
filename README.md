# Wireguard-iSCSI-Target
Expose an iSCSI target via Wireguard from docker

## Go [here](https://github.com/linuxserver/docker-wireguard) for Wireguard questions
This Dockerfile is built on top of https://github.com/linuxserver/docker-wireguard and mostly only adds iSCSI stuff.
The only Wireguard stuff this repo is responsible for is the server template and scripts found in the root/default dir.

## Use case
This creates a Docker image/container that creates a Wireguard network with a single peer (called initiator), and exposes iSCSI target portals via wireguard.  This network only allows 3260/TCP traffic in.  Environment variables provide a default configuration for an iSCSI target, and a [targetcli](https://github.com/open-iscsi/targetcli-fb) config will be created should there not be one already.

Once the container is running, you can define a bunch of extra iSCSI stuff should you want, and it should also become available over wireguard.

Your iSCSI initiator will need to be able to talk to that Wireguard network somehow, perhaps it terminates directly on the machine or you're forwarding 3260/TCP to/from it somehow.  It will need to use the specified usernames/passwords and initiator name to access the target.

## Usage

### Docker compose:

```yaml
---
version: 3

services:
  iscsi-target:
    build:
      context: ./Wireguard-iSCSI-Target/ #Point this to the github repo to build
    hostname: iscsi-target
    container_name: iscsi-target
    restart: always
    cap_add:
      - NET_ADMIN
#      - SYS_MODULE #Uncomment if necessary
    devices:
      - /dev/mapper/my-lv:/dev/iscsi-target #Lefthandside is local block device to be shared
    group_add:
      - "6" #Group with access to block devices, not needed as we're privileged, but one day we will restrict further if possible
    privileged: true #Hoping to remove this with further work
    volumes:
      - /path/to/targetcli/config/:/etc/target/
      - /path/to/wireguard/config/:/config/
      - /lib/modules/:/lib/modules/
      - /sys/kernel/config/:/sys/kernel/config/
      - /var/run/dbus:/var/run/dbus
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Melbourne
      # WG config - see https://github.com/linuxserver/docker-wireguard
      - LOG_CONFS=true
      - PEERS=initiator
      - USE_COREDNS=true
      - PERSISTENTKEEPALIVE_PEERS=initiator
      - SERVERURL=iscsi.example.com #Wireguard server DNS name or IP for initiator to use
      - SERVERPORT=51820
      - INTERNAL_SUBNET=172.16.222.0
      - ALLOWEDIPS=172.16.222.1/32
      # ISCSI target config - for WWNs, I suggest an IQN - https://en.wikipedia.org/wiki/ISCSI#Addressing
      # Also see targetcli documentation - https://github.com/open-iscsi/targetcli-fb
      # If there is no existing config in /etc/target/ these are not optional
      - TCLI_USER=my-username #Initiator username
      - TCLI_PASS=my-password #Initiator password
      - TCLI_TARGET_WWN=2023-12.com.example:storage:my-lv #Target's WWN
      - TCLI_INITIATOR_WWN=2023-12.com.example:initiator1 #Initiator's WWN
    ports:
      - 51820:51820/udp

