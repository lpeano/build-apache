# apachehttpd_modcluster
__Install.bash__

Scritp to build apache 2.4.46 with mod_cluster modules

Run the build with command:
```  
  bash Install.bash all <install-path> <apache-version> <apr-version>
```
For example:
```  
  bash Install.bash all /tmp/apache/ 2.4.46 1.7.0
```

To install apache in chroot:

```  
bash Install.bash  make_chroot /HTTPD1/ /tmp/apache/httpd.tar.gz 2.4.46
```  
