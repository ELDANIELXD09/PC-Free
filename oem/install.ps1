$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$logDirectory = Join-Path $env:LOCALAPPDATA 'PC-Free'
$logPath = Join-Path $logDirectory 'app-install.log'
$failurePath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'PC-Free-app-install-FAILED.txt'
$transcriptStarted = $false

function Install-Application {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][uri]$DownloadUrl,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $installerPath = Join-Path $env:TEMP "$Name-Setup.exe"
    Write-Output "Downloading $Name from $DownloadUrl"
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
    if (-not (Test-Path $installerPath) -or (Get-Item $installerPath).Length -eq 0) {
        throw "The $Name installer download is empty."
    }

    Write-Output "Installing $Name"
    $process = Start-Process -FilePath $installerPath -ArgumentList $Arguments -Wait -PassThru -WindowStyle Hidden
    if ($process.ExitCode -ne 0) {
        throw "$Name installer exited with code $($process.ExitCode)."
    }
    Remove-Item -LiteralPath $installerPath -Force
}

try {
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    Start-Transcript -Path $logPath -Append | Out-Null
    $transcriptStarted = $true

    Install-Application -Name 'Discord' -DownloadUrl 'https://discord.com/api/download?platform=win' -Arguments @('--silent')
    Install-Application -Name 'Roblox' -DownloadUrl 'https://www.roblox.com/download/client?os=win' -Arguments @('-silent', '-skipui')
    Install-Application -Name 'RobloxStudio' -DownloadUrl 'https://setup.rbxcdn.com/RobloxStudioLauncherBeta.exe' -Arguments @('-silent', '-skipui')

    $steamPath = Join-Path $env:LOCALAPPDATA 'Programs\Steam'
    New-Item -ItemType Directory -Path (Split-Path $steamPath -Parent) -Force | Out-Null
    Install-Application -Name 'Steam' -DownloadUrl 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe' -Arguments @('/S', "/D=`"$steamPath`"")

    Write-Output 'All requested applications were installed successfully.'
}
catch {
    $message = "PC-Free could not install the default applications: $($_.Exception.Message). See $logPath and rerun C:\OEM\install.ps1."
    Write-Output $message
    New-Item -ItemType Directory -Path (Split-Path $failurePath -Parent) -Force | Out-Null
    Set-Content -LiteralPath $failurePath -Value $message
    throw $message
}
finally {
    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
}
