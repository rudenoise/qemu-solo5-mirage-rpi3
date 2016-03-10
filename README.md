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
sudo apt-get -y install qemu-kvm qemu-system qemu-utils qemu-block-extra qemu-user git vim bridge-utils uml-utilities
mkdir code
cd code
git checkout https://github.com/rudenoise/qemu-solo5-mirage-rpi3.git
cd qemu-solo5-mirage-rpi3
```

Edit network interfaces and add a bridge interface:
```
auto br0
iface br0 inet dhcp
    bridge_ports enxb827eb7cbbb0
        bridge_fd 9
    bridge_hello 2
    bridge_maxage 12
    bridge_stp off
```

```sh
sudo /etc/init.d/networking restart
```

Outside the Pi, copy the built _iso_ and _img_ from the container:
```sh
docker cp solo5-mirage:/home/solo5/solo5/kernel.iso ./
docker cp solo5-mirage:/home/solo5/solo5/disk.img ./
```

Copy the _iso_ and _img_ to the RPi.
```sh
scp ./disk.img {{user}}@{{rPi ip address}}:~/code/qemu-solo5-mirage-rpi3
scp ./kernel.iso {{user}}@{{rPi ip address}}:~/code/qemu-solo5-mirage-rpi3
```

Inside the Pi, run the unikernel and disk in _qemu_
```sh
cd code/qemu-solo5-mirage-rpi3
sudo qemu-system-x86_64 \
    -s -nographic \
    -name mirage \
    -m 256 \
    -cdrom kernel.iso /
    -net nic,model=virtio \
    -net tap,ifname=tap0,script=./tap-up.sh,downscript=tap-down.sh \
    -drive file=disk.img,format=raw,if=virtio \
    -boot d
```

## Results

The unikernel is running but haven't configured network, yet.
```sh
            |      ___|
  __|  _ \  |  _ \ __ \
\__ \ (   | | (   |  ) |
____/\___/ _|\___/____/
Found virtio network device with MAC: 52 54 00 12 34 56
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
Listening on http://localhost/
```

```
# arp
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.1.1              ether   48:ee:0c:6c:f8:34   C                     br0
10.0.0.2                 ether   52:54:00:12:34:56   CM                    tap0
192.168.1.7              ether   a0:99:9b:02:ea:d5   C                     br0
```

```
# ifconfig br0
br0       Link encap:Ethernet  HWaddr 16:69:d8:29:01:d5
          inet addr:192.168.1.10  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::ba27:ebff:fe7c:bbb0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7905 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3510 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1117097 (1.1 MB)  TX bytes:440074 (440.0 KB)
```

```
# ifconfig tap0
tap0      Link encap:Ethernet  HWaddr 16:69:d8:29:01:d5
          inet addr:10.0.0.1  Bcast:10.255.255.255  Mask:255.0.0.0
          inet6 addr: fe80::1469:d8ff:fe29:1d5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1 errors:0 dropped:0 overruns:0 frame:0
          TX packets:179 errors:0 dropped:1961 overruns:0 carrier:0
          collisions:0 txqueuelen:500
          RX bytes:42 (42.0 B)  TX bytes:36537 (36.5 KB)
```

Can't ping 10.0.0.2
