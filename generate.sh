#!/bin/bash
rm -rf *.lsrules *.tmp

wget https://winhelp2002.mvps.org/hosts.txt -O mvps.txt

wget https://someonewhocares.org/hosts/zero/hosts -O someonewhocares.txt

wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O stevenblacklist.txt

wget https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts -O add2o7.txt

wget 'https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts_without_controversies.txt' -O KAD.txt

wget 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0' -O peterlowe.txt

# Try later to group sed with multiple commands. sed -e '/:/d' 's/\t/ /g' ... etc
grep --extended-regexp '^0.0.0.0 .*[^0-9]$' KAD.txt             | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > KAD.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' add2o7.txt          | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > add2o7.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' mvps.txt            | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > mvps.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' someonewhocares.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > someonewhocares.tmp

grep --extended-regexp '^0.0.0.0 .*[^0-9]$' stevenblacklist.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > stevenblacklist.tmp

grep --extended-regexp '^[0-9]*.[0-9].[0-9]*.[0-9]* .*[^0-9]$' peterlowe.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > peterlowe.tmp

cat block.txt phishing.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > block.tmp

cat allow.txt | sed -e 's/\n/ /g' -e '/:/d' | tr -dc '[[:print:]\n]' | tr -s ' \n' | sed -e 's/#.*//g' | cut -d' ' -f2- | sed -e 's/ //g' > allow.tmp

sort -t'\n' --ignore-case --ignore-nonprinting --ignore-leading-blanks --dictionary-order --unique --mergesort --output='combined_block.tmp' someonewhocares.tmp mvps.tmp stevenblacklist.tmp add2o7.tmp KAD.tmp peterlowe.tmp block.tmp

sort -t'\n' --ignore-case --ignore-nonprinting --ignore-leading-blanks --dictionary-order --unique --mergesort --output='combined_allow.tmp' allow.tmp

# Daniel Blacklist
echo -n '{"name":"Daniel Combo List","description":"Daniel Combo List","rules":[{"action":"deny","remote-hosts":' > blacklist.tmp
jq -Rsc '. / "\n" - [""]' combined_block.tmp >> blacklist.tmp
echo -n '},{"action":"allow","process":"any","protocol":"tcp","ports":"443","remote-hosts":' >> blacklist.tmp
jq -Rsc '. / "\n" - [""]' combined_allow.tmp >> blacklist.tmp
echo -n '}]}' >> blacklist.tmp

cat blacklist.tmp | tr -d '\n' >> littlesnitch.lsrules

echo -n '{"name":"Daniels Cloudfront Blacklist","description":"Cloudfront Blacklist","rules":[{"action":"deny","remote-hosts":' > cloudfront.tmp
jq -Rsc '. / "\n" - [""]' cloudfront.txt >> cloudfront.tmp
echo -n '}]}' >> cloudfront.tmp
cat cloudfront.tmp | tr -d '\n' >> cloudfront.lsrules

/usr/bin/git add --all
/usr/bin/git commit --message "Update on $(echo -n date)"
/usr/bin/git push

rm -rf *.tmp

exit 0
