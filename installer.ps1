# Anyone seeing this? well don't waste time improving this script.
# It's messy and just temporary until i get the new version.

# Branch options:
#   1 = luatools plugin (default)
#   2 = steamtools-collection plugin
#   3 = Spacetheme Block Remover         (by waike - waike.dev)
#   4 = Steam Offline Fix                (by waike - waike.dev)
#   5 = ST Uninstaller                   (by Potatoes9411)
#   6 = Steam Bulk Fixer                 (by waike - waike.dev)

param(
    [string]$DownloadLink, # Overwrites the download link (give a direct link)
    [string]$PluginName,   # Overwrites the plugin name
    [int]$Branch,          # See branch options above
    [switch]$SkipDefender  # Branch 6 only: skips adding Windows Defender exclusions
)

## Configure this
$Host.UI.RawUI.WindowTitle = "Luatools plugin installer | .gg/luatools"
$name = "luatools"
$link = "https://github.com/madoiscool/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"
$milleniumTimer = 5 # in seconds for auto-installation

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Hidden defines
$steam = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam").InstallPath
$upperName = $name.Substring(0, 1).ToUpper() + $name.Substring(1).ToLower()
if ($DownloadLink) { $link = $DownloadLink }
if ($PluginName)   { $name = $PluginName }

# Branch 2: steamtools-collection
if ($br -eq 2 -or $Branch -eq 2) {
    $name = "steamtools-collection"
    $link = "https://github.com/clemdotla/steamtools-collection/releases/download/Latest/steamtools-collection.zip"
}


#### Logging ####
function Log {
    param ([string]$Type, [string]$Message, [boolean]$NoNewline = $false)
    $Type = $Type.ToUpper()
    switch ($Type) {
        "OK"   { $foreground = "Green" }
        "INFO" { $foreground = "Cyan" }
        "ERR"  { $foreground = "Red" }
        "WARN" { $foreground = "Yellow" }
        "LOG"  { $foreground = "Magenta" }
        "AUX"  { $foreground = "DarkGray" }
        default { $foreground = "White" }
    }
    $date = Get-Date -Format "HH:mm:ss"
    $prefix = if ($NoNewline) { "`r[$date] " } else { "[$date] " }
    Write-Host $prefix -ForegroundColor "Cyan" -NoNewline
    Write-Host [$Type] $Message -ForegroundColor $foreground -NoNewline:$NoNewline
}

function Sep   { Write-Host ("=" * 63) -ForegroundColor Cyan }
function Blank { Write-Host "" }

Log "WARN" "Hey! Just letting you know that i'm working on a new version combining various scripts of the server"
Log "AUX"  "Will include language support on THIS script too, luv y'all brazilians"
Write-Host

$ProgressPreference = 'SilentlyContinue'


#### Branch 3: Spacetheme Block Remover (by waike - waike.dev) ####
if ($Branch -eq 3) {
    Log "INFO" "Spacetheme Block Remover"
    Log "AUX"  "Removes the 'get a job loser' text blocking your Steam client."
    Log "AUX"  "Credit: waike (waike.dev)"
    Blank

    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if (-not $steamPath -or -not (Test-Path $steamPath)) {
        Log "ERR" "Steam not found."
        exit 1
    }

    $skinDir = "$steamPath\steamui\skins\Steam"
    if (-not (Test-Path $skinDir)) {
        Log "ERR" "Spacetheme was not found. Exiting."
        Read-Host "Press Enter to exit"
        exit 1
    }

    $cssFile = "$skinDir\src\css\regular.css"
    if (-not (Test-Path $cssFile)) {
        Log "ERR" "Spacetheme css files were not found. Exiting."
        Read-Host "Press Enter to exit"
        exit 1
    }

    Log "WARN" "Closing all Steam processes..."
    Get-Process -Name "steam" -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    Start-Sleep -Seconds 1
    Get-Process -Name "steam", "steamwebhelper", "steamerrorreporter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Stop-Service "Steam Client Service" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Get-Process -Name "steam", "steamwebhelper", "steamservice", "steamerrorreporter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1

    $content = Get-Content $cssFile -Raw
    $pattern = '(?s)/\*\s*\n?\s*& Ban piracy plugins.*?color: #fff !important;\s*\}'

    if ($content -match $pattern) {
        $content = $content -replace $pattern, '/* Retard owner tried to block luatools.. lmao */'
        Set-Content $cssFile -Value $content -NoNewline -Encoding UTF8
        Log "OK" "Patched regular.css"
    } else {
        Log "INFO" "Did not patch regular.css — nothing to replace."
    }

    exit
}


