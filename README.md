# Gestion données de consommation énergétique

## Principe

Ce script permet de trier et sélectionner des données au format csv (contenues dans le dossier *sources*) et de générer des graphiques à partir de celles-ci.

## Utilisation

- **Appel général du script**
```
./main.sh [OPTION] ...
```

- **Options**
    - Générer un histogramme de la production d'énergie selon le type (hydroélectrique, solaire, ...)
    ```
    ./main.sh --World-repartition                       (ou -W)
    ```
    - Générer .csv + graphique de l'évolution de la consommation annuelle d'énergie de 1990 à 2020 pour ```<nom_continent>```
    ```
    ./main.sh --Continent <nom_continent>               (ou -C)
    ```
    - Générer .csv + graphique de l'évolution de la consommation annuelle d'énergie de 1990 à 2020 pour ```<nom_pays>```
    ```
    ./main.sh --Country <nom_pays>                      (ou -c)
    ```
    - Générer .csv + graphique de l'évolution de la consommation annuelle d'énergie de 1990 à 2020 de deux pays (comparaison ```<pays_1> <pays_2>```)
    ```
    ./main.sh --Country --Compare <pays_1> <pays_2>     (ou -c --Compare)
    ```
    - Afficher le pays qui produit le plus d'énergie *renouvelable*
    ```
    ./main.sh --Country --max-renouv                    (ou -c --max-renouv)
    ```
    - Afficher le pays qui produit le plus d'énergie *non renouvelable*
    ```
    ./main.sh --Country --max-non-renouv                (ou -c --max-non-renouv)
    ```
    - Afficher l'aide
    ```
    ./main.sh --help                                    (ou -h)
    ```

- **Arborescence générée**

Dans la mesure où l'utilisateur se sert de l'ensemble des fonctions du script, il obtiendra une arborescence de fichiers de ce type :
```
Résultats/
    |__ Continents/
        |__ Continent_1
        |__ Continent_2
        |__ …
    |__ Countries/
        |__ Comparaison/
            |__ Pays1_Pays2
            |__ Pays3_Pays2
        |__ Pays_1
        |__ Pays_2
        |__ …
```

---

Louis Travaux | Edouard Calzado  
PRE-ING-2