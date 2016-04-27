#!/bin/bash

if [ ! -z "$1" ]
then
    grep -rnw ../app ../../embedded -e "$1"
    res=$(grep -rnw ../app ../../embedded -e "$1" | wc -l) #outputs count
    shouldbe=0

    if [ $res = $shouldbe ]
    then
        locales=$PWD/*

        for f in $locales
        do
            if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]] || [[ $f == *"jsonoutput"* ]]
            then
                continue
            else
                echo "Searching in $f for $1..."

                oldsize=$(wc -c < "$f")

                node locale_search.js $f $1

                newsize=$(wc -c < "$f")

                if [[ $oldsize = $newsize ]]
                then
                    echo -e "Key not found or an error has occurred.\n"
                else
                    echo -e "Key deleted.\n"
                fi
            fi
        done
    else
        echo -e "\n"
        echo -e "Cannot delete $1, key in use. Check output above.\n"
    fi
else
    echo "No key specified. Switching to search & destroy mode."

    locales=$PWD/*

    for f in $locales
    do
        if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]] || [[ $f == *"jsonoutput"* ]]
        then
            continue
        else
            echo "Searching in $f..."

            node ./locale_search.js $f

            IFS=$',' GLOBIGNORE='*' command eval  'keys=($(cat ./jsonoutput.txt))'

            for i in "${keys[@]}"
            do
                :
                if [[ $i == *"member_type"* ]] || [[ $i == *"errors."* ]] || [[ $i == *"preferences.groups.title"* ]] || [[ $i == *"preferences.locale.title"* ]] || [[ $i == *"preferences.title"* ]] || [[ $i == *"communities.friends.title"* ]] || [[ $i == *"preferences.channellist.title"* ]]
                then
                    continue
                else
                    grep -rnw ../app ../../embedded -e "$i"
                    res=$(grep -rnw ../app ../../embedded -e "$i" | wc -l) #outputs count
                    shouldbe=0
                    if [ $res = $shouldbe ]
                    then
                        locales=$PWD/*
                        for f in $locales
                        do
                            if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]] || [[ $f == *"jsonoutput"* ]]
                            then
                                continue
                            else
                                echo "Searching in $f for $i..."

                                oldsize=$(wc -c < "$f")

                                node locale_search.js $f $i

                                newsize=$(wc -c < "$f")

                                if [[ $oldsize = $newsize ]]
                                then
                                    echo -e "Key not found or an error has occurred.\n"
                                else
                                    echo -e "Key deleted.\n"
                                fi
                            fi
                        done
                    else
                        echo -e "\n"
                        echo -e "Cannot delete $i, key in use. Check output above.\n"
                    fi
                fi
            done

            rm ./jsonoutput.txt
        fi
    done
fi
