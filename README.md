# Audio Extractor — Convertisseur MP4 / M4A vers MP3

> Application portable pour Windows 10 / 11 — aucune installation, aucun droit administrateur requis.

---

## A quoi ca sert ?

**Audio Extractor** extrait la piste audio d'une video MP4 ou convertit un fichier M4A en fichier MP3 universel.

**Cas d'usage typiques :**

- Vous avez une conference, un cours ou une interview en video `.mp4` et vous voulez juste l'audio pour l'ecouter sur votre telephone
- Vous avez des fichiers `.m4a` (format Apple) et vous voulez des `.mp3` compatibles partout
- Vous voulez alleger vos fichiers en ne gardant que la piste audio

L'outil est **100 % portable** : il fonctionne depuis un dossier local, un disque reseau ou une cle USB, sans rien installer sur le poste.

---

## Comment ca marche ?

Sous le capot, Audio Extractor utilise **FFmpeg**, un moteur de conversion audio/video professionnel et open source.

La commande executee en coulisse :

```
ffmpeg -i "votre_fichier.mp4" -q:a 0 -map a "votre_fichier.mp3"
```

| Parametre | Role |
|-----------|------|
| `-q:a 0`  | Qualite audio maximale (VBR — Variable Bit Rate) |
| `-map a`  | Extrait uniquement la piste audio, ignore la video |

Le MP3 obtenu est compatible avec tous les lecteurs : telephone, voiture, VLC, Spotify, Windows Media Player...

---

## Contenu du dossier

```
audio-extractor-portable/
|
+-- lancer.vbs                    <- Demarrer l'application (sans fenetre noire)
+-- lancer.bat                    <- Alternative si lancer.vbs est bloque
+-- audio-extractor.ps1           <- Script principal (interface graphique)
+-- ffmpeg-xxxx-essentials/       <- Dossier FFmpeg (a telecharger, voir ci-dessous)
|     bin/
|       ffmpeg.exe
+-- README.md                     <- Ce fichier
```

---

## Installation

### Etape 1 — Telecharger FFmpeg *(a faire une seule fois)*

FFmpeg n'est pas inclus dans ce depot pour des raisons de taille.

1. Rendez-vous sur **https://www.gyan.dev/ffmpeg/builds/**
2. Telechargez **`ffmpeg-release-essentials.zip`**
   *(la version "essentials" est suffisante, inutile de prendre "full")*
3. Decompressez le zip **directement dans le dossier `audio-extractor-portable/`**
4. C'est tout — le script trouve `ffmpeg.exe` automatiquement

**Structure attendue apres decompression :**

```
audio-extractor-portable/
  ffmpeg-2025-xx-xx-essentials_build/
    bin/
      ffmpeg.exe   <- le script le trouve tout seul
```

### Etape 2 — Lancer l'application

| Methode | Fichier | Remarque |
|---------|---------|----------|
| **Recommandee** | `lancer.vbs` | Aucune fenetre noire en arriere-plan |
| Alternative | `lancer.bat` | A utiliser si `.vbs` est bloque par votre entreprise |

> **Note :** Au premier lancement sur un nouveau poste, Windows peut afficher un avertissement de securite. C'est normal — le script `Unblock-File` debloque automatiquement `ffmpeg.exe`.

---

## Utilisation

### Interface

```
+----------------------------------------------------------+
|  Selectionnez un ou plusieurs fichiers MP4/M4A :         |
|  [ chemin/du/fichier.mp4_________________ ] [Selectionner]|
|                                                          |
|  Dossier de destination :                                |
|  [ C:\Users\...\Musique__________________ ] [Parcourir...] |
|                                                          |
|  [              Convertir en MP3                       ] |
|  -------------------------------------------------------- |
|  Pret                                                    |
+----------------------------------------------------------+
```

---

### Conversion simple (1 fichier)

1. Cliquez sur **[Selectionner...]**
2. Choisissez votre fichier `.mp4` ou `.m4a`
3. Le dossier de destination se remplit automatiquement *(modifiable avec [Parcourir...]*
4. Cliquez sur **[Convertir en MP3]**
5. Une fenetre de succes s'affiche a la fin

```
C:\Videos\reunion.mp4  ->  C:\Videos\reunion.mp3
```

---

### Conversion par lot (plusieurs fichiers)

1. Cliquez sur **[Selectionner...]**
2. Dans la boite de dialogue :
   - **Ctrl + clic** pour selectionner plusieurs fichiers un par un
   - **Shift + clic** pour selectionner une plage de fichiers
3. La zone de texte affiche `"3 fichiers selectionnes"`
4. Choisissez eventuellement un dossier de destination avec **[Parcourir...]**
5. Cliquez sur **[Convertir en MP3]**
6. Le statut se met a jour en temps reel : `Conversion 2/3 : fichier.mp4`
7. Un recapitulatif s'affiche a la fin

---

### Choisir un dossier de destination

Par defaut, le `.mp3` est cree dans le meme dossier que le fichier source.

Cliquez sur **[Parcourir...]** pour enregistrer ailleurs :
un dossier de musique, un disque reseau, une cle USB...

---

## Depannage

| Probleme | Solution |
|----------|----------|
| L'application ne s'ouvre pas | Essayez `lancer.bat` a la place de `lancer.vbs` |
| Erreur "ffmpeg.exe introuvable" | Verifiez que le dossier FFmpeg est bien dans `audio-extractor-portable/` et contient `bin/ffmpeg.exe` |
| Erreur de conversion (code FFmpeg) | Le fichier source est peut-etre corrompu ou sans piste audio |
| Bloque par l'antivirus | Ajoutez le dossier en exception ; `Unblock-File` est execute automatiquement au demarrage |
| Fenetre CMD visible en arriere-plan | Utilisez `lancer.vbs` au lieu de `lancer.bat` |

---

## Informations techniques

| Element | Detail |
|---------|--------|
| Langage | PowerShell 5.1 |
| Interface | Windows Forms (integre a Windows, aucune dependance) |
| Moteur audio | [FFmpeg](https://ffmpeg.org) |
| Compatibilite | Windows 10 / 11 |
| Droits requis | Aucun (utilisateur standard) |
| Connexion | Non requise — fonctionne entierement hors ligne |
