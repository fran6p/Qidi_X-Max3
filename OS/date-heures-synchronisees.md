Gestion date et heure

Deux sytèmes en conflis pour synchroniser heure  / date
chronyd et systemd-timesyncd

systemctl status systemd-timesyncd
systemctl stop systemd-timesyncd
systemctl disable --now systemd-timesyncd.service
systemctl status systemd-timesyncd

cat /etc/chrony/chrony.conf
sudo nano /etc/chrony/chrony.conf
sudo systemctl restart chronyd
systemctl status chronyd
chronyc sources
date
chronyc tracking