#### Branch 4: Steam Offline Fix (by waike - waike.dev) ####
if ($Branch -eq 4) {
    Log "INFO" "Steam Offline Fix"
    Log "AUX"  "Steamtools sometimes forces offline mode — this attempts to fix the loading icon issue."
    Log "AUX"  "Credit: waike (waike.dev)"
    Blank

    $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -ErrorAction SilentlyContinue).InstallPath
    if (-not $steamPath) {
        $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam' -ErrorAction SilentlyContinue).InstallPath
    }

    $loginUsersPath = Join-Path $steamPath 'config\loginusers.vdf'
    if (Test-Path $loginUsersPath) {
        $content = Get-Content -Path $loginUsersPath -Raw
        if ($content -match '"WantsOfflineMode"\s+"1"') {
            $newContent = $content -replace '("WantsOfflineMode"\s+)"1"', '$1"0"'
            Set-Content -Path $loginUsersPath -Value $newContent -Encoding UTF8
            Log "OK" "Fixed — WantsOfflineMode set to 0 in loginusers.vdf"
        } else {
            Log "INFO" "Steam was not set to offline mode, nothing changed."
        }
    } else {
        Log "ERR" "loginusers.vdf not found at: $loginUsersPath"
    }

    exit
}


#### Branch 5: ST Uninstaller (by Potatoes9411) ####
if ($Branch -eq 5) {
    $Host.UI.RawUI.WindowTitle = "Luatools Uninstaller | .gg/luatools"
    Log "INFO" "ST Uninstaller"
    Log "AUX"  "Fully uninstalls Steamtools and Luatools."
    Log "AUX"  "Credit: Potatoes9411"
    Blank

    function Get-SteamPath {
        $entries = @(
            @{ Path = "HKCU:\Software\Valve\Steam";             Key = "SteamPath"   },
            @{ Path = "HKLM:\SOFTWARE\Valve\Steam";             Key = "InstallPath" },
            @{ Path = "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam"; Key = "InstallPath" }
        )
        foreach ($e in $entries) {
            if (Test-Path $e.Path) {
                $val = (Get-ItemProperty -Path $e.Path -Name $e.Key -ErrorAction SilentlyContinue).($e.Key)
                if ($val -and (Test-Path $val)) { return $val }
            }
        }
        return $null
    }

    $steam = Get-SteamPath
    if (-not $steam) {
        Log "ERR" "Steam not found. Is Steam installed?"
        Blank; Read-Host "Press Enter to exit"
        exit 1
    }

    function Test-PluginInstalled {
        $dir = Join-Path $steam "plugins"
        if (-not (Test-Path $dir)) { return $false }
        foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
            $jp = Join-Path $p.FullName "plugin.json"
            if (Test-Path $jp) {
                $j = Get-Content $jp -Raw | ConvertFrom-Json
                if ($j.name -eq $name) { return $true }
            }
        }
        return $false
    }

    function Test-SteamtoolsInstalled {
        $hasDll = (@("dwmapi.dll","xinput1_4.dll") | Where-Object { Test-Path (Join-Path $steam $_) }).Count -gt 0
        return ($hasDll -or (Test-Path "C:\Program Files\SteamTools"))
    }

    function Test-MillenniumInstalled {
        return (@("millennium.dll","python311.dll") | Where-Object { Test-Path (Join-Path $steam $_) }).Count -gt 0
    }

    function Get-LuaFileCount {
        $p = Join-Path $steam "config\stplug-in"
        if (-not (Test-Path $p)) { return 0 }
        return @(Get-ChildItem -Path $p -Filter "*.lua" -ErrorAction SilentlyContinue).Count
    }

    function Uninstall-Plugin {
        Blank; Sep; Log "INFO" "Uninstalling plugin: $name"; Sep; Blank

        $dir = Join-Path $steam "plugins"
        if (-not (Test-Path $dir)) { Log "WARN" "Plugins directory not found."; return }

        $pluginPath = $null
        foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
            $jp = Join-Path $p.FullName "plugin.json"
            if (Test-Path $jp) {
                $j = Get-Content $jp -Raw | ConvertFrom-Json
                if ($j.name -eq $name) { $pluginPath = $p.FullName; break }
            }
        }

        if ($pluginPath) {
            Log "LOG" "Removing: $pluginPath"
            Remove-Item $pluginPath -Recurse -Force
            Log "OK" "$upperName folder removed"
        } else {
            Log "WARN" "Plugin folder for '$name' not found — already uninstalled?"
        }

        $configPath = Join-Path $steam "ext/config.json"
        if (Test-Path $configPath) {
            $config = (Get-Content $configPath -Raw -Encoding UTF8) | ConvertFrom-Json
            if ($config.plugins -and $config.plugins.enabledPlugins) {
                $before = @($config.plugins.enabledPlugins)
                $after  = $before | Where-Object { $_ -ne $name }
                if ($before.Count -ne $after.Count) {
                    $config.plugins.enabledPlugins = $after
                    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
                    Log "OK" "Removed '$name' from enabled plugins list"
                }
            }
        }

        Log "OK" "$upperName uninstalled"
    }

    function Uninstall-Steamtools([bool]$RemoveLuas) {
        Blank; Sep; Log "INFO" "Uninstalling SteamTools"; Sep; Blank

        $stDlls          = @("dwmapi.dll","xinput1_4.dll")
        $foundDlls       = $stDlls | Where-Object { Test-Path (Join-Path $steam $_) }
        $stAppDir        = "C:\Program Files\SteamTools"
        $stAppExists     = Test-Path $stAppDir
        $stplugPath      = Join-Path $steam "config\stplug-in"
        $luaFiles        = @()
        if (Test-Path $stplugPath) { $luaFiles = @(Get-ChildItem -Path $stplugPath -Filter "*.lua" -ErrorAction SilentlyContinue) }
        $stRegKey        = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SteamTools"
        $stRegExists     = Test-Path $stRegKey
        $startMenuDir    = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\SteamTools"
        $startMenuExists = Test-Path $startMenuDir

        if ($foundDlls.Count -eq 0 -and -not $stAppExists) { Log "INFO" "SteamTools does not appear to be installed."; return }

        Log "WARN" "Killing Steam and SteamTools..."
        Get-Process -Name "steam","SteamTools" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2

        foreach ($f in $foundDlls) {
            $t = Join-Path $steam $f
            try   { Remove-Item -Path $t -Force -ErrorAction Stop; Log "OK" "Removed: $f" }
            catch { Log "ERR" "Could not remove $f — try running as Administrator" }
        }

        if ($RemoveLuas) {
            foreach ($lua in $luaFiles) {
                try   { Remove-Item -Path $lua.FullName -Force -ErrorAction Stop; Log "OK" "Removed: $($lua.Name)" }
                catch { Log "ERR" "Could not remove $($lua.Name)" }
            }
        }

        if ($stAppExists) {
            try   { Remove-Item -Path $stAppDir -Recurse -Force -ErrorAction Stop; Log "OK" "Removed: $stAppDir" }
            catch { Log "ERR" "Could not remove $stAppDir — try running as Administrator" }
        }

        if ($stRegExists) {
            try   { Remove-Item -Path $stRegKey -Recurse -Force -ErrorAction Stop; Log "OK" "Registry entry removed" }
            catch { Log "ERR" "Could not remove registry entry" }
        }

        if ($startMenuExists) {
            try   { Remove-Item -Path $startMenuDir -Recurse -Force -ErrorAction Stop; Log "OK" "Start Menu folder removed" }
            catch { Log "ERR" "Could not remove Start Menu folder" }
        }

        Log "OK" "SteamTools uninstalled"
    }

    function Uninstall-Millennium([bool]$KeepPlugins) {
        Blank; Sep; Log "INFO" "Uninstalling Millennium"; Sep; Blank

        $milFiles   = @("millennium.dll","python311.dll","python311.zip")
        $milDirs    = @("ext","plugins","millennium","pkg")
        $foundFiles = $milFiles | Where-Object { Test-Path (Join-Path $steam $_) }
        $foundDirs  = $milDirs  | Where-Object { Test-Path (Join-Path $steam $_) }

        if ($foundFiles.Count -eq 0 -and $foundDirs.Count -eq 0) { Log "INFO" "Millennium does not appear to be installed."; return }

        Log "WARN" "Killing Steam..."
        Get-Process -Name "steam" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2

        foreach ($f in $foundFiles) {
            $t = Join-Path $steam $f
            try   { Remove-Item -Path $t -Force -ErrorAction Stop; Log "OK" "Removed: $f" }
            catch { Log "ERR" "Could not remove $f — try running as Administrator" }
        }

        foreach ($d in $foundDirs) {
            if ($d -eq "plugins" -and $KeepPlugins) { Log "AUX" "Skipping plugins folder"; continue }
            $t = Join-Path $steam $d
            try   { Remove-Item -Path $t -Recurse -Force -ErrorAction Stop; Log "OK" "Removed: $d\" }
            catch { Log "ERR" "Could not remove $d\ — try running as Administrator" }
        }

        Log "OK" "Millennium uninstalled"
    }

    function Restart-Steam {
        $exe = Join-Path $steam "steam.exe"
        if (Test-Path $exe) { Start-Process -FilePath $exe; Log "OK" "Steam started" }
        else                { Log "ERR" "steam.exe not found" }
    }

    $luaCount      = Get-LuaFileCount
    $doPlugin      = Test-PluginInstalled
    $doSteamtools  = Test-SteamtoolsInstalled
    $doMillennium  = Test-MillenniumInstalled
    $doLuas        = $false
    $doKeepPlugins = $false

    function Write-Menu {
        Clear-Host
        Sep
        Write-Host "  Luatools Uninstaller  |  .gg/luatools" -ForegroundColor Cyan
        Sep
        Blank

        function Checkbox([bool]$on) { if ($on) { return "[X]" } else { return "[ ]" } }
        function Status([bool]$found) { if ($found) { return "[installed]" } else { return "[not found]" } }

        Write-Host "  WHAT TO UNINSTALL:" -ForegroundColor DarkGray
        Write-Host "  1  $(Checkbox $doPlugin)    " -ForegroundColor Cyan -NoNewline
        Write-Host "Plugin ($name)   " -NoNewline
        Write-Host (Status (Test-PluginInstalled)) -ForegroundColor DarkGray

        Write-Host "  2  $(Checkbox $doSteamtools) " -ForegroundColor Cyan -NoNewline
        Write-Host "SteamTools       " -NoNewline
        Write-Host (Status (Test-SteamtoolsInstalled)) -ForegroundColor DarkGray

        Write-Host "  3  $(Checkbox $doMillennium) " -ForegroundColor Cyan -NoNewline
        Write-Host "Millennium       " -NoNewline
        Write-Host (Status (Test-MillenniumInstalled)) -ForegroundColor DarkGray

        Blank
        Write-Host "  OPTIONS:" -ForegroundColor DarkGray

        $luaLabel = if ($luaCount -gt 0) { "($luaCount file(s) found)" } else { "(none found)" }
        Write-Host "  4  $(Checkbox $doLuas)    " -ForegroundColor Cyan -NoNewline
        Write-Host "Remove SteamTools Lua files  " -NoNewline
        Write-Host $luaLabel -ForegroundColor DarkGray

        Write-Host "  5  $(Checkbox $doKeepPlugins) " -ForegroundColor Cyan -NoNewline
        Write-Host "Keep Millennium plugins folder"

        Blank
        Write-Host "  R" -ForegroundColor Green -NoNewline; Write-Host "  Run"
        Write-Host "  Q" -ForegroundColor DarkGray -NoNewline; Write-Host "  Quit"
        Blank
    }

    while ($true) {
        Write-Menu
        $key = Read-Host "Toggle option or run"

        switch ($key.Trim().ToUpper()) {
            "1" { $doPlugin      = -not $doPlugin }
            "2" { $doSteamtools  = -not $doSteamtools }
            "3" { $doMillennium  = -not $doMillennium }
            "4" { $doLuas        = -not $doLuas }
            "5" { $doKeepPlugins = -not $doKeepPlugins }
            "Q" { exit 0 }
            "R" {
                if (-not $doPlugin -and -not $doSteamtools -and -not $doMillennium) {
                    Clear-Host
                    Log "WARN" "Nothing selected to uninstall."
                    Blank
                    Read-Host "Press Enter to go back"
                    break
                }

                Clear-Host; Sep
                Write-Host "  Running uninstaller..." -ForegroundColor Cyan
                Sep

                if ($doPlugin)     { Uninstall-Plugin }
                if ($doSteamtools) { Uninstall-Steamtools -RemoveLuas $doLuas }
                if ($doMillennium) { Uninstall-Millennium -KeepPlugins $doKeepPlugins }

                Blank
                $restart = Read-Host "Restart Steam? (y/n)"
                if ($restart.Trim() -ieq "y") { Restart-Steam }

                Blank; Sep
                Write-Host "  Done!" -ForegroundColor Green
                Sep; Blank
                Read-Host "Press Enter to exit"
                exit 0
            }
        }
    }
}


