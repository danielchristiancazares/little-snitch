#!/bin/bash
SHA1SUM_OLD="$(sha1sum blacklist.lsrules)"
SHA1SUM_NEW=""
wget https://winhelp2002.mvps.org/hosts.txt -O mvps.txt

wget https://someonewhocares.org/hosts/zero/hosts -O someonewhocares.txt

wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O stevenblacklist.txt

wget https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts -O add2o7.txt

wget https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts_without_controversies.txt -O KAD.txt

# Try later to group sed with multiple commands. sed -e '/:/d' 's/\t/ /g' ... etc
grep --extended-regexp '^0.0.0.0 .*[^0-9]$' KAD.txt             | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > KAD.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' add2o7.txt          | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > add2o7.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' mvps.txt            | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > mvps.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' someonewhocares.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > someonewhocares.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' stevenblacklist.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > stevenblacklist.tmp

sort -t'\n' --ignore-case --ignore-nonprinting --ignore-leading-blanks --dictionary-order --unique --mergesort --output='combined.tmp' someonewhocares.tmp mvps.tmp stevenblacklist.tmp add2o7.tmp KAD.tmp

# Daniel Blacklist

echo -n '{"name":"Daniel Combo Blacklist","description":"Daniel Combo Blacklist","rules":[{"action":"deny","process":"any","remote-hosts":' > blacklist.tmp

jq -Rsc '. / "\n" - [""]' combined.tmp >> blacklist.tmp

echo -n '}]}' >> blacklist.tmp

cat blacklist.tmp | tr -d '\n' > blacklist.lsrules

rm *.tmp

SHA1SUM_NEW="$(sha1sum blacklist.lsrules)"

echo "OLD: ${SHA1SUM_OLD} - NEW: ${SHA1SUM_NEW}"

exit 0 
