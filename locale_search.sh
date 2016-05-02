#!/bin/bash

paths="../app ../../embedded"

bold=$(tput bold)
normal=$(tput sgr0)

if [ ! -z "$1" ]
then
    grep -rnw $paths -e "$1"
    res=$(grep -rnw $paths -e "$1" | wc -l) #outputs count
    shouldbe=0

    if [ $res == $shouldbe ]
    then
        locales=$PWD/*

        for f in $locales
        do
            if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]] || [[ $f == *"jsonoutput"* ]]
            then
                continue
            else
                echo -e "\033[33mSearching in ${bold}$f ${normal}for ${bold}$1${normal}...\n"

                oldsize=$(wc -c < "$f")

                node locale_search.js $f $1

                newsize=$(wc -c < "$f")

                if [[ $oldsize == $newsize ]]
                then
                    echo -e "\033[31mKey not found or an error has occurred.\n"
                else
                    echo -e "\033[32mKey deleted.\n"
                fi
            fi
        done
    else
        echo -e "\n"
        echo -e "\033[35mCannot delete ${bold}$1${normal} \033[35munder ${bold}$f${normal}\033[35m, key in use. Check output above.\033[0m\n"

        sleep 0.5
    fi
else
    echo -e "\033[36mNo key specified. Switching to search & destroy mode in 3 seconds.\n"

    sleep 3

    locales=$PWD/*

    for f in $locales
    do
        if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]] || [[ $f == *"jsonoutput"* ]]
        then
            continue
        else
            echo -e "\033[33mSearching in ${bold}$f${normal}...\n"

            node ./locale_search.js $f

            IFS=$',' GLOBIGNORE='*' command eval  'keys=($(cat ./jsonoutput.txt))'

            for i in "${keys[@]}"
            do
                :
                if [[ $i == *"member_type"* ]] || [[ $i == *"errors."* ]] || [[ $i == *"preferences.groups.title"* ]] || [[ $i == *"preferences.locale.title"* ]] || [[ $i == *"preferences.title"* ]] || [[ $i == *"communities.friends.title"* ]] || [[ $i == *"preferences.channellist.title"* ]]
                then
                    continue
                else
                    grep -rnw $paths -e "$i"
                    res=$(grep -rnw $paths -e "$i" | wc -l) #outputs count
                    shouldbe=0

                    if [ $res == $shouldbe ]
                    then
                        locales=$PWD/*

                        for f in $locales
                        do
                            if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]] || [[ $f == *"jsonoutput"* ]]
                            then
                                continue
                            else
                                echo -e "\033[33mSearching in ${bold}$f${normal} for ${bold}$i${normal}...\n"

                                oldsize=$(wc -c < "$f")

                                node locale_search.js $f $i

                                newsize=$(wc -c < "$f")

                                if [[ $oldsize == $newsize ]]
                                then
                                    echo -e "\033[31mKey not found or an error has occurred.\n"
                                else
                                    echo -e "\033[32mKey deleted.\n"
                                fi
                            fi
                        done
                    else
                        echo -e "\n"
                        echo -e "\033[35mCannot delete ${bold}$i${normal} \033[35munder ${bold}$f${normal}\033[35m, key in use. Check output above. Moving to next key.\033[0m\n"
                    fi
                fi
            done

            rm ./jsonoutput.txt

            unset IFS
        fi
    done
fi
