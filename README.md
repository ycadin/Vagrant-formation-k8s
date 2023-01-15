# Vagrant-formation-k8s
Vagrantfile [et fichiers connexes] pour déployer les machines virtuelles qui seront les nœuds d'un cluster Kubernetes

Pour "provoquer" l'ajout (automatique) des "VirtualBox Guest Additions" dans les machines virtuelles pendant leur génération, il convient au préalable d'ajouter le plug-in Vagrant ad-hoc avec l'instruction suivante :
~~~
   vagrant plugin install vagrant-vbguest    # explications : https://subscription.packtpub.com/book/cloud-&-networking/9781786464910/1/ch01lvl1sec12/enabling-virtualbox-guest-additions-in-vagrant
~~~
Cette instruction est à exécuter par CHAQUE utilisateur de la commande vagrant.
