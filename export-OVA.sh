#for in
#do
#    vagrant ssh $ -c "sudo halt -p"
#done

vagrant halt

vboxmanage export $(vagrant status | awk '/)$/{ print $1 }') --ovf20 --options=manifest --output ~/Documents/test-export-cli.ova