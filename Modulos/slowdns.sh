#!/bin/bash

colores
lor1='\033[1;31m';lor2='\033[1;32m';lor3='\033[1;33m';lor4='\033[1;34m';lor5='\033[1;35m';lor6='\033[1;36m';lor7='\033[1;37m'

if [ $(id -u) -eq 0 ];then
clear
else
echo -e "Ejecutar Script Como Usuario${lor2}root${lor7}"
exit
fi 

drop_port() {
    local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
    local NOREPEAT
    local reQ
    local Port
    unset DPB
    while read port; do
      reQ=$(echo ${port} | awk '{print $1}')
      Port=$(echo {$port} | awk '{print $9}' | awk -F ":" '{print $2}')
      [[ $(echo -e $NOREPEAT | grep -w "$Port") ]] && continue
      NOREPEAT+="$Port\\n"

      case ${reQ} in
      sshd | dropbear | stunnel4 | stunnel | python | python3) DPB+=" $reQ:$Port" ;;
      *) continue ;;
      esac
    done <<<"${portasVAR}"
  }

menu_sld () {
tput clear
echo -e
echo -e "\e[1;33m      MENU SLOWDNS      \033[1;33m  \033[0m"
msg -bar
[[ $(ps x | grep -w dns-server | grep -v grep) ]] && serslow="PARAR SERVICIO${lor2}[◉] " || serslow="INICIAR SERVIÇO ${lor1}[◉] "
echo -e "\e[1;32m  [1] \033[1;33mINSTALAR SLOWDNS \033[0m"
echo -e "\e[1;32m  [2] \033[1;33mREINICIAR SLOWDNS \033[0m"
echo -e "\e[1;32m  [3] \033[1;33mDESINTALAR SLOWDNS \033[0m"
echo -e "\e[1;32m  [4] \033[1;33mBASE DE DADOS \033[0m"
echo -e "\e[1;32m  [5] \033[1;33m$serslow \033[0m"
echo -e "\e[1;33m ▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎▪︎\e[0m"
echo -e "\e[1;32m  [0] \033[1;31m SAIR DO MENU \033[0m"
msg -bar
read -p " ESCOLHA UMA OPÇÃO: " opci
case $opci in

#opcion 1
1)
if [ -d /etc/newadm/dns ]; then
tput clear
echo
echo -e "${lor1}      SLOWDNS JÁ ESTA INSTALADO ${lor7}"
sleep 3
else
tput clear
echo
echo;echo -ne "\n${col7} >>> Ingresa Un Dominio Para Conexion NS: "
read ns
if [[ -z "$ns" ]]; then
tput clear
echo
echo;echo -e "${lor1}        DOMINIO INCORRETO ${lor7}"
else
echo
msg -bar
echo -e "\e[1;32m  [1] \e[97m SLOWDNS SSH \e[0m"
echo -e "\e[1;32m  [2] \e[97m SLOWDNS DROPBEAR \e[0m"
echo -e "\e[1;32m  [3] \e[97m SLOWDNS SSL \e[0m"
msg -bar
read -p "SELECT OPTION : " opcc
if [ -z $opcc ]; then
echo
else	
if [[ "$opcc" == '1' ]]; then
ptdns='22'
fi
if [[ "$opcc" == '2' ]]; then
sls=$(netstat -nplt |grep 'dropbear' | awk -F ":" 'NR==1{print $2}' | cut -d " " -f 1)
if [[ $sls == '' ]]; then
echo;echo -e "${lor1}              DROPBEAR NÃO ESTA INSTALADO O INICIADO "
sleep 3
else
ptdns="$sls"
fi
fi
if [[ "$opcc" == '3' ]]; then
sls=$(netstat -nplt | grep 'stunnel' | awk {'print $4'} | cut -d: -f2)
if [[ $sls == '' ]]; then
echo;echo -e "${lor1}              SSL NÃO ESTA INSTALADO O INICIADO "
sleep 3
else
ptdns="$sls"
fi
fi
configdns() {
apt install iptables
[[ ! -e /etc/iptables/rules.v4 ]]&& iptables-save > /etc/iptables/rules.v4
    mkdir /etc/newadm/dns >/dev/null 2>&1
    wget -P /etc/newadm/dns https://www.dropbox.com/s/jx2fow1bmshzxqv/dns-server >/dev/null 2>&1
    chmod 777 /etc/newadm/dns/dns-server >/dev/null 2>&1
    /etc/newadm/dns/dns-server -gen-key -privkey-file /etc/newadm/dns/server.key -pubkey-file /etc/newadm/dns/server.pub >/dev/null 2>&1
    interface=$(ip a | awk '/state UP/{print $2}' | cut -d: -f1|head -1)
    iptables -F >/dev/null 2>&1
    iptables -I INPUT -p udp --dport 5300 -j ACCEPT
    iptables -t nat -I PREROUTING -i $interface -p udp --dport 53 -j REDIRECT --to-ports 5300
    ip6tables -I INPUT -p udp --dport 5300 -j ACCEPT
    ip6tables -t nat -I PREROUTING -i $interface -p udp --dport 53 -j REDIRECT --to-ports 5300
DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
cat /dev/null >~/.bash_history && history -c
}
tput clear
echo
echo;echo -e "${lor3}                INSTALANDO SLOWDNS ${lor7}"
echo
fun_bar 'configdns'
screen -dmS slow_dns /etc/newadm/dns/dns-server -udp :5300 -privkey-file /etc/newadm/dns/server.key ${ns} 0.0.0.0:${ptdns} >/dev/null 2>&1
echo "${ptdns}" > /etc/newadm/dns/portdns
keypub=$(cat /etc/newadm/dns/server.pub)
cd $HOME
echo
msg -bar
echo;echo
msg -ama "                 REGISTRO SLOWDNS CRIADO COM SUCESSO.... "
sleep 3
tput clear
echo
echo "${ns}" > /etc/newadm/dns/ns
echo -e "${lor6} DOMINIO NS${lor7}  :${ns} ${lor7}"
echo -e "${lor6} KEY PUBLICO${lor7} :${keypub} ${lor7}"   
echo
msg -bar
echo
sleep 3
fi;fi;fi
menu_sld
;;

