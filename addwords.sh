#!/bin/sh

# Just a handy script for adding words to the wordlist

cp meta/level/wordlist.txt /tmp

sed -e 's/\(.*\)/\L\1/g' |
sed -e 's/ \+/ /g' |
sed -e 's/[^a-z ]//g' |
sed -e 's/^ \+//g' |
sed -e 's/ \+$//g' >> /tmp/wordlist.txt

sort -u /tmp/wordlist.txt > meta/level/wordlist.txt
