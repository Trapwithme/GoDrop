param(
  [Parameter(Mandatory=$true)][string]$Url,
  [string]$Out = "$env:TEMP\godrop-output.bat",
  [ValidateSet('bat','exe')][string]$Type = 'bat',
  [ValidateSet('en','es','fr')][string]$Locale = 'en'
)

$messages = @{
  en = @{ Downloading = 'Downloading artifact...'; Saved = 'Saved' }
  es = @{ Downloading = 'Descargando artefacto...'; Saved = 'Guardado' }
  fr = @{ Downloading = "Téléchargement de l'artefact..."; Saved = 'Enregistré' }
}

$msg = $messages[$Locale]
Write-Host $msg.Downloading
Invoke-WebRequest -Uri $Url -OutFile $Out

$hash = (Get-FileHash -Path $Out -Algorithm SHA256).Hash.ToLower()
Write-Host "$($msg.Saved): $Out"
Write-Host "SHA256: $hash"
