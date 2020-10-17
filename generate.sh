#!/bin/bash
cat blacklist.txt | grep --extended-regexp '^[^#].*$' > blacklist2.txt
sed 's/#.*//g' blacklist2.txt > blacklist.txt
sed 's/ //g' blacklist.txt > blacklist2.txt
cat blacklist2.txt > blacklist.txt
rev blacklist2.txt | sort -nsd
rev blacklist.txt | sort -nd > blacklist2.txt
cat blacklist.txt | sort --field-separator='.' -d -k3,1 > blacklist2.txt
