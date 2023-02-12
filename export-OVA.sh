if [[ "${1,,}" == *-h* ]]
then
	echo "Usage: $(basename $0) [ NOM_ARCHIVE ]"
	exit 0
fi

NOM_ARCHIVE=${1:-XW335-MicroK8s}
DOSSIER_OVA="$HOME/Documents/"

read -p "Copier l'OVA sur diablotin.fr [O/n] ? " COPIER

vagrant halt	# à la place de vagrant ssh $NOEUD -c "sudo halt -p" appliqué à chaque machine

vboxmanage export $(vagrant status | awk '/)$/{ print $1 }') --ovf20 --options=manifest --output "$DOSSIER_OVA$NOM_ARCHIVE".ova

if [[ "${COPIER^}" != N* ]]
then
	cd "$DOSSIER_OVA"
	sha256sum "$NOM_ARCHIVE".ova | tee $(basename "$NOM_ARCHIVE".SHA256SUM.txt)
	scp "$NOM_ARCHIVE"* wwwbis:IB/XW335/ && echo OVA copiée
fi
