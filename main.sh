#!/bin/bash

# créer conso.csv avec années et data pays/continent
# ici $1:"Continents/Countries" | $2:nom du continent ou pays | $3:doc.csv
function get_conso()
{
    local i=1
    while [[ `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; do                   # tant qu'il y a des en-tete
        if [[ `head -1 sources/"$3" | cut -d',' -f"$i"` = "$2" ]]; then         # si l'en-tete correspond a celui recherché
            mkdir -p Resultats/"$1"/"$2"                                        # creer répertoire (+ parents)
            cut -d',' -f1,"$i" sources/"$3" > Resultats/"$1"/"$2"/conso.csv     # creer conso.csv et ajouter données
            create_graph "$1" "$2"                                              # créer graphique correspondant
            break                                                               # sortir while
        fi
        let "i++"                                                               # passer à entete suivant
    done

    if [[ ! `head -1 sources/"$3" | cut -d',' -f"$i"` ]]; then                  # alerter si le pays/continent n'est pas dans csv
        echo "Pays/Continent non trouvé"
    fi
}

# créer conso.csv avec conso deux pays
# ici $1:"Countries" | $2:nom du 1er pays | $3:nom du 2e pays | $4:doc.csv
function compare_conso()
{
    local i=1
    while [[ `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; do                                                                       # tant qu'il y a des en-tete
        if [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$2" ]] || [[ `head -1 sources/"$4" | cut -d',' -f"$i"` = "$3" ]]; then   # si l'en-tete correspond a un des deux recherchés
            j=$i                                                                                                # stocker (retenir) current $i
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
        let "i++"                                                                                               # passer à entete suivant
    done

    if [[ ! `head -1 sources/"$4" | cut -d',' -f"$i"` ]]; then                                                  # alerter si le pays/continent n'est pas dans csv
        echo "Pays/Continent non trouvé"
    fi
}

# créer graphique avec data d'un pays (conso.csv)
# ici $1:"Continents/Countries" | $2:nom du continent ou pays
function create_graph()
{
    # parametres de gnuplot (config + plotting)
    gnuplot -e "reset;
    set terminal png;
    set output \"Resultats/$1/$2/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\";
    set ylabel \"Consommation énergétique (TWH)\";
    set title \"Consommantion annuelle de : $2\";
    set style line 1 lw 2 lt 2 pi -1;
    set pointintervalbox 2;
    plot \"Resultats/$1/$2/conso.csv\" u 1:2 w linespoint ls 1 title \"$2\""
    # ls : line style | lt : couleur | lw : line width | pi : cercle autour des points (espace pt-courbe)

    echo "Données (conso.csv) et graphique (conso.png) dans : [ Resultats/$1/$2 ]"  # Annoncer emplacement
}

# créer graphique avec : courbe [pays 1] et [pays 2]
# ici $1:"Countries" | $2:pays 1 | $3:pays 2
function create_compare_graph()
{
    local new_dir="$2_$3"   # nom nouveau dossier (pays1_pays2)

    # ordre pays passés en paramètre : pas nécessairement ordre dans csv
    local fst_country=`head -1 Resultats/$1/Comparaison/"$new_dir"/conso.csv | cut -d',' -f2`
    local scd_country=`head -1 Resultats/$1/Comparaison/"$new_dir"/conso.csv | cut -d',' -f3`

    # parametres de gnuplot (config + plotting)
    gnuplot -e "reset;
    set terminal png;
    set output \"Resultats/$1/Comparaison/$new_dir/conso.png\";
    set datafile separator \",\";
    set xlabel \"Année\";
    set ylabel \"Consommation énergétique (TWH)\";
    set title \"Comparaison conso annuelle $2 - $3\";
    set style data linespoints;
    set style line 1 lw 2 lt 1 pt 1 pi -1;
    set style line 2 lw 2 lt 2 pt 4 pi -1;
    set pointintervalbox 2;
    plot \"Resultats/$1/Comparaison/$new_dir/conso.csv\" u 1:2 ls 1 title \"$fst_country\",
    \"Resultats/$1/Comparaison/$new_dir/conso.csv\" u 1:3 ls 2 title \"$scd_country\""
    # ls : line style | lt : couleur | lw : line width | pi : cercle autour des points (espace pt-courbe)

    echo "Données (conso.csv) et graphique (conso.png) dans : [ Resultats/$1/Comparaison/$new_dir ]"    # Annoncer emplacement
}

# repartition production énergie selon type ([--World-repartition] / [-W])
function world_repartition_graph()
{
    gnuplot -e "reset;
    set terminal png;
    set output \"Resultats/World_repartition/conso.png\";
    set datafile separator \",\";
    set xlabel \"Type d'énergie\";
    set ylabel \"Production (TWH)\";
    set title \"Production d'énergie renouvelable par type d'énergie\";
    set xtics nomirror rotate by -45 scale 0;
    set style data histogram;
    set style fill solid border -1;
    set style histogram clustered gap 1;
    set boxwidth 1;
    plot \"<(head -8 sources/nonRenewablesTotalPowerGeneration.csv | tail -7)\" u 2:xtic(1) lt 2 notitle"   # head -8 ... --> récupérer uniquement lignes intéressantes (pas les entete et les totaux)
    # ls : line style | lt : couleur | lw : line width | pi : cercle autour des points (espace pt-courbe)

    echo "Graphique (conso.png) dans : [ Resultats/World_repartition ]"                                     # Annoncer emplacement
}

# afficher aide [-h] / [--help]
function afficher_aide()
{
    echo "Utilisation : ./main.sh [OPTION] ..."
    echo ""
    echo "  -W, --World-repartition                             : graph production énergie renouv. par type d'énergie"
    echo "  -C, --Continent         <nom_continent>             : créer csv + graph pour <nom_continent>"
    echo "  -c, --Country           <nom_pays>                  : créer csv + graph pour <nom_pays>"
    echo "                        | --Compare <pays_1> <pays_2> : créer csv + graph comparant <pays_1> <pays_2>"
    echo "                        | --max-renouv                : retourner pays qui produit le plus d'énergie renouvelable"
    echo "                        | --max-non-renouv            : retourner pays qui produit le plus d'énergie non renouvelable"
    echo "  -h, --help                                          : afficher manuel d'utilisation"
    echo ""
    echo ""
    echo "2022 | Louis Travaux | Edouard Calzado"
}


if [[ "$1" = "--Continent" ]] || [[ "$1" = "-C" ]]; then                            # si Continent
    if [[ $2 ]]; then                                                               # si le continent est précisé
        if [[ ! -d Resultats/Continents/"$2" ]]; then                               # si dossier n'existe pas
            get_conso "Continents" "$2" "Continent_Consumption_TWH.csv"
        else                                                                        # sinon, si le dossier existe déjà (on ne fait rien)
            echo "[ $2 ] : le dossier existe déjà, supprimez-le puis réessayez."
        fi
    else                                                                            # si le continent n'est pas précisé
        echo "$1 : attend un paramètre."
        echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
    fi
elif [[ "$1" = "--Country" ]] || [[ "$1" = "-c" ]]; then                            # si Pays
    if [[ $2 ]]; then                                                               # s'il y a un deuxième paramètre
        case "$2" in
            "--max-renouv")
                # pays qui produit le plus energie renouv
                pays=`sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f1`
                conso=`sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | head -1 | cut -d',' -f6`
                result=`echo "$pays : $conso" | tr -d '\r'`                         # necessaire pour pas réécrire 'TWh' par dessus 'China'
                echo "$result TWh"
                ;;
            "--max-non-renouv")
                # pays qui produit le plus energie NON renouv (plutot 'le moins energie renouv, mais accepté...')
                pays=`sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | tail -2 | head -1 | cut -d',' -f1`
                conso=`sort -t',' -k6rn sources/top20CountriesPowerGeneration.csv | tail -2 | head -1 | cut -d',' -f6`
                result=`echo "$pays : $conso" | tr -d '\r'`                         # necessaire pour pas réécrire 'TWh' par dessus 'China'
                echo "$result TWh"
                ;;
            "--Compare")
                # comparer deux Pays
                if [[ $3 ]] && [[ $4 ]]; then                                       # si les deux Pays a comparer sont bien précisés
                    if [[ ! -d Resultats/Countries/Comparaison/"$3"_"$4"/ ]] && [[ ! -d Resultats/Countries/Comparaison/"$4"_"$3"/ ]];then   # si dossier n'existe pas (tenir compte ordre)
                        compare_conso "Countries" "$3" "$4" "Country_Consumption_TWH.csv"
                    else                                                            # sinon, si dossier existe déjà
                        echo "[ $3_$4 ] : le dossier existe déjà, supprimez-le puis réessayez."
                    fi
                else                                                                # si un Pays (ou les deux) n'est (ne sont) pas précisé(s)
                    echo "$2 : attend exactement deux paramètres (<pays_1> et <pays_2>)."
                    echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
                fi
                ;;
            *)                                                                      # sinon, obtenir data + grapher le pays précisé (existance pays vérifiée plus tard)
                if [[ ! -d Resultats/Countries/"$2" ]]; then                        # si le répertoire n'existe pas
                    get_conso "Countries" "$2" "Country_Consumption_TWH.csv"
                else                                                                # sinon, si le dossier existe déjà (on ne fait rien)
                    echo "[ $2 ] : le dossier existe déjà, supprimez-le puis réessayez."
                fi
            ;;
        esac
    else
        # si paramètre manquant
        echo "$1 : attend au moins un paramètre."
        echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
    fi
