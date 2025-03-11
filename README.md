# Interpréteur d'Expressions Ensemblistes  

Ce projet a été réalisé uniquement par **BONHOMME Matthew** dans le cadre du **projet final en Automates et Théorie des Langages** en **L3 Informatique**.  

Il s'agit d'un interpréteur permettant d'analyser et d'exécuter des expressions ensemblistes en utilisant **Flex** pour l'analyse lexicale et **Bison** pour l'analyse syntaxique et sémantique. L'interpréteur prend en charge plusieurs opérations sur les ensembles, notamment **l'union, l'intersection, le complémentaire, la cardinalité et la différence**.  

## Compilation et Exécution  

Le fichier **Makefile** fourni dans ce projet, à été modifié par rapport à celui de base. **Il est recommander d'utiliser ce Makefile** pour éviter toute erreur et garantir le bon fonctionnement du programme.  

### Compilation  

Pour compiler l'interpréteur, exécutez la commande suivante dans le terminal :  

```bash
make Analyseur
```
Une fois la compilation terminée, l'interpréteur peut être exécuté avec un fichier de test en utilisant :
```bash
./Analyseur < VotreFichierTest.data
```
Cela analysera et exécutera les expressions contenues dans le fichier et affichera les résultats ou les éventuelles erreurs détectées.
