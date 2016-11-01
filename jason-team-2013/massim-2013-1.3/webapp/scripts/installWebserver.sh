#!/bin/bash -i
cat $( basename $0 )
exit 0

# disable selinux
setenforce 0
# or if you want to disable it permanently
vim /etc/selinux/config
# and change it to disabled
# disable firewall(s)
#system-config-firewall-tui --disabled -q

# set mail alias
echo "root:	federico.schlesinger@tu-clausthal.de" >> /etc/aliases
newaliases

# install packages
yum install man openssh-clients openssh gcc-c++ gcc make nmap links wget system-config-securitylevel-tui gpm vim nano svn httpd httpd-devel screen java-1.7.0-openjdk php subversion java-1.7.0-openjdk-devel

# install maven
cd /usr/local/
wget ftp://ftp.uni-erlangen.de/pub/mirrors/apache/maven/binaries/apache-maven-3.0.5-bin.tar.gz
tar xvfz apache-maven-*-bin.tar.gz 
ln -s apache-maven-3.0.5 maven
echo "export M2_HOME=/usr/local/maven" >> /root/.bashrc
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /root/.bashrc
source /root/.bashrc

# install tomcat and tomcat connector
# 6.0.32 and 1.2.32 was working for CentOS 5
# Also works for CentOS 6
cd /usr/local/
wget http://ftp-stud.hs-esslingen.de/Mirrors/ftp.apache.org/dist/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz
tar xvfz apache-tomcat*.tar.gz
ln -s /usr/local/apache-tomcat-6.0.37 tomcat

#wget http://www.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.32-src.tar.gz
wget http://ftp-stud.hs-esslingen.de/Mirrors/ftp.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.37-src.tar.gz 
tar xvfz tomcat-connectors-*-src.tar.gz
cd tomcat-connectors-1.2.37-src/native
./configure --with-apxs=/usr/sbin/apxs
make
make install

# checkout massim
mkdir -p /home/massim/
cd /home/massim/
svn co svn://vz103.in.tu-clausthal.de/massim/trunk

# configure tomcat
hostname=$( dnsdomainname -f )
cp -r /home/massim/trunk/webapp/webserver/jk /usr/local/tomcat/conf/
sed -i.bak 's#<Server port="8005" shutdown="SHUTDOWN">#<Server port="8005" shutdown="SHUTDOWN">\n  <Listener className="org.apache.jk.config.ApacheConfig" modJk="/etc/httpd/modules/mod_jk.so" workersConfig="/usr/local/tomcat/conf/jk/workers.properties" />#g' /usr/local/tomcat/conf/server.xml
sed -i "s#</Engine>#<Host name=\"$hostname\" appBase=\"/home/massim/www/webapps\" unpackWARs=\"true\" autoDeploy=\"true\" xmlValidation=\"false\" xmlNamespaceAware=\"false\">\n<Context path=\"/massim\" docBase=\"massim\" debug=\"0\" reloadable=\"true\"/>\n<Listener className=\"org.apache.jk.config.ApacheConfig\" append=\"true\" forwardAll=\"false\" modJk=\"/etc/httpd/modules/mod_jk.so\" />\n</Host>\n</Engine>#g" /usr/local/tomcat/conf/server.xml

# configure apache
sed -i.bak '0,/AllowOverride None/s//AllowOverride All/' /etc/httpd/conf/httpd.conf
echo "Include /usr/local/tomcat/conf/auto/mod_jk.conf" >> /etc/httpd/conf/httpd.conf

# install massim to maven repository
cd /home/massim/trunk/massim/
mvn install

# install webapp
mkdir -p /home/massim/www/webapps/
cd /home/massim/trunk/webapp/
mvn package
cp /home/massim/trunk/webapp/target/massim.war /home/massim/www/webapps/

# install redirection
echo "<?PHP
        header ('Location: /massim/');
?>" > /var/www/html/index.php

# start tomcat
/usr/local/tomcat/bin/startup.sh
sleep 10

# (re-)start apache
mkdir -p /home/massim/htpasswd
cp /home/massim/trunk/webapp/webserver/htpasswd/.htusers /home/massim/htpasswd/
/etc/init.d/httpd restart

# start massim server
cd /home/massim/trunk/massim/scripts/
screen ./startServer.sh
