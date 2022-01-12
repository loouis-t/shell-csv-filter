#!/bin/bash

function get_conso()
{
    # ici $1:"Continents/Countries" | $2:nom du continent | $3:doc.csv
    # tant qu'il y a des en-tete :
    local i=1
    while [[ `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; do
        # si l'en-tete correspond a celui recherché :
        if [[ `head -1 sources/"$3" | cut -d',' -f"$i"` = "$2" ]]; then
            mkdir -p Resultats/"$1"/"$2"                                        # creer répertoire (+ parents)
            cut -d',' -f1,"$i" sources/"$3" > Resultats/"$1"/"$2"/conso.csv   # creer conso.csv et ajouter données
            break                                                               # sortir while
        fi
        let "i++"                                                               # passer à entete suivant
    done
    # alerter si le pays/continent n'est pas dans csv
    if [[ ! `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; then
        echo "Pays/Continent non trouvé"
    fi
}

function compare_conso()
{
    # ici $1:"Countries" | $2:nom du 1er pays | $3:nom du 2e pays | $4:doc.csv
    # tant qu'il y a des en-tete :
    local i=1
    while [[ `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; do
        # si l'en-tete correspond a celui recherché :
        if [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$2" ]] || [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$3" ]]; then
            j=$i
            while [[ `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; do
                let "i++"
                if [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$2" ]] || [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$3" ]]; then
                    mkdir -p Resultats/"$1"/Comparaison/"$2"_"$3"                                               # creer répertoire (+ parents)
                    cut -d',' -f1,"$j","$i" sources/"$4" > Resultats/"$1"/Comparaison/"$2"_"$3"/conso.csv       # creer conso.csv et ajouter données
                    break 2                                                                                     # sortir while
                fi
            done
        fi
        let "i++"                                                               # passer à entete suivant
    done
    # alerter si le pays/continent n'est pas dans csv
    if [[ ! `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; then
        echo "Pays/Continent non trouvé"
    fi
}

function create_graph()
{
    # ici $1:"Continent/Country" | $2:nom du continent
    # parametres de gnuplot (config + plotting)
    gnuplot -e "reset;
    set autoscale fix;
    set terminal png;
    set output \"Resultats/$1/$2/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\";
    set ylabel \"Consommation énergétique (TWH)\";
    set title \"Consommantion annuelle de : $2\";
    plot \"Resultats/$1/$2/conso.csv\" u 1:2 w l notitle"
}

function create_compare_graph()
{
    # ici $1:"Continent/Country" | $2:nom du continent
    # parametres de gnuplot (config + plotting)
    gnuplot -e "reset;
    set autoscale fix;
    set terminal png;
    set output \"Resultats/$1/Compare/"$2"_"$3"/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\";
    set ylabel \"Consommation énergétique (TWH)\";
    set title \"Consommantion annuelle de : $2\";
    plot \"Resultats/$1/Compare/"$2"_"$3"/conso.csv\" u 1:3 w l notitle" # plot deux courbes --- A COMPLETER ---
}


if [[ "$1" = "Continent" ]] && [[ ! -d Resultats/Continents/"$2" ]]; then
    get_conso "Continents" "$2" "Continent_Consumption_TWH.csv"
    create_graph "Continents" "$2"
elif [[ "$1" = "Country" ]]; then
    case "$2" in
        "max_renouv")
            sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f1
            ;;
        "max_non_renouv")
            sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | tail -2 | head -1 | cut -d',' -f1
            ;;
        "Compare")
            if [[ $3 ]] && [[ $4 ]]; then
                compare_conso "Countries" "$3" "$4" "Country_Consumption_TWH.csv"
                create_graph "Countries" "$3" "$4"
            fi
            ;;
        *)
            if [[ ! -d Resultats/Countries/"$2" ]]; then
                get_conso "Countries" "$2" "Country_Consumption_TWH.csv"
                create_graph "Countries" "$2"
            fi
        ;;
    esac
fi
