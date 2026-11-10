param(
    [string]$c
)

$ErrorActionPreference = "Stop"

$steps = @(
    "api-pax/docker.ps1",
    "admin-pax/docker.ps1",
    "svc-pax/recompose.ps1"
)

foreach ($relativePath in $steps) {
    $script = Join-Path $PSScriptRoot $relativePath
    $directory = Split-Path -Path $script -Parent

    Write-Host "Running $relativePath"
    Push-Location $directory
    try {
        if ($relativePath -eq "services/recompose.ps1" -and $PSBoundParameters.ContainsKey("c")) {
            & $script -c $c
        }
        else {
            & $script
        }

        if ($LASTEXITCODE -ne 0) {
            throw "$relativePath failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }
}
