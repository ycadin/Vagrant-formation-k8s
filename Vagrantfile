# -*- mode: ruby -*-
# vi: set ft=ruby :

groupe = "XW335-MicroK8s"
nom_vm = "node"
nombre_de_noeuds = 3
numero_poste = 43
ram_en_Mo = 3072
utilisateur_principal = "boss"
description = <<-FIN_DESCRIPTION
NE PAS TOUCHER / NE PAS UTILISER

boss / boss
root / root

scripts qu'il faut sourcer dans /usr/local/etc 
FIN_DESCRIPTION

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/jammy64"
  #  config.vm.box = "generic/ubuntu2204"

  # Disable automatic box update checking. If you disable this, then boxes will only be checked for updates when the user runs `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  config.vm.hostname = nom_vm + numero_poste.to_s
  config.vm.provider :virtualbox do |vb|
      vb.name = nom_vm + numero_poste.to_s
      vb.memory = ram_en_Mo
      vb.customize ['modifyvm', :id, '--groups', '/' + groupe]
      # vb.customize ['modifyvm', :id, '--name', nom_vm + numero_poste.to_s]	# SEULEMENT SI config.vm.hostname et vb.name (qui correspond a priori à ce réglage) NE SUFFISENT PAS
      vb.customize ['modifyvm', :id, '--graphicscontroller', 'vmsvga']		# trouvé sur https://github.com/mrlesmithjr/vagrant-box-templates/blob/master/Vagrantfile
      vb.customize ['modifyvm', :id, '--vram', '16']
      vb.customize ['modifyvm', :id, '--description', description]
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]		# alternativement : vb.customize [ "modifyvm", :id, "--uart1", "off" ]  (trouvé dans https://stackoverflow.com/questions/59964319/removing-default-serial-port-from-vagrant)
  end

  # Create a public network, which generally matched to bridged network.  # Bridged networks make the machine appear as another physical device on your network.
  # config.vm.network "public_network"

  config.vm.network "forwarded_port", guest: 22, host: 2200 + numero_poste, id: "ssh"	# , host_ip: "127.0.0.1"
  config.vm.network "private_network", ip: "192.168.100." + numero_poste.to_s, virtualbox__intnet: "kluster"

  # Share an additional folder to the guest VM. The first argument is the path on the host to the actual folder.
  # The second argument is the path on the guest to mount the folder. And the optional third argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder '.', '/vagrant', disabled: true			# trouvé dans https://superuser.com/questions/756758/is-it-possible-to-disable-default-vagrant-synced-folder (ainsi que le moyen d'en faire un réglage par défaut)

  config.vm.provision "file", source: "coloration", destination: "/tmp/"
  config.vm.provision "file", source: "microk8s", destination: "/tmp/"

  # Enable provisioning with a shell script. Additional provisioners such as Ansible, Chef, Docker, Puppet and Salt are also available.
  # Please see the documentation for more information about their specific syntax and use.
  config.vm.provision "shell", args: "nom_vm utilisateur_principal", inline: <<-SHELL
    nom_machine=${1}
    utilisateur_principal=${2}
    echo UTILISATEUR PRINCIPAL : ${utilisateur_principal}

    cp /tmp/{coloration,microk8s} /usr/local/etc/

    curl -O https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.5.1.tar.xz && tar xf kbd-2.5.1.tar.xz -C /tmp/ && cp -a /tmp/kbd-2.5.1/data/keymaps/ /usr/share/   # https://www.claudiokuenzler.com/blog/1257/how-to-fix-missing-keymaps-debian-ubuntu-localectl-failed-read-list
    localectl set-keymap fr   # rendu possible avec l'enchaînement d'instructions qui précède
    localectl set-locale fr_FR.UTF-8

    timedatectl set-ntp true
    timedatectl set-timezone Europe/Paris

    apt update && apt upgrade -y
    apt install -y jq gpm bat && echo alias bat=batcat >> /etc/bash.bashrc

    for N in {1..9}; do echo -e "192.168.100.$N\t${nom_machine}$N" >> /etc/hosts; done
    echo -e "192.168.100.99\tserveurnfs" >> /etc/hosts

    # sed -i.bak 's/^PasswordAuthentication no/PasswordAuthentication yes/;s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && systemctl reload sshd
    echo -e "PasswordAuthentication yes\nPermitRootLogin yes" > /etc/ssh/sshd_config.d/password_et_root_ok.conf && systemctl reload sshd

    # wget -O get-docker.sh https://get.docker.com/ && sh get-docker.sh && usermod -aG docker vagrant && useradd -s /bin/bash -m -G sudo,docker ${utilisateur_principal}

    useradd -s /bin/bash -m -r ${utilisateur_principal} ; echo -e ${utilisateur_principal}"\n"${utilisateur_principal} | passwd ${utilisateur_principal}
    echo -e "root\nroot" | passwd root

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

    # snap install microk8s --classic
    # microk8s status --wait-ready
    # microk8s enable dns
    
    reboot
  SHELL
end