#opcion 2
2)
    tput clear 
    echo
    msg -ama "                REINICIANDO SLOWDNS...."
    screen -S slow_dns -p 0 -X quit
    [[ -e /etc/newadm/dns/ns ]] && NS=$(cat /etc/newadm/dns/ns)
    [[ -e /etc/newadm/dns/portdns ]] && PORT=$(cat /etc/newadm/dns/portdns)
    screen -dmS slow_dns /etc/newadm/dns/dns-server -udp :5300 -privkey-file /root/server.key ${ns} 127.0.0.1:${ptdns}
    echo
    msg -verd "              >> REINICIADO COM EXITO << "
    echo
    sleep 3
menu_sld
;;

#opcion 3
3)
tput clear
echo
if [ -d /etc/newadm/dns/ ];then
rm -rf /etc/newadm/dns/
screen -r -S "slow_dns" -X quit >/dev/null 2>&1
screen -wipe > /dev/null 2>&1
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -t raw -F && iptables -t raw -X && iptables -t security -F && iptables -t security -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
echo;echo -e "${lor1}              SLOWDNS FUE DESINTALADO ${lor7}"
echo
sleep 3
else
echo;echo -e "${lor1}              SLOWDNS NÃO ESTA INSTALADO ${lor7}"
echo
sleep 3
fi
menu_sld
;;

#opcion 4
4)
tput clear
echo
if [ -f /etc/newadm/dns/ns ];then
keypub=$(cat /etc/newadm/dns/server.pub)
ns=$(cat /etc/newadm/dns/ns)
echo
echo -e "                REGISTROS VIGENTES SLOWDNS  "
msg -bar
echo
echo -e "${lor6} DOMINIO NS${lor7}  :${ns} ${lor7}"
echo -e "${lor6} KEY PUBLICO${lor7} :${keypub} ${lor7}"  
echo
msg -bar
echo
read -t 60 -n 1 -rsp $'\033[1;39m       << Presiona enter para Continuar >>\n'
else
echo;echo -e "${lor1}              BASE DE DADOS NÃO ENCONTRADA ${lor7}"
echo
sleep 3
fi
menu_sld
;;

#opcion 5
5)
tput clear
echo
if [ -d /etc/newadm/dns ];then
if ps x | grep -w dns-server | grep -v grep 1>/dev/null 2>/dev/null; then 
screen -r -S "slow_dns" -X quit >/dev/null 2>&1
screen -wipe > /dev/null 2>&1
echo;echo -e "${lor1}                SLOWDNS DETENIDO ${col7}"
echo
sleep 3
else
ns=$(cat /etc/newadm/dns/ns)
keypub=$(cat /etc/newadm/dns/server.pub)
ptdns=$(cat /etc/newadm/dns/portdns)
screen -dmS slow_dns /etc/newadm/dns/dns-server -udp :5300 -privkey-file /etc/newadm/dns/server.key ${ns} 0.0.0.0:${ptdns} >/dev/null 2>&1
echo;echo -e "${lor2}                SLOWDNS INICIADO ${col7}"
sleep 3
fi
else
echo;echo -e "${lor1}              SLOWDNS NÃO ESTA INSTALADO ${lor7}"
echo
sleep 3
fi
menu_sld
;;

#opcion 0
0)
exit 0;;

#error
*)echo
echo -e "\e[1;31m Escolha Uma Opção Valida....!!!\e[0m"
sleep 1
menu_sld;;
esac
}
menu_sld
