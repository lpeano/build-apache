apacheuser=apache
apacheid=1000
apachegroup=apache:1000
apacheservicename=apacheservice
# Hardening FS ACCESS
echo "${apacheuser}:x::${apacheid}:Apache:/httpd:/sbin/nologin"

# Hardeing apache configuration
echo ServerTokens Prod
ServerSignature Off
cat << EOF >> X
ServerTokens Prod
ServerSignature Off
TraceEnable off
Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure
Header always append X-Frame-Options SAMEORIGIN
Header set X-XSS-Protection "1; mode=block"
Timeout 60

<Directory /> 
Options -Indexes 
AllowOverride None
</Directory>

<Directory /httpd/htdocs>
Options –Indexes -Includes
Order allow,denyAllow from all
</Directory>
<LimitExcept GET POST HEAD>
deny from all
</LimitExcept>


<Directory /httpd/htdocs>
Options -Indexes
</Directory>

FileETag None

# Disable HTTP/1.1
RewriteEngine On
RewriteCond %{THE_REQUEST} !HTTP/1.1$
RewriteRule .* - [F]

EOF
