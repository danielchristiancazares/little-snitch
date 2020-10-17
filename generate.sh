#!/bin/bash
wget https://winhelp2002.mvps.org/hosts.txt -O mvps.txt

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' mvps.txt| sed '/:/d' | sed 's/\t/ /g' | tr -s ' \n' | sed 's/#.*//g' | cut -d' ' -f2- | sed 's/ //g' | sort > mvps.tmp

wget https://someonewhocares.org/hosts/zero/hosts -O someonewhocares.txt

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' someonewhocares.txt| sed '/:/d' | sed 's/\t/ /g' | tr -s ' \n' | sed 's/#.*//g' | cut -d' ' -f2- | sed 's/ //g' | sort > someonewhocares.tmp

wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O stevenblacklist.txt

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' stevenblacklist.txt | sed '/:/d' | sed 's/\t/ /g' | tr -s ' \n' | sed 's/#.*//g' | cut -d' ' -f2- | sed 's/ //g' | sort > stevenblacklist.tmp

rm -rf combined.tmp

cat mvps.tmp >> combined.tmp

cat someonewhocares.tmp >> combined.tmp

cat stevenblacklist.tmp >> combined.tmp

# Daniel Blacklist

echo -n '{"name":"Daniel's Combo Blacklist","description":"Daniel's Combo Blacklist","rules":[{"action":"deny","process":"any","remote-hosts": ["' > blacklist.tmp

uniq -i combined.tmp | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/","/g' | tr -d '\n' >> blacklist.tmp

echo -n '"]}]}' >> blacklist.tmp

cat blacklist.tmp | tr -d '\n' >> blacklist.lsrules

exit 0
