# Load .secrets, walking up from -Repo. Existing environment variables are left unchanged.
param(
    [string]$Repo = (Get-Location).Path
)

function Find-UpFile {
    param(
        [string]$Start,
        [string]$Name
    )

    $dir = $Start
    while ($dir) {
        $candidate = Join-Path $dir $Name
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }

        $parent = Split-Path -Path $dir -Parent
        if (-not $parent -or ($parent -eq $dir)) {
            break
        }
        $dir = $parent
    }

    return $null
}

function Import-EnvFile {
    param(
        [string]$Path
    )

    $loaded = @()
    foreach ($rawLine in Get-Content -LiteralPath $Path) {
        $line = $rawLine.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith("#")) {
            continue
        }

        $eq = $line.IndexOf("=")
        if ($eq -lt 1) {
            continue
        }

        $name = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1)
        if (
            ($value.Length -ge 2) -and
            (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'")))
        ) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        if ($null -eq [Environment]::GetEnvironmentVariable($name)) {
            Set-Item -Path "Env:$name" -Value $value
        }
        $loaded += $name
    }

    return $loaded
}

$secretFile = Find-UpFile -Start $Repo -Name ".secrets"
if (-not $secretFile) {
    throw ".secrets was not found in $Repo or any parent directory."
}

Import-EnvFile -Path $secretFile
