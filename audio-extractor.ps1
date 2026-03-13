#Requires -Version 5.1
# =============================================================================
# Audio Extractor - Convertisseur MP4/M4A vers MP3
# Version : 1.0
# Usage   : Lancez ce script via lancer.bat
# =============================================================================

# Chargement des assemblies pour l'interface graphique Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -----------------------------------------------------------------------------
# Recherche de ffmpeg.exe : d'abord a la racine, puis dans les sous-dossiers
# (compatible avec les archives extraites ex: ffmpeg-2026-xx-xx-essentials/bin/)
# -----------------------------------------------------------------------------
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ffmpegPath = Join-Path $scriptDir "ffmpeg.exe"

if (-not (Test-Path $ffmpegPath)) {
    $found = Get-ChildItem -Path $scriptDir -Filter "ffmpeg.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue |
             Select-Object -First 1
    if ($found) {
        $ffmpegPath = $found.FullName
    }
}

# Supprimer le Mark of the Web (fichier telecharge depuis internet) pour
# eviter le blocage SmartScreen lors de l'execution de ffmpeg.exe
Unblock-File -Path $ffmpegPath -ErrorAction SilentlyContinue

if (-not (Test-Path $ffmpegPath)) {
    [System.Windows.Forms.MessageBox]::Show(
        "ffmpeg.exe introuvable !`n`nDecompressez l'archive FFmpeg dans ce dossier :`n$scriptDir`n`nConsultez le README.txt pour savoir comment obtenir FFmpeg.",
        "Erreur - FFmpeg manquant",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

# -----------------------------------------------------------------------------
# Creation de la fenetre principale
# -----------------------------------------------------------------------------
$form                  = New-Object System.Windows.Forms.Form
$form.Text             = "Audio Extractor (MP4 -> MP3)"
$form.Size             = New-Object System.Drawing.Size(520, 285)
$form.StartPosition    = "CenterScreen"
$form.FormBorderStyle  = "FixedSingle"
$form.MaximizeBox      = $false
$form.Font             = New-Object System.Drawing.Font("Segoe UI", 9)

# -----------------------------------------------------------------------------
# Label d'instruction
# -----------------------------------------------------------------------------
$labelInstruction          = New-Object System.Windows.Forms.Label
$labelInstruction.Text     = "Selectionnez un ou plusieurs fichiers MP4/M4A (Ctrl+clic pour multi-selection) :"
$labelInstruction.Location = New-Object System.Drawing.Point(12, 15)
$labelInstruction.Size     = New-Object System.Drawing.Size(490, 20)
$form.Controls.Add($labelInstruction)

# -----------------------------------------------------------------------------
# TextBox affichant le chemin du fichier selectionne
# -----------------------------------------------------------------------------
$textBoxFile           = New-Object System.Windows.Forms.TextBox
$textBoxFile.Location  = New-Object System.Drawing.Point(12, 40)
$textBoxFile.Size      = New-Object System.Drawing.Size(370, 24)
$textBoxFile.ReadOnly  = $true
$textBoxFile.Text      = "(aucun fichier selectionne)"
$textBoxFile.BackColor = [System.Drawing.Color]::WhiteSmoke
$form.Controls.Add($textBoxFile)

# -----------------------------------------------------------------------------
# Bouton "Selectionner un fichier"
# -----------------------------------------------------------------------------
$buttonSelect          = New-Object System.Windows.Forms.Button
$buttonSelect.Text     = "Selectionner..."
$buttonSelect.Location = New-Object System.Drawing.Point(392, 38)
$buttonSelect.Size     = New-Object System.Drawing.Size(110, 28)
$form.Controls.Add($buttonSelect)

# -----------------------------------------------------------------------------
# Label "Dossier de destination"
# -----------------------------------------------------------------------------
$labelDest          = New-Object System.Windows.Forms.Label
$labelDest.Text     = "Dossier de destination :"
$labelDest.Location = New-Object System.Drawing.Point(12, 75)
$labelDest.Size     = New-Object System.Drawing.Size(490, 18)
$form.Controls.Add($labelDest)

# TextBox affichant le dossier de destination choisi
$textBoxDest           = New-Object System.Windows.Forms.TextBox
$textBoxDest.Location  = New-Object System.Drawing.Point(12, 95)
$textBoxDest.Size      = New-Object System.Drawing.Size(370, 24)
$textBoxDest.ReadOnly  = $true
$textBoxDest.Text      = "(meme dossier que le fichier source)"
$textBoxDest.BackColor = [System.Drawing.Color]::WhiteSmoke
$form.Controls.Add($textBoxDest)

# Bouton "Parcourir..." pour choisir le dossier de destination
$buttonBrowseDest          = New-Object System.Windows.Forms.Button
$buttonBrowseDest.Text     = "Parcourir..."
$buttonBrowseDest.Location = New-Object System.Drawing.Point(392, 93)
$buttonBrowseDest.Size     = New-Object System.Drawing.Size(110, 28)
$form.Controls.Add($buttonBrowseDest)

# -----------------------------------------------------------------------------
# Bouton "Convertir en MP3"
# -----------------------------------------------------------------------------
$buttonConvert           = New-Object System.Windows.Forms.Button
$buttonConvert.Text      = "Convertir en MP3"
$buttonConvert.Location  = New-Object System.Drawing.Point(12, 140)
$buttonConvert.Size      = New-Object System.Drawing.Size(490, 36)
$buttonConvert.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$buttonConvert.ForeColor = [System.Drawing.Color]::White
$buttonConvert.FlatStyle = "Flat"
$buttonConvert.Font      = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($buttonConvert)

# -----------------------------------------------------------------------------
# Label de statut
# -----------------------------------------------------------------------------
$labelStatus           = New-Object System.Windows.Forms.Label
$labelStatus.Text      = "Pret"
$labelStatus.Location  = New-Object System.Drawing.Point(12, 195)
$labelStatus.Size      = New-Object System.Drawing.Size(490, 20)
$labelStatus.ForeColor = [System.Drawing.Color]::DimGray
$form.Controls.Add($labelStatus)

$separator             = New-Object System.Windows.Forms.Label
$separator.Text        = ""
$separator.Location    = New-Object System.Drawing.Point(0, 187)
$separator.Size        = New-Object System.Drawing.Size(520, 2)
$separator.BorderStyle = "Fixed3D"
$form.Controls.Add($separator)

# -----------------------------------------------------------------------------
# Variables pour stocker les chemins selectionnes
# -----------------------------------------------------------------------------
$selectedFiles  = @()   # tableau de fichiers (selection simple ou multiple)
$destinationDir = ""

# -----------------------------------------------------------------------------
# Evenement : clic sur "Selectionner un fichier"
# -----------------------------------------------------------------------------
$buttonSelect.Add_Click({
    $openDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.Title            = "Selectionner un ou plusieurs fichiers audio/video"
    $openDialog.Filter           = "Fichiers audio/video (*.mp4;*.m4a)|*.mp4;*.m4a|Tous les fichiers (*.*)|*.*"
    $openDialog.InitialDirectory = [System.Environment]::GetFolderPath("MyVideos")
    $openDialog.Multiselect      = $true

    if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:selectedFiles = $openDialog.FileNames

        # Affichage dans la TextBox
        if ($script:selectedFiles.Count -eq 1) {
            $textBoxFile.Text = $script:selectedFiles[0]
        } else {
            $textBoxFile.Text = "$($script:selectedFiles.Count) fichiers selectionnes"
        }

        # Pre-remplir le dossier de destination avec le dossier du premier fichier
        if ([string]::IsNullOrEmpty($script:destinationDir)) {
            $script:destinationDir = Split-Path -Parent $script:selectedFiles[0]
            $textBoxDest.Text      = $script:destinationDir
        }

        $labelStatus.Text      = "Pret - $($script:selectedFiles.Count) fichier(s) selectionne(s)"
        $labelStatus.ForeColor = [System.Drawing.Color]::DimGray
    }
})

# -----------------------------------------------------------------------------
# Evenement : clic sur "Parcourir..." (dossier de destination)
# -----------------------------------------------------------------------------
$buttonBrowseDest.Add_Click({
    $folderDialog                       = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description           = "Choisissez le dossier de destination pour le fichier MP3"
    $folderDialog.ShowNewFolderButton   = $true
    if (-not [string]::IsNullOrEmpty($script:destinationDir)) {
        $folderDialog.SelectedPath = $script:destinationDir
    }
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:destinationDir = $folderDialog.SelectedPath
        $textBoxDest.Text      = $script:destinationDir
    }
})

