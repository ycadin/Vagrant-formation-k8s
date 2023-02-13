if [[ "${1,,}" == -h || "${1,,}" == --help ]]
then
	echo "Usage: $(basename $0) [ NOM_ARCHIVE ]"
	exit 0
fi

NOM_ARCHIVE=${1:-XW335-MicroK8s}
DOSSIER_OVA="$HOME/Documents/"

if [ -s "$DOSSIER_OVA$NOM_ARCHIVE".ova ]
then
	read -p "Une archive '$DOSSIER_OVA$NOM_ARCHIVE.ova' existe déjà, continuer [N/o] ? " CONTINUER

	if [[ "${CONTINUER^}" != O* ]]
	then
		echo Abandon
		exit 1
	else
		rm "$DOSSIER_OVA$NOM_ARCHIVE".ova "$DOSSIER_OVA$NOM_ARCHIVE".SHA256SUM.txt 2>/dev/null
	fi
fi

read -p "Copier l'OVA sur diablotin.fr [O/n] ? " COPIER

if [[ "${COPIER^}" != N* ]]
then
	read -sp "Mot de passe SSH (vide si authentification par clef) : " PASSE_SSH
fi

vagrant halt	# à la place de vagrant ssh $NOEUD -c "sudo halt -p" appliqué à chaque machine

vboxmanage export $(vagrant status | awk '/)$/{ print $1 }') --ovf20 --options=manifest --output "$DOSSIER_OVA$NOM_ARCHIVE".ova

if [[ "${COPIER^}" != N* ]]
then
	cd "$DOSSIER_OVA"
	sha256sum "$NOM_ARCHIVE".ova | tee $(basename "$NOM_ARCHIVE".SHA256SUM.txt)

	if [ -z "$PASSE_SSH" ]
	then
		scp "$NOM_ARCHIVE"* wwwbis:IB/XW335/ && echo OVA copiée
	else
		sshpass -p $PASSE_SSH scp "$NOM_ARCHIVE"* wwwbis:IB/XW335/ && echo "'$NOM_ARCHIVE'.ova copié"
	fi
fi
