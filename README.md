# Livre …

## Dépendances

Les outils suivants doivent être dans le path.

 - `git`
 - `make`
 - `latexmk`
 - `sed`
   - Modification de la version pour enlever l'identifiant du commit
 - `tail`
   - Récupération de la version précédente
 - `head`
 - `bash`
   - Certaine Fonctionnalité avancée de bash son utilisée dans `./Makefile`
 - `zip`
   - Lorsqu'un Makefile génère un fichier zip
 - `find`
 - `sort`
 - `latexdiff-vc`
   - Utilisé lors de la génération de diff
 - `rustc` and `cargo`
   - Certain outils sont écrit en rust
 - `date`

## Commande LaTeX utiles

### `\input` un fichier générer par make

Compile le fichier à la demande (si la compilation est lancer avec `latexmk -use-make`) et l'inclus.
La commande est fournie par le paquet `arsar` (`latex/arsar.sty`).

```latex
% utilisez 
\inputMake{filename}
% à la place de
\input{filename}
```

### Date et heure

Le paquet `datetime2` est chargé par `arsar`.
Les dates et heures suivantes sont disponible à travers les commandes
`\DTMuser`, `\DTMUsedate`, `\TDMusedate` et `\DTMusetime`.

 - **lastcommit**: Date et heure du dernier commit.
 - **git**: S'il n'y a pas de modification local, c'est égal à `lastcommit`
   sinon corresponds à la date et heure de modification du dernier fichier
   (sauf des fichiers lister dans les `.gitignore`).

### Journal de Modification

La command `\gitlog` affiche un tableau contenant la liste des commits git.
Si dans l'historique git des noms d'auteur ou leur adresse mails sont fausse,
elle peuvent être changée pour l'affichage en créant un fichier `.mailmap` à
la racine du dépôt git.

## Fonctionnalité

### Compilation d'un document racine

```sh
cd latex
make <document>.pdf
```

#### Recompilation automatique lorsque les fichiers sources changent

```sh
cd latex
make <document>.pdf.pvc
```

#### Compilation d'un chapitre uniquement

```sh
cd latex
make content/<chapter>.pdf
# ou pour recompiler automatiquement lorsque les sources changent
make content/<chapter>.pdf.pvc
```

### PDF affichant les différences

#### Entre une version ou un commit spécifique et le répertoire de travail

```sh
make diff/v0.0.1
make diff/HEAD
make diff/<hash>
```

#### Entre deux versions ou commits spécifiques

```sh
make diff/<first-ref>..<second-ref>
```
