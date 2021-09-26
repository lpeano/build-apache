CHROOT=$1
APACHEINSTALL=$2
apacheuser=${3:-apache}
apacheid=${4:-2000}
apachegroup=${5:-apache}
apachegid=${6:-2000}
apacheservicename=${7:-apacheservice}
# Hardening FS ACCESS
# Config User for apache 
echo "${apacheuser}:x::${apacheid}:Apache:/httpd:/sbin/nologin" > /$CHROOT/etc/passwd
echo "${apachegroup}:x:${apachegid}" > /$CHROOT/etc/group
# Set capability to bind port under 1024
echo "setcap cap_net_bind_service=+ep $CHROOT/$APACHEINSTALL/bin/httpd" > /tmp/CAP
bash /tmp/CAP
chown $apacheid:$apachegid -R $CHROOT/$APACHEINSTALL
groupadd -g $apachegid $apachegroup
useradd -u $apacheid -g $apachegid $apachegroup
chmod -R u=rwx,g=rwx,o=---  $CHROOT/$APACHEINSTALL
chmod -R u=rwx,g=rwx,o=r-x  $CHROOT/$APACHEINSTALL/logs


# Hardeing apache configuration on httpd.conf
cat apache-hardening.httpd.conf > $CHROOT/$APACHEINSTALL/conf/httpd.conf
mkdir $CHROOT/scripts
cp apache-systemd.script $CHROOT/scripts/httpd-$apacheservicename.service
sed -i 's/{Service-Name}/'"$apacheservicename"'/' $CHROOT/scripts/httpd-$apacheservicename.service
sed -i 's/{chroot}/'"\/$(echo $CHROOT|sed 's/\///g')"'/' $CHROOT/scripts/httpd-$apacheservicename.service
sed -i 's/{apacheuser}/'"$apacheuser"'/' $CHROOT/scripts/httpd-$apacheservicename.service
sed -i 's/{apachegroup}/'"$apachegroup"'/' $CHROOT/scripts/httpd-$apacheservicename.service
