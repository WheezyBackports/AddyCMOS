Welcome to AddyCMOS (Addy CPU Mining Oriented System)!

Below is an index for the various sections in this README.
If you're using Vim/Vi/less then all you have to do to skip to different sections is the following :

shift + : 
Type ?GETSTARTED

Each section has a string like GETSTARTED to skip to the desired section. 
This just makes navigation a little easier and faster, but you don't have to do this.


Index :
  Getting Started : ?GETSTARTED
  Connect to Wifi : ?CONNECTWIFI
  Scripts and File Locations : ?SFLOCATIONS
  Configure Your Own Image : ?CONFIGYOURIMG


Getting Started | GETSTARTED

To get started using AddyCMOS you'll first have to download the image and write it to a USB/SD/HDD/SSD drive.
AddyCMOS is however primarily configured for USB/SD , but you can use an HDD/SSD if you choose to.

Once you download the image make sure you have Etcher installed for writing the image.
Make sure to write the image to your drive of choice using etcher and you'll be set to go and boot the image!

If you're on Linux Etcher is not required, but it is user friendly. The alternative is to use the "dd" command.
Make sure to replace "/dev/sdX" with the drive you want to use. If you're not sure what the name of the drive is try lsblk. 
(If you use an SD card it should look something like /dev/mmcblk0)

sudo dd if=addycmos-alpha-v.10.img of=/dev/sdX

Once you have the image written to the drive you may now boot the drive.
When the drive boots it'll start OpenRC init and when everything else gets done loading AddyCMOS will begin resizing it's own root partition.
Once the root partition is done resizing itself you will be able to log in. 
The default users and passwords are :

root : cmosminer9k
addycmos : cmosminer9k

The root user is for when you need root priviledges for any changes you need to make to the system itself.
The addycmos user is for running the setup-miner.sh script in the home directory and for SSH access.

When you log in if your machine is already plugged into ethernet don't worry about network setup as ethernet is automatically taken care of on boot.
If you need to connect to wifi go to the "Connect to Wifi" section.

If you would like to see your local IP for ssh access then do : 

ip addr show

Once you have done all of the above you may run the miner-setup.sh script.

sh miner-setup.sh WALLETADDR=yourwallet WORKERNAME=yourworkername

The miner-setup script will automatically setup everything for you including an init script to start xmrig-mo on boot. By default the pool gulf.moneroocean.stream:10128 is used.
If for any reason you need more options or want to remove the dev fee for AddyCMOS please see the "Scripts and File Locations" section.

Once you have run the miner-setup.sh script you can just let the system run or you can change the root and addycmos password using the "passwd" command. 
(Changing the default passwords is recommended. To change the root password you'll have to log into root using "su" if you're logged in as "addycmos")
 

Connect to Wifi | CONNECTWIFI

To connect to wifi it is recommended to use the default alpine "setup-interfaces" script.
To use the script as addycmos do :

doas setup-interfaces

The setup-interfaces script will interactively take you through setting up your wifi interface. This script can also be used for other interfaces too.


Scripts and File Locations | SFLOCATIONS

README
Location : /home/addycmos/README

miner-setup.sh
Location : /home/addycmos/miner-setup.sh
miner-setup.sh Options :
The options for the miner-setup.sh scripts are as follows.

WALLETADDR= 
	Specify wallet address for miner-setup.sh to use.

WORKERNAME=
	Specify the worker name to be used.

POOLADDR=
	Specify the pool to be used. (Default is gulf.moneroocean.stream:10128)

NOFEE=y
	If you choose to you can remove the AddyCMOS 0.1% dev fee using this option.
	If you would like to support the project please keep the dev fee on. it would be much appreciated. :)

LOG=y
	If you want to enable logging use this option. Logs are stored in /srv/xmrig-mo/log.txt

 
XMRig & XMRig Config
XMRig Location : /srv/xmrig-mo/xmrig
XMRig Config Location : /srv/xmrig-mo/conf.d

xmrigboot Init Script
Location : /etc/init.d/xmrigboot 

resizeroot Scripts
Init Location : /etc/init.d/resizeroot
Script Location : /sbin/resizeroot

doas.conf
Location : /etc/doas.conf

motd
Location : /etc/motd

Configure Your Own Image | CONFIGYOURIMG

For advanced users who would like to modify the image or use the same config on multiple machines by just writing the same image you can follow these steps.
(It is recommended that you use Linux to do this as the guide has been written for Linux users.)

To setup your own image you are going to need to do a few things.
You're going to need to make sure you have the AddyCMOS image and the "losetup" command.
Most distributions come with "losetup" , so it is unlikely that you will need to install it.

First you will need to setup a "loopback device" by doing :

sudo losetup -fP addycmos-alpha-v1.0.img

Once the loopback device is created you can use "lsblk" to list all the block devices on your system.
The loopback device should show up like this : 

NAME      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0       7:0    0   1.2G  0 loop
├─loop0p1 259:3    0   100M  0 part
├─loop0p2 259:4    0   100M  0 part
└─loop0p3 259:5    0   999M  0 part

"loop0p3" is the AddyCMOS root partition. You will need to keep this in mind for the next step.

Next you are going to want to mount "/dev/loop0p3" to /mnt. This will allow you to modify the root filesystem and later on use "chroot".

Once you have mounted the root filesystem you can refer to the "Scripts and File Locations" section for any configuration files, scipts, and etc that you would want to modify.

If you want to put your wallet address and workername into the XMRig config file make sure to do this :
(You shouldn't need sudo for this step as your user should be able to modify files in /srv/xmrig-mo without root priviledges.)

cd /mnt/srv/xmrig-mo/conf.d
cp template-config.json config.json

Once you have copied the template configuration you can start editing the config.json to include your wallet address and worker name.
(If you wanted to you could also change other settings in here too.)

After you have setup your config.json you can have the xmrigboot init script configured by doing this :

First you are going to chroot into the root filesystem on /mnt.

sudo chroot /mnt /bin/ash

If you are not on Alpine you will have to specify command locations manually such as "/bin/ls"

Once you are chrooted you will want to run the command to enable xmrigboot on boot.

/sbin/rc-update add xmrigboot default

After you have done that you can exit the chroot and remove the loopback device.

sudo losetup -d /dev/loop0

Once you have removed the loopback device your image is ready to go!




