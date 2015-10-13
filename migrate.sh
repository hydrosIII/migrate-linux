#!/bin/bash
#
#
#  DMDc-installer is an alternative installer for remastered livecd/dvd's
#  Based remastersys-installet to Tony "Fragadelic" Brijeski
#  DMDc-installer created by "Frannoe" frannoe@gmail.com <http://frannoe.blogspot.com.es/> 2014/Mar/26
#  Copyright 2008-2014 Under the GNU GPL2 License


## nuevoos sistemas de archvis Nilfs y Btrfs , falta probar

## requires yad. 
 
DIALOGMENU="`which yad` --window-icon=/usr/share/pixmaps/dmdc-installe.png "
DIALOG="`which yad` --window-icon=/usr/share/pixmaps/dmdc-installer.png"
TITLE="--always-print-result --dialog-sep --image=/usr/share/pixmaps/dmdc-installe.png --image-on-top --title="
TEXT="--text="
ENTRY="--entry "
ENTRYTEXT="--entry-text "
MENU="--list --column=Pick --column=Info --column="""
YESNO=" --button=yes:0 --button=No:1 "
MSGBOX=" --button=Ok:0 "
PASSWORD="--entry --hide-text "
TITLETEXT="DMDc Installer"
#########LIVE_USERNAME##########0
. /etc/live/config.conf
#########LIVE_USERNAME##########1
 
# checking to make sure script is running with root privileges
###################0
testroot="`whoami`"
testmode=`grep "1000" /etc/passwd | grep -v "Live"`
if [ "$testroot" != "root" ]; then
$DIALOG $TITLE"$TITLETEXT" --button=Exit $TEXT"The installer must be run as root"
exit 1
fi
 
if [ "$testmode" != "" ]; then
$DIALOG $TITLE"$TITLETEXT" --button=Exit $TEXT"This installer must be run in a Live session"
exit 1
fi
###################1
progressbar () {
tail -f /opt/dmdc-locales/es_ES/dmdc-installer | $DIALOG $TITLE"$TITLETEXT" $TEXT"$@" --no-buttons --progress 
--pulsate --auto-close
}
 
###################0
GPARTEDISK ()  {
$DIALOG $TITLE"$TITLETEXT" --button=Exit:2 --button=Continue:1 --button="Create Partition":0 $TEXT"<b>gparted</b> 
also allow you to create new partitions if necessary to install the system. \nIf you already have partitions to 
install the system, press <b>Continue</b>.  "
QUES=$?
if [ $QUES = 2 ]; then
exit 0
fi
 
if [ $QUES = 0 ]; then
 
lsblk -l -o NAME,TYPE,SIZE,FSTYPE,GROUP | grep -e disk -e floppy | grep -v loop | grep -v cdrom | grep -v $LIVECD 
| grep -v part | grep -v swap | sed "s/        \+/ '-----' /g" | awk '{print $1, $3, $2, $5, $4}' >> /tmp/disks
sed -i 's/floppy/Externo/g' /tmp/disks
while read disks; do
diskmenu="$diskmenu $disks"
done < /tmp/disks
rm /tmp/disks
 
PARTDRIVE=""
QUES=""
until [[ "$PARTDRIVE" !=  "" ||  "$QUES" =  "1" ]]
do
PARTDRIVE=`$DIALOGMENU --height=250 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0 --list --column=Disk 
--column="Size(GB)" --column=Tipe --column="Location"  --column=Infom --no-click $TEXT"Please select a drive on 
which to create new partitions <b>Gparted</b>." $diskmenu`
QUES="$?"
done
if [ $QUES != 0 ]; then
exit 0
fi
 
PARTDRIVE=`echo $PARTDRIVE | cut -d "|" -f 1`
gparted /dev/$PARTDRIVE
diskmenu=""
fi
}
###################1
 
 
 
###################0
 
 
LIVECD=`lsblk -l -o NAME,MOUNTPOINT | grep live | grep -v loop | awk '{print $1}' | cut -c 1-3`
 
$DIALOG $TITLE"$TITLETEXT" $YESNO $TEXT"This is the installer of DMDc. Do you want to continue? "
 
if [ $? != 0 ]; then
exit 0
fi
 
$DIALOG $TITLE"$TITLETEXT" --button="Exit":2 --button="No":1  --button="yes":0 $TEXT"The installer will use the 
locale, the language and keyboard layout by default. \nDid you install or remove other keyboard options and 
location?. "
QUES=$?
if [ $QUES = 0 ]; then
dpkg-reconfigure -f gnome locales
dpkg-reconfigure -f gnome console-data
#dpkg-reconfigure -f gnome console-setup
dpkg-reconfigure -f gnome keyboard-configuration
else
if [ $QUES = 2 ]; then
exit 1
fi
fi
QUES=""
###################1
 
killall -KILL udisks-daemon
 
###################0
QUES=""
$DIALOG $TITLE"$TITLETEXT" --button="Exit":3 --button="Use SWAP existing":2 --button="Not used SWAP":1 
--button="Create SWAP":0 $TEXT"If your computer is low on RAM (less than 2GB) is convenient and appropriate to use 
a swap partition. \nIf you do not have it you can create one by pressing the appropriate button. \nWhat would you 
like to do?. "
 
