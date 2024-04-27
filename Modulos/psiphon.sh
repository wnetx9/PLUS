#!/bin/bash
#20/12/2023
#PSIPHON PROTOCOLO

tput clear

### MENU
psimen () {
tput clear  
echo
echo -e "\033[1;32m         MENU  PSIPHON       \033[0m"
msg -bar
echo -e "\033[1;32m [1] \033[1;33mATIVAR PSIPHON \033[0m"
echo -e "\033[1;32m [2] \033[1;33mVER Server.Dat PSIPHON \033[0m"
echo -e "\033[1;32m [3] \033[1;33mEDITAR Server.Json PSIPHON \033[0m"
echo -e "\033[1;32m [4] \033[1;33mDESACTIVAR PSIPHON \033[0m"
msg -bar
echo -e "\033[1;32m [0] \033[1;31m SAIR DOS PROTOCOLOS \033[0m"
msg -bar
read -p " SELECIONE UMA OPÇÃO : " opci
case $opci in

1)
tput clear
echo
rm -rf /root/psi
kill $(ps aux | grep 'psiphond' | awk '{print $2}') 1> /dev/null 2> /dev/null
killall psiphond 1> /dev/null 2> /dev/null
cd /root
mkdir psi
cd psi
ship=$(wget -qO- ipv4.icanhazip.com)
curl -o /root/psi/psiphond https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/psiphond/psiphond 1> /dev/null 2> /dev/null
chmod 777 psiphond
echo
echo -e "\e[1;33m >>>      ELECCION DE PUERTOS PSIPHON       <<< \e[0m"
msg -bar
echo
read -p " Puerto Psiphon SSH: " sh
read -p " Puerto Psiphon OSSH: " osh
read -p " Puerto Psiphon FRONTED-MEEK: " fm
read -p " Puerto Psiphon UNFRONTED-MEEK: " umo
./psiphond --ipaddress $ship --protocol SSH:$sh --protocol OSSH:$osh --protocol FRONTED-MEEK-OSSH:$fm --protocol UNFRONTED-MEEK-OSSH:$umo generate
chmod 666 psiphond.config
chmod 666 psiphond-traffic-rules.config
chmod 666 psiphond-osl.config
chmod 666 psiphond-tactics.config
chmod 666 server-entry.dat
cat server-entry.dat >> /root/psi.txt
screen -dmS psiserver ./psiphond run
cd /root

tput clear
pres_adm
echo
echo -e "\e[33m       ✓✓✓ \e[1;32mINSTALADO CON EXITO \e[33m✓✓✓\e[0m"
sleep 0.3
msg -bar
echo -e "\033[1;33m ✓ PROTOCOLOS HABILITADOS:\033[0m"
echo
echo -e "\033[1;33m → SSH:\033[1;32m $sh \033[0m"
echo -e "\033[1;33m → OSSH:\033[1;32m $osh \033[0m"
echo -e "\033[1;33m → FRONTED-MEEK-OSSH:\033[1;32m $fm \033[0m"
echo -e "\033[1;33m → UNFRONTED-MEEK-OSSH:\033[1;32m $umo \033[0m"
msg -bar
echo
echo -e "\033[1;33m ✓ DIRECTORIO DE ARCHIVOS:\033[1;32m /root/psi \033[0m"
msg -bar
msg -ne "Enter Para Continuar" && read enter
psimen
;;
2)
tput clear
echo
psi=`cat /root/psi.txt`;
echo
echo -e "\033[1;33m  LA CONFIGURACION DE TU SERVIDOR ES:\033[0m"
sleep 0.3
msg -bar
echo
echo -e "\033[1;32m $psi \033[0m"
echo
echo -e "\033[1;33m ✓ PROTOCOLOS HABILITADOS:\033[0m"
echo
echo -e "\033[1;33m → SSH:\033[1;32m $sh \033[0m"
echo -e "\033[1;33m → OSSH:\033[1;32m $osh \033[0m"
echo -e "\033[1;33m → FRONTED-MEEK-OSSH:\033[1;32m $fm \033[0m"
echo -e "\033[1;33m → UNFRONTED-MEEK-OSSH:\033[1;32m $umo \033[0m"
msg -bar
echo
echo -e "\033[1;33m ✓ ARCHIVOS ALOJADO EN:\033[1;32m /root/psi \033[0m"
msg -bar
msg -ne "Enter Para Continuar" && read enter
psimen
;;

3)
tput clear
echo
echo -e "\e[1;97m Al finalizar presione (CTRL + X + Y + Enter) \e[0m"
sleep 0.5
cat /root/psi/server-entry.dat|xxd -p -r|jq . > /root/psi/server-entry.json
nano /root/psi/server-entry.json
echo
msg -ne "Enter Para Continuar" && read enter
psimen
;;

4)
tput clear
echo
echo -e "\033[1;97m  DESACTIVANDO SERVIDOR PSIPHON EN EL SISTEMA...\033[0m"
sleep 0.3
rm -rf /root/psi
rm -rf /root/psi.txt
kill $(ps aux | grep 'psiphond' | awk '{print $2}') 1> /dev/null 2> /dev/null
killall psiphond 1> /dev/null 2> /dev/null
echo
echo -e "\e[1;33m    PROTOCOLO PSIPHON DESACTIVADO... \e[0m"
msg -bar
msg -ne "Enter Para Continuar" && read enter
exit 0
;;

0)
return 0
;;

*) psimen;;

esac
}

psimen
