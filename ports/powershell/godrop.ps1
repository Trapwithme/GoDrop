param(
  [string]$Out = "$env:TEMP\godrop-output.bat",
  [ValidateSet('bat','exe')][string]$Type = 'bat',
  [ValidateSet('en','es','fr')][string]$Locale = 'en'
)

$EncryptionKey = 'GoDropEmbedKey2026'
$EncryptedUrlHex = '__ENC_URL__'

function Convert-HexToBytes {
  param([string]$Hex)

  $bytes = New-Object byte[] ($Hex.Length / 2)
  for ($i = 0; $i -lt $Hex.Length; $i += 2) {
    $bytes[$i / 2] = [Convert]::ToByte($Hex.Substring($i, 2), 16)
  }

  return $bytes
}

function Get-DecryptedUrl {
  $cipher = Convert-HexToBytes -Hex $EncryptedUrlHex
  $key = [Text.Encoding]::UTF8.GetBytes($EncryptionKey)

  for ($i = 0; $i -lt $cipher.Length; $i++) {
    $cipher[$i] = $cipher[$i] -bxor $key[$i % $key.Length]
  }

  return [Text.Encoding]::UTF8.GetString($cipher)
}

$messages = @{
  en = @{ Downloading = 'Downloading artifact...'; Saved = 'Saved' }
  es = @{ Downloading = 'Descargando artefacto...'; Saved = 'Guardado' }
  fr = @{ Downloading = "Téléchargement de l'artefact..."; Saved = 'Enregistré' }
}

$url = Get-DecryptedUrl
if (-not ($url.StartsWith('http://') -or $url.StartsWith('https://'))) {
  Write-Error 'Embedded URL must use http or https.'
  exit 1
}

$msg = $messages[$Locale]
Write-Host $msg.Downloading
Invoke-WebRequest -Uri $url -OutFile $Out

$hash = (Get-FileHash -Path $Out -Algorithm SHA256).Hash.ToLower()
Write-Host "$($msg.Saved): $Out"
Write-Host "SHA256: $hash"
