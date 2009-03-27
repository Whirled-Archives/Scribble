#!/bin/sh

# Just a handy script for adding words to the wordlist

cp meta/level/wordlist.txt /tmp
cat >> /tmp/wordlist.txt
sort -u /tmp/wordlist.txt > meta/level/wordlist.txt
