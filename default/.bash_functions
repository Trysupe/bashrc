#!/bin/bash

file_info(){
    [[ -z ${1} ]] && echo -e "\e[31mEs wurde kein Dateiname angegeben\e[39m" && return 1
    local counter=0
    local anzahl=$#
	for file in $@; do
		((counter++))
		[[ -d $file ]] && echo -e "\e[31m$file ist ein Ordner\e[39m" && continue
		[[ ! -f $file ]] && echo -e "\e[31mDie Datei $file exisitiert nicht\e[39m" && continue
    	echo -e "Datei:\t\t$file"
    	echo -e "Größe:\t\t$(du -h $file | cut -f1)"
    	echo -e "Anzahl Zeilen:\t$(cat $file | wc -l)"
    	echo -e "Modifiziert:\t$(find $file -printf "%CH:%CM:%.2CS %Cd.%Cm.%CY")"
    	echo -e "Rechte:\t\t$(find $file -printf "%M (%m)")"
    	echo -e "Besitzer:\t$(find $file -printf "%u")"
    	echo -e "Gruppe:\t\t$(find $file -printf "%g")"
    	if (( $( bc -l <<< "$anzahl>$counter" ) > 0)); then
    		 echo -e "\n\n"
   		fi
    done
}

git_url(){
    if [[ "$(git status 2>&1)" =~ (Kein Git-Repo|not a git repository) ]]; then
        echo -e "\e[31mEs wurde kein GIT Repository gefunden\e[0m"
        return 1
    fi
    echo -ne "Repository URL: \e[96m"
    git config --get remote.origin.url | sed 's/\.git//' | sed 's/git@github.com:/https:\/\/www.github.com\//'
    echo -ne "\e[0m"
}

search_string(){
    [[ -z ${1} ]] && echo -e "\e[31mEs wurde kein Suchbegriff angegeben\e[39m" && return 1
    if [[ $# == 1 ]]; then
        grep -inrs --color=auto "${1}" ./* || echo -e "\e[33mEs wurden keine Sucherergbnisse gefunden\e[39m"
    else
        grep -inrs --color=auto "${1}" "${2}" || echo -e "\e[33mEs wurden keine Sucherergbnisse gefunden\e[39m"
    fi
}

search_file(){
    [[ -z ${1} ]] && echo -e "\e[31mEs wurde kein Suchbegriff angegeben\e[39m" && return 1
    #Grep, um eine Fehlermeldung bei keinen Suchergebnissen anzeigen zu können und die Fundorte farbig zu markieren
    find . -iname "*${1}*" | grep -i "${1}" --color=always || echo -e "\e[33mEs wurden keine Sucherergbnisse gefunden\e[39m"
}

search_help(){
    echo -e "\e[96mFunktion\t\tBeschreibung\e[39m\n"
    echo -e "search_string\t\tSucht rekursiv nach einem gegebenen String im aktuellen Verzeichnis\n\t\t\t    oder in einem als zweites Argument übergebenen gegeben Verzeichnis"
    echo -e "search_file\t\tSucht rekursiv nach einer Datei mit dem gegebenen Namen im aktuellen Verzeichnis"
    [[ $(hostname) == "openhab" ]] && echo -e "search_log\t\tSucht nach einem gegebenen String in den Logs"
    echo -e "search_help\t\tZeigt diese Hilfe an"
}


repeat(){
    [[ -z ${2} ]] && sleeptime="1.0" || sleeptime=$(echo ${2} | sed 's/,/./')
    local counter=0
    while (true); do
        ((counter ++))

        heading="   $(date +%T)   |   Durchlauf: $counter   |   Alle $(echo $sleeptime | sed 's/\./,/')s   |   Kommando: ${1}   "
        [ "${#heading}" -gt "$(tput cols)" ] && heading="   $(date +%T)   |   Durchlauf: $counter   |   Alle $(echo $sleeptime | sed 's/\./,/')s   "
        echo -e "\n\e[96m\e[1m"; center "$heading"; echo -e "\e[0m"

        bash -c "${1}"
        read -t $sleeptime
    done
}
