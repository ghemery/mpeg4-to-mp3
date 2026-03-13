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
$form.Size             = New-Object System.Drawing.Size(520, 230)
$form.StartPosition    = "CenterScreen"
$form.FormBorderStyle  = "FixedSingle"
$form.MaximizeBox      = $false
$form.Font             = New-Object System.Drawing.Font("Segoe UI", 9)

# -----------------------------------------------------------------------------
# Label d'instruction
# -----------------------------------------------------------------------------
$labelInstruction          = New-Object System.Windows.Forms.Label
$labelInstruction.Text     = "Selectionnez un fichier MP4 ou M4A a convertir en MP3 :"
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
# Bouton "Convertir en MP3"
# -----------------------------------------------------------------------------
$buttonConvert           = New-Object System.Windows.Forms.Button
$buttonConvert.Text      = "Convertir en MP3"
$buttonConvert.Location  = New-Object System.Drawing.Point(12, 85)
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
$labelStatus.Location  = New-Object System.Drawing.Point(12, 140)
$labelStatus.Size      = New-Object System.Drawing.Size(490, 20)
$labelStatus.ForeColor = [System.Drawing.Color]::DimGray
$form.Controls.Add($labelStatus)

$separator             = New-Object System.Windows.Forms.Label
$separator.Text        = ""
$separator.Location    = New-Object System.Drawing.Point(0, 132)
$separator.Size        = New-Object System.Drawing.Size(520, 2)
$separator.BorderStyle = "Fixed3D"
$form.Controls.Add($separator)

# -----------------------------------------------------------------------------
# Variable pour stocker le chemin du fichier selectionne
# -----------------------------------------------------------------------------
$selectedFilePath = ""

# -----------------------------------------------------------------------------
# Evenement : clic sur "Selectionner un fichier"
# -----------------------------------------------------------------------------
$buttonSelect.Add_Click({
    $openDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.Title            = "Selectionner un fichier audio/video"
    $openDialog.Filter           = "Fichiers audio/video (*.mp4;*.m4a)|*.mp4;*.m4a|Tous les fichiers (*.*)|*.*"
    $openDialog.InitialDirectory = [System.Environment]::GetFolderPath("MyVideos")

    if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:selectedFilePath = $openDialog.FileName
        $textBoxFile.Text        = $script:selectedFilePath
        $labelStatus.Text        = "Pret - Fichier selectionne"
        $labelStatus.ForeColor   = [System.Drawing.Color]::DimGray
    }
})

# -----------------------------------------------------------------------------
# Evenement : clic sur "Convertir en MP3"
# -----------------------------------------------------------------------------
$buttonConvert.Add_Click({

    if ([string]::IsNullOrEmpty($script:selectedFilePath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Veuillez d'abord selectionner un fichier MP4 ou M4A.",
            "Aucun fichier selectionne",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    if (-not (Test-Path $script:selectedFilePath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Le fichier source est introuvable :`n$($script:selectedFilePath)",
            "Fichier introuvable",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    $outputPath = [System.IO.Path]::ChangeExtension($script:selectedFilePath, ".mp3")

    if (Test-Path $outputPath) {
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Le fichier de sortie existe deja :`n$outputPath`n`nVoulez-vous le remplacer ?",
            "Fichier existant",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }
    }

    $labelStatus.Text      = "Conversion en cours..."
    $labelStatus.ForeColor = [System.Drawing.Color]::DarkOrange
    $buttonConvert.Enabled = $false
    $buttonSelect.Enabled  = $false
    $form.Refresh()

    try {
        $ffmpegArgs = "-y -i `"$($script:selectedFilePath)`" -q:a 0 -map a `"$outputPath`""

        $process = Start-Process `
            -FilePath     $ffmpegPath `
            -ArgumentList $ffmpegArgs `
            -Wait `
            -PassThru `
            -WindowStyle Hidden

        if ($process.ExitCode -eq 0) {
            $outName               = [System.IO.Path]::GetFileName($outputPath)
            $labelStatus.Text      = "Termine ! -> $outName"
            $labelStatus.ForeColor = [System.Drawing.Color]::DarkGreen

            [System.Windows.Forms.MessageBox]::Show(
                "Conversion terminee avec succes !`n`nFichier cree :`n$outputPath",
                "Succes",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
        else {
            $labelStatus.Text      = "Erreur de conversion (code $($process.ExitCode))"
            $labelStatus.ForeColor = [System.Drawing.Color]::Red

            [System.Windows.Forms.MessageBox]::Show(
                "FFmpeg a retourne une erreur (code $($process.ExitCode)).`n`nVerifiez que le fichier source est un MP4 ou M4A valide.",
                "Erreur de conversion",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
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
        $buttonConvert.Enabled = $true
        $buttonSelect.Enabled  = $true
    }
})

# -----------------------------------------------------------------------------
# Affichage de la fenetre
# -----------------------------------------------------------------------------
[void]$form.ShowDialog()
