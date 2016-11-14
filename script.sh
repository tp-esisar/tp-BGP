#!/bin/bash

echo "
10.224.32.1 pop1r1
10.224.32.2 pop1r2
10.224.32.254 pop1bk1
10.224.32.253 pop1bk2
10.224.32.3 pop1hq
10.224.64.1 pop2r1
10.224.64.2 pop2hq
10.224.64.254 pop2bk1
10.224.64.253 pop2bk2
10.224.96.1 pop3r1
10.224.96.2 pop3hq
10.224.96.254 pop3bk1
10.224.96.253 pop3bk2
10.224.33.1 pop4r1
10.224.33.254 pop4bk1
10.224.33.253 pop4bk2
" >> /etc/hosts

apt-get update && apt-get install sshpass

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
				reseau="10.224.32.10/24"
				ipR1="10.224.32.1" 
				;;
			"br1") 
				i=1
				reseau="10.224.64.10/24"
				ipR1="10.224.64.1" 
				;;
			"br2")
				i=2
				reseau="10.224.96.10/24"
				ipR1="10.224.96.1"
				;;
			"br3") 
				i=3
				reseau="10.224.33.10/24"
				ipR1="10.224.33.1"
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

