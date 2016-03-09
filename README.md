# qemu-solo5-mirage-rpi3

An attempt to run a MirageOS unikernel, built with Solo5, running in Qemu, on a Raspberry Pi 3

## Setup and tools

* A Docker environment and Solo5 Docker Image.
* A Mirage unikernel _iso_ and _img_ built with Solo5.
* A Raspberry Pi 3.
* RPi 3 Ubuntu Mate on microSD card.

## Set up:

Insert the Pi's SD card, attach screen and keyboard. Then follow
setup procedure.

Once you have completed setup and have a user account, connect the
Pi to your network and the rest can be done over ssh.

Inside the Pi, get up-to-date and install _qemu_ tools.
```sh
sudo apt-get update
sudo apt-get upgrade
# install tools
sudo apt-get -y install qemu-kvm qemu-system qemu-utils qemu-block-extra qemu-user git vim bridge-utils
```

Outside the Pi, copy the built _iso_ and _img_ from the container:
```sh
docker cp solo5-mirage:/home/solo5/solo5/kernel.iso ./
docker cp solo5-mirage:/home/solo5/solo5/disk.img ./
```

Copy the _iso_ and _img_ to the RPi.
```sh
scp ./disk.img {{user}}@{{rPi ip address}}:~/
scp ./kernel.iso {{user}}@{{rPi ip address}}:~/
```

Inside the Pi, run the unikernel and disk in _qemu_
```sh
sudo qemu-system-x86_64 /
    -s -nographic /
    -name mirage /
    -m 256 /
    -cdrom kernel.iso /
    -net nic,model=virtio /
    -drive file=disk.img,format=raw,if=virtio -boot d
```

## Results

The unikernel is running but haven't configured network, yet.
```sh
Warning: vlan 0 is not connected to host network
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Found virtio network device with MAC: 54 54 00 55 55 55
host features: 71000ed4: 2 4 6 7 9 10 11 24 28 29 30
Found virtio block device with capacity: 2048 * 512 = 1048576
queue size is 128
DJW: new bindings
getenv(OCAMLRUNPARAM) -> null
getenv(CAMLRUNPARAM) -> null
getenv(PATH) -> null
Unsupported function lseek called in Mini-OS kernel
Unsupported function lseek called in Mini-OS kernel
Unsupported function lseek called in Mini-OS kernel
getenv(OCAMLRUNPARAM) -> null
getenv(CAMLRUNPARAM) -> null
getenv(TMPDIR) -> null
getenv(TEMP) -> null
getenv(DEBUG) -> null
getenv(OMD_DEBUG) -> null
getenv(OMD_FIX) -> null
lib/solo5_stubs.c: connect!!

lib/solo5_stubs.c: WARNING: returning hardcoded MAC
Netif: plugging into tap0 with mac 52:54:00:12:34:56
Netif: connect tap0
tap0 with mac 52:54:00:12:34:56
Attempt to open(/dev/urandom)!
Unsupported function getpid called in Mini-OS kernel
Unsupported function getppid called in Mini-OS kernel
Manager: connect
Manager: configuring
Manager: Interface to 10.0.0.2 nm 255.255.255.0 gw [10.0.0.1]

Manager: connect
Manager: configuring
Manager: Interface to 10.0.0.2 nm 255.255.255.0 gw [10.0.0.1]

ARP: sending gratuitous from 10.0.0.2
Manager: configuration done
```
