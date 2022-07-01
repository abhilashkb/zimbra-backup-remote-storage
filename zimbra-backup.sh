#!/bin/bash


if df -h /backup/ | grep your-storagebox.de ; 
then
echo ok ;

else

mount.cifs -o user=u30xxx,pass=q8Ol2JWyxxxxx //u30xxx.your-storagebox.de/backup /backup

if df -h /backup/ | grep your-storagebox.de ; 
then
echo ok ;

else

echo "backup mount failed" | mailx -s "Backup error" support@support.com

exit 

fi


fi


#Rsync Zimbra while still online...reduces downtime
rsync -avHK --delete --exclude 'data.mdb' /opt/zimbra /backup/zimbrabackup/

#Backup ldap database
#This line is necessary after the first database backup because mdb_copy won't delete existing file
mv /some/backup/location/ldap/data.mdb /backup/zimbrabackup/ldap/data.mdb.bak

/opt/zimbra/common/bin/mdb_copy /opt/zimbra/data/ldap/mdb/db /backup/zimbrabackup/ldap

#Stop Zimbra Services
su - zimbra -c 'zmcontrol stop'

sleep 30

#Rsync again while zimbra services are stopped
rsync -avHK --delete --exclude 'data.mdb' /opt/zimbra /backup/zimbrabackup

#Start zimbra services
su - zimbra -c 'zmcontrol start'

exit
