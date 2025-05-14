
read -p "check for package:      >>>   " REPO
read -p "if not installed run:   >>>   " BCD
if [[ $(dpkg -s $REPO 2>/dev/null| grep '^Status.*ok.*' | sed -e 's/.*ok //') != "installed" ]] ; then ${BCD} ; fi

