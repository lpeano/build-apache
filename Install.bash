download() 
{
  curl https://downloads.apache.org//apr/apr-util-$APRUTILVER.tar.gz -O
  curl https://downloads.apache.org//apr/apr-$APRVER.tar.gz -O
  curl https://downloads.apache.org//httpd/httpd-$APACHEVER.tar.gz -O 
}

packages()
{

 sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
 sudo  dnf -y install apr-util.x86_64 pcre-devel lua lua-devel git perl m4 autoconf automake libtool make patch openssl openssl-devel expat expat-devel
}

extract()
{
tar xvf  httpd-$APACHEVER.tar.gz
cd httpd-$APACHEVER/srclib
tar xvf ../../apr-util-$APRUTILVER.tar.gz
mv apr-util-$APRUTILVER apr-util
tar xvf ../../apr-$APRVER.tar.gz
mv apr-$APRVER apr
cd ../../
}

apacheconfig()
{
	PREFIX=${1:-/httpd}
	cd httpd-$APACHEVER
	./configure  --enable-mpms-shared='worker event' \
             --enable-mods-shared=most \
             --enable-maintainer-mode \
             --enable-ssl \
             --enable-proxy \
             --enable-proxy-http \
             --enable-proxy-ajp \
             --enable-proxy-balancer \
	     --enable-ssl \
	     --enable-so \
	     --enable-mods-shared=all  --with-included-apr --prefix=$PREFIX
	cd -
}

apacheconfig-modcluster()
{
	PREFIX=${1:-/httpd}
	cd httpd-$APACHEVER
	./configure  --enable-mpms-shared='worker event' \
             --enable-mods-shared=most \
             --enable-maintainer-mode \
             --enable-ssl \
             --enable-proxy \
             --enable-proxy-http \
             --enable-proxy-ajp \
             --disable-proxy-balancer \
	     --enable-ssl \
	     --enable-so \
	     --enable-mods-shared=all  --with-included-apr --prefix=$PREFIX
	cd -
}

build()
{
	cd httpd-$APACHEVER
	make 
	cd -
}

install(){
	cd httpd-$APACHEVER
	export DESTDIR=$InstallDir
	mkdir $InstallDir
	make -e  install
	cd -
}
clone_mod_cluster()
{


	git clone https://github.com/modcluster/mod_cluster.git
	cd mod_cluster
	#git checkout 1.3.16.Final
	git checkout 1.3.11.Final
       	mvn package -Dmaven.compiler.target=1.8
	cd -

}

build_modules()
{
	cd mod_cluster/native
        for p in advertise mod_manager mod_proxy_cluster mod_cluster_slotmem
        do
                cd $p
                        ./buildconf
                        CFLAGS=-Wno-error ./configure --with-apxs=$InstallDir/httpd/bin/apxs
			make CFLAGS="-Wno-error"
                        cp $p.so $InstallDir/httpd/modules/

                cd -
        done

	cd ../..
}
package()
{
	if [ "X${1}X" == "X/X" ]
	then
		cd $InstallDir
		tar zcvf ../httpd.tar.gz *
		mv ../httpd.tar.gz .
		cd -
		mkdir build ;cp $InstallDir/httpd.tar.gz build/
	else
		cd $InstallDir
		tar zcvf httpd.tar.gz httpd
		cd -
		mkdir build ;cp $InstallDir/httpd.tar.gz build/
	fi
}
buildjarPkgs()
{
	git clone https://github.com/modcluster/mod_cluster.git
        cd mod_cluster
	git checkout $(git tag |grep Final|tail -1)
        mvn package -Dmaven.compiler.target=1.8
        cd -	
	tar zcvf $InstallDir/modcluster-dist-target.tar.gz mod_cluster/dist/target
}
ARGS=$1
InstallDir=${2:-/tmp/apache/}
APACHEVER=${3:-2.4.46}
APRVER=${4:-1.7.0}
APRUTILVER=${5:-1.6.1}
case "$ARGS" in 
"download")
		download
;;
"packages")
		packages
;;
"extract")
		extract	
;;
"apacheconfig")
		PREFIX=$1
		apacheconfig $PREFIX	
;;
"apacheconfig-modcluster")
		apacheconfig-modcluster $PREFIX
;;
"build")
		build	
;;
"install")
		install	
;;
"clone_mod_cluster")
		clone_mod_cluster
;;
"build_modules")
		build_modules
;;
"package")
		package
;;
"buildjarPkgs")
	buildjarPkgs
;;
"mod-cluster-all")
	download
	packages
	extract
	apacheconfig-modcluster
	build
	install
	clone_mod_cluster
	build_modules
	package
	buildjarPkgs
;;
"all")
	download
	packages
	extract
	apacheconfig $PREFIX
	build
	install
	package $PREFIX
;;
"make_chroot")
	CHROOT=$2
	PACKAGE=$3
	VERSION=${4:-version}
	APACHEDIR=${5:-httpd}
        USERNAME=${6:-ocapache} 
        USERID=${7:-3000} 
        GROUPNAME=${8:-ocapache} 
        GROUPID=${9:-3000} 
	sudo bash make_chroot.bash clean /$CHROOT; 
	sudo bash make_chroot.bash  install /$CHROOT $PACKAGE
	sudo bash  apache-hardening.bash /$CHROOT $APACHEDIR $USERNAME $USERID $GROUPNAME $GROUPID
	sudo tar zcvf /tmp/chroot-httpd-${VERSION}.tar.gz /$CHROOT
;;
esac


