OPTION=$1
CHROOT=$2
APACHEPPKG=$3

install()
{
mkdir $CHROOT 
if [ $? -eq 0 ]
then
	#dnf --releasever=/ --installroot=$CHROOT openssl
        dnf --releasever=/ --setopt=install_weak_deps=False --setopt=tsflags=nodocs  --installroot=/$CHROOT install -y openssl httpd
        #yum --releasever=/ --setopt=tsflags=nodocs  --installroot=/$CHROOT install -y openssl
	rpm --root $CHROOT -e $(rpm --root $CHROOT -qa |grep http)  --nodeps
        mkdir /$CHROOT/dev/shm
	chmod 777 /$CHROOT/dev/shm
 	mknod /$CHROOT/dev/zero c 1 5 
        chmod g+r,g+w,u+r,u+w,o+r,o+w /$CHROOT/dev/zero
 	mknod /$CHROOT/dev/urandom  c 1 9 
        chmod g+r,g+w,u+r,u+w,o+r,o+w /$CHROOT/dev/urandom
 	mknod /$CHROOT/dev/random  c 1 8 
        chmod g+r,g+w,u+r,u+w,o+r,o+w /$CHROOT/dev/random
        rm -f /$CHROOT/dev/null
	chroot /$CHROOT/ mknod /dev/null c 1 3
        chmod g+r,g+w,u+r,u+w,o+r,o+w /$CHROOT/dev/null
	cd /$CHROOT/usr
	rm -rf games 
	rm -rf local
	rm -rf src
	rm -rf lib
	rm -rf sbin
        rm -rf share
        rm -rf bin
	cd /$CHROOT
	cp -pr /usr/local/lib/lua /usr/lib64/
	tar zxvf $APACHEPPKG
fi 
}

clean()
{
	rm -rf $1
}

case "$OPTION" in
	"clean")
		clean $CHROOT
	;;
	"install")
		install
	;;
esac
