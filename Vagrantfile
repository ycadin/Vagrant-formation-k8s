# -*- mode: ruby -*-
# vi: set ft=ruby :

prefixe_nom_vm = "noeud"   # les valeurs de cette définition et des 3 suivantes sont choisies pour coïncider avec le schéma (Keynote) 
numero_premier_noeud = 1
nombre_de_noeuds = 3
prefixe_reseau = "192.168.100."
groupe = "XW335-MicroK8s"
utilisateur_principal = "boss"
description = "NE PAS TOUCHER / NE PAS UTILISER\n\n" + utilisateur_principal + " / " + utilisateur_principal + "\nroot / root\n\nDes scripts (qu'il faut \"sourcer\") se trouvent dans /usr/local/etc"
ram_en_Mo = 3072

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
    # https://docs.vagrantup.com.
   # config.ssh.insert_key = false
    
    numero_dernier_noeud = numero_premier_noeud + nombre_de_noeuds - 1

    (numero_premier_noeud..numero_dernier_noeud).each do |numero_noeud|
       # nom_vm = prefixe_nom_vm + "%02d" % numero_noeud
        nom_vm = prefixe_nom_vm + numero_noeud.to_s

        config.vm.define nom_vm do |machine|
            # Every Vagrant development environment requires a box. You can search for boxes at https://vagrantcloud.com/search.
            machine.vm.box = "ubuntu/jammy64"
            #  machine.vm.box = "generic/ubuntu2204"
      
            # Disable automatic box update checking. If you disable this, then boxes will only be checked for updates when the user runs `vagrant box outdated`. This is not recommended.
            # machine.vm.box_check_update = false
      
            machine.vm.hostname = nom_vm

            machine.vm.provider :virtualbox do |vb|
               # vb.linked_clone = true	# pour économiser de la place sur le disque de l'hôte !  5,3 Go contre 6,5 Go (le gain devrait être moindre avec l'installation de MicroK8s)
                vb.name = nom_vm
                vb.memory = ram_en_Mo
                vb.customize ['modifyvm', :id, '--groups', '/' + groupe]
               # vb.customize ['modifyvm', :id, '--name', nom_vm]		 # SEULEMENT SI config.vm.hostname et vb.name (qui correspond a priori à ce réglage) NE SUFFISENT PAS
                vb.customize ['modifyvm', :id, '--graphicscontroller', 'vmsvga']	 # trouvé sur https://github.com/mrlesmithjr/vagrant-box-templates/blob/master/Vagrantfile
                vb.customize ['modifyvm', :id, '--vram', '8']
                vb.customize ['modifyvm', :id, '--description', description]
                vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]	 # alternativement : vb.customize [ "modifyvm", :id, "--uart1", "off" ]  (trouvé dans https://stackoverflow.com/questions/59964319/removing-default-serial-port-from-vagrant)
            end
      
            # Create a public network, which generally matched to bridged network.  # Bridged networks make the machine appear as another physical device on your network.
            # machine.vm.network "public_network"
      
            machine.vm.network "forwarded_port", guest: 22, host: 2200 + numero_noeud, id: "ssh"	# , host_ip: "127.0.0.1"
            machine.vm.network "private_network", ip: prefixe_reseau + numero_noeud.to_s, virtualbox__intnet: "kluster"
      
            # Share an additional folder to the guest VM. The first argument is the path on the host to the actual folder.
            # The second argument is the path on the guest to mount the folder. And the optional third argument is a set of non-required options.
            # machine.vm.synced_folder "../data", "/vagrant_data"
            machine.vm.synced_folder '.', '/vagrant', disabled: true		# trouvé dans https://superuser.com/questions/756758/is-it-possible-to-disable-default-vagrant-synced-folder (ainsi que le moyen d'en faire un réglage par défaut)
      
            machine.vm.provision "file", source: "coloration", destination: "/tmp/"
            machine.vm.provision "file", source: "microk8s", destination: "/tmp/"
      
            # Enable provisioning with a shell script. Additional provisioners such as Ansible, Chef, Docker, Puppet and Salt are also available.
            # Please see the documentation for more information about their specific syntax and use.
            machine.vm.provision "shell", args: [utilisateur_principal, prefixe_nom_vm, prefixe_reseau, numero_premier_noeud, numero_dernier_noeud], inline: <<-SHELL
                utilisateur_principal=${1}
                prefixe_nom_vm=${2}
                prefixe_reseau=${3}
		numero_premier_noeud=${4}
      		numero_dernier_noeud=${5}
                echo "UTILISATEUR PRINCIPAL : ${utilisateur_principal}"
		echo "       PREFIXE NOM VM : ${prefixe_nom_vm}"
		echo "       PREFIXE RESEAU : ${prefixe_reseau}"
		echo " NUMERO PREMIER NOEUD : ${numero_premier_noeud}"
		echo " NUMERO DERNIER NOEUD : ${numero_dernier_noeud}"

                cp /tmp/{coloration,microk8s} /usr/local/etc/
      
                curl -O https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.5.1.tar.xz && tar xf kbd-2.5.1.tar.xz -C /tmp/ && cp -a /tmp/kbd-2.5.1/data/keymaps/ /usr/share/   # https://www.claudiokuenzler.com/blog/1257/how-to-fix-missing-keymaps-debian-ubuntu-localectl-failed-read-list
                localectl set-keymap fr   # rendu possible avec l'enchaînement d'instructions qui précède
                localectl set-locale fr_FR.UTF-8
      
                timedatectl set-ntp true
                timedatectl set-timezone Europe/Paris
      
                apt update && apt upgrade -y
                apt install -y jq gpm bat && echo alias bat=batcat >> /etc/bash.bashrc
      
                for N in $(seq ${numero_premier_noeud} $(expr ${numero_dernier_noeud} + 3 )); do echo -e ajout de "${prefixe_reseau}$N\t${prefixe_nom_vm}$N" dans /etc/hosts ; echo -e "${prefixe_reseau}$N\t${prefixe_nom_vm}$N" >> /etc/hosts; done
                echo -e "${prefixe_reseau}99\tserveurnfs" >> /etc/hosts
      
                # sed -i.bak 's/^PasswordAuthentication no/PasswordAuthentication yes/;s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && systemctl reload sshd
                echo -e "PasswordAuthentication yes\nPermitRootLogin yes" > /etc/ssh/sshd_config.d/password_et_root_ok.conf && systemctl reload sshd
      
                # wget -O get-docker.sh https://get.docker.com/ && sh get-docker.sh && usermod -aG docker vagrant && useradd -s /bin/bash -m -G sudo,docker ${utilisateur_principal}
      
                echo -e "root\nroot" | passwd root
                useradd -s /bin/bash -m -r ${utilisateur_principal} ; echo -e ${utilisateur_principal}"\n"${utilisateur_principal} | passwd ${utilisateur_principal}
      
                mkdir -m 1777 /partage
                echo "pour tester accès NFS ou CIFS (SMB)" > /partage/index.html
                IP_KLUSTER=$(ip -4 -j a s enp0s8 | jq -r .[0].addr_info[0].local)	# -j(son) [ -br(ief) -p(retty) ]
                cd ~root
                # SERVEUR NFS :
                echo '#!/bin/bash' > installe-serveur-nfs.bash
                echo 'if ! [ -f /root/.nfs_installed ]' >> installe-serveur-nfs.bash
                echo 'then' >> installe-serveur-nfs.bash
                echo '    apt update && apt install -y nfs-server' >> installe-serveur-nfs.bash
                echo '    echo "/partage *(rw)" >> /etc/exports' >> installe-serveur-nfs.bash
                echo '    systemctl reload nfs-server' >> installe-serveur-nfs.bash
                echo '    touch /root/.nfs_installed' >> installe-serveur-nfs.bash
                echo 'fi' >> installe-serveur-nfs.bash
                echo 'echo ""' >> installe-serveur-nfs.bash
                echo 'echo "Sur postes clients :"' >> installe-serveur-nfs.bash
                echo 'echo -e "\t echo '${IP_KLUSTER}' servnfs >> /etc/hosts"' >> installe-serveur-nfs.bash
                echo 'echo -e "Puis sur Ubuntu/Debian :\n\t apt update && apt install -y nfs-common\n\t mount servnfs:/partage /mnt"' >> installe-serveur-nfs.bash
                echo 'echo -e "Ou sur Linux Alpine :\n\t apk add --no-cache nfs-utils\n\t mount '${IP_KLUSTER}':/partage /mnt"' >> installe-serveur-nfs.bash
                chmod +x installe-serveur-nfs.bash
                
                # SERVEUR SMB :
                echo '#!/bin/bash' > installe-serveur-cifs.bash
                echo 'if ! [ -f /root/.cifs_installed ]' >> installe-serveur-cifs.bash
                echo 'then' >> installe-serveur-cifs.bash
                echo '    apt update && apt install -y samba smbclient cifs-utils' >> installe-serveur-cifs.bash
                echo '    echo -e '${utilisateur_principal}'"\n"'${utilisateur_principal}' | smbpasswd -a '${utilisateur_principal} >> installe-serveur-cifs.bash
                echo '    echo -e "[partage]\n   comment = Partage\n   path = /partage\n   public = yes\n   guest ok = yes\n   available = yes\n   browsable = yes\n   write list = root '${utilisateur_principal}'\n   create mask = 0755" >> /etc/samba/smb.conf' >> installe-serveur-cifs.bash
                echo '    systemctl reload smbd' >> installe-serveur-cifs.bash
                echo '    touch /root/.cifs_installed' >> installe-serveur-cifs.bash
                echo 'fi' >> installe-serveur-cifs.bash
                echo 'echo ""' >> installe-serveur-cifs.bash
                echo 'echo "Sur postes clients :"' >> installe-serveur-cifs.bash
                echo 'echo -e "\t echo '${IP_KLUSTER}' servsmb >> /etc/hosts"' >> installe-serveur-cifs.bash
                echo 'echo -e "Puis sur Ubuntu/Debian :\n\t apt update && apt install -y cifs-utils\n\t mount -o username='${utilisateur_principal}',password='${utilisateur_principal}' //servsmb/partage /mnt"' >> installe-serveur-cifs.bash
                echo 'echo -e "Ou sur Linux Alpine :\n\t apk add --no-cache cifs-utils\n\t mount -o username='${utilisateur_principal}',password='${utilisateur_principal}' //'${IP_KLUSTER}'/partage /mnt"' >> installe-serveur-cifs.bash
                chmod +x installe-serveur-cifs.bash
      
		# MicroK8s (installation) :
		apt install sshpass
                snap install microk8s --classic
		usermod -aG microk8s ${utilisateur_principal}
		microk8s status --wait-ready
		# Initialisation cluster :
		nom_premier_noeud=${prefixe_nom_vm}${numero_premier_noeud}
		[ $HOSTNAME != ${nom_premier_noeud} ] && echo $HOSTNAME \!= ${nom_premier_noeud} alors join && $(sshpass -p vagrant ssh -l vagrant ${nom_premier_noeud} -o StrictHostKeyChecking=no sudo microk8s add-node | fgrep 192.168.100.) && echo attente 2 minutes && sleep 120 && microk8s status
		# Après constitution cluster :
		[ $HOSTNAME == ${prefixe_nom_vm}${numero_dernier_noeud} ] && echo $HOSTNAME == ${prefixe_nom_vm}${numero_dernier_noeud} alors enable dns && microk8s enable dns
		# semble incompatible avec microk8s.kubectl curl -L https://github.com/kubecolor/kubecolor/releases/download/v0.0.21/kubecolor_0.0.21_Linux_x86_64.tar.gz | tar xz -C /usr/local/bin kubecolor   # le paquet kubecolor est ancien et comporte une erreur
		# 	VARIANTE a priori plus récente      curl -L https://github.com/hidetatz/kubecolor/releases/download/v0.0.25/kubecolor_0.0.25_Linux_x86_64.tar.gz | tar xz -C /usr/local/bin kubecolor
		curl -L https://github.com/derailed/k9s/releases/download/v0.27.2/k9s_Linux_amd64.tar.gz | tar xz -C /usr/local/bin k9s  # requiert k config view --raw > ~/.kube/config
                reboot
            SHELL
        end
    end
end
