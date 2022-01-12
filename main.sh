#!/bin/bash

# créer conso.csv avec années et data pays/continent
function get_conso()
{
    # ici $1:"Continents/Countries" | $2:nom du continent ou pays | $3:doc.csv
    # tant qu'il y a des en-tete :
    local i=1
    while [[ `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; do
        # si l'en-tete correspond a celui recherché :
        if [[ `head -1 sources/"$3" | cut -d',' -f"$i"` = "$2" ]]; then
            mkdir -p Resultats/"$1"/"$2"                                        # creer répertoire (+ parents)
            cut -d',' -f1,"$i" sources/"$3" > Resultats/"$1"/"$2"/conso.csv     # creer conso.csv et ajouter données
            create_graph "$1" "$2"                                              # créer graphique correspondant
            break                                                               # sortir while
        fi
        let "i++"                                                               # passer à entete suivant
    done
    # alerter si le pays/continent n'est pas dans csv
    if [[ ! `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; then
        echo "Pays/Continent non trouvé"
    fi
}

# créer conso.csv avec conso deux pays
function compare_conso()
{
    # ici $1:"Countries" | $2:nom du 1er pays | $3:nom du 2e pays | $4:doc.csv
    # tant qu'il y a des en-tete :
    local i=1
    while [[ `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; do
        # si l'en-tete correspond a un des deux recherchés :
        if [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$2" ]] || [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$3" ]]; then
            j=$i
            while [[ `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; do
                let "i++"
                if [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$2" ]] || [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$3" ]]; then
                    mkdir -p Resultats/"$1"/Comparaison/"$2"_"$3"                                               # creer répertoire (+ parents)
                    cut -d',' -f1,"$j","$i" sources/"$4" > Resultats/"$1"/Comparaison/"$2"_"$3"/conso.csv       # creer conso.csv et ajouter données
                    create_compare_graph "Countries" "$2" "$3"                                                  # créer graphique correspondant
                    break 2                                                                                     # sortir deux while
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

# créer graphique avec data d'un pays (conso.csv)
function create_graph()
{
    # ici $1:"Continents/Countries" | $2:nom du continent ou pays
    # parametres de gnuplot (config + plotting)
    gnuplot -e "reset;
    set autoscale fix;
    set terminal png;
    set output \"Resultats/$1/$2/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\";
    set ylabel \"Consommation énergétique (TWH)\";
    set title \"Consommantion annuelle de : $2\";
    plot \"Resultats/$1/$2/conso.csv\" u 1:2 w l title \"$2\""

    # Annoncer emplacement
    echo "Données (conso.csv) et graphique (conso.png) dans : [ Resultats/$1/$2 ]"
}

# créer graphique avec : courbe [pays 1] et [pays 2]
function create_compare_graph()
{
    # ici $1:"Countries" | $2:pays 1 | $3:pays 2
    # parametres de gnuplot (config + plotting)
    local new_dir="$2_$3"

    # ordre pays passés en paramètre : pas nécessairement ordre dans csv
    local fst_country=`head -1 Resultats/$1/Comparaison/"$new_dir"/conso.csv | cut -d',' -f2`
    local scd_country=`head -1 Resultats/$1/Comparaison/"$new_dir"/conso.csv | cut -d',' -f3`

    gnuplot -e "reset;
    set autoscale fix;
    set terminal png;
    set output \"Resultats/$1/Comparaison/$new_dir/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\";
    set ylabel \"Consommation énergétique (TWH)\";
    set title \"Comparaison conso annuelle $2 - $3\";
    plot \"Resultats/$1/Comparaison/$new_dir/conso.csv\" u 1:2 w l title \"$fst_country\", 
    \"Resultats/$1/Comparaison/$new_dir/conso.csv\" u 1:3 w l title \"$scd_country\"" # plot deux courbes --- A COMPLETER ---

    # Annoncer emplacement
    echo "Données (conso.csv) et graphique (conso.png) dans : [ Resultats/$1/Comparaison/$new_dir ]"
}

function afficher_aide()
{
    echo "Utilisation : ./main.sh [OPTION] ..."
    echo "  -C, --Continent   <nom_continent>           : créée 'conso.csv' + 'conso.png' (graph) correspondant au continent"
    echo "  -c, --Country     <nom_pays>                : créée 'conso.csv' + 'conso.png' (graph) correspondant au pays"
    echo "                  | Compare <pays_1> <pays_2> : créée 'conso.csv' + 'conso.png' (graph) comparant 'pays_1' et 'pays_2'"
    echo "                  | max_renouv                : retourne pays qui produit le plus d'énergie renouvelable"
    echo "                  | max_non_renouv            : retourne pays qui produit le plus d'énergie non renouvelable"
    echo ""
    echo "  -h, --help                                  : manuel d'utilisation"
    echo ""
    echo "2022 | Louis Travaux | Edouard Calzado"
}


if [[ "$1" = "--Continent" ]] || [[ "$1" = "-C" ]]; then 
    if [[ $2 ]]; then
        if [[ ! -d Resultats/Continents/"$2" ]]; then
            get_conso "Continents" "$2" "Continent_Consumption_TWH.csv"
        else
            echo "[ $2 ] : le dossier existe déjà, supprimez-le puis réessayez."
        fi
    else
        # si paramètre manquant
        echo "$1 : attend un paramètre."
        echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
    fi
elif [[ "$1" = "--Country" ]] || [[ "$1" = "-c" ]]; then
    if [[ $2 ]]; then
        case "$2" in
            "max_renouv")
                # pays qui produit le plus energie renouv
                sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f1
                ;;
            "max_non_renouv")
                # pays qui produit le plus energie NON renouv (plutot 'le moins energie renouv, mais accepté...')
                sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | tail -2 | head -1 | cut -d',' -f1
                ;;
            "Compare")
                if [[ $3 ]] && [[ $4 ]]; then
                    # verifier si dossier deja existant
                    if [[ ! -d Resultats/Countries/Comparaison/"$3"_"$4"/ ]];then
                        compare_conso "Countries" "$3" "$4" "Country_Consumption_TWH.csv"
                    else
                        echo "[ $3_$4 ] : le dossier existe déjà, supprimez-le puis réessayez."
                    fi
                else
                    # si paramètre manquant
                    echo "$2 : attend exactement deux paramètres (<pays_1> et <pays_2>)."
                    echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
                fi
                ;;
            *)
                if [[ ! -d Resultats/Countries/"$2" ]]; then
                    get_conso "Countries" "$2" "Country_Consumption_TWH.csv"
                fi
            ;;
        esac
    else
        # si paramètre manquant
        echo "$1 : attend au moins un paramètre."
        echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
    fi
elif [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then
    afficher_aide
else 
    # si paramètre incorrect (inconnu)
    echo "$1 : paramètre inconnu."
    echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
fi
