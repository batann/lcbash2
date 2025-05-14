DEPS="qtbase5-dev gcc g++ make python3 zlib1g-dev pkg-config"

for REPO in ${DEPS[@]}; do
INSTALLED=$(dpkg -s $REPO 2>/dev/null| grep '^Status.*ok.*' | sed -e 's/.*ok //' )
if [[ $INSTALLED != "installed" ]]; then
echo "\033[34mInstalling \033[32m$REPO\033[0m"
sudo apt install $REPO -y >/dev/null 2>$1
fi
done

git clone https://github.com/ParrotSec/encryptpad.git
cd encryptpad
./configure.py --build-botan --build-zlib
make



#
wget https://github.com/evpo/EncryptPad/releases/download/v0.3.2.5\
/encryptpad0_3_2_5_webupd8_ppa_changes.tar.gz

wget https://github.com/evpo/EncryptPad/releases/download/v0.3.2.5\
/encryptpad0_3_2_5_webupd8_ppa_changes.tar.gz.asc

#3. Receive and verify the EncryptPad Release key:
gpg --recv-key 634BFC0CCC426C74389D89310F1CFF71A2813E85
#4. Verify the signature on the tarball:
gpg --verify encryptpad0_3_2_5_webupd8_ppa_changes.tar.gz.asc

#5. Extract the content:
tar -xf encryptpad0_3_2_5_webupd8_ppa_changes.tar.gz

#6. Compare the "changes" file for your distribution with the file from step 1. The SHA hashes should match.
diff encryptpad_0.3.2.5-1~webupd8~yakkety1_source.changes \
encryptpad0_3_2_5_webupd8_ppa_changes/encryptpad_0.3.2.5-1~webupd8~yakkety1_source.changes