# -----------------------------------------------------------------------------
# Evenement : clic sur "Convertir en MP3"
# -----------------------------------------------------------------------------
$buttonConvert.Add_Click({

    # --- Verification : au moins un fichier doit etre selectionne ---
    if ($script:selectedFiles.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Veuillez d'abord selectionner un ou plusieurs fichiers MP4 ou M4A.",
            "Aucun fichier selectionne",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    # --- Dossier de destination par defaut = dossier du premier fichier ---
    if ([string]::IsNullOrEmpty($script:destinationDir)) {
        $script:destinationDir = Split-Path -Parent $script:selectedFiles[0]
        $textBoxDest.Text      = $script:destinationDir
    }

    # --- Desactivation des boutons pendant la conversion ---
    $buttonConvert.Enabled      = $false
    $buttonSelect.Enabled       = $false
    $buttonBrowseDest.Enabled   = $false

    $total   = $script:selectedFiles.Count
    $success = 0
    $errList = @()

    try {
        for ($i = 0; $i -lt $total; $i++) {
            $file     = $script:selectedFiles[$i]
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
            $shortName = [System.IO.Path]::GetFileName($file)

            # Mise a jour du statut
            $labelStatus.Text      = "Conversion $($i + 1)/$total : $shortName"
            $labelStatus.ForeColor = [System.Drawing.Color]::DarkOrange
            $form.Refresh()

            # Verification que le fichier source existe toujours
            if (-not (Test-Path $file)) {
                $errList += "$shortName (introuvable)"
                continue
            }

            $outputPath = Join-Path $script:destinationDir "$baseName.mp3"
            $ffmpegArgs = "-y -i `"$file`" -q:a 0 -map a `"$outputPath`""

            $process = Start-Process `
                -FilePath     $ffmpegPath `
                -ArgumentList $ffmpegArgs `
                -Wait `
                -PassThru `
                -WindowStyle Hidden

            if ($process.ExitCode -eq 0) {
                $success++
            }
            else {
                $errList += "$shortName (erreur FFmpeg code $($process.ExitCode))"
            }
        }

        # --- Message de fin ---
        if ($errList.Count -eq 0) {
            $labelStatus.Text      = "Termine ! $success/$total fichier(s) converti(s)"
            $labelStatus.ForeColor = [System.Drawing.Color]::DarkGreen
            [System.Windows.Forms.MessageBox]::Show(
                "$success fichier(s) converti(s) avec succes !`n`nDestination : $($script:destinationDir)",
                "Succes",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
        else {
            $labelStatus.Text      = "$success/$total converti(s) - $($errList.Count) erreur(s)"
            $labelStatus.ForeColor = [System.Drawing.Color]::DarkOrange
            $errMsg = ($errList -join "`n")
            [System.Windows.Forms.MessageBox]::Show(
                "$success/$total fichier(s) converti(s).`n`nEchecs :`n$errMsg",
                "Conversion partielle",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
        }
    }
    catch {
        $labelStatus.Text      = "Erreur inattendue"
        $labelStatus.ForeColor = [System.Drawing.Color]::Red
        [System.Windows.Forms.MessageBox]::Show(
            "Une erreur inattendue s'est produite :`n$($_.Exception.Message)",
            "Erreur",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $buttonConvert.Enabled    = $true
        $buttonSelect.Enabled     = $true
        $buttonBrowseDest.Enabled = $true
    }
})

# -----------------------------------------------------------------------------
# Affichage de la fenetre
# -----------------------------------------------------------------------------
[void]$form.ShowDialog()
