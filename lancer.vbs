' Lanceur invisible pour Audio Extractor
' Utilise WScript.Shell pour demarrer PowerShell sans fenetre CMD visible

Dim shell, dir, cmd
Set shell = CreateObject("WScript.Shell")

' Recupere le dossier ou se trouve ce script VBS
dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))

' Construit la commande PowerShell
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden" & _
      " -Command ""Unblock-File '" & dir & "audio-extractor.ps1';" & _
      " & '" & dir & "audio-extractor.ps1'"""

' 0 = fenetre cachee, False = ne pas attendre la fin
shell.Run cmd, 0, False
