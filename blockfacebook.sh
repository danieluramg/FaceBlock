#!/bin/sh
#Lista de IPs liberados para acessar o Facebook
IPS_ACCEPT=$(cut -f 1 -d" " /partition/face_ips_permitidos | grep -v ^#)
CLIENTES=$(grep -v :3 usr/local/easycaptive/config/passwd | cut -f 3 -d:)

#Sub-rede interna do ambiente em questão
REDE_INTERNA="192.168.0.0/16"

#Criando nova regra FACEBOOK
iptables -N FACEBOOK

#Transferindo todo tráfego fonte da rede interna para a regra FACEBOOK
iptables -I FORWARD -s $REDE_INTERNA -j FACEBOOK

#Percorre o arquivo dos IPs do Facebook (face_ips_block) e vai colocando REJECT em todos os IPs da rede interna, exceto os liberados.
for i in `grep -v ^# /partition/face_ips_block`; do

    #O acesso dos IPs (que caíram na regra FACEBOOK) ao Facebook vai ser rejeitado
    iptables -A FACEBOOK -d $i -j REJECT

	#Percorre lista de IPs dos clientes no EasyCaptive e vai colocando ACCEPT neles
    for clientes_liberados in $CLIENTES; do
		iptables -I FORWARD -s $clientes_liberados -d $i -j ACCEPT
	done
	
    #Percorre lista de IPs liberados e vai colocando ACCEPT neles
    for liberados in $IPS_ACCEPT; do
		iptables -I FORWARD -s $liberados -d $i -j ACCEPT
	done

done
