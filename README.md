# Livre …


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
