#!/bin/bash

function get_conso()
{
    local i=1
    # ici $1:"Continents/Countries" | $2:nom du continent | $3:doc.csv
    # tant qu'il y a des en-tete :
    while [[ `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; do
        # si l'en-tete correspond a celui recherché :
        if [[ `head -1 sources/"$3" | cut -d',' -f"$i"` = "$2" ]]; then
            mkdir -p Resultats/"$1"/"$2"                                        # creer répertoire (+ parents)
            cut -d',' -f1 -f"$i" sources/"$3" > Resultats/"$1"/"$2"/conso.csv   # creer conso.csv et ajouter données
            break                                                               # sortir while
        fi
        let "i++"                                                               # passer à entete suivant
    done
    # alerter si le pays/continent n'est pas dans csv
    if [[ ! `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; then
        echo "Pays/Continent non trouvé"
    fi
}

function create_graph()
{
    # ici $1:"Continent/Country" | $2:nom du continent
    gnuplot -e "reset;
    set autoscale fix;
    set terminal png;
    set output \"Resultats/$1/$2/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\"; set ylabel \"Consommation énergétique\";
    set title \"Consommantion annuelle de : $2\";
    plot \"Resultats/$1/$2/conso.csv\" u 1:2 w l notitle"
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
    if [[ "$1" = "Continent" ]] && [[ ! -d Resultats/Continents/"$2" ]]; then
        get_conso "Continents" "$2" "Continent_Consumption_TWH.csv"
        create_graph "Continents" "$2"
    elif [[ "$1" = "Country" ]]; then
        case "$2" in
            "max_renouv")
                sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f1
                ;;
            "max_non_renouv")
                echo "max_non_renouv indisponible"
                ;;
            *)
                if [[ ! -d Resultats/Countries/"$2" ]]; then
                    get_conso "Countries" "$2" "Country_Consumption_TWH.csv"
                    create_graph "Countries" "$2"
                fi
            ;;
        esac
    fi
fi


