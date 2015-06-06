#!/bin/bash
	user=$(whoami)
	
	
	if [ $(cat /etc/redhat-release | awk '{print $1}') = Fedora ]
	then 
		echo "Your Syetem is Running $(cat /etc/redhat-release) $(uname -p ) As $user "
	elif [ $(cat /etc/redhat-release | awk '{print $1}') = CentOS ]
		
	then
		 echo "Your Syetem is Running $(cat /etc/redhat-release) $(uname -p ) As $user "
	elif [ $(cat /etc/redhat-release | awk '{print $1,$2}') = "Red Hat" ]

	then
		echo " Your System is Running $(cat /etc/redhat-release) $(uname -p) As $user"
	else 
		echo " Error: This script is only support for Fedora , CentOS and Red Hat ."
	fi	
	
        echo "    You can install by typing following  options 
               -PHP
	       -mysql 
               -firewall
	       -apache
	       -webmin
               -update ( to update the system)
               -exit " 
	while true
	do
		read -p "Type option>" option 
		case $option in 
			PHP) yum install php php-gd php-mysql php-mbstring php-mcrypt php-pspell php-imap -y
				echo " You have done PHP installation "
			;;
			mysql) yum install mariadb mariadb-server -y
				systemctl start mariadb
				systemctl enable mariadb
				read -p "Define Mysql root user password:" mysqlrootpwd
				
				SECURE_MYSQL=$(expect -c "

				set timeout 10
				spawn mysql_secure_installation

				expect \"Enter current password for root (enter for none):\"
				send \"$MYSQL\r\"

				expect \"Change the root password?\"
				send \"y\r\"

				expect \"New Password:\"
				send \"$mysqlrootpwd\r\"

				expect \"Re-enter new password:\"
				send \"$mysqlrootpwd\r\"	

				expect \"Remove annoymous users?\"
				send \"y\r\"

				expect \"Disallow root login remotely?\"
				send \"y\r\"

				expect \"Remove test database and access to it?\"
				esend \"y\r\"

				expect \"Reload privilege tables now?\"
				send \"y\r\"

				expect eof
				")
				echo "$SECURE_MYSQL"

				echo " You have done mysql installation. "
			;;
			firewall) yum install firewalld -y
				  systemctl start firewalld
				  systemctl enable firewalld
				echo " You have done Firewall installation. "	
                       ;;
			apache) yum install httpd -y
				systemctl start httpd
				systemctl enable httpd
				echo " You have done Apache Installation. "
			;;
			webmin)
				wget http://prdownloads.sourceforge.net/webadmin/webmin-1.750-1.noarch.rpm
				rpm -ivh webmin-1.750-1.noarch.rpm
				firewalld-cmd --zone=public --add-port=10000/tcp --permanent
			;;
			update)
				if [ $(cat /etc/redhat-release) $(uname -p) = root ]
				then 
				   yum update -y
				else echo " You need to be root to perform this option ,
						login here " 
						su
					yum update -y
				fi
						
			;;
			exit) exit 
			;;
			*) echo " ERROR : PLz Type Only Above Options "
		esac	
		done