#### Branch 6: Steam Bulk Fixer (by waike - waike.dev) ####
if ($Branch -eq 6) {
    Log "INFO" "Steam Bulk Fixer"
    Log "AUX"  "Runs a collection of fixes for your Steam client and Steamtools."
    Log "AUX"  "Credit: waike (waike.dev)"
    if ($SkipDefender) {
        Log "AUX" "Skipping Windows Defender exclusions (-SkipDefender flag set)"
        $env:SKIP_DEFENDER = "1"
    }
    Blank

    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if (-not $IsAdmin) {
        Write-Host "Not running as admin, Windows Defender changes won't run." -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "Are you sure you want to continue? (Y/N)"
        if ($choice -notin @("Y","y")) {
            Log "ERR" "Cancelled."
            Start-Sleep -Seconds 1
            exit
        }
        Write-Host "Continuing..." -ForegroundColor Green
    }

    Write-Host "Starting..." -ForegroundColor Cyan

    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if (-not $steamPath -or -not (Test-Path $steamPath)) {
        Log "ERR" "Steam not found."
        exit
    }

    Write-Host "Steam path: $steamPath"

    Write-Host "Closing Steam..."
    while (Get-Process steam, steamwebhelper -ErrorAction SilentlyContinue) {
        Get-Process steam, steamwebhelper -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep 1
    }
    Write-Host "Steam closed." -ForegroundColor Green

    if ($IsAdmin -and $env:SKIP_DEFENDER -ne "1") {
        Write-Host "Adding Defender exclusion..."
        try {
            Add-MpPreference -ExclusionPath $steamPath -ErrorAction Stop
            Write-Host "Defender updated." -ForegroundColor Green
        } catch {
            Write-Host "Defender change failed." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Skipping Defender changes."
    }

    Write-Host "Downloading DLLs..."
    $urls = @{
        "xinput1_4.dll" = "http://update.steamox.com/update"
        "dwmapi.dll"    = "http://update.steamox.com/dwmapi"
    }
    foreach ($dll in $urls.Keys) {
        $dest = Join-Path $steamPath $dll
        Write-Host "Getting $dll..."
        try {
            Invoke-RestMethod -Uri $urls[$dll] -OutFile $dest
            Write-Host "$dll done." -ForegroundColor Green
        } catch {
            Write-Host "Failed: $dll" -ForegroundColor Red
        }
    }
    Write-Host "DLLs finished."

    Write-Host "Running Luatools fixer."
    try {
        Invoke-Expression (Invoke-RestMethod "https://luatools.vercel.app/temporary-fixer.ps1")
    } catch {
        Write-Host "Fixer failed." -ForegroundColor Yellow
    }

    Write-Host "Installing LuaTools..."
    try {
        Invoke-Expression (Invoke-RestMethod "https://luatools.vercel.app/install-plugin.ps1")
    } catch {
        Write-Host "LuaTools failed." -ForegroundColor Yellow
    }

    Write-Host "Launching Steam..."
    Start-Process (Join-Path $steamPath "steam.exe")

    Log "OK" "Done."
    exit
}


#### Plugin install flow (branches 1 & 2 / default) ####

Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force


#### Requirements part ####

function CheckSteamtools {
    $files = @( "dwmapi.dll", "xinput1_4.dll" )
    foreach($file in $files) {
        if (!( Test-Path (Join-Path $steam $file) )) { return $false }
    }
    return $true
}

$path = Join-Path $steam "dwmapi.dll"
if ( CheckSteamtools ) {
    Log "INFO" "Steamtools already installed"
}
else {
    $script = Invoke-RestMethod "https://luatools.vercel.app/st.ps1"
    $keptLines = @()

    foreach ($line in $script -split "`n") {
        $conditions = @(
            ($line -imatch "Start-Process" -and $line -imatch "steam"),
            ($line -imatch "steam\.exe"),
            ($line -imatch "Start-Sleep" -or $line -imatch "Write-Host"),
            ($line -imatch "cls" -or $line -imatch "exit"),
            ($line -imatch "Stop-Process" -and -not ($line -imatch "Get-Process"))
        )
        if (-not($conditions -contains $true)) { $keptLines += $line }
    }

    $SteamtoolsScript = $keptLines -join "`n"
    Log "ERR" "Steamtools not found."

    for ($i = 0; $i -lt 5; $i++) {
        Log "AUX"  "Install it at your own risk! Close this script if you don't want to."
        Log "WARN" "Pressing any key will install steamtools (UI-less)."

        [void][System.Console]::ReadKey($true)
        Write-Host
        Log "WARN" "Installing Steamtools"

        Invoke-Expression $SteamtoolsScript *> $null

        if ( CheckSteamtools ) {
            Log "OK" "Steamtools installed"
            break
        }
        else {
            Log "ERR" "Steamtools installation failed, retrying..."
        }
    }
}

# Millenium check
$milleniumInstalling = $false
foreach ($file in @("millennium.dll", "python311.dll")) {
    if (!( Test-Path (Join-Path $steam $file) )) {

        Log "ERR" "Millenium not found, installation process will start in 5 seconds."
        Log "WARN" "Press any key to cancel the installation."

        for ($i = $milleniumTimer; $i -ge 0; $i--) {
            if ([Console]::KeyAvailable) {
                Write-Host
                Log "ERR" "Installation cancelled by user."
                exit
            }
            Log "LOG" "Installing Millenium in $i second(s)... Press any key to cancel." $true
            Start-Sleep -Seconds 1
        }
        Write-Host

        Log "INFO" "Installing millenium"
        Invoke-Expression "& { $(Invoke-RestMethod 'https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1') } -NoLog -DontStart -SteamPath '$steam'"
        Log "OK" "Millenium done installing"
        $milleniumInstalling = $true
        break
    }
}
if ($milleniumInstalling -eq $false) { Log "INFO" "Millenium already installed" }


#### Plugin part ####
if (!( Test-Path (Join-Path $steam "plugins") )) {
    New-Item -Path (Join-Path $steam "plugins") -ItemType Directory *> $null
}

$Path = Join-Path $steam "plugins\$name"

foreach ($plugin in Get-ChildItem -Path (Join-Path $steam "plugins") -Directory) {
    $testpath = Join-Path $plugin.FullName "plugin.json"
    if (Test-Path $testpath) {
        $json = Get-Content $testpath -Raw | ConvertFrom-Json
        if ($json.name -eq $name) {
            Log "INFO" "Plugin already installed, updating it"
            $Path = $plugin.FullName
            break
        }
    }
}

$subPath = Join-Path $env:TEMP "$name.zip"

Log "LOG" "Downloading $name"
if ($DownloadLink) { Log "AUX" $($link) }
Invoke-WebRequest -Uri $link -OutFile $subPath *> $null
if ( !( Test-Path $subPath ) ) {
    Log "ERR" "Failed to download $name"
    exit
}
Log "LOG" "Unzipping $name"
try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($subPath)
    foreach ($entry in $zip.Entries) {
        $destinationPath = Join-Path $Path $entry.FullName

        if (-not $entry.FullName.EndsWith('/') -and -not $entry.FullName.EndsWith('\')) {
            $parentDir = Split-Path -Path $destinationPath -Parent
            if ($parentDir -and $parentDir.Trim() -ne '') {
                $pathParts = $parentDir -replace [regex]::Escape($steam), '' -split '[\\/]' | Where-Object { $_ }
                $currentPath = $Path

                foreach ($part in $pathParts) {
                    $currentPath = Join-Path $currentPath $part
                    if (Test-Path $currentPath) {
                        $item = Get-Item $currentPath
                        if (-not $item.PSIsContainer) { Remove-Item $currentPath -Force }
                    }
                }

                [System.IO.Directory]::CreateDirectory($parentDir) | Out-Null
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destinationPath, $true)
            }
        }
    }
    $zip.Dispose()
}
catch {
    write-host "Error: $($_.Exception.Message)"
    if ($zip) { $zip.Dispose() }
    Log "ERR" "Extraction failed, trying normal way"
    Expand-Archive -Path $subPath -DestinationPath $Path -Force
}

