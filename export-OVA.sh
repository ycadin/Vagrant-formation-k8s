DEBUG=   # affecter "echo" comme valeur pour activer le mode debug / enlever "echo" pour désactiver le mode debug

if [[ "${1,,}" == -h || "${1,,}" == --help ]]
then
	echo "Usage: $(basename $0) [ NOM_ARCHIVE ]"
	exit 0
fi

NOM_ARCHIVE=${1:-XW335-MicroK8s}
DOSSIER_OVA_LOCAL="$HOME/Documents/"
MACHINE_DISTANTE=wwwbis
DOSSIER_OVA_DISTANT="IB/XW335/"

if [ -s "$DOSSIER_OVA_LOCAL$NOM_ARCHIVE".ova ]
then
	read -p "Une archive '$DOSSIER_OVA_LOCAL$NOM_ARCHIVE.ova' existe déjà, continuer [N/o] ? " CONTINUER

	if [[ "${CONTINUER^}" != O* ]]
	then
		echo Abandon
		exit 1
	else
		$DEBUG rm "$DOSSIER_OVA_LOCAL$NOM_ARCHIVE".ova "$DOSSIER_OVA_LOCAL$NOM_ARCHIVE".SHA256SUM.txt 2>/dev/null
	fi
fi

read -p "Copier l'OVA sur $MACHINE_DISTANTE [O/n] ? " COPIER

if [[ "${COPIER^}" != N* ]]
then
	read -sp "Mot de passe SSH (laisser vide pour une authentification par clef) : " PASSE_SSH ; echo
fi

$DEBUG vagrant halt	# à la place de vagrant ssh $NOEUD -c "sudo halt -p" appliqué à chaque machine

$DEBUG vboxmanage export $(vagrant status | awk '/)$/{ print $1 }') --ovf20 --options=manifest --output "$DOSSIER_OVA_LOCAL$NOM_ARCHIVE".ova

if [[ "${COPIER^}" != N* ]]
then
	cd "$DOSSIER_OVA_LOCAL"
	$DEBUG sha256sum "$NOM_ARCHIVE".ova | $DEBUG tee $(basename "$NOM_ARCHIVE".SHA256SUM.txt)

	[ -n "$PASSE_SSH" ] && SSHPASS="sshpass -p $PASSE_SSH"
	$DEBUG $SSHPASS scp "$NOM_ARCHIVE"* $MACHINE_DISTANTE:"'$DOSSIER_OVA_DISTANT'" && echo "$NOM_ARCHIVE.ova copié sur $MACHINE_DISTANTE dans '$DOSSIER_OVA_DISTANT'"
	$DEBUG $SSHPASS ssh $MACHINE_DISTANTE "cd '$DOSSIER_OVA_DISTANT' ; sha256sum -c '$NOM_ARCHIVE.SHA256SUM.txt'"
fi
