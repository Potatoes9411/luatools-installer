# Anyone seeing this? well don't waste time improving this script.
# It's messy and just temporary until i get the new version.

param(
    [string]$DownloadLink, # Overwrites the download link (give a direct link)
    [string]$PluginName,   # Overwrites the plugin name
    [int]$Branch,          # Skip the menu and go straight to a branch (see menu for numbers)
    [switch]$SkipDefender  # Branch 6 only: skips adding Windows Defender exclusions
)

## Configure this
$Host.UI.RawUI.WindowTitle = "Luatools Tool Suite | .gg/luatools"
$name = "luatools"
$link = "https://github.com/piqseu/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"
$milleniumTimer = 5 # in seconds for auto-installation

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Steam path
$steam = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
if (-not $steam) { $steam = (Get-ItemProperty "HKLM:\SOFTWARE\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath }
if (-not $steam) { $steam = (Get-ItemProperty "HKCU:\Software\Valve\Steam"  -ErrorAction SilentlyContinue).SteamPath }

$upperName = $name.Substring(0, 1).ToUpper() + $name.Substring(1).ToLower()
if ($DownloadLink) { $link = $DownloadLink }
if ($PluginName)   { $name = $PluginName }


#### Logging ####
function Log {
    param ([string]$Type, [string]$Message, [boolean]$NoNewline = $false)
    $Type = $Type.ToUpper()
    switch ($Type) {
        "OK"    { $fg = "Green" }
        "INFO"  { $fg = "Cyan" }
        "ERR"   { $fg = "Red" }
        "WARN"  { $fg = "Yellow" }
        "LOG"   { $fg = "Magenta" }
        "AUX"   { $fg = "DarkGray" }
        default { $fg = "White" }
    }
    $date   = Get-Date -Format "HH:mm:ss"
    $prefix = if ($NoNewline) { "`r[$date] " } else { "[$date] " }
    Write-Host $prefix -ForegroundColor Cyan -NoNewline
    Write-Host "[$Type] $Message" -ForegroundColor $fg -NoNewline:$NoNewline
}

function Sep   { Write-Host ("=" * 63) -ForegroundColor Cyan }
function Blank { Write-Host "" }

$ProgressPreference = 'SilentlyContinue'

Log "WARN" "Hey! Just letting you know that i'm working on a new version combining various scripts of the server"
Log "AUX"  "Will include language support on THIS script too, luv y'all brazilians"
Blank


#### Main menu ####
function Get-PluginStatus([string]$pluginName) {
    if (-not $steam) { return "[unknown]" }
    $roots = Get-PluginRootPaths -steamBase $steam
    if (-not $roots -or $roots.Count -eq 0) { return "[not installed]" }
    foreach ($dir in $roots) {
        foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
            $jp = Join-Path $p.FullName "plugin.json"
            if (Test-Path $jp) {
                $j = try { Get-Content $jp -Raw | ConvertFrom-Json } catch { $null }
                if ($j -and $j.name -eq $pluginName) { return "[installed]" }
            }
        }
    }
    return "[not installed]"
}

function Get-SpacethemePaths {
    param([string]$steamBase)
    $paths = @()
    if ($steamBase) {
        $paths += Join-Path $steamBase "steamui\skins\Steam"
        $paths += Join-Path $steamBase "steamui\skins\spacetheme"
        $paths += Join-Path $steamBase "millennium\themes"
        $paths += Join-Path $steamBase "millennium\themes\Steam"
    }
    $paths += "C:\Program Files (x86)\Steam\millennium\themes"
    $paths += "C:\Program Files (x86)\Steam\millennium\themes\Steam"
    $paths += "C:\Program Files\Steam\millennium\themes"
    $paths += "C:\Program Files\Steam\millennium\themes\Steam"
    $paths += "C:\Program Files (x86)\Steam\steamui\skins\Steam"
    $paths += "C:\Program Files (x86)\Steam\steamui\skins\spacetheme"
    return $paths | Where-Object { Test-Path $_ } | Select-Object -Unique
}

function Get-SpacethemeStatus {
    if (-not $steam) { return "[unknown]" }
    $paths = Get-SpacethemePaths -steamBase $steam
    if ($paths.Count -gt 0) { return "[found]" }
    return "[not found]"
}

function Get-PluginRootPaths {
    param([string]$steamBase)
    $roots = @()
    if ($steamBase) {
        $roots += Join-Path $steamBase "plugins"
        $roots += Join-Path $steamBase "millennium\plugins"
    }
    $roots += "C:\Program Files (x86)\Steam\plugins"
    $roots += "C:\Program Files (x86)\Steam\millennium\plugins"
    $roots += "C:\Program Files\Steam\plugins"
    $roots += "C:\Program Files\Steam\millennium\plugins"
    return $roots | Where-Object { Test-Path $_ } | Select-Object -Unique
}

function Get-PluginRootPath {
    param([string]$steamBase)
    $roots = Get-PluginRootPaths -steamBase $steamBase
    if ($roots.Count -gt 0) { return $roots[0] }
    if ($steamBase) { return Join-Path $steamBase "plugins" }
    return "C:\Program Files (x86)\Steam\plugins"
}

function Prompt-ExitOrReturnToMenu {
    while ($true) {
        $answer = Read-Host "Done. Exit script? (Y/N)"
        switch ($answer.Trim().ToUpper()) {
            "Y" { exit 0 }
            "N" { return }
            default { Write-Host "Please answer Y or N." -ForegroundColor Yellow }
        }
    }
}

function Write-MainMenu {
    Clear-Host
    Sep
    Write-Host "  Luatools Tool Suite  |  .gg/luatools" -ForegroundColor Cyan
    Sep
    Blank

    Write-Host "  INSTALL / UPDATE" -ForegroundColor DarkGray
    Write-Host "  1   " -ForegroundColor Cyan -NoNewline
    Write-Host "Install Luatools plugin              " -NoNewline
    Write-Host (Get-PluginStatus "luatools") -ForegroundColor DarkGray

    Write-Host "  2   " -ForegroundColor Cyan -NoNewline
    Write-Host "Install steamtools-collection        " -NoNewline
    Write-Host (Get-PluginStatus "steamtools-collection") -ForegroundColor DarkGray

    Blank
    Write-Host "  FIXES" -ForegroundColor DarkGray

    Write-Host "  3   " -ForegroundColor Cyan -NoNewline
    Write-Host "Spacetheme Block Remover             " -NoNewline
    Write-Host (Get-SpacethemeStatus) -ForegroundColor DarkGray
    Write-Host "       " -NoNewline
    Write-Host "Removes the 'get a job loser' block  " -NoNewline
    Write-Host "by waike" -ForegroundColor DarkGray

    Blank
    Write-Host "  4   " -ForegroundColor Cyan -NoNewline
    Write-Host "Steam Offline Fix"
    Write-Host "       " -NoNewline
    Write-Host "Fixes Steam stuck on loading icon    " -NoNewline
    Write-Host "by waike" -ForegroundColor DarkGray

    Blank
    Write-Host "  6   " -ForegroundColor Cyan -NoNewline
    Write-Host "Steam Bulk Fixer"
    Write-Host "       " -NoNewline
    Write-Host "Runs various Steam/Steamtools fixes  " -NoNewline
    Write-Host "by waike" -ForegroundColor DarkGray

    Blank
    Write-Host "  OTHER" -ForegroundColor DarkGray

    Write-Host "  5   " -ForegroundColor Cyan -NoNewline
    Write-Host "ST Uninstaller"
    Write-Host "       " -NoNewline
    Write-Host "Full Steamtools/Luatools uninstaller " -NoNewline
    Write-Host "by Potatoes9411" -ForegroundColor DarkGray

    Blank
    Write-Host "  7   " -ForegroundColor Cyan -NoNewline
    Write-Host "Steam Manifest Downloader"
    Write-Host "       " -NoNewline
    Write-Host "Downloads depot manifests when       " -NoNewline
    Write-Host "by Skyflare (Modified by Potatoes9411)" -ForegroundColor DarkGray
    Write-Host "       " -NoNewline
    Write-Host "SteamTools servers are unavailable   " -ForegroundColor DarkGray

    Blank
    Write-Host "  8   " -ForegroundColor Cyan -NoNewline
    Write-Host "No Internet Connection Fix"
    Write-Host "       " -NoNewline
    Write-Host "Fixes Steam 'No Internet' errors via " -NoNewline
    Write-Host "Program by SelectivelyGood | Script by Peron" -ForegroundColor DarkGray
    Write-Host "       " -NoNewline
    Write-Host "CloudRedirectCLI /stfixer            " -ForegroundColor DarkGray

    Blank
    Write-Host "  9   " -ForegroundColor Cyan -NoNewline
    Write-Host "Download / Launch CloudRedirect (GUI)"
    Write-Host "       " -NoNewline
    Write-Host "Downloads & launches CloudRedirect   " -NoNewline
    Write-Host "by Potatoes9411 | App by SelectivelyGood" -ForegroundColor DarkGray
    Write-Host "       " -NoNewline
    Write-Host "GUI, or runs it if already installed " -ForegroundColor DarkGray

    Blank
    Write-Host "  10  " -ForegroundColor Cyan -NoNewline
    Write-Host "Millennium & SteamTools Reinstaller"
    Write-Host "       " -NoNewline
    Write-Host "Reinstalls Millennium + SteamTools,  " -NoNewline
    Write-Host "by clem.la & melly" -ForegroundColor DarkGray
    Write-Host "       " -NoNewline
    Write-Host "fixes hardlink errors on reinstall   " -ForegroundColor DarkGray

    Blank
    Write-Host "  Q   " -ForegroundColor DarkGray -NoNewline
    Write-Host "Quit"
    Blank
}

if (-not $Branch) {
    while ($true) {
        Write-MainMenu
        $sel = Read-Host "Select an option"
        switch ($sel.Trim().ToUpper()) {
            "1" { $Branch = 1; break }
            "2" { $Branch = 2; break }
            "3" { $Branch = 3; break }
            "4" { $Branch = 4; break }
            "5" { $Branch = 5; break }
            "6" {
                $Branch = 6
                $defChoice = Read-Host "Skip Windows Defender exclusions? (y/N)"
                if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                break
            }
            "7" { $Branch = 7; break }
            "8" { $Branch = 8; break }
            "9" { $Branch = 9; break }
            "10" { $Branch = 10; break }
            "Q" { exit 0 }
            default { continue }
        }
        if ($Branch -ne 0) { break }
    }
    Blank
}

:MainLoop
while ($true) {

# Apply branch 2 name/link (works for both -Branch 2 and menu selection)
if ($Branch -eq 2) {
    $name = "steamtools-collection"
    $link = "https://github.com/clemdotla/steamtools-collection/releases/download/Latest/steamtools-collection.zip"
    $upperName = "Steamtools-collection"
}


#### Branch 3: Spacetheme Block Remover (by waike - waike.dev) ####
if ($Branch -eq 3) {
    Log "INFO" "Spacetheme Block Remover"
    Log "AUX"  "Removes the 'get a job loser' text blocking your Steam client."
    Log "AUX"  "Credit: waike (waike.dev)"
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

    function Find-SpacethemeRoots {
        param([string]$steamBase)

        $paths = @()
        if ($steamBase) {
            $paths += Join-Path $steamBase "steamui\skins\Steam"
            $paths += Join-Path $steamBase "steamui\skins\spacetheme"
            $paths += Join-Path $steamBase "millennium\themes"
            $paths += Join-Path $steamBase "millennium\themes\Steam"
        }

        $paths += "C:\Program Files (x86)\Steam\millennium\themes"
        $paths += "C:\Program Files (x86)\Steam\millennium\themes\Steam"
        $paths += "C:\Program Files\Steam\millennium\themes"
        $paths += "C:\Program Files\Steam\millennium\themes\Steam"
        $paths += "C:\Program Files (x86)\Steam\steamui\skins\Steam"
        $paths += "C:\Program Files (x86)\Steam\steamui\skins\spacetheme"

        return $paths | Where-Object { Test-Path $_ } | Select-Object -Unique
    }

    $steamPath = Get-SteamPath
    if (-not $steamPath) {
        Log "ERR" "Steam not found."
        Prompt-ExitOrReturnToMenu
        $Branch = 0
        continue MainLoop
    }

    $themeRoots = Find-SpacethemeRoots -steamBase $steamPath
    if (-not $themeRoots -or $themeRoots.Count -eq 0) {
        Log "ERR" "Spacetheme was not found. Is it installed in Steam or Millennium themes?"
        Prompt-ExitOrReturnToMenu
        $Branch = 0
        continue MainLoop
    }

    Log "WARN" "Closing all Steam processes..."
    Get-Process -Name "steam" -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    Start-Sleep -Seconds 1
    Get-Process -Name "steam","steamwebhelper","steamerrorreporter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Stop-Service "Steam Client Service" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Get-Process -Name "steam","steamwebhelper","steamservice","steamerrorreporter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1

    $pattern = '(?is)/\*\s*\r?\n?\s*&\s*Ban piracy plugins.*?color:\s*#fff\s*!important;\s*\}'
    $patchedFiles = @()

    foreach ($root in $themeRoots) {
        Log "INFO" "Scanning theme path: $root"
        foreach ($cssFile in Get-ChildItem -Path $root -Recurse -Filter "*.css" -ErrorAction SilentlyContinue) {
            $content = Get-Content $cssFile.FullName -Raw
            if ($content -match $pattern) {
                $content = $content -replace $pattern, '/* Patched piracy warning block */'
                Set-Content -Path $cssFile.FullName -Value $content -NoNewline -Encoding UTF8
                $patchedFiles += $cssFile.FullName
                Log "OK" "Patched $($cssFile.FullName)"
            }
        }
    }

    if ($patchedFiles.Count -gt 0) {
        Log "OK" "Patched $($patchedFiles.Count) Spacetheme CSS file(s)"
    } else {
        Log "INFO" "Nothing to patch in matched Spacetheme CSS files — block may already be removed."
    }

    Blank
    Prompt-ExitOrReturnToMenu
    $Branch = 0
    continue MainLoop
}


#### Branch 4: Steam Offline Fix (by waike - waike.dev) ####
if ($Branch -eq 4) {
    Log "INFO" "Steam Offline Fix"
    Log "AUX"  "Steamtools sometimes forces offline mode — this attempts to fix the loading icon issue."
    Log "AUX"  "Credit: waike (waike.dev)"
    Blank

    $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -ErrorAction SilentlyContinue).InstallPath
    if (-not $steamPath) { $steamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam' -ErrorAction SilentlyContinue).InstallPath }
    if (-not $steamPath) {
        Log "ERR" "Steam path not found."
        Read-Host "Press Enter to exit"
        exit 1
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

    Blank
    Prompt-ExitOrReturnToMenu
    $Branch = 0
    continue MainLoop
}


#### Branch 5: ST Uninstaller (by Potatoes9411) ####
if ($Branch -eq 5) {
    $Host.UI.RawUI.WindowTitle = "Luatools Uninstaller | .gg/luatools"

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
        Prompt-ExitOrReturnToMenu
        $Branch = 0
        continue MainLoop
    }

    function Test-PluginInstalled {
        $pluginRoots = Get-PluginRootPaths -steamBase $steam
        foreach ($dir in $pluginRoots) {
            foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
                $jp = Join-Path $p.FullName "plugin.json"
                if (Test-Path $jp) {
                    $j = try { Get-Content $jp -Raw | ConvertFrom-Json } catch { $null }
                    if ($j -and $j.name -eq $name) { return $true }
                }
            }
        }
        return $false
    }

    function Test-SteamtoolsInstalled {
        $hasDll = (@("dwmapi.dll","xinput1_4.dll") | Where-Object { Test-Path (Join-Path $steam $_) }).Count -gt 0
        return ($hasDll -or (Test-Path "C:\Program Files\SteamTools"))
    }

    function Test-MillenniumInstalled {
        $millenniumMarkers = @(
            "millennium.dll",
            "python311.dll",
            "python311.zip",
            "version.dll",
            "user32.dll",
            "winmm.dll",
            "millennium_bootstrap.dll",
            "ext",
            "millennium",
            "pkg"
        )
        return ($millenniumMarkers | Where-Object { Test-Path (Join-Path $steam $_) }).Count -gt 0
    }

    function Get-LuaFileCount {
        $p = Join-Path $steam "config\stplug-in"
        if (-not (Test-Path $p)) { return 0 }
        return @(Get-ChildItem -Path $p -Filter "*.lua" -ErrorAction SilentlyContinue).Count
    }

    function Uninstall-Plugin {
        Blank; Sep; Log "INFO" "Uninstalling plugin: $name"; Sep; Blank

        $pluginRoots = Get-PluginRootPaths -steamBase $steam
        if (-not $pluginRoots -or $pluginRoots.Count -eq 0) { Log "WARN" "Plugins directory not found."; return }

        $pluginPath = $null
        foreach ($dir in $pluginRoots) {
            foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
                $jp = Join-Path $p.FullName "plugin.json"
                if (Test-Path $jp) {
                    $j = try { Get-Content $jp -Raw | ConvertFrom-Json } catch { $null }
                    if ($j -and $j.name -eq $name) { $pluginPath = $p.FullName; break }
                }
            }
            if ($pluginPath) { break }
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
            $config = try { (Get-Content $configPath -Raw -Encoding UTF8) | ConvertFrom-Json } catch { $null }
            if ($config -and $config.plugins -and $config.plugins.enabledPlugins) {
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

        $milFiles   = @(
            "millennium.dll",
            "python311.dll",
            "python311.zip",
            "version.dll",
            "user32.dll",
            "winmm.dll",
            "millennium_bootstrap.dll"
        )
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

    function Restart-SteamApp {
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

    function Write-UninstallMenu {
        Clear-Host
        Sep
        Write-Host "  ST Uninstaller  |  .gg/luatools  |  by Potatoes9411" -ForegroundColor Cyan
        Sep
        Blank

        function Checkbox([bool]$on) { if ($on) { "[X]" } else { "[ ]" } }
        function InstallStatus([bool]$found) { if ($found) { "[installed]" } else { "[not found]" } }

        Write-Host "  WHAT TO UNINSTALL" -ForegroundColor DarkGray
        Write-Host "  1   " -ForegroundColor Cyan -NoNewline
        Write-Host "$(Checkbox $doPlugin) Plugin ($name)        " -NoNewline
        Write-Host (InstallStatus (Test-PluginInstalled)) -ForegroundColor DarkGray

        Write-Host "  2   " -ForegroundColor Cyan -NoNewline
        Write-Host "$(Checkbox $doSteamtools) SteamTools            " -NoNewline
        Write-Host (InstallStatus (Test-SteamtoolsInstalled)) -ForegroundColor DarkGray

        Write-Host "  3   " -ForegroundColor Cyan -NoNewline
        Write-Host "$(Checkbox $doMillennium) Millennium            " -NoNewline
        Write-Host (InstallStatus (Test-MillenniumInstalled)) -ForegroundColor DarkGray

        Blank
        Write-Host "  OPTIONS" -ForegroundColor DarkGray

        $luaLabel = if ($luaCount -gt 0) { "($luaCount file(s) found)" } else { "(none found)" }
        Write-Host "  4   " -ForegroundColor Cyan -NoNewline
        Write-Host "$(Checkbox $doLuas) Remove SteamTools Lua files   " -NoNewline
        Write-Host $luaLabel -ForegroundColor DarkGray

        Write-Host "  5   " -ForegroundColor Cyan -NoNewline
        Write-Host "$(Checkbox $doKeepPlugins) Keep Millennium plugins folder"

        Blank
        Write-Host "  R   " -ForegroundColor Green -NoNewline; Write-Host "Run"
        Write-Host "  Q   " -ForegroundColor DarkGray -NoNewline; Write-Host "Quit"
        Blank
    }

    while ($true) {
        Write-UninstallMenu
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
                if ($restart.Trim() -ieq "y") { Restart-SteamApp }

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
    Blank

    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if (-not $IsAdmin) {
        Log "WARN" "Not running as admin — Windows Defender changes won't run."
        Blank
        $choice = Read-Host "Are you sure you want to continue? (Y/N)"
        if ($choice -notin @("Y","y")) {
            Log "ERR" "Cancelled."
            Start-Sleep -Seconds 1
            exit
        }
        Log "INFO" "Continuing..."
    }

    if ($SkipDefender) {
        Log "AUX" "Skipping Windows Defender exclusions (-SkipDefender flag set)"
        $env:SKIP_DEFENDER = "1"
    }

    Blank
    Log "INFO" "Starting..."

    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if (-not $steamPath -or -not (Test-Path $steamPath)) {
        Log "ERR" "Steam not found."
        Read-Host "Press Enter to exit"
        exit
    }

    Log "AUX" "Steam path: $steamPath"

    Log "WARN" "Closing Steam..."
    while (Get-Process steam, steamwebhelper -ErrorAction SilentlyContinue) {
        Get-Process steam, steamwebhelper -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep 1
    }
    Log "OK" "Steam closed."

    if ($IsAdmin -and $env:SKIP_DEFENDER -ne "1") {
        Log "INFO" "Adding Defender exclusion..."
        try {
            Add-MpPreference -ExclusionPath $steamPath -ErrorAction Stop
            Log "OK" "Defender updated."
        } catch {
            Log "WARN" "Defender change failed."
        }
    } else {
        Log "AUX" "Skipping Defender changes."
    }

    Log "INFO" "Downloading DLLs..."
    $urls = @{
        "xinput1_4.dll" = "http://update.steamox.com/update"
        "dwmapi.dll"    = "http://update.steamox.com/dwmapi"
    }
    foreach ($dll in $urls.Keys) {
        $dest = Join-Path $steamPath $dll
        Log "LOG" "Getting $dll..."
        try {
            Invoke-RestMethod -Uri $urls[$dll] -OutFile $dest
            Log "OK" "$dll done."
        } catch {
            Log "ERR" "Failed to download $dll"
        }
    }
    Log "OK" "DLLs finished."

    Log "INFO" "Running Luatools temporary fixer..."
    try {
        Invoke-Expression (Invoke-RestMethod "https://luatools.vercel.app/temporary-fixer.ps1")
    } catch {
        Log "WARN" "Fixer failed."
    }

    Log "INFO" "Installing LuaTools plugin..."
    try {
        Invoke-Expression (Invoke-RestMethod "https://luatools.vercel.app/install-plugin.ps1")
    } catch {
        Log "WARN" "LuaTools install failed."
    }

    Log "INFO" "Launching Steam..."
    Start-Process (Join-Path $steamPath "steam.exe")

    Blank
    Log "OK" "Done."
    Blank
    Prompt-ExitOrReturnToMenu
    $Branch = 0
    continue MainLoop
}


#### Branch 7: Steam Manifest Downloader (by Skyflare - Modified by Potatoes9411) ####
if ($Branch -eq 7) {
    Log "INFO" "Steam Manifest Downloader"
    Log "AUX"  "Downloads depot manifests when SteamTools servers are unavailable."
    Log "AUX"  "Credit: Skyflare (Modified by Potatoes9411)"
    Blank

    # ---- Manifest Downloader: Inner functions (scoped to avoid collisions) ----

    function Write-ManifestHeader {
        param([string]$Mode = "github")
        # Clickable hyperlinks using ANSI escape sequences (works in Windows Terminal)
        $esc = [char]27
        if ($Mode -eq "github+morrenus") {
            $sourceLink = "$esc]8;;https://hubcapmanifest.com/$esc\Morrenus$esc]8;;$esc\"
            $sourcePad  = "          "
        } elseif ($Mode -eq "github+manifesthub") {
            $sourceLink = "$esc]8;;https://github.com/SteamAutoCracks/ManifestHub$esc\ManifestHub$esc]8;;$esc\"
            $sourcePad  = "       "
        } else {
            $sourceLink = "$esc]8;;https://github.com/qwe213312/k25FCdfEOoEJ42S6$esc\GitHub Mirror$esc]8;;$esc\"
            $sourcePad  = "    "
        }
        $discordLink = "$esc]8;;https://discord.gg/luatools$esc\discord.gg/luatools$esc]8;;$esc\"
        Write-Host "  +================================================================+" -ForegroundColor Cyan
        Write-Host "  |        STEAM MANIFEST DOWNLOADER (For Steamtools)              |" -ForegroundColor Cyan
        Write-Host "  |   Downloads Out-Of-Date Manifest Files From $sourceLink$sourcePad|" -ForegroundColor Cyan
        Write-Host "  |                                                                |" -ForegroundColor Cyan
        Write-Host "  |                   by $discordLink                       |" -ForegroundColor DarkCyan
        Write-Host "  +================================================================+" -ForegroundColor Cyan
        Write-Host ""
    }

    function Write-ManifestProgressBar {
        param(
            [int]$Current,
            [int]$Total,
            [string]$Label,
            [int]$Width = 40,
            [ConsoleColor]$Color = "Green"
        )
        $percent = if ($Total -gt 0) { [math]::Round(($Current / $Total) * 100) } else { 0 }
        $filled = [math]::Floor(($Current / [math]::Max($Total, 1)) * $Width)
        $empty = $Width - $filled
        $barFilled = "#" * $filled
        $barEmpty = "-" * $empty
        Write-Host ("`r  {0} [{1}" -f $Label, $barFilled) -NoNewline
        Write-Host $barEmpty -NoNewline -ForegroundColor DarkGray
        Write-Host ("] {0}% ({1}/{2})    " -f $percent, $Current, $Total) -NoNewline
    }

    function Write-ManifestBatchProgress {
        param(
            [int]$Current,
            [int]$Total,
            [DateTime]$StartTime,
            [int]$Width = 40
        )
        $percent = if ($Total -gt 0) { [math]::Round(($Current / $Total) * 100) } else { 0 }
        $filled = [math]::Floor(($Current / [math]::Max($Total, 1)) * $Width)
        $empty = $Width - $filled
        $barFilled = "#" * $filled
        $barEmpty = "-" * $empty
        $etaString = "--:--"
        if ($Current -gt 0 -and $Current -lt $Total) {
            $elapsed = (Get-Date) - $StartTime
            $secondsPerItem = $elapsed.TotalSeconds / $Current
            $remainingItems = $Total - $Current
            $etaSeconds = $secondsPerItem * $remainingItems
            $etaTimeSpan = [TimeSpan]::FromSeconds($etaSeconds)
            if ($etaTimeSpan.TotalHours -ge 1) {
                $etaString = $etaTimeSpan.ToString("hh\:mm\:ss")
            } else {
                $etaString = $etaTimeSpan.ToString("mm\:ss")
            }
        } elseif ($Current -eq $Total) {
            $etaString = "00:00"
        }
        # Removed \r and -NoNewline because this is drawn fresh after a Clear-Host
        Write-Host ("  BATCH PROGRESS [{0}{1}] {2}% ({3}/{4}) | ETA: {5}" -f $barFilled, $barEmpty, $percent, $Current, $Total, $etaString) -ForegroundColor Magenta
    }

    function Write-ManifestStatus {
        param([string]$Message, [ConsoleColor]$Color = "White")
        Write-Host "  [*] $Message" -ForegroundColor $Color
    }

    function Write-ManifestSuccess {
        param([string]$Message)
        Write-Host "  [+] $Message" -ForegroundColor Green
    }

    function Write-ManifestErrorMsg {
        param([string]$Message)
        Write-Host "  [-] $Message" -ForegroundColor Red
    }

    function Write-ManifestWarningMsg {
        param([string]$Message)
        Write-Host "  [!] $Message" -ForegroundColor Yellow
    }

    function Exit-ManifestWithPrompt {
        Write-Host ""
        Write-Host "  Press any key to return to main menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $script:_manifestAbort = $true
    }

    function Get-ManifestSteamPath {
        $registryPaths = @(
            "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam",
            "HKLM:\SOFTWARE\Valve\Steam",
            "HKCU:\SOFTWARE\Valve\Steam"
        )
        foreach ($path in $registryPaths) {
            try {
                $steamPath = (Get-ItemProperty -Path $path -ErrorAction SilentlyContinue).InstallPath
                if ($steamPath -and (Test-Path $steamPath)) {
                    return $steamPath
                }
            } catch {}
        }
        return $null
    }

    function Get-DepotIdsFromLua {
        param([string]$LuaPath)
        $depots = @()
        $content = Get-Content -Path $LuaPath -ErrorAction Stop
        foreach ($line in $content) {
            if ($line -match 'addappid\s*\(\s*(\d+)\s*,\s*\d+\s*,\s*"[a-fA-F0-9]+"') {
                $depotId = $matches[1]
                $depots += $depotId
            }
        }
        return $depots | Select-Object -Unique
    }

    function Get-AppInfo {
        param([string]$AppId)
        $url = "https://api.steamcmd.net/v1/info/$AppId"
        try {
            $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 30
            return $response
        } catch {
            return $null
        }
    }

    function Get-ManifestIdForDepot {
        param(
            [object]$AppInfo,
            [string]$AppId,
            [string]$DepotId
        )
        try {
            $depots = $AppInfo.data.$AppId.depots
            if ($depots.$DepotId -and $depots.$DepotId.manifests -and $depots.$DepotId.manifests.public) {
                return $depots.$DepotId.manifests.public.gid
            }
        } catch {}
        return $null
    }

    function Try-DownloadUrl {
        param(
            [string]$Url,
            [string]$OutputFile,
            [int]$MaxRetries,
            [string]$Label,
            [int]$RetryDelaySeconds = 3
        )
        $lastError = $null
        for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
            try {
                if (Test-Path $OutputFile) {
                    Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
                }
                Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 120 -OutFile $OutputFile -ErrorAction Stop
                if (Test-Path $OutputFile) {
                    $fileSize = (Get-Item $OutputFile).Length
                    if ($fileSize -gt 0) {
                        return @{ Success = $true; Is404 = $false; Size = $fileSize; Attempts = $attempt }
                    }
                }
                $lastError = "Empty file received"
            } catch {
                $statusCode = $null
                if ($_.Exception.Response) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                }
                if ($statusCode -eq 404) {
                    if (Test-Path $OutputFile) { Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue }
                    return @{ Success = $false; Is404 = $true; Error = "Not found (404)"; Attempts = $attempt }
                }
                $lastError = $_.Exception.Message
            }
            if ($attempt -lt $MaxRetries) {
                Write-Host "      Attempt $attempt failed ($Label): $lastError" -ForegroundColor DarkYellow
                Write-Host "      Retrying in ${RetryDelaySeconds}s..." -ForegroundColor DarkGray
                Start-Sleep -Seconds $RetryDelaySeconds
            }
        }
        return @{ Success = $false; Is404 = $false; Error = $lastError; Attempts = $MaxRetries }
    }

    function Download-Manifest {
        param(
            [string]$DepotId,
            [string]$ManifestId,
            [string]$OutputPath,
            [string]$Mode,
            [string]$ApiKey,
            [int]$RetryDelaySeconds = 3
        )
        $outputFile = Join-Path $OutputPath "${DepotId}_${ManifestId}.manifest"
        $githubUrl = "https://raw.githubusercontent.com/qwe213312/k25FCdfEOoEJ42S6/main/${DepotId}_${ManifestId}.manifest"
        $githubResult = Try-DownloadUrl -Url $githubUrl -OutputFile $outputFile -MaxRetries 2 -Label "GitHub" -RetryDelaySeconds $RetryDelaySeconds
        if ($githubResult.Success) {
            return @{ Success = $true; FilePath = $outputFile; Size = $githubResult.Size; Attempts = $githubResult.Attempts }
        }
        if ($githubResult.Is404 -and $Mode -ne "github") {
            if ($Mode -eq "github+morrenus") {
                Write-Host "      Not on GitHub, trying Morrenus..." -ForegroundColor DarkGray
                $secondaryUrl = "https://hubcapmanifest.com/api/v1/generate/manifest?depot_id=${DepotId}&manifest_id=${ManifestId}&api_key=${ApiKey}"
                $secondaryLabel = "Morrenus"
            } else {
                Write-Host "      Not on GitHub, trying ManifestHub..." -ForegroundColor DarkGray
                $secondaryUrl = "https://api.manifesthub1.filegear-sg.me/manifest?apikey=${ApiKey}&depotid=${DepotId}&manifestid=${ManifestId}"
                $secondaryLabel = "ManifestHub"
            }
            $secondaryResult = Try-DownloadUrl -Url $secondaryUrl -OutputFile $outputFile -MaxRetries 5 -Label $secondaryLabel -RetryDelaySeconds $RetryDelaySeconds
            if ($secondaryResult.Success) {
                return @{ Success = $true; FilePath = $outputFile; Size = $secondaryResult.Size; Attempts = $secondaryResult.Attempts }
            }
            return @{ Success = $false; Error = $secondaryResult.Error; Attempts = $secondaryResult.Attempts }
        }
        return @{ Success = $false; Error = $githubResult.Error; Attempts = $githubResult.Attempts }
    }

    function Format-ManifestFileSize {
        param([long]$Bytes)
        if ($Bytes -ge 1MB) {
            return "{0:N2} MB" -f ($Bytes / 1MB)
        } elseif ($Bytes -ge 1KB) {
            return "{0:N2} KB" -f ($Bytes / 1KB)
        } else {
            return "$Bytes B"
        }
    }

    # ---- Manifest Downloader: Main execution ----

    $script:_manifestAbort = $false

    # Mode selection
    $manifestApiKey      = $ApiKey
    $manifestMorrenusKey = $MorrenusApiKey
    $manifestAppId       = $AppId

    if ($env:MANIFEST_MODE) {
        $resolvedMode = $env:MANIFEST_MODE
    } else {
        Clear-Host
        Write-ManifestHeader -Mode "github"
        Write-Host "  Select download mode:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    1. Github Mirror    (No Key Required, Try This First!)" -ForegroundColor White
        Write-Host "    2. Morrenus         (Free Key from https://hubcapmanifest.com/)" -ForegroundColor White
        Write-Host "    3. ManifestHub      (Free Key from https://manifesthub1.filegear-sg.me/)" -ForegroundColor White
        Write-Host ""
        do {
            $modeChoice = Read-Host "  Enter choice (1-3)"
        } while ($modeChoice -notin @("1","2","3"))
        $resolvedMode = switch ($modeChoice) {
            "1" { "github" }
            "2" { "github+morrenus" }
            "3" { "github+manifesthub" }
        }
    }

    Clear-Host
    Write-ManifestHeader -Mode $resolvedMode

    $activeApiKey = $null

    if ($resolvedMode -eq "github") {
        Write-Host "  [MODE] GitHub Only - No API key required" -ForegroundColor Yellow
    } elseif ($resolvedMode -eq "github+morrenus") {
        Write-Host "  [MODE] GitHub + Morrenus - Morrenus API as fallback" -ForegroundColor Cyan
        $activeApiKey = $manifestMorrenusKey
        if (-not $activeApiKey) { $activeApiKey = $env:MORRENUS_API_KEY }
        if (-not $activeApiKey) {
            Write-Host ""
            Write-Host "  How to get your Morrenus API key:" -ForegroundColor DarkGray
            Write-Host "    1. Login at https://hubcapmanifest.com/ with your Discord account" -ForegroundColor DarkGray
            Write-Host "    2. Generate your key at https://hubcapmanifest.com/api-keys/user" -ForegroundColor DarkGray
            Write-Host "    3. Or get it from LuaTools plugin settings if you set it there" -ForegroundColor DarkGray
            Write-Host ""
            $activeApiKey = Read-Host "  Enter Morrenus API Key"
        }
        if ([string]::IsNullOrWhiteSpace($activeApiKey)) {
            Write-ManifestErrorMsg "Morrenus API Key is required!"
            Exit-ManifestWithPrompt
        }
        if ($script:_manifestAbort) { }
        # Validate key format: smm_ prefix + 96 hex chars = 100 total
        elseif ($activeApiKey -notmatch '^smm_[0-9a-f]{96}$') {
            Write-ManifestErrorMsg "Invalid Morrenus API key format!"
            Write-Host "  Expected: smm_ followed by 96 hex characters (total 100 chars)" -ForegroundColor DarkGray
            Exit-ManifestWithPrompt
        }
        if ($script:_manifestAbort) { }
        # Validate key against Morrenus API
        else {
        Write-Host ""
        Write-ManifestStatus "Validating Morrenus API key..."
        try {
            $statsResponse = Invoke-RestMethod -Uri "https://hubcapmanifest.com/api/v1/user/stats?api_key=$activeApiKey" -Method Get -TimeoutSec 15 -ErrorAction Stop
            if (-not $statsResponse.can_make_requests) {
                Write-ManifestErrorMsg "Your Morrenus key has hit its daily limit ($($statsResponse.daily_usage)/$($statsResponse.daily_limit)). Try again tomorrow."
                Exit-ManifestWithPrompt
            }
            Write-ManifestSuccess "Welcome back $($statsResponse.username)! Fetching depots now!"
        } catch {
            $statusCode = $null
            if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
            if ($statusCode -eq 401 -or $statusCode -eq 403 -or $statusCode -eq 404) {
                Write-ManifestErrorMsg "API key not found or expired."
            } else {
                try {
                    $errBody = $_.ErrorDetails.Message | ConvertFrom-Json
                    Write-ManifestErrorMsg $errBody.detail
                } catch {
                    Write-ManifestErrorMsg "Failed to validate Morrenus API key: $($_.Exception.Message)"
                }
            }
            Exit-ManifestWithPrompt
        }
        }
    } elseif ($resolvedMode -eq "github+manifesthub") {
        Write-Host "  [MODE] GitHub + ManifestHub - ManifestHub API as fallback" -ForegroundColor Cyan
        $activeApiKey = $manifestApiKey
        if (-not $activeApiKey) { $activeApiKey = $env:MH_API_KEY }
        if (-not $activeApiKey) {
            Write-Host "  Get your API key from: " -NoNewline
            Write-Host "https://manifesthub1.filegear-sg.me/" -ForegroundColor Yellow
            Write-Host ""
            $activeApiKey = Read-Host "  Enter ManifestHub API Key"
        }
        if ([string]::IsNullOrWhiteSpace($activeApiKey)) {
            Write-ManifestErrorMsg "ManifestHub API Key is required!"
            Exit-ManifestWithPrompt
        }
    }

    if (-not $script:_manifestAbort) {

    # Find Steam installation early since batch processing needs it
    Write-ManifestStatus "Locating Steam installation..."
    $manifestSteamPath = Get-ManifestSteamPath

    if (-not $manifestSteamPath) {
        Write-ManifestErrorMsg "Could not find Steam installation!"
        Read-Host "Press Enter to exit"
        exit
    }

    Write-ManifestSuccess "Steam found at: $manifestSteamPath"
    Write-Host ""

    while ($true) {

        Write-Host "  ================================================================" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Select processing mode:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    1. Process a single game (Enter AppID manually)" -ForegroundColor White
        Write-Host "    2. Patch ALL games (Scan all .lua files systematically)" -ForegroundColor White
        Write-Host ""
        do {
            $processChoice = Read-Host "  Enter choice (1-2)"
        } while ($processChoice -notin @("1","2"))

        $appIdsToProcess = @()

        if ($processChoice -eq "1") {
            $promptAppId = $env:APP_ID
            if (-not $promptAppId) {
                $promptAppId = Read-Host "  Enter Steam AppID (Not Depot ID or DLC ID)"
            }
            if ([string]::IsNullOrWhiteSpace($promptAppId) -or $promptAppId -notmatch '^\d+$') {
                Write-ManifestErrorMsg "Valid App ID is required!"
                continue
            }
            $appIdsToProcess += $promptAppId
        } else {
            $luaDir = Join-Path $manifestSteamPath "config\stplug-in"
            if (-not (Test-Path $luaDir)) {
                Write-ManifestErrorMsg "stplug-in directory not found at $luaDir"
                continue
            }
            Write-ManifestStatus "Scanning $luaDir for .lua files..."
            $luaFiles = Get-ChildItem -Path $luaDir -Filter "*.lua"
            if ($luaFiles.Count -eq 0) {
                Write-ManifestErrorMsg "No .lua files found in stplug-in directory!"
                continue
            }
            Write-ManifestSuccess "Found $($luaFiles.Count) game configuration files."
            
            # Cache all found AppIDs before starting the loop
            foreach ($file in $luaFiles) {
                if ($file.BaseName -match '^\d+$') {
                    $appIdsToProcess += $file.BaseName
                }
            }
            
            # Give the user a moment to see the scan result before clearing screen
            Start-Sleep -Seconds 2
        }

        if ($appIdsToProcess.Count -eq 0) {
            Write-ManifestErrorMsg "No valid AppIDs found to process."
            continue
        }

        $globalSuccessCount = 0
        $globalSkippedCount = 0
        $globalFailedDepots = @()
        $globalTotalSize = 0
        $globalDownloadQueueCount = 0
        $batchStartTime = Get-Date

        for ($appIndex = 0; $appIndex -lt $appIdsToProcess.Count; $appIndex++) {
            $currentAppId = $appIdsToProcess[$appIndex]

            # Clear screen and redraw header for every single app to prevent console spam
            Clear-Host
            Write-ManifestHeader -Mode $resolvedMode
            Write-Host ""

            # Draw Batch Progress Bar at the top if processing multiple apps
            if ($appIdsToProcess.Count -gt 1) {
                Write-ManifestBatchProgress -Current $appIndex -Total $appIdsToProcess.Count -StartTime $batchStartTime
                Write-Host "`n"
            }

            Write-Host "  PROCESSING APPID: $currentAppId" -ForegroundColor Cyan
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray

            # Check for Lua file
            $luaPath = Join-Path $manifestSteamPath "config\stplug-in\$currentAppId.lua"
            Write-ManifestStatus "Looking for Lua file: $luaPath"

            if (-not (Test-Path $luaPath)) {
                Write-ManifestWarningMsg "Lua file not present for AppID $currentAppId"
                Write-Host "  Expected path: $luaPath" -ForegroundColor DarkGray
                Write-Host ""
                Start-Sleep -Seconds 1
                continue
            }

            Write-ManifestSuccess "Lua file found!"
            Write-Host ""

            # Parse Lua file for depot IDs
            Write-ManifestStatus "Parsing Lua file for depot IDs..."
            $depotIds = Get-DepotIdsFromLua -LuaPath $luaPath

            if ($depotIds.Count -eq 0) {
                Write-ManifestWarningMsg "No depot IDs found in Lua file!"
                Write-Host ""
                Start-Sleep -Seconds 1
                continue
            }

            Write-ManifestSuccess "Found $($depotIds.Count) depot ID(s) in Lua file"
            Write-Host ""

            # Display found depot IDs
            Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray
            Write-Host "  | Depot IDs found:                                              |" -ForegroundColor DarkGray
            $depotList = ($depotIds -join ", ")
            if ($depotList.Length -gt 55) {
                $depotList = $depotList.Substring(0, 52) + "..."
            }
            $paddedDepotList = $depotList.PadRight(60)
            Write-Host "  | $paddedDepotList|" -ForegroundColor White
            Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray
            Write-Host ""

            # Get app info from SteamCMD API
            Write-ManifestStatus "Fetching app info from SteamCMD API..."
            $appInfo = Get-AppInfo -AppId $currentAppId

            if (-not $appInfo -or $appInfo.status -ne "success") {
                Write-ManifestWarningMsg "Failed to fetch app info from SteamCMD API!"
                Write-Host ""
                Start-Sleep -Seconds 1
                continue
            }

            Write-ManifestSuccess "App info retrieved successfully"
            Write-Host ""

            # Match depot IDs with manifest IDs
            Write-ManifestStatus "Matching depot IDs with manifest IDs..."
            $downloadQueue = @()

            foreach ($depotId in $depotIds) {
                $manifestId = Get-ManifestIdForDepot -AppInfo $appInfo -AppId $currentAppId -DepotId $depotId

                if ($manifestId) {
                    $downloadQueue += @{
                        DepotId = $depotId
                        ManifestId = $manifestId
                    }
                }
            }

            if ($downloadQueue.Count -eq 0) {
                Write-ManifestWarningMsg "No matching manifests found for any depot IDs!"
                Write-Host ""
                Start-Sleep -Seconds 1
                continue
            }

            Write-ManifestSuccess "Found $($downloadQueue.Count) depot(s) with available manifests"
            Write-Host ""

            $globalDownloadQueueCount += $downloadQueue.Count

            # Prepare output directory
            $depotCachePath = Join-Path $manifestSteamPath "depotcache"
            if (-not (Test-Path $depotCachePath)) {
                New-Item -ItemType Directory -Path $depotCachePath -Force | Out-Null
            }

            Write-ManifestStatus "Output directory: $depotCachePath"
            Write-Host ""

            # ===========================================================================
            # DOWNLOAD SECTION
            # ===========================================================================

            Write-Host "  DOWNLOADING MANIFESTS" -ForegroundColor Cyan
            Write-Host ""

            for ($i = 0; $i -lt $downloadQueue.Count; $i++) {
                $item = $downloadQueue[$i]
                $depotId = $item.DepotId
                $manifestId = $item.ManifestId

                # Update app progress
                Write-Host ""
                Write-ManifestProgressBar -Current ($i) -Total $downloadQueue.Count -Label "App Download Progress" -Color Cyan
                Write-Host ""
                Write-Host ""

                # Check if manifest up-to-date
                $existingFile = Join-Path $depotCachePath "${depotId}_${manifestId}.manifest"
                if (Test-Path $existingFile) {
                    $existingSize = (Get-Item $existingFile).Length
                    if ($existingSize -gt 0) {
                        $globalSkippedCount++
                        $sizeStr = Format-ManifestFileSize -Bytes $existingSize
                        Write-Host "  [=] Depot $depotId - Not Out-Of-Date ($sizeStr), skipping" -ForegroundColor DarkCyan
                        continue
                    }
                }

                # Show current download info
                Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray
                $depotLine = "Downloading: Depot $depotId"
                $manifestLine = "Manifest ID: $manifestId"
                Write-Host ("  | {0,-62}|" -f $depotLine) -ForegroundColor Yellow
                Write-Host ("  | {0,-62}|" -f $manifestLine) -ForegroundColor White
                Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray

                # Download the manifest
                $result = Download-Manifest -DepotId $depotId -ManifestId $manifestId -OutputPath $depotCachePath -Mode $resolvedMode -ApiKey $activeApiKey

                if ($result.Success) {
                    $globalSuccessCount++
                    $globalTotalSize += $result.Size
                    $sizeStr = Format-ManifestFileSize -Bytes $result.Size
                    $retryInfo = if ($result.Attempts -gt 1) { " [Attempt $($result.Attempts)]" } else { "" }
                    Write-ManifestSuccess "Depot $depotId - Downloaded ($sizeStr)$retryInfo"
                } else {
                    $globalFailedDepots += @{
                        AppId = $currentAppId
                        DepotId = $depotId
                        ManifestId = $manifestId
                        Error = $result.Error
                    }
                    Write-ManifestErrorMsg "Depot $depotId - Failed after $($result.Attempts) attempts: $($result.Error)"
                }
            }

            # Final app progress update
            Write-Host ""
            Write-ManifestProgressBar -Current $downloadQueue.Count -Total $downloadQueue.Count -Label "App Download Progress" -Color Cyan
            Write-Host ""
            Write-Host ""
            
            # Give a small pause at the end of an app so the user can see it hit 100% before the screen wipes
            if ($appIdsToProcess.Count -gt 1) {
                Start-Sleep -Milliseconds 500
            }
        }

        # Draw final 100% batch progress before summary
        if ($appIdsToProcess.Count -gt 1) {
            Clear-Host
            Write-ManifestHeader -Mode $resolvedMode
            Write-Host ""
            Write-ManifestBatchProgress -Current $appIdsToProcess.Count -Total $appIdsToProcess.Count -StartTime $batchStartTime
            Write-Host "`n"
        } else {
            Clear-Host
            Write-ManifestHeader -Mode $resolvedMode
            Write-Host ""
        }

        $endTime = Get-Date
        $elapsed = $endTime - $batchStartTime

        # ===========================================================================
        # SUMMARY
        # ===========================================================================

        Write-Host ""
        Write-Host "  ================================================================" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  DOWNLOAD COMPLETE" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray
        Write-Host "  |                         SUMMARY                               |" -ForegroundColor DarkGray
        Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray

        $successText = "Downloaded:    $globalSuccessCount"
        Write-Host ("  |  {0,-60}|" -f $successText) -ForegroundColor Green

        $skippedText = "Skipped:       $globalSkippedCount (up-to-date)"
        Write-Host ("  |  {0,-60}|" -f $skippedText) -ForegroundColor DarkCyan

        $failedText = "Failed:        $($globalFailedDepots.Count)"
        $failedColor = if ($globalFailedDepots.Count -gt 0) { "Red" } else { "Green" }
        Write-Host ("  |  {0,-60}|" -f $failedText) -ForegroundColor $failedColor

        $totalText = "Total:         $globalDownloadQueueCount manifests processed"
        Write-Host ("  |  {0,-60}|" -f $totalText) -ForegroundColor White

        $appsText = "Apps Scanned:  $($appIdsToProcess.Count) games"
        Write-Host ("  |  {0,-60}|" -f $appsText) -ForegroundColor White

        $sizeText = "Downloaded:    $(Format-ManifestFileSize -Bytes $globalTotalSize)"
        Write-Host ("  |  {0,-60}|" -f $sizeText) -ForegroundColor White

        $timeText = "Time Elapsed:  $($elapsed.ToString('mm\:ss'))"
        Write-Host ("  |  {0,-60}|" -f $timeText) -ForegroundColor White

        $outputText = "Output:        $depotCachePath"
        if ($outputText.Length -gt 60) {
            $outputText = $outputText.Substring(0, 57) + "..."
        }
        Write-Host ("  |  {0,-60}|" -f $outputText) -ForegroundColor White

        Write-Host "  +---------------------------------------------------------------+" -ForegroundColor DarkGray

        # Show failed depots if any
        if ($globalFailedDepots.Count -gt 0) {
            Write-Host ""
            Write-Host "  FAILED DOWNLOADS:" -ForegroundColor Red
            Write-Host ""
            foreach ($failed in $globalFailedDepots) {
                Write-Host "    App $($failed.AppId) | Depot $($failed.DepotId) (Manifest: $($failed.ManifestId))" -ForegroundColor Red
                Write-Host "    Error: $($failed.Error)" -ForegroundColor DarkRed
                Write-Host ""
            }
        }

        Write-Host ""
        Write-Host "  What would you like to do next?" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    1. Return to Main Menu" -ForegroundColor White
        Write-Host "    2. Done! (close PowerShell)" -ForegroundColor White
        Write-Host ""
        do {
            $nextChoice = Read-Host "  Enter choice (1-2)"
        } while ($nextChoice -notin @("1","2"))

        if ($nextChoice -eq "2") { break }

        $manifestAppId = $null
        Clear-Host
        Write-ManifestHeader -Mode $resolvedMode
        Write-Host ""

    } # end while ($true)

    } # end if (-not $script:_manifestAbort)

    # Return to main menu
    $Branch = 0
    $Host.UI.RawUI.WindowTitle = "Luatools Tool Suite | .gg/luatools"

    # Show menu and get new selection
    while ($true) {
        Write-MainMenu
        $sel = Read-Host "Select an option"
        switch ($sel.Trim().ToUpper()) {
            "1" { $Branch = 1; break }
            "2" { $Branch = 2; break }
            "3" { $Branch = 3; break }
            "4" { $Branch = 4; break }
            "5" { $Branch = 5; break }
            "6" {
                $Branch = 6
                $defChoice = Read-Host "Skip Windows Defender exclusions? (y/N)"
                if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                break
            }
            "7" { $Branch = 7; break }
            "8" { $Branch = 8; break }
            "9" { $Branch = 9; break }
            "10" { $Branch = 10; break }
            "Q" { exit 0 }
            default { continue }
        }
        if ($Branch -ne 0) { break }
    }
    Blank
    continue MainLoop
}


#### Branch 8: No Internet Connection Fix (Program by SelectivelyGood | Script by Peron) ####
if ($Branch -eq 8) {
    $Host.UI.RawUI.WindowTitle = "No Internet Fix | .gg/luatools"

    # ---- Branch 8: Inner functions ----

    function Write-NoInternetHeader {
        Clear-Host
        Sep
        Write-Host "  No Internet Connection Fix  |  .gg/luatools" -ForegroundColor Cyan
        Sep
        Blank
        Write-Host "  Fixes Steam 'No Internet Connection' errors by redirecting" -ForegroundColor White
        Write-Host "  Steam's update servers through CloudRedirectCLI (/stfixer)." -ForegroundColor White
        Blank
        Write-Host "  CloudRedirectCLI" -NoNewline -ForegroundColor Cyan
        Write-Host " by SelectivelyGood  |  Script by Peron" -ForegroundColor DarkGray
        Blank
    }

    function Write-NoInternetMenu {
        Write-NoInternetHeader
        Write-Host "  HOW TO USE THIS FIX" -ForegroundColor DarkGray
        Write-Host "  1. Open PowerShell as Administrator" -ForegroundColor White
        Write-Host "     (Press " -NoNewline; Write-Host "Ctrl + Shift + Enter" -ForegroundColor Cyan -NoNewline; Write-Host " when launching PowerShell)" -ForegroundColor White
        Write-Host "  2. The fix will run automatically when you select Run below." -ForegroundColor White
        Blank
        Sep
        Write-Host "  WHAT DOES THIS DO?" -ForegroundColor DarkGray
        Write-Host "  Downloads CloudRedirectCLI.exe temporarily and runs it with" -ForegroundColor White
        Write-Host "  the /stfixer flag, which patches Steam's server routing to" -ForegroundColor White
        Write-Host "  restore internet connectivity for downloads and updates." -ForegroundColor White
        Blank
        Sep
        Blank
        Write-Host "  1   " -ForegroundColor Cyan -NoNewline; Write-Host "Run the fix now"
        Write-Host "  2   " -ForegroundColor Cyan -NoNewline; Write-Host "View the PowerShell command manually"
        Blank
        Write-Host "  Q   " -ForegroundColor DarkGray -NoNewline; Write-Host "Back to Main Menu"
        Blank
    }

    while ($true) {
        Write-NoInternetMenu
        $noIntChoice = Read-Host "Select an option"

        switch ($noIntChoice.Trim().ToUpper()) {
            "1" {
                Clear-Host
                Sep
                Write-Host "  Running No Internet Connection Fix..." -ForegroundColor Cyan
                Sep
                Blank

                $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
                    [Security.Principal.WindowsBuiltInRole]::Administrator
                )
                if (-not $IsAdmin) {
                    Log "WARN" "Not running as Administrator — the fix may not work correctly."
                    Log "WARN" "Re-launch this script with Ctrl+Shift+Enter for best results."
                    Blank
                    $adminChoice = Read-Host "Continue anyway? (Y/N)"
                    if ($adminChoice.Trim() -notin @("Y","y")) {
                        Log "INFO" "Cancelled. Returning to menu."
                        Start-Sleep -Seconds 1
                        break
                    }
                }

                Log "INFO" "Downloading CloudRedirectCLI.exe..."
                $cliDest = Join-Path $env:TEMP "CloudRedirectCLI.exe"
                try {
                    Invoke-WebRequest -Uri "https://github.com/Selectively11/CloudRedirect/releases/latest/download/CloudRedirectCLI.exe" -OutFile $cliDest -ErrorAction Stop
                    Log "OK" "Downloaded to: $cliDest"
                } catch {
                    Log "ERR" "Download failed: $($_.Exception.Message)"
                    Blank
                    Read-Host "Press Enter to go back"
                    break
                }

                Log "INFO" "Running CloudRedirectCLI /stfixer..."
                try {
                    $proc = Start-Process -FilePath $cliDest -ArgumentList "/stfixer" -Wait -PassThru -ErrorAction Stop
                    if ($proc.ExitCode -eq 0) {
                        Log "OK" "CloudRedirectCLI completed successfully."
                    } else {
                        Log "WARN" "CloudRedirectCLI exited with code: $($proc.ExitCode)"
                    }
                } catch {
                    Log "ERR" "Failed to run CloudRedirectCLI: $($_.Exception.Message)"
                }

                Blank
                Log "INFO" "Cleaning up temp file..."
                Remove-Item -Path $cliDest -Force -ErrorAction SilentlyContinue
                Log "OK" "Done."
                Blank
                Read-Host "Press Enter to go back to the menu"
                break
            }
            "2" {
                Clear-Host
                Sep
                Write-Host "  Manual PowerShell Command" -ForegroundColor Cyan
                Sep
                Blank
                Write-Host "  To run this fix manually, open PowerShell as Administrator" -ForegroundColor White
                Write-Host "  (Ctrl + Shift + Enter) and paste the following command:" -ForegroundColor White
                Blank
                Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
                Write-Host "  Invoke-WebRequest -Uri `"https://github.com/Selectively11/CloudRedirect/releases/latest/download/CloudRedirectCLI.exe`" -OutFile `"`$env:TEMP\CloudRedirectCLI.exe`"; & `"`$env:TEMP\CloudRedirectCLI.exe`" /stfixer" -ForegroundColor Yellow
                Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
                Blank
                Read-Host "Press Enter to go back to the menu"
                break
            }
            "Q" {
                $Host.UI.RawUI.WindowTitle = "Luatools Tool Suite | .gg/luatools"

                while ($true) {
                    Write-MainMenu
                    $sel = Read-Host "Select an option"
                    switch ($sel.Trim().ToUpper()) {
                        "1" { $Branch = 1; break }
                        "2" { $Branch = 2; break }
                        "3" { $Branch = 3; break }
                        "4" { $Branch = 4; break }
                        "5" { $Branch = 5; break }
                        "6" {
                            $Branch = 6
                            $defChoice = Read-Host "Skip Windows Defender exclusions? (y/N)"
                            if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                            break
                        }
                        "7" { $Branch = 7; break }
                        "8" { $Branch = 8; break }
                        "9" { $Branch = 9; break }
                        "10" { $Branch = 10; break }
                        "Q" { exit 0 }
                        default { continue }
                    }
                    if ($Branch -ne 0) { break }
                }
                Blank
                continue MainLoop
            }
        }
    }
}


#### Branch 9: Download / Launch CloudRedirect GUI (App by SelectivelyGood | Script by Potatoes9411) ####
if ($Branch -eq 9) {
    $Host.UI.RawUI.WindowTitle = "CloudRedirect GUI | .gg/luatools"

    $cloudRedirectDir  = "C:\Program Files (x86)\Steam\CloudRedirect"
    $cloudRedirectExe  = Join-Path $cloudRedirectDir "CloudRedirect.exe"
    $cloudRedirectUrl  = "https://github.com/Selectively11/CloudRedirect/releases/latest/download/CloudRedirect.exe"

    function Write-CloudRedirectHeader {
        Clear-Host
        Sep
        Write-Host "  CloudRedirect (GUI)  |  .gg/luatools" -ForegroundColor Cyan
        Sep
        Blank
        Write-Host "  Downloads and launches CloudRedirect, a GUI tool for fixing" -ForegroundColor White
        Write-Host "  Steam connectivity and server routing issues." -ForegroundColor White
        Blank
        Write-Host "  CloudRedirect" -NoNewline -ForegroundColor Cyan
        Write-Host " by SelectivelyGood  |  Script by Potatoes9411" -ForegroundColor DarkGray
        Blank
    }

    function Get-CloudRedirectInstalled {
        return (Test-Path $cloudRedirectExe)
    }

    function Write-CloudRedirectMenu {
        Write-CloudRedirectHeader
        $installed = Get-CloudRedirectInstalled
        $statusText = if ($installed) { "[installed]" } else { "[not installed]" }
        $statusColor = if ($installed) { "Green" } else { "DarkGray" }

        Write-Host "  Install path: " -NoNewline -ForegroundColor DarkGray
        Write-Host $cloudRedirectDir -ForegroundColor White
        Write-Host "  Status:       " -NoNewline -ForegroundColor DarkGray
        Write-Host $statusText -ForegroundColor $statusColor
        Blank
        Sep
        Blank

        Write-Host "  1   " -ForegroundColor Cyan -NoNewline
        Write-Host "Download & Launch CloudRedirect" -NoNewline
        Write-Host "  (always downloads latest)" -ForegroundColor DarkGray

        Write-Host "  2   " -ForegroundColor Cyan -NoNewline
        if ($installed) {
            Write-Host "Launch CloudRedirect (already installed)"
        } else {
            Write-Host "Launch CloudRedirect " -NoNewline
            Write-Host "(not installed — download first)" -ForegroundColor DarkGray
        }

        Blank
        Write-Host "  Q   " -ForegroundColor DarkGray -NoNewline; Write-Host "Back to Main Menu"
        Blank
    }

    while ($true) {
        Write-CloudRedirectMenu
        $crChoice = Read-Host "Select an option"

        switch ($crChoice.Trim().ToUpper()) {
            "1" {
                Clear-Host
                Sep
                Write-Host "  Downloading CloudRedirect..." -ForegroundColor Cyan
                Sep
                Blank

                Log "INFO" "Creating install directory..."
                try {
                    New-Item -Path $cloudRedirectDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
                    Log "OK" "Directory ready: $cloudRedirectDir"
                } catch {
                    Log "ERR" "Could not create directory: $($_.Exception.Message)"
                    Blank
                    Read-Host "Press Enter to go back"
                    break
                }

                Log "INFO" "Downloading CloudRedirect.exe from GitHub..."
                try {
                    Invoke-WebRequest -Uri $cloudRedirectUrl -OutFile $cloudRedirectExe -ErrorAction Stop
                    Log "OK" "Saved to: $cloudRedirectExe"
                } catch {
                    Log "ERR" "Download failed: $($_.Exception.Message)"
                    Blank
                    Read-Host "Press Enter to go back"
                    break
                }

                Blank
                Log "INFO" "Launching CloudRedirect..."
                try {
                    Start-Process -FilePath $cloudRedirectExe -ErrorAction Stop
                    Log "OK" "CloudRedirect launched."
                } catch {
                    Log "ERR" "Failed to launch CloudRedirect: $($_.Exception.Message)"
                }

                Blank
                Read-Host "Press Enter to go back to the menu"
                break
            }
            "2" {
                if (-not (Get-CloudRedirectInstalled)) {
                    Clear-Host
                    Sep
                    Log "WARN" "CloudRedirect is not installed yet."
                    Log "INFO" "Please use option 1 to download it first."
                    Sep
                    Blank
                    Read-Host "Press Enter to go back"
                    break
                }

                Clear-Host
                Sep
                Write-Host "  Launching CloudRedirect..." -ForegroundColor Cyan
                Sep
                Blank

                Log "INFO" "Starting CloudRedirect from: $cloudRedirectExe"
                try {
                    Start-Process -FilePath $cloudRedirectExe -ErrorAction Stop
                    Log "OK" "CloudRedirect launched."
                } catch {
                    Log "ERR" "Failed to launch CloudRedirect: $($_.Exception.Message)"
                }

                Blank
                Read-Host "Press Enter to go back to the menu"
                break
            }
            "Q" {
                $Host.UI.RawUI.WindowTitle = "Luatools Tool Suite | .gg/luatools"

                while ($true) {
                    Write-MainMenu
                    $sel = Read-Host "Select an option"
                    switch ($sel.Trim().ToUpper()) {
                        "1" { $Branch = 1; break }
                        "2" { $Branch = 2; break }
                        "3" { $Branch = 3; break }
                        "4" { $Branch = 4; break }
                        "5" { $Branch = 5; break }
                        "6" {
                            $Branch = 6
                            $defChoice = Read-Host "Skip Windows Defender exclusions? (y/N)"
                            if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                            break
                        }
                        "7" { $Branch = 7; break }
                        "8" { $Branch = 8; break }
                        "9" { $Branch = 9; break }
                        "10" { $Branch = 10; break }
                        "Q" { exit 0 }
                        default { continue }
                    }
                    if ($Branch -ne 0) { break }
                }
                Blank
                continue MainLoop
            }
        }
    }
}


#### Branch 10: Millennium & SteamTools Reinstaller (by clem.la & melly) ####
if ($Branch -eq 10) {
    $Host.UI.RawUI.WindowTitle = "Millennium & ST Reinstaller | .gg/luatools"

    # ---- Branch 10: Inner functions ----

    function Write-ReinstallHeader {
        Clear-Host
        Sep
        Write-Host "  Millennium & SteamTools Reinstaller  |  .gg/luatools" -ForegroundColor Cyan
        Sep
        Blank
        Write-Host "  Performs a clean reinstall of Millennium and SteamTools." -ForegroundColor White
        Write-Host "  Also fixes hardlink errors caused by corrupt or leftover files." -ForegroundColor White
        Blank
        Write-Host "  by clem.la & melly" -ForegroundColor DarkGray
        Blank
    }

    function Write-ReinstallMenu {
        Write-ReinstallHeader
        Sep
        Blank
        Write-Host "  WHAT THIS DOES:" -ForegroundColor DarkGray
        Write-Host "  - Stops Steam completely" -ForegroundColor White
        Write-Host "  - Removes leftover/conflicting DLLs and config files" -ForegroundColor White
        Write-Host "    (steam.cfg, beta flag, version.dll, old DLLs, Tencent cache)" -ForegroundColor DarkGray
        Write-Host "  - Clears SteamTools registry unlock flags" -ForegroundColor White
        Write-Host "  - Adds Defender exclusions for the new DLLs" -ForegroundColor White
        Write-Host "  - Downloads fresh xinput1_4.dll + dwmapi.dll" -ForegroundColor White
        Write-Host "  - Reinstalls Millennium silently (no restart)" -ForegroundColor White
        Write-Host "  - Sets iscdkey=false and relaunches Steam" -ForegroundColor White
        Blank
        Sep
        Blank
        Write-Host "  1   " -ForegroundColor Cyan -NoNewline; Write-Host "Run clean reinstall"
        Blank
        Write-Host "  Q   " -ForegroundColor DarkGray -NoNewline; Write-Host "Back to Main Menu"
        Blank
    }

    # Locate Steam path — tries all three registry locations like the rest of the script
    $b10SteamPath = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
    if (-not $b10SteamPath) { $b10SteamPath = (Get-ItemProperty "HKLM:\SOFTWARE\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath }
    if (-not $b10SteamPath) { $b10SteamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath }

    if (-not $b10SteamPath -or -not (Test-Path $b10SteamPath)) {
        Write-ReinstallHeader
        Log "ERR" "Steam installation not found. Is Steam installed?"
        Blank
        Read-Host "Press Enter to return to the menu"
        $Branch = 0
        $Host.UI.RawUI.WindowTitle = "Luatools Tool Suite | .gg/luatools"
        while ($true) {
            Write-MainMenu
            $sel = Read-Host "Select an option"
            switch ($sel.Trim().ToUpper()) {
                "1"  { $Branch = 1; break }
                "2"  { $Branch = 2; break }
                "3"  { $Branch = 3; break }
                "4"  { $Branch = 4; break }
                "5"  { $Branch = 5; break }
                "6"  {
                    $Branch = 6
                    $defChoice = Read-Host "Skip Windows Defender exclusions? (y/N)"
                    if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                    break
                }
                "7"  { $Branch = 7; break }
                "8"  { $Branch = 8; break }
                "9"  { $Branch = 9; break }
                "10" { $Branch = 10; break }
                "Q"  { exit 0 }
                default { continue }
            }
            if ($Branch -ne 0) { break }
        }
        Blank
        continue MainLoop
    }

    $b10SteamToolsRegPath = 'HKCU:\Software\Valve\Steamtools'
    $b10LocalPath         = Join-Path $env:LOCALAPPDATA "steam"

    while ($true) {
        Write-ReinstallMenu
        $b10Choice = Read-Host "Select an option"

        switch ($b10Choice.Trim().ToUpper()) {
            "1" {
                Clear-Host
                Sep
                Write-Host "  Running Millennium & SteamTools Reinstaller..." -ForegroundColor Cyan
                Sep
                Blank

                # --- Stop Steam ---
                Log "WARN" "Stopping Steam..."
                $b10ForceStop = {
                    param($procName)
                    Get-Process $procName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                    if (Get-Process $procName -ErrorAction SilentlyContinue) {
                        Start-Process cmd -ArgumentList "/c taskkill /f /im $procName.exe" -WindowStyle Hidden -ErrorAction SilentlyContinue
                    }
                }
                & $b10ForceStop "steam"
                & $b10ForceStop "steamwebhelper"
                & $b10ForceStop "steamerrorreporter"
                Start-Sleep -Seconds 1
                Log "OK" "Steam stopped."
                Blank

                # --- Ensure local appdata folder exists ---
                if (-not (Test-Path $b10LocalPath)) {
                    New-Item $b10LocalPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
                }

                # --- Remove leftover / conflicting files ---
                Log "INFO" "Removing conflicting files..."

                $b10FilesToRemove = @(
                    (Join-Path $b10SteamPath "steam.cfg"),
                    (Join-Path $b10SteamPath "package\beta"),
                    (Join-Path $env:LOCALAPPDATA "Microsoft\Tencent"),
                    (Join-Path $b10SteamPath "version.dll"),
                    (Join-Path $b10SteamPath "user32.dll"),
                    (Join-Path $b10SteamPath "xinput1_4.dll"),
                    (Join-Path $b10SteamPath "dwmapi.dll")
                )

                foreach ($f in $b10FilesToRemove) {
                    if (Test-Path $f) {
                        try {
                            Remove-Item -Path $f -Force -Recurse -ErrorAction Stop
                            Log "OK" "Removed: $(Split-Path $f -Leaf)"
                        } catch {
                            Log "WARN" "Could not remove: $(Split-Path $f -Leaf) — $($_.Exception.Message)"
                        }
                    }
                }
                Log "OK" "Cleanup done."
                Blank

                # --- Clear SteamTools registry unlock flags ---
                Log "INFO" "Clearing SteamTools registry flags..."
                if (-not (Test-Path $b10SteamToolsRegPath)) {
                    New-Item -Path $b10SteamToolsRegPath -Force | Out-Null
                }
                Remove-ItemProperty -Path $b10SteamToolsRegPath -Name "ActivateUnlockMode"  -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $b10SteamToolsRegPath -Name "AlwaysStayUnlocked"  -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $b10SteamToolsRegPath -Name "notUnlockDepot"       -ErrorAction SilentlyContinue
                Set-ItemProperty    -Path $b10SteamToolsRegPath -Name "iscdkey" -Value "false" -Type String
                Log "OK" "Registry flags cleared."
                Blank

                # --- Add Defender exclusions ---
                $b10XinputPath = Join-Path $b10SteamPath "xinput1_4.dll"
                $b10DwmapiPath = Join-Path $b10SteamPath "dwmapi.dll"
                Log "INFO" "Adding Defender exclusions..."
                try { Add-MpPreference -ExclusionPath $b10XinputPath -ErrorAction SilentlyContinue } catch {}
                try { Add-MpPreference -ExclusionPath $b10DwmapiPath -ErrorAction SilentlyContinue } catch {}
                Log "OK" "Exclusions added."
                Blank

                # --- Download fresh SteamTools DLLs ---
                Log "INFO" "Downloading SteamTools DLLs..."
                $b10DllMap = @{
                    $b10XinputPath = "http://update.steamcdn.com/update"
                    $b10DwmapiPath = "http://update.steamcdn.com/dwmapi"
                }
                foreach ($dest in $b10DllMap.Keys) {
                    $uri     = $b10DllMap[$dest]
                    $dllName = Split-Path $dest -Leaf
                    Log "LOG" "Downloading $dllName..."
                    try {
                        Invoke-RestMethod -Uri $uri -OutFile $dest -ErrorAction Stop
                        Log "OK" "$dllName downloaded."
                    } catch {
                        # If file already exists (old copy), back it up and retry
                        if (Test-Path $dest) {
                            Move-Item -Path $dest -Destination "$dest.old" -Force -ErrorAction SilentlyContinue
                            try {
                                Invoke-RestMethod -Uri $uri -OutFile $dest -ErrorAction SilentlyContinue
                                Log "OK" "$dllName downloaded (after backup)."
                            } catch {
                                Log "WARN" "Could not download $dllName — $($_.Exception.Message)"
                            }
                        } else {
                            Log "WARN" "Could not download $dllName — $($_.Exception.Message)"
                        }
                    }
                }
                Log "OK" "DLLs done."
                Blank

                # --- Reinstall Millennium (silent, no Steam restart) ---
                Log "INFO" "Reinstalling Millennium (silent)..."
                try {
                    $b10MillenniumInstaller = [ScriptBlock]::Create((Invoke-RestMethod "https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1"))
                    & $b10MillenniumInstaller -NoLog -DontStart -SteamPath $b10SteamPath
                    Log "OK" "Millennium reinstalled."
                } catch {
                    Log "WARN" "Millennium reinstall failed: $($_.Exception.Message)"
                    Log "WARN" "You can reinstall manually at https://steambrew.app/"
                }
                Blank

                # --- Launch Steam ---
                Log "INFO" "Launching Steam..."
                $b10SteamExe = Join-Path $b10SteamPath "steam.exe"
                if (Test-Path $b10SteamExe) {
                    Start-Process $b10SteamExe
                    Start-Process "steam://"
                    Log "OK" "Steam launched. Log in to complete activation."
                } else {
                    Log "WARN" "steam.exe not found at expected path — launch Steam manually."
                }

                Blank
                Sep
                Write-Host "  Done! Reinstall complete." -ForegroundColor Green
                Sep
                Blank
                Read-Host "Press Enter to go back to the menu"
                break
            }
            "Q" {
                $Branch = 0
                $Host.UI.RawUI.WindowTitle = "Luatools Tool Suite | .gg/luatools"
                while ($true) {
                    Write-MainMenu
                    $sel = Read-Host "Select an option"
                    switch ($sel.Trim().ToUpper()) {
                        "1"  { $Branch = 1; break }
                        "2"  { $Branch = 2; break }
                        "3"  { $Branch = 3; break }
                        "4"  { $Branch = 4; break }
                        "5"  { $Branch = 5; break }
                        "6"  {
                            $Branch = 6
                            $defChoice = Read-Host "Skip Windows Defender exclusions? (y/N)"
                            if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                            break
                        }
                        "7"  { $Branch = 7; break }
                        "8"  { $Branch = 8; break }
                        "9"  { $Branch = 9; break }
                        "10" { $Branch = 10; break }
                        "Q"  { exit 0 }
                        default { continue }
                    }
                    if ($Branch -ne 0) { break }
                }
                Blank
                continue MainLoop
            }
        }
    }
}


#### Plugin install flow (branches 1 & 2) ####

if ($Branch -eq 1 -or $Branch -eq 2) {

Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force


#### Requirements ####

function CheckSteamtools {
    $files = @("dwmapi.dll", "xinput1_4.dll")
    foreach ($file in $files) {
        if (!(Test-Path (Join-Path $steam $file))) { return $false }
    }
    return $true
}

if (CheckSteamtools) {
    Log "INFO" "Steamtools already installed"
} else {
    $script    = Invoke-RestMethod "https://luatools.vercel.app/st.ps1"
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

        if (CheckSteamtools) {
            Log "OK" "Steamtools installed"
            break
        } else {
            Log "ERR" "Steamtools installation failed, retrying..."
        }
    }
}

# Millennium check
$milleniumInstalling = $false
foreach ($file in @("millennium.dll", "python311.dll")) {
    if (!(Test-Path (Join-Path $steam $file))) {

        Log "ERR" "Millenium not found, installation process will start in $milleniumTimer seconds."
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

        Log "INFO" "Installing Millenium"
        $millenniumInstaller = [ScriptBlock]::Create((Invoke-RestMethod "https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1"))
        & $millenniumInstaller -NoLog -DontStart -SteamPath $steam
        Log "OK" "Millenium done installing"
        $milleniumInstalling = $true
        break
    }
}
if (-not $milleniumInstalling) { Log "INFO" "Millenium already installed" }


#### Plugin install ####
$pluginRoot = Get-PluginRootPath -steamBase $steam
if (-not $pluginRoot) {
    Log "ERR" "Could not determine plugin installation path."
    exit
}
if (!(Test-Path $pluginRoot)) {
    New-Item -Path $pluginRoot -ItemType Directory -Force *> $null
}

$Path = Join-Path $pluginRoot "$name"

foreach ($root in Get-PluginRootPaths -steamBase $steam) {
    foreach ($plugin in Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue) {
        $testpath = Join-Path $plugin.FullName "plugin.json"
        if (Test-Path $testpath) {
            $json = try { Get-Content $testpath -Raw | ConvertFrom-Json } catch { $null }
            if ($json -and $json.name -eq $name) {
                Log "INFO" "Plugin already installed, updating it"
                $Path = $plugin.FullName
                break
            }
        }
    }
    if ($Path -ne (Join-Path $pluginRoot "$name")) { break }
}

$subPath = Join-Path $env:TEMP "$name.zip"

Log "LOG" "Downloading $name"
if ($DownloadLink) { Log "AUX" $link }
Invoke-WebRequest -Uri $link -OutFile $subPath *> $null
if (!(Test-Path $subPath)) {
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
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($zip) { $zip.Dispose() }
    Log "ERR" "Extraction failed, trying normal way"
    Expand-Archive -Path $subPath -DestinationPath $Path -Force
}

if (Test-Path $subPath) { Remove-Item $subPath -ErrorAction SilentlyContinue }

Log "OK" "$upperName installed"

    Blank
    Prompt-ExitOrReturnToMenu
    $Branch = 0
    continue MainLoop
}


# Remove beta flag
$betaPath = Join-Path $steam "package\beta"
if (Test-Path $betaPath) { Remove-Item $betaPath -Recurse -Force }

# Remove x32 overrides
$cfgPath = Join-Path $steam "steam.cfg"
if (Test-Path $cfgPath) { Remove-Item $cfgPath -Recurse -Force }
Remove-ItemProperty -Path "HKCU:\Software\Valve\Steam"             -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam"             -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue


# Enable plugin in Millennium config
$configPath = Join-Path $steam "ext/config.json"
if (-not (Test-Path $configPath)) {
    $config = @{
        plugins = @{ enabledPlugins = @($name) }
        general = @{ checkForMillenniumUpdates = $false }
    }
    New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
} else {
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


# Launch Steam
Blank
if ($milleniumInstalling) { Log "WARN" "Steam startup will be longer, don't panic and don't touch anything in steam!" }

$exe = Join-Path $steam "steam.exe"
Start-Process $exe -ArgumentList "-clearbeta"

Log "INFO" "Starting Steam"
Log "WARN" "Hey so there is a bug where steam may not start"
Log "WARN" "Hopefully this script fixes it"
Log "WARN" "But i had to turn updates of millennium off."
Log "WARN" "In future, they will come back but in the meantime:"
Log "OK"   "Manually check for updates of millennium if you want up to date."
Log "AUX"  "Millennium is working now tho (latest version)."

Blank
Prompt-ExitOrReturnToMenu
$Branch = 0
continue MainLoop

} # end if Branch 1 or 2

} # end :MainLoop