QUES="$?"
if [ $QUES = 3 ]; then
exit 0
fi
 
if [[ $QUES = 0 || $QUES = 2 ]]; then
 
YESNOSWAP="yes"
 
 
if [ $QUES = 0 ]; then
 
lsblk -l -o NAME,TYPE,SIZE,FSTYPE,GROUP | grep -e disk -e floppy | grep -v loop | grep -v cdrom | grep -v $LIVECD 
| grep -v part | grep -v swap | sed "s/        \+/ '-----' /g" | awk '{print $1, $3, $2, $5}' >> /tmp/disks
 
sed -i 's/floppy/Externo/g' /tmp/disks
 
while read disks; do
diskmenuswap="$diskmenuswap $disks"
done < /tmp/disks
rm /tmp/disks
 
QUES=""
until [[ "$PARTDRIVESWAP" !=  "" ||  "$QUES" =  "1" ]]
do
PARTDRIVESWAP=`$DIALOGMENU --height=250 $TITLE"$TITLETEXT"--button="Exit":1 --button="OK":0  --list --column=Disk 
--column="Size(GB)" --column=Tipe --column=Tipe --no-click $TEXT"Please select a unit \nwhich to create the 
partition <b>Swap</b>.  " $diskmenuswap`
QUES="$?"
done
 
 
if [ $QUES != 0 ]; then
exit 0
fi
 
PARTDRIVESWAP=`echo $PARTDRIVESWAP | cut -d "|" -f 1`
 
gparted /dev/$PARTDRIVESWAP
 
fi
 
###################1
 
 
###################0
lsblk -l -o NAME,SIZE,FSTYPE,GROUP | grep swap | awk '{print $1, $2, $3, $4}' >> /tmp/diskswap
sed -i 's/floppy/Externo/g' /tmp/diskswap
 
 
while read diskswap; do
diskswapmenu="$diskswapmenu $diskswap"
done < /tmp/diskswap
rm /tmp/diskswap
 
SWAP=""
QUES=""
until [[ "$SWAP" !=  "" ||  "$QUES" =  "1" ]]
do
SWAP=`$DIALOGMENU --height=250 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  --list --column=Part 
--column="Size(GB)" --column="Partition type" --column="Location"  --no-click $TEXT"Please select a swap partition 
to use.  " $diskswapmenu`
QUES="$?"
done
 
if [ $QUES != 0 ]; then
exit 0
fi
SWAP=`echo $SWAP | cut -d "|" -f 1`
 
GPARTEDISK
 
else
 
 
SWAP="no"
QUES=""
GPARTEDISK
 
fi
###################1
 
 
###################0
lsblk -l -o NAME,SIZE,TYPE,FSTYPE,GROUP | grep -e part -e floppy | grep -v loop | grep -v swap  | grep -v cdrom | 
grep -v $LIVECD | grep part | sed "s/        \+/ '-----' /g" | awk '{print $1, $2, $3, $4, $5}' >> /tmp/diskpart
 
sed -i 's/floppy/Externo/g' /tmp/diskpart
while read diskpart; do
diskpartmenu="$diskpartmenu $diskpart"
done < /tmp/diskpart
rm /tmp/diskpart
 
 
TARGETPART=""
QUES=""
until [[ "$TARGETPART" !=  "" ||  "$QUES" =  "1" ]]
do
TARGETPART=`$DIALOGMENU --height=350 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  --list --column=Part 
--column=Size --column=Tipe --column="FsTipe" --column="Location"  --no-click $TEXT"Please select a partition to 
install the system.  " $diskpartmenu`
QUES="$?"
done
 
if [ $QUES != 0 ]; then
exit 0
fi
TARGETPARTGB=`echo $TARGETPART | cut -d "|" -f 2`
TARGETPARTTP=`echo $TARGETPART | cut -d "|" -f 3`
TARGETPARTGP=`echo $TARGETPART | cut -d "|" -f 5`
TARGETPART=`echo $TARGETPART | cut -d "|" -f 1`
 
FSTYPES=""
QUES=""
until [[ "$FSTYPES" !=  "" ||  "$QUES" =  "1" ]]
do
FSTYPES=`$DIALOGMENU --height=200 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  --list --column=EXT 
--column="Format in..."  --no-click $TEXT"Please select the type of file system to use. " ext2 "Filesystem Ext2" 
ext3 "Filesystem Ext3" ext4 "Filesystem Ext4" btrfs " Filesystem btrfs (experimental)" nilfs " Filesystem nilfs 
(for realiability)"`
QUES="$?"
done
 
if [ $QUES != 0 ]; then
exit 0
fi
 
FSTYPES=`echo $FSTYPES | cut -d "|" -f 1`
###################1
 
###################0
 
