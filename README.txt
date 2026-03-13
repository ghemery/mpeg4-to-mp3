==============================================================================
  AUDIO EXTRACTOR - Convertisseur MP4 / M4A  →  MP3
  Application portable pour Windows 10 / 11
==============================================================================

CONTENU DU DOSSIER
------------------
  audio-extractor-portable/
  ├── audio-extractor.ps1   ← Script principal (interface graphique)
  ├── lancer.bat            ← Double-cliquez ici pour démarrer
  ├── ffmpeg.exe            ← À télécharger (voir ci-dessous)
  └── README.txt            ← Ce fichier

------------------------------------------------------------------------------
ÉTAPE 1 — TÉLÉCHARGER FFMPEG
------------------------------------------------------------------------------

1. Rendez-vous sur : https://www.gyan.dev/ffmpeg/builds/
2. Téléchargez la version "ffmpeg-release-essentials.zip"
   (ou "ffmpeg-git-full.7z" pour la version complète)
3. Décompressez l'archive
4. Dans le dossier décompressé, naviguez jusqu'à : bin\
5. Copiez le fichier  ffmpeg.exe  dans CE dossier
   (à côté de audio-extractor.ps1 et lancer.bat)

Exemple de chemin final :
  audio-extractor-portable\ffmpeg.exe  ✓

------------------------------------------------------------------------------
ÉTAPE 2 — LANCER L'APPLICATION
------------------------------------------------------------------------------

Méthode recommandée (la plus simple) :
  → Double-cliquez sur  lancer.bat

Méthode alternative (PowerShell manuel) :
  1. Clic droit sur audio-extractor.ps1
  2. Choisissez "Exécuter avec PowerShell"
  (Si un message de sécurité apparaît, cliquez sur "Ouvrir quand même")

NOTE : Aucune installation, aucun droit administrateur requis.

------------------------------------------------------------------------------
ÉTAPE 3 — CONVERTIR UN FICHIER
------------------------------------------------------------------------------

1. Cliquez sur le bouton  [Sélectionner...]
2. Dans la boîte de dialogue, choisissez votre fichier .mp4 ou .m4a
3. Le chemin du fichier s'affiche dans la zone de texte
4. Cliquez sur  [Convertir en MP3]
5. Attendez la fin de la conversion (quelques secondes)
6. Un message de succès apparaît → le fichier .mp3 est créé dans le même
   dossier que votre fichier source, avec le même nom

Exemple :
  C:\Videos\film.mp4  →  C:\Videos\film.mp3

------------------------------------------------------------------------------
DÉPANNAGE
------------------------------------------------------------------------------

Erreur "ffmpeg.exe introuvable"
  → Vérifiez que ffmpeg.exe est bien dans le même dossier que le script.

Erreur "La politique d'exécution ne permet pas..."
  → Utilisez lancer.bat au lieu de double-cliquer sur le .ps1

Erreur de conversion (code d'erreur FFmpeg)
  → Le fichier source est peut-être corrompu ou n'a pas de piste audio.
  → Vérifiez que l'extension correspond au format réel du fichier.

La fenêtre ne s'ouvre pas
  → Clic droit sur lancer.bat > Exécuter en tant qu'administrateur
  (uniquement si la méthode normale ne fonctionne pas)

------------------------------------------------------------------------------
AMÉLIORATIONS FUTURES (idées)
------------------------------------------------------------------------------

  - Glisser-déposer un fichier directement sur la fenêtre
  - Conversion par lot (sélection de plusieurs fichiers)
  - Choix du bitrate MP3 (128k, 192k, 320k)
  - Barre de progression pendant la conversion
  - Choix du dossier de destination

==============================================================================
