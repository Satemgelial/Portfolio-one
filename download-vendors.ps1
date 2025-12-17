# download-vendors.ps1
# Run this script once while online to download required vendor files into ./vendor
# Usage (PowerShell):
#   .\download-vendors.ps1

$vendorDir = Join-Path $PSScriptRoot "vendor"
if (-not (Test-Path $vendorDir)) {
    New-Item -ItemType Directory -Path $vendorDir | Out-Null
}

$files = @(
    @{ url = "https://unpkg.com/react@18/umd/react.production.min.js"; name = "react.production.min.js" },
    @{ url = "https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"; name = "react-dom.production.min.js" },
    @{ url = "https://unpkg.com/@babel/standalone/babel.min.js"; name = "babel.min.js" },
    @{ url = "https://cdn.tailwindcss.com"; name = "tailwindcdn.js" },
    @{ url = "https://unpkg.com/lucide-static@0.516.0/font/lucide.css"; name = "lucide.css" },
    @{ url = "https://unpkg.com/lucide-static@0.516.0/font/lucide.eot"; name = "lucide.eot" },
    @{ url = "https://unpkg.com/lucide-static@0.516.0/font/lucide.woff2"; name = "lucide.woff2" },
    @{ url = "https://unpkg.com/lucide-static@0.516.0/font/lucide.woff"; name = "lucide.woff" },
    @{ url = "https://unpkg.com/lucide-static@0.516.0/font/lucide.ttf"; name = "lucide.ttf" },
    @{ url = "https://unpkg.com/lucide-static@0.516.0/font/lucide.svg"; name = "lucide.svg" }
)

Write-Host "Downloading vendor files into: $vendorDir"

foreach ($f in $files) {
    $out = Join-Path $vendorDir $($f.name)
    Write-Host " - $($f.url) -> $out"
    try {
        Invoke-WebRequest -Uri $f.url -OutFile $out -UseBasicParsing -ErrorAction Stop
        Write-Host "   OK"
    } catch {
        Write-Warning "Failed to download $($f.url): $_"
    }
}

Write-Host "Done. Verify files exist in vendor/ and then follow README-offline.md to update your HTML to use these local files."