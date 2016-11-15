#!/bin/bash

echo "
10.0.201.11 as10r1
10.0.202.12 as10r2
10.0.203.13 as10r3
10.0.204.14 as10r4
" >> /etc/hosts

apt-get install sshpass

brctl addbr br0
read -p "Lancer tous les périphériques de Marionnet et appuyer sur entrer" pause

brctl addbr br1
brctl addbr br2
brctl addbr br3

liste=$(brctl show | grep -o "sktap[0-9]*")
occupation_bridge=("0" "0" "0" "0")

for interface in $liste 
do
	echo "Traitement de l'interface $interface"
	old_bridge="br0"
	for bridge in br3 br2 br1 br0
	do			
		case "$bridge" in
			"br0") 
				i=0				
				reseau="10.0.201.111/24"
				ipR1="10.0.201.11" 
				;;
			"br1") 
				i=1
				reseau="10.0.202.112/24"
				ipR1="10.0.202.12" 
				;;
			"br2")
				i=2
				reseau="10.0.203.113/24"
				ipR1="10.0.203.13"
				;;
			"br3") 
				i=3
				reseau="10.0.204.114/24"
				ipR1="10.0.204.14"
				;;
		esac

		if [ ${occupation_bridge[$i]} != 0 ]
		then 
			continue
		fi

		echo "--- Ping : $ipR1"

		brctl delif $old_bridge $interface
		brctl addif $bridge $interface
		ifconfig $bridge $reseau
		ping -I $bridge -c 1 $ipR1 >> /dev/null
		if [ $? -eq 0 ] 
		then
			echo "=> $bridge : $reseau"
			occupation_bridge[$i]=1
			echo "Avancement :" ${occupation_bridge[@]}
			break
		fi
		
		old_bridge=$bridge
		
	done
		
done

echo "Configuration terminée"

