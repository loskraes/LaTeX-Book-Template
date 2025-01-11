# Livre …

## Dépendances

 - `git`
 - `make`
 - `latexmk`
 - `sed`
   - Modification de la version pour enlever l'identifiant du commit
 - `tail`
   - Récupération de la version précédente
 - `bash`
   - Certaine Fonctionnalité avancée de bash son utilisée dans `./Makefile`
 - `zip`
   - Lorsqu'un Makefile génère un fichier zip
 - `find`
 - `latexdiff-vc`
   - Utilisé lors de la génération de diff

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
