grep -rnw '../app' -e "$1"
res=$(grep -rnw '../app' -e "$1" | wc -l) #outputs count
shouldbe=0

if [ $res = $shouldbe ]
then
    locales=$PWD/*
    for f in $locales
    do
        if [[ $f == *"emoji"* ]] || [[ $f == *"locale_"* ]]
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
   echo "Cannot delete $1, key in use. Check output above."
fi
