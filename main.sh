#!/bin/bash

function get_conso()
{
    local i=1
    # ici $1:doc.csv | $2:nom du continent
    # tant qu'il y a des en-tete : 
    while [ `head -1 sources/$1 | cut -d',' -f$i` ]; do                 # gérer si commande retourne erreur
        # si l'en-tete correspond a celui recherché :
        if [ `head -1 sources/"$1" | cut -d',' -f$i` = "$2" ]; then
            mkdir -p Resultats/Continents/"$2"
            cut -d',' -f1 -f$i sources/"$1" > Resultats/Continents/"$2"/conso.csv
            break
        fi
        let "i++"
    done
}

# Pays qui produit le plus d'énergie renouvelable
if [ "$1" = "pays" ]; then 
    if [ "$2" = "max_renouv" ]; then
        sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f1
    else
        if [ "$2" = "max_non_renouv"]; then
            # Pays qui produit le plus d'énergie NON-renouvelable
            echo 0
        fi
    fi
else
    if [ "$1" = "continent" ]; then
        get_conso "Continent_Consumption_TWH.csv" $2
    fi
fi