lsblk -l -o NAME,SIZE,TYPE,FSTYPE,GROUP | grep -e part -e floppy | grep -v loop | grep -v swap  | grep -v cdrom | 
grep -v $TARGETPART | grep -v $LIVECD | grep part | sed "s/        \+/ '-----' /g" | awk '{print $1, $2, $3, $4, 
$5}' >> /tmp/diskparth
sed -i 's/floppy/Externo/g' /tmp/diskparth
while read diskparth; do
homepartmenu="$homepartmenu $diskparth"
done < /tmp/diskparth
rm /tmp/diskparth
 
 
HOMEPART=""
QUES=""
until [[ "$HOMEPART" !=  "" ||  "$QUES" =  "1" ]]
do
HOMEPART=`$DIALOGMENU --height=350 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  --list --column=Part 
--column=Size --column=Tipe --column="FsTipe" --column="Location" --no-click $TEXT"Please select a partition to 
install <b>/home</b>. \nIf you do not understand what you are doing, then install the HOME where the system is 
installed. \nYou selected to install the system on the partition <b>$TARGETPART</b> you can see labeled: <b>*</b>. 
" $TARGETPART "$TARGETPARTGB*" "$TARGETPARTTP*" "$FSTYPES*" "$TARGETPARTGP *" $homepartmenu`
QUES="$?"
done
 
if [ $QUES != 0 ]; then
exit 0
fi
 
HOMEPART=`echo $HOMEPART | cut -d "|" -f 1`
 
 
if [ "$HOMEPART" != "$TARGETPART" ]; then
 
HFSTYPE=""
QUES=""
until [[ "$HFSTYPE" !=  "" ||  "$QUES" =  "1" ]]
do
HFSTYPE=`$DIALOGMENU --height=250 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  --list --column=EXT 
--column="Format in..."  --no-click $TEXT"Please select the type of file system for the partition <b>home</b>. If 
there is another <b>home</b> and want to share, select no formatting. Otherwise select a format type. " ext2 
"Filesystem Ext2" ext3 "Filesystem Ext3" ext4 "Filesystem Ext4" Btrfs "Btrfs Filesystem" Nilfs "nilfs Filesystem 
(reliability)"  NoFormat "Do Not Format the home partition"`
QUES="$?"
done
fi
 
 
if [ $QUES != 0 ]; then
exit 0
fi
 
HFSTYPE=`echo $HFSTYPE | cut -d "|" -f 1`
 
###################1
 
 
###################0
 
while [ "$PASSOK" != "Yes" ]; do
 
CHOICES=`$DIALOGMENU --align=right $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  $TEXT"Please complete all 
the fields properly. \n\n<b>Very Important note: </b>Capital letters, spaces and special characters are not 
allowed in the user name, user real name or name computer, does not support special characters or spaces, but 
supports uppercase letters" --form \
--field=:LBL "" \
--field="Password for Root":H \
--field="Password for Root again":H \
--field=:LBL "" \
--field="New User Real Name" \
--field="New Username" \
--field="Password for new user":H \
--field="Password for new user again":H \
--field="Enable sudo:":CB "" "" "" "" "" "" "no"!"yes" \
--field="Automatic login:":CB "yes"!"no" \
--field="Animated boot (Splash):":CB "no"!"yes" \
--field=:LBL "" \
--field="Host Name for the computer"`
 
if [ "$?" = "0" ]; then
TARGETROOTPASS=`echo $CHOICES | cut -d "|" -f 2`
TARGETROOTPASS2=`echo $CHOICES | cut -d "|" -f 3`
TARGETUSERFULLNAME=`echo $CHOICES | cut -d "|" -f 5`
TARGETUSER=`echo $CHOICES | cut -d "|" -f 6`
TARGETPASS=`echo $CHOICES | cut -d "|" -f 7`
TARGETPASS2=`echo $CHOICES | cut -d "|" -f 8`
USERSUDO=`echo $CHOICES | cut -d "|" -f 9`
AUTOINI=`echo $CHOICES | cut -d "|" -f 10`
SPLASH=`echo $CHOICES | cut -d "|" -f 11`
TARGETHOSTNAME=`echo $CHOICES | cut -d "|" -f 13`
else
  exit 1
fi
 
[ "$TARGETROOTPASS" != "" ] && \
[ "$TARGETROOTPASS" = "$TARGETROOTPASS2" ] && \
[ "$TARGETUSERFULLNAME" != "" ] && \
[[ "$TARGETUSERFULLNAME" = "${TARGETUSERFULLNAME//[\' ]/}" ]] && \
[ "$TARGETUSER" != "" ] && \
[ "$TARGETUSER" != "$LIVE_USERNAME" ] && \
[[ "$TARGETUSER" = "${TARGETUSER//[\' ]/}" ]] && \
[ "$TARGETPASS" != "" ] && \
[ "$TARGETPASS" = "$TARGETPASS2" ] && \
[ "$TARGETROOTPASS" != "$TARGETPASS" ] && \
[ "$TARGETHOSTNAME" != "" ] && \
[[ "$TARGETHOSTNAME" = "${TARGETHOSTNAME//[\' ]/}" ]] && \
PASSOK="Yes"
 