if ( Test-Path $subPath ) { Remove-Item $subPath -ErrorAction SilentlyContinue }

Log "OK" "$upperName installed"


# Removing beta
$betaPath = Join-Path $steam "package\beta"
if ( Test-Path $betaPath ) { Remove-Item $betaPath -Recurse -Force }

# Removing potential x32
$cfgPath = Join-Path $steam "steam.cfg"
if ( Test-Path $cfgPath ) { Remove-Item $cfgPath -Recurse -Force }
Remove-ItemProperty -Path "HKCU:\Software\Valve\Steam"                 -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam"                 -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam"     -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue


# Toggling the plugin on
$configPath = Join-Path $steam "ext/config.json"
if (-not (Test-Path $configPath)) {
    $config = @{
        plugins = @{ enabledPlugins = @($name) }
        general = @{ checkForMillenniumUpdates = $false }
    }
    New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
}
else {
    $config = (Get-Content $configPath -Raw -Encoding UTF8) | ConvertFrom-Json

    function _EnsureProperty {
        param($Object, $PropertyName, $DefaultValue)
        if (-not $Object.$PropertyName) {
            $Object | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $DefaultValue -Force
        }
    }

    _EnsureProperty $config "general" @{}
    _EnsureProperty $config "general.checkForMillenniumUpdates" $false
    $config.general.checkForMillenniumUpdates = $false

    _EnsureProperty $config "plugins" @{ enabledPlugins = @() }
    _EnsureProperty $config "plugins.enabledPlugins" @()

    $pluginsList = @($config.plugins.enabledPlugins)
    if ($pluginsList -notcontains $name) {
        $pluginsList += $name
        $config.plugins.enabledPlugins = $pluginsList
    }

    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
}
Log "OK" "Plugin enabled"


# Result
Write-Host
if ($milleniumInstalling) { Log "WARN" "Steam startup will be longer, don't panic and don't touch anything in steam!" }

$exe = Join-Path $steam "steam.exe"
Start-Process $exe -ArgumentList "-clearbeta"

Log "INFO" "Starting steam"
Log "WARN" "Hey so there's a bug where steam may not start"
Log "WARN" "Hopefully this script fixes it"
Log "WARN" "But i had to turn updates of millennium off."
Log "WARN" "In future, they will come back but in the meantime:"
Log "OK"   "Manually check for updates of millennium if you want up to date."
Log "AUX"  "Millennium is working now tho (latest version)."
