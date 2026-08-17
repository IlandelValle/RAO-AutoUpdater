[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArchivePath,

    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?$')]
    [string]$Version,

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*\.exe$')]
    [string]$Executable = 'rao-client.exe',

    [string]$Repository = 'Rhember-AO/RAO-AutoUpdater',

    [switch]$Publish
)

$ErrorActionPreference = 'Stop'

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$archive = Get-Item -LiteralPath $ArchivePath
if ($archive.Extension -ne '.zip') {
    throw 'ArchivePath must point to a .zip file.'
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($archive.FullName)
try {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq $Executable } | Select-Object -First 1
    if ($null -eq $entry) {
        throw "The ZIP must contain '$Executable' at its root."
    }
}
finally {
    $zip.Dispose()
}

$tag = "v$Version"
$assetName = $archive.Name
$sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive.FullName).Hash.ToLowerInvariant()
$downloadUrl = "https://github.com/$Repository/releases/download/$tag/$assetName"
$manifest = [ordered]@{
    version = $Version
    download_url = $downloadUrl
    sha256 = $sha256
    executable = $Executable
}
$manifestJson = $manifest | ConvertTo-Json

if (-not $Publish) {
    Write-Host 'Publication preview (no GitHub changes were made):'
    Write-Output $manifestJson
    Write-Host "Run again with -Publish to create release $tag and publish manifest.json."
    exit 0
}

Require-Command gh
Require-Command git

Push-Location $repositoryRoot
try {
    $existingRelease = gh release view $tag --repo $Repository 2>$null
    if ($LASTEXITCODE -eq 0 -or $null -ne $existingRelease) {
        throw "Release $tag already exists. Refusing to overwrite it."
    }

    if ($PSCmdlet.ShouldProcess("GitHub release $tag", 'Create release and upload client archive')) {
        gh release create $tag $archive.FullName --repo $Repository --title "RAO Client $Version" --notes "Cliente Windows $Version para pruebas."
        if ($LASTEXITCODE -ne 0) {
            throw "GitHub release creation failed for $tag."
        }
    }

    $manifestPath = Join-Path $repositoryRoot 'manifest.json'
    if ($PSCmdlet.ShouldProcess($manifestPath, 'Write update manifest')) {
        [System.IO.File]::WriteAllText($manifestPath, "$manifestJson`n", [System.Text.UTF8Encoding]::new($false))
        git add -- manifest.json
        git commit -m "release: publicar cliente $Version" -m "Se publicó el manifiesto de actualización del cliente $Version."
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not commit manifest.json.'
        }
        git push origin main
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not push manifest.json to main.'
        }
    }
}
finally {
    Pop-Location
}

Write-Host "Published $Version. Manifest: https://raw.githubusercontent.com/$Repository/main/manifest.json"