[ "$TARGETROOTPASS" = "" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"Root password is blank. "
 
[ "$TARGETROOTPASS" != "$TARGETROOTPASS2" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"Root passwords do not 
match. "
 
[ "$TARGETUSERFULLNAME" = "" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"User Full Name is blank. "
 
[[ "$TARGETUSERFULLNAME" != "${TARGETUSERFULLNAME//[\' ]/}" ]] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"The 
real user name can not contain spaces or special characters. "
 
[ "$TARGETUSER" = "" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"Username is blank. "
 
[[ "$TARGETUSER" != "${TARGETUSER//[\' ]/}" ]] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"The username can not 
contain spaces or special characters. "
 
[ "$TARGETUSER" = "$LIVE_USERNAME" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"Username can't be the same as the 
live username. "
 
[ "$TARGETPASS" = "" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"User password is blank. "
 
[ "$TARGETPASS" != "$TARGETPASS2" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"User passwords do not match. "
 
[ "$TARGETROOTPASS" = "$TARGETPASS" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"Root and user passwords are the 
same.\n\nPlease use different password. "
 
[ "$TARGETHOSTNAME" = "" ] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"Host Name is blank. "
 
[[ "$TARGETHOSTNAME" != "${TARGETHOSTNAME//[\' ]/}" ]] && $DIALOG $TITLE"$TITLETEXT" $MSGBOX $TEXT"The computer 
name can not contain spaces or special characters. "
 
done
 
###################1
 
###################0
INSTDISK=`echo $TARGETPART | cut -c 1-3`
lsblk -l -o NAME,SIZE,TYPE,FSTYPE,GROUP | grep -e disk -e floppy -e part | grep -v loop | grep -v cdrom | grep -v 
$LIVECD | grep -v swap | sed "s/        \+/ '-----' /g" | awk '{print $1, $2, $3, $4, $5}' >> /tmp/diskgrub
 
sed -i 's/floppy/Externo/g' /tmp/diskgrub
 
while read diskgrub; do
 
diskmenugrub="$diskmenugrub $diskgrub"
done < /tmp/diskgrub
rm /tmp/diskgrub
 
GRUBSELT=""
QUES=""
until [[ "$GRUBSELT" !=  "" ||  "$QUES" =  "1" ]]
do
 
GRUBSELT=`$DIALOGMENU --height=500 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0  --list --column=Disk 
--column=Size --column=Tipe --column=FsTipe --column="Información" --no-click $TEXT"Select a place to install 
Grub. If you do not know you are doing, it is recommended to install the master boot disk where the system is 
installed. That is, if the system is installed in <b>$TARGETPART</b> select <b>$INSTDISK</b> to install Grub. \nOn 
the other hand, if your system has a boot <b>EFI</b>, select the appropriate partition for this purpose." 
$diskmenugrub`
QUES="$?"
done
if [ $QUES != 0 ]; then
exit 0
fi
 
GRUBSELT=`echo $GRUBSELT | cut -d "|" -f 1`
 
GRUBLOC="/dev/$GRUBSELT"
###################1
 
 
###################0
#Timezone setting
QUES=""
$DIALOG $TITLE"$TITLETEXT" --button="Exit":2  --button="No":1 --button="yes":0 $TEXT"Is your system clock set to 
your current local time?. \nAnswering no will indicate it is set to UTC. "
QUES=$?
if [ $QUES = 2 ]; then
exit 0
fi
 
if [ $QUES = 0 ]; then
if [ "$(grep "UTC" /etc/adjtime)" != "" ]; then
 sed -i -e 's|UTC|LOCALTIME|g' /etc/adjtime
fi
else
if [ "$(grep "LOCALTIME" /etc/adjtime)" != "" ]; then
 sed -i -e 's|LOCALTIME|UTC|g' /etc/adjtime
fi
fi
progressbar "Generating Time Zones... Please Wait. " &
cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "/" | sort > /tmp/dmdc.zoneinfo
for i in `cat /tmp/dmdc.zoneinfo`; do
ZONES="$ZONES $i `(TZ=$i date +"%A %R" | awk '{print $1, $2}')`"
done
killall -KILL tail
ZONESINFO=""
QUES=""
until [[ "$ZONESINFO" !=  "" ||  "$QUES" =  "1" ]]
do
ZONESINFO=`$DIALOGMENU --width=400 --height=600 $TITLE"$TITLETEXT" --button="Exit":1 --button="OK":0 --list 
--column=Zone --column="Day" --column=Time  $TEXT"Please select a timezone for your system. " $ZONES`
QUES="$?"
done
 
 
if [ $QUES != 0 ]; then
exit 0
fi
 
ZONESINFO=`echo $ZONESINFO | cut -d "|" -f 1`
 
 
###################1
 
###################0
###########################################################################
###########################################################################
progressbar "Processing the input data ... Please Wait. " &
FNZONEINFO=`cat /tmp/dmdc.zoneinfo | sort | uniq`
FNZONEINFO=`echo $FNZONEINFO | sed 's/ /!/g'`
FNTARGETPART=`lsblk -l -o NAME,SIZE,TYPE,FSTYPE,GROUP | grep -e part -e floppy | grep -v loop | grep -v swap  | 
grep -v cdrom | grep -v $LIVECD | grep part | awk '{print $1}'`
FNGRUB=`lsblk -l -o NAME,TYPE,SIZE,GROUP,FSTYPE | grep -e disk -e floppy -e part | grep -v loop | grep -v cdrom | 
grep -v $LIVECD | grep -v swap | awk '{print $1}'`
FNSWAP=`lsblk -l -o NAME,SIZE,FSTYPE,GROUP | grep swap | awk '{print $1}'`
if [[ "$SWAP" = "no" ]]; then
YESNOSWAP="no"
fi
FNTARGETPART=`echo $FNTARGETPART | sed 's/ /!/g'`
FNGRUB=`echo $FNGRUB | sed 's/ /!/g'`
FNSWAP=`echo $FNSWAP | sed 's/ /!/g'`
if [ "$HFSTYPE" = "" ]; then
HFSTYPE='NoFormat'
fi
killall -KILL tail
 
hb3=""
hb4=""
hb6=""
QUES=""
while [[ "$hb3" != "${hb3//[\' ]/}" || "$hb4" != "${hb4//[\' ]/}" || "$hb7" != "${hb7//[\' ]/}" || "$hb3" = "" ||  
"$hb4" = "" ||  "$hb7" = "" ]]
do
CONFIR=`$DIALOG --align=right --columns=2 $TITLE"$TITLETEXT" --button="Abort":1 --button="Install":0 
$TEXT"\nPlease verify that the information is correct. If you intend to modify some data, make sure you do it 
correctly. " \
--form \
--field=:LBL "" \
--field="<b>Current user configuration</b>":LBL "" \
--field="User Real Name:" $TARGETUSERFULLNAME \
--field="Username:" $TARGETUSER \
--field="Automatic login:":CB $AUTOINI!"yes"!"no" \
--field="Enable user sudo:":CB $USERSUDO!"yes"!"no" \
--field="Name for computer:" $TARGETHOSTNAME  \
--field=:LBL "" \
--field="<b>Currently selected time zone:</b>":LBL "" \
--field="Time zone:":CB $ZONESINFO!$FNZONEINFO \
--field=:LBL "" \
--field="                ":LBL "" \
--field="                ":LBL "" \
--field="                ":LBL "" \
--field="<b>Settings the physical installation</b>":LBL "" \
--field="The system will be installed in:":CB $TARGETPART!$FNTARGETPART   \
--field="System File Format:":CB $FSTYPES!ext2!ext3!ext4!btrfs!nilfs  \
--field=:LBL "" \
--field="The HOME will be installed in:":CB $HOMEPART!$FNTARGETPART  \
--field="Format partition HOME:":CB "$HFSTYPE"!NoFormat!ext2!ext3!ext4!btrfs!nilfs \
--field=:LBL "" \
--field="Swap:":CB $SWAP!$FNSWAP  \
--field="Use Swap:":CB $YESNOSWAP!"yes"!"no"  \
--field=:LBL "" \
--field="Use Splash:":CB $SPLASH!"yes"!"no" \
--field="The GRUB will be installed in:":CB $GRUBSELT!$FNGRUB`
 
QUES="$?"
if [ $QUES != 0 ]; then
exit 0
fi
 
hb3=`echo $CONFIR | cut -d "|" -f 3`
hb4=`echo $CONFIR | cut -d "|" -f 4`
hb5=`echo $CONFIR | cut -d "|" -f 5`
hb6=`echo $CONFIR | cut -d "|" -f 6`
hb7=`echo $CONFIR | cut -d "|" -f 7`
 
hb10=`echo $CONFIR | cut -d "|" -f 10`
 
hb16=`echo $CONFIR | cut -d "|" -f 16`
hb17=`echo $CONFIR | cut -d "|" -f 17`
 
hb19=`echo $CONFIR | cut -d "|" -f 19`
hb20=`echo $CONFIR | cut -d "|" -f 20`
 
hb22=`echo $CONFIR | cut -d "|" -f 22`
hb23=`echo $CONFIR | cut -d "|" -f 23`
 
hb25=`echo $CONFIR | cut -d "|" -f 25`
hb26=`echo $CONFIR | cut -d "|" -f 26`
 
done
 
if [[ $hb3 != $TARGETUSERFULLNAME || $hb4 != $TARGETUSER || $hb5 != $AUTOINI || $hb6 != $USERSUDO || $hb7 != 
$TARGETHOSTNAME || $hb10 != $ZONESINFO || $hb16 != $TARGETPART || $hb17 != $FSTYPES || $hb19 != $HOMEPART || $hb20 
!= $HFSTYPE || $hb22 != $SWAP || $hb23 != $YESNOSWAP || $hb25 != $SPLASH || $hb26 != $GRUBSELT ]]; then
QUES=""
$DIALOG $TITLE"$TITLETEXT" --button="Abort":1 --button="Install":0  $TEXT"There have been changes in the above 
data. \nIf you are certain changes press <b>Install</b>."
QUES="$?"
if [ $QUES != 0 ]; then
exit 0
fi
 
 
TARGETUSERFULLNAME=$hb3
TARGETUSER=$hb4
AUTOINI=$hb5
USERSUDO=$hb6
TARGETHOSTNAME=$hb7
 
ZONESINFO=$hb10
 
TARGETPART=$hb16
FSTYPES=$hb17
 
HOMEPART=$hb19
 
SPLASH=$hb25
GRUBLOC="/dev/$hb26"
 
if [ "$hb19" = "$hb16" ]; then
HFSTYPE="NoFormat"
else
HFSTYPE=$hb20
fi
 
if [[ "$hb22" = "no" || "$hb23" = "no" ]]; then
YESNOSWAP="no"
else
SWAP=$hb22
YESNOSWAP=$hb23
fi
 
fi
###########################################################################
###########################################################################
###################1
 
 
###################0
 
 
echo "$ZONESINFO" > /etc/timezone
cp /usr/share/zoneinfo/$ZONESINFO /etc/localtime
 
 
      if [ "$YESNOSWAP" = "yes" ] ; then
progressbar "Configuring <b>SWAP</b>. Please Wait... " &
sleep 2
#mkswap /dev/$SWAP
swapon /dev/$SWAP
         fi
killall -KILL tail
 
 
cp -f /etc/mdm/mdm.conf /tmp/mdm.conf
 
if [ "$AUTOINI" = "yes" ]; then
sed -i 's/AutomaticLogin=dmdc/AutomaticLogin='$TARGETUSER'/g' /tmp/mdm.conf
else
sed -i -e 's/AutomaticLogin=dmdc/AutomaticLogin='$TARGETUSER'/g' -e 
's/AutomaticLoginEnable=true/AutomaticLoginEnable=false/g' /tmp/mdm.conf
fi
 
 
if [ "$SPLASH" = "yes" ]; then
cat > /etc/default/grub <<FOO
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'
 
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=\`lsb_release -i -s 2> /dev/null || echo Debian\`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash \\\$vt_handoff"
GRUB_CMDLINE_LINUX="init=/bin/systemd vga=792"
 
# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"
 
# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console
 
# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command \`vbeinfo'
#GRUB_GFXMODE=640x480
 
# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true
 
# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"
 
# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"
 
FOO
 
else
cat > /etc/default/grub <<FOO
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'
 
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=\`lsb_release -i -s 2> /dev/null || echo Debian\`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="init=/bin/systemd vga=792"
 
# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"
 
# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console
 
# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command \`vbeinfo'
#GRUB_GFXMODE=640x480
 
# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true
 
# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"
 
# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"
 
FOO
 
fi
 
progressbar "Formatting the partition: <b>$TARGETPART</b> para el sistema. \nPlease Wait... " &
 
if [ "`mount | grep $TARGETPART`" ]; then
echo "Unmounting the partition we are going to use and format now"
umount /dev/$TARGETPART
fi
mkfs.$FSTYPES /dev/$TARGETPART
mkdir -p /TARGET
sleep 2
echo "Mounting the TARGET partition now"
mount /dev/$TARGETPART /TARGET -o rw
sleep 2
echo "Using tune2fs to prevent the forced checks on boot"
###tune2fs -c 0 -i 0 /dev/$TARGETPART
rm -rf "/TARGET/lost+found"
 
 
killall -KILL tail
 
if [ "$HOMEPART" != "$TARGETPART" ]; then
if [ "$HFSTYPE" != "NoFormat" ]; then
 
progressbar "Formatting the partition: <b>$HOMEPART</b> for <b>HOME</b>. \nPlease Wait... " &
 
if [ "`mount | grep $HOMEPART`" ]; then
echo "Unmounting the partition we are going to use and format now"
umount /dev/$HOMEPART
fi
mkfs.$HFSTYPE /dev/$HOMEPART
fi
echo "Mounting the TARGET home partition now"
mkdir -p /TARGET/home
mount /dev/$HOMEPART /TARGET/home -o rw
#tune2fs -c 0 -i 0 /dev/$HOMEPART
rm -rf "/TARGET/home/lost+found"
sleep 2
 
killall -KILL tail
 
fi
 
 
#TARGETCDROM=`cat /proc/mounts | grep "/live/image" | awk '{print $1}'`
TARGETCDROM="/dev/cdrom"
 
sleep 1
 
killall -KILL tail
 
 
#testmode=`grep "1000" /etc/passwd | grep -v "Live"`
 
cat > /var/log/dmdc-installer.log <<FOO
==============================
DMDc-Installer log file
==============================
LIVEMODE=DIST
==============================================================
TARGETUSER=$TARGETUSER
==============================================================
TARGETHOSTNAME=$TARGETHOSTNAME
==============================================================
SWAP=$SWAP
==============================================================
TARGETPART=$TARGETPART
==============================================================
FSTYPES=$FSTYPES
==============================================================
HOMEPART=$HOMEPART
==============================================================
HFSTYPE=$HFSTYPE
==============================================================
AUTOINI=$AUTOINI
==============================================================
USERSUDO=$USERSUDO
==============================================================
SPLASH=$SPLASH
==============================================================
GRUBLOC=$GRUBLOC
==============================================================
FOO
 
echo "==============================================================" >> /var/log/dmdc-installer.log
echo "MOUNTS" >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
mount >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
echo "LSBLK listing" >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
###3# 'fdisk' no funciona con disco 'GDT' utilizaremos entonces 'lsblk'
lsblk -l -o NAME,TYPE,SIZE,FSTYPE,GROUP >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
echo "live config listing" >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
cat /etc/live/config.conf >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
echo "End of Log" >> /var/log/dmdc-installer.log
echo "==============================================================" >> /var/log/dmdc-installer.log
 
 
progressbar "Copy files to the target disk <b>$TARGETPART</b>. \nPlease Wait... " &
# copy the live system to the hd
echo "Copying the live system to the hard drive now."
echo "This may take a while so please wait until completed."
rsync -a / /TARGET --ignore-existing --exclude=/{TARGET,lib/live/mount,live,cdrom,mnt,proc,run,sys,media}
 
mkdir -p /TARGET/{proc,mnt,lib/live/mount,run,sys,media/cdrom}
 
killall -KILL tail
 
progressbar "Completing the installation. Please Wait... " &
 
 
mount -o bind /proc /TARGET/proc
mount -o bind /dev /TARGET/dev
mount -o bind /sys /TARGET/sys
rm -f /TARGET/etc/fstab
rm -f /TARGET/etc/profile.d/zz-live.sh
 
###7# Creamos fstab con la SWAP
         if [ "$YESNOSWAP" = "yes" ] ; then
 
#create the new fstab
if [ "$HOMEPART" = "$TARGETPART" ]; then
cat > /TARGET/etc/fstab <<FOO
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
 
proc /proc proc defaults 0 0
# /dev/$TARGETPART
UUID=`blkid -s UUID -o value /dev/$TARGETPART` / $FSTYPES relatime,errors=remount-ro 0 1
# /dev/$SWAP
UUID=`blkid -s UUID -o value /dev/$SWAP` none swap sw 0 0
# cdrom
$TARGETCDROM /media/cdrom udf,iso9660 user,noauto,exec,utf8 0 0
 
FOO
 
else
 
cat > /TARGET/etc/fstab <<FOO
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
 
proc /proc proc defaults 0 0
# /dev/$TARGETPART
UUID=`blkid -s UUID -o value /dev/$TARGETPART` / $FSTYPES relatime,errors=remount-ro 0 1
# /dev/$HOMEPART home
UUID=`blkid -s UUID -o value /dev/$HOMEPART` /home `lsblk -l -o FSTYPE /dev/$HOMEPART | grep -v FSTYPE | awk 
'{print $1}'` relatime 0 0
# /dev/$SWAP
UUID=`blkid -s UUID -o value /dev/$SWAP` none swap sw 0 0
# cdrom
$TARGETCDROM /media/cdrom udf,iso9660 user,noauto,exec,utf8 0 0
 
FOO
 
fi
 
         else
 
if [ "$HOMEPART" = "$TARGETPART" ]; then
cat > /TARGET/etc/fstab <<FOO
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
 
proc /proc proc defaults 0 0
# /dev/$TARGETPART
UUID=`blkid -s UUID -o value /dev/$TARGETPART` / $FSTYPES relatime,errors=remount-ro 0 1
# cdrom
$TARGETCDROM /media/cdrom udf,iso9660 user,noauto,exec,utf8 0 0
 
FOO
 
else
 
cat > /TARGET/etc/fstab <<FOO
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
 
proc /proc proc defaults 0 0
# /dev/$TARGETPART
UUID=`blkid -s UUID -o value /dev/$TARGETPART` / $FSTYPES relatime,errors=remount-ro 0 1
# /dev/$HOMEPART home
UUID=`blkid -s UUID -o value /dev/$HOMEPART` /home `lsblk -l -o FSTYPE /dev/$HOMEPART | grep -v FSTYPE | awk 
'{print $1}'` relatime 0 0
# cdrom
$TARGETCDROM /media/cdrom udf,iso9660 user,noauto,exec,utf8 0 0
 
FOO
 
fi
         fi
 
 
 
# remove diverted update-initramfs as live-initramfs makes it a dummy file when booting the livecd
if [ -f /TARGET/usr/sbin/update-initramfs.debian ]; then
rm -f /TARGET/usr/sbin/update-initramfs
fi
 
# remove diverted update-notifier as it is disabled by live-config
if [ -f /TARGET/usr/lib/update-notifier/apt-check.debian ]; then
rm -f /TARGET/usr/lib/update-notifier/apt-check
fi
 
# remove diverted anacron as it is disabled by live-config
if [ -f /TARGET/usr/sbin/anacron.debian ]; then
rm -f /TARGET/usr/sbin/anacron
fi
 
# fix adept_notifier by copying the file we saved when remastersys first ran as live-initramfs removes it
if [ -f /TARGET/etc/remastersys/adept_notifier_auto.desktop ]; then
mv /TARGET/etc/remastersys/adept_notifier_auto.desktop /TARGET/usr/share/autostart/adept_notifier_auto.desktop
fi
 
# copy trackerd stuff as live-initramfs disables it
if [ -f /TARGET/etc/remastersys/tracker-applet.desktop ]; then
mv /TARGET/etc/remastersys/tracker-applet.desktop /TARGET/etc/xdg/autostart/tracker-applet.desktop
fi
if [ -f /TARGET/etc/remastersys/trackerd.desktop.xdg ]; then
mv /TARGET/etc/remastersys/trackerd.desktop.xdg /TARGET/etc/xdg/autostart/trackerd.desktop
fi
if [ -f /TARGET/etc/remastersys/trackerd.desktop.share ]; then
mv /TARGET/etc/remastersys/trackerd.desktop.share /TARGET/usr/share/autostart/trackerd.desktop
fi
 
#restore original inittab as live-initramfs changes it
cp /TARGET/usr/share/sysvinit/inittab /TARGET/etc/inittab
 
#check if this is a backup livecd or a dist livecd
#if [ "$TARGETUSER" != "" ]; then
 
echo "$TARGETHOSTNAME" > /TARGET/etc/hostname
echo "127.0.0.1 localhost" > /TARGET/etc/hosts
echo "127.0.0.1 $TARGETHOSTNAME" >> /TARGET/etc/hosts
touch /TARGET/etc/resolv.conf
 
#cleanup live polkit file from new install
rm -f /TARGET/var/lib/polkit-1/localauthority/10-vendor.d/10-live-cd.pkla
 
if [ -f /etc/remastersys/remastersys-installer.conf ]; then
. /etc/remastersys/remastersys-installer.conf
fi
if [ "$DEFAULTGROUPS" = "" ]; then
DEFAULTGROUPS="audio,cdrom,dialout,floppy,video,plugdev,netdev"
fi
 
if [ $USERSUDO = "yes" ]; then
SUDO="sed -i '/User privilege specification/a\'$TARGETUSER'  ALL=(ALL:ALL) ALL' /etc/sudoers"
else
SUDO="echo"
fi
 
 
cat > /TARGET/bin/tempinstallerscript <<FOO
#!/bin/bash
 
echo -e '$TARGETROOTPASS\n$TARGETROOTPASS\n' | passwd root
userdel -f -r $LIVE_USERNAME
sed -i '/'$LIVE_USERNAME'/d' /etc/sudoers
groupadd -g 1000 $TARGETUSER
useradd -u 1000 -g 1000 -c "$TARGETUSERFULLNAME,,," -G $DEFAULTGROUPS -s /bin/bash -m $TARGETUSER
$SUDO
echo -e "$TARGETPASS\n$TARGETPASS\n" | passwd $TARGETUSER
dpkg-divert --remove --rename --quiet /usr/lib/update-notifier/apt-check
dpkg-divert --remove --rename --quiet /usr/sbin/update-initramfs
dpkg-divert --remove --rename --quiet /usr/sbin/anacron
update-initramfs -t -c -k $(/bin/uname -r)
shadowconfig on
 
FOO
 
 
#else
 
#cat > /TARGET/bin/tempinstallerscript <<FOO
#!/bin/bash
 
#dpkg-divert --remove --rename --quiet /usr/lib/update-notifier/apt-check
#dpkg-divert --remove --rename --quiet /usr/sbin/update-initramfs
#dpkg-divert --remove --rename --quiet /usr/sbin/anacron
#update-initramfs -t -c -k $(uname -r)
#for i in `ls -d /home/*`; do
 
#if [ /$i/.config/Thunar/volmanrc ]; then
  #sed -i -e 's/FALSE/TRUE/g' /$i/.config/Thunar/volmanrc
 # cp -f /$i/.config/volmanrc /root/.config/Thunar/volmanrc
#fi
 
#done
 
##FOO
 
 
##fi
 
chmod 755 /TARGET/bin/tempinstallerscript
chroot /TARGET /bin/tempinstallerscript
rm /TARGET/bin/tempinstallerscript
 
killall -KILL tail
 
# Setup grub
 
#if [ $GPT = "not" ]; then
 
cat > /tmp/dmdc-Grub-Install << FOO
#!/bin/bash
chroot /TARGET grub-install --force --no-floppy "$GRUBLOC"
chroot /TARGET update-grub
exit 0
FOO
#else
#cat > /tmp/dmdc-Grub-Install << FOO
##!/bin/bash
#chroot /TARGET grub-install --force --no-floppy "$GRUBLOC"
#chroot /TARGET update-grub
#exit 0
#FOO
#fi
 
 
chmod +x /tmp/dmdc-Grub-Install
 
 
progressbar "Installing and setting up GRUB... Please Wait. " &
/tmp/dmdc-Grub-Install
sleep 1
 
rm -rf /tmp/dmdc-Grub-Install
rm -f /TARGET/usr/share/applications/dmdc-installer*.desktop
rm -f /TARGET/etc/xdg/autostart/add-dmdc-installer.desktop
rm -f /TARGET/usr/bin/remastersys*
rm -rf /TARGET/etc/remastersys*
rm -rf /TARGET/opt/dmdc-locales
rm -f /TARGET/etc/live/config.conf
mv -f /TARGET/opt/yad.png /TARGET/usr/share/pixmaps
mv -f /TARGET/usr/bin/gksu /TARGET/usr/bin/gksuX
mv -f /TARGET/usr/bin/gksuY /TARGET/usr/bin/gksu
mv -f /tmp/mdm.conf /TARGET/etc/mdm/mdm.conf
 
 
 
sleep 1
umount /TARGET/proc
sleep 1
umount /TARGET/dev
sleep 1
umount /TARGET/sys
sleep 1
umount /TARGET/home
sleep 1
umount /TARGET
sleep 1
 
 
killall -KILL tail
 
 
$DIALOG $TITLE"$TITLETEXT" $YESNO $TEXT"Installation is complete. \nIf everything went well you should have your 
new system installed and ready. \nDo you want to reboot now to try it out?. "
 
if [ $? != 0 ]; then
exit 0
else
reboot
fi