elif [[ "$1" = "--World-repartition" ]] || [[ "$1" = "-W" ]]; then                  # afficher graphique de répartition des production d'energie (selon type)
    if [[ ! -d Resultats/World_repartition ]]; then                                 # si dossier n'existe pas on le créée
        mkdir -p Resultats/World_repartition
        world_repartition_graph
    else                                                                            # sinon, si le dossier existe déjà
        echo "[ World_repartition ] : le dossier existe déjà, supprimez-le puis réessayez."
    fi
elif [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then                               # [-h] / [--help] afficher l'aide
    afficher_aide
elif [[ ! $1 ]]; then                                                               # si aucun parametre
    echo ""
    echo "      - - - - - - - - - - - - -"
    echo "       P R O J E T  S H E L L"
    echo "       v1.0           01-2022"                                            # (faut bien s'amuser)
    echo "      - - - - - - - - - - - - -"
    echo ""
    echo "2022 | Louis Travaux | Edouard Calzado"
    echo ""
    echo ""
    echo "Précisez un paramètre pour utiliser ce script."
    echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
else                                                                                # si paramètre incorrect (inconnu)
    echo "$1 : paramètre inconnu."
    echo "Tapez [ ./main.sh -h ] ou [ ./main.sh --help ] pour plus d'informations."
fi
