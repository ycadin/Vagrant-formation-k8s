utilisateur_principal="boss"

NOEUD_TEST=$(vagrant status | awk '/)$/{ print $1 }' | sed -n 2p)   # autrement dit le second noeud listé par vagrant status

vagrant ssh $NOEUD_TEST -c "id boss" || echo utilisateur principal, $utilisateur_principal', INEXISTANT !'
echo
vagrant ssh $NOEUD_TEST -c "sudo microk8s.status | sed /disabled/q"
echo
vagrant ssh $NOEUD_TEST -c "sudo microk8s.kubectl version --short 2>/dev/null"
echo
vagrant ssh $NOEUD_TEST -c "sudo microk8s.kubectl get nodes"
echo
