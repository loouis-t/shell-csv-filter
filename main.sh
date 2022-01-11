#!/bin/bash

function get_conso()
{
    local i=1
    # ici $1:"Continent/Country" | $2:nom du continent | $3:doc.csv
    # tant qu'il y a des en-tete :
    while [[ `head -1 sources/$3 | cut -d',' -f$i` ]]; do
        # si l'en-tete correspond a celui recherché :
        if [[ `head -1 sources/$3 | cut -d',' -f$i` = "$2" ]]; then
            mkdir -p Resultats/$1/"$2"
            cut -d',' -f1 -f$i sources/$3 > Resultats/$1/$2/conso.csv
            break   # sortir while
        fi
        let "i++"   # passer à entete suivant
    done
}

function create_graph()
{
    echo "Graph non disponible"
}


# Pays qui produit le plus d'énergie renouvelable
if [[ "$1" = "pays" ]]; then 
    if [[ "$2" = "max_renouv" ]]; then
        sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f1
    else
        if [[ "$2" = "max_non_renouv" ]]; then
            # Pays qui produit le plus d'énergie NON-renouvelable
            echo 0
        fi
    fi
else
    if [[ "$1" = "Continent" ]] && [[ ! -d Resultats/Continents/$2 ]]; then
        get_conso "Continent" $2 "Continent_Consumption_TWH.csv"
        create_graph
    elif [[ "$1" = "Country" ]] && [[ ! -d Resultats/Countries/$2 ]]; then
        get_conso "Countries" $2 "Country_Consumption_TWH.csv"
        create_graph
    fi
fi


