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
    Write-Host "[$Type] $(Translate $Message)" -ForegroundColor $fg -NoNewline:$NoNewline
}

function Sep   { Write-Host ("=" * 63) -ForegroundColor Cyan }
function Blank { Write-Host "" }

$SupportedLanguages = [ordered]@{
    en = "English"
    es = "Español"
    pt = "Português"
}
$script:ScriptLanguage = "en"
$Translations = @{ 
    en = @{ 
        "Luatools Tool Suite  |  .gg/luatools" = "  Luatools Tool Suite  |  .gg/luatools"
        "  INSTALL / UPDATE" = "  INSTALL / UPDATE"
        "  FIXES" = "  FIXES"
        "  OTHER" = "  OTHER"
        "Install Luatools plugin              " = "Install Luatools plugin              "
        "Install steamtools-collection        " = "Install steamtools-collection        "
        "Spacetheme Block Remover             " = "Spacetheme Block Remover             "
        "Removes the 'get a job loser' block  " = "Removes the 'get a job loser' block  "
        "by waike" = "by waike"
        "Steam Offline Fix" = "Steam Offline Fix"
        "Fixes Steam stuck on loading icon    " = "Fixes Steam stuck on loading icon    "
        "Steam Bulk Fixer" = "Steam Bulk Fixer"
        "Runs various Steam/Steamtools fixes  " = "Runs various Steam/Steamtools fixes  "
        "ST Uninstaller" = "ST Uninstaller"
        "Full Steamtools/Luatools uninstaller " = "Full Steamtools/Luatools uninstaller "
        "by Potatoes9411" = "by Potatoes9411"
        "Steam Manifest Downloader" = "Steam Manifest Downloader"
        "Downloads depot manifests when       " = "Downloads depot manifests when       "
        "by Skyflare (Modified by Potatoes9411)" = "by Skyflare (Modified by Potatoes9411)"
        "SteamTools servers are unavailable   " = "SteamTools servers are unavailable   "
        "No Internet Connection Fix" = "No Internet Connection Fix"
        "Fixes Steam 'No Internet' errors via " = "Fixes Steam 'No Internet' errors via "
        "Program by SelectivelyGood | Script by Peron" = "Program by SelectivelyGood | Script by Peron"
        "CloudRedirectCLI /stfixer            " = "CloudRedirectCLI /stfixer            "
        "Download / Launch CloudRedirect (GUI)" = "Download / Launch CloudRedirect (GUI)"
        "Downloads & launches CloudRedirect   " = "Downloads & launches CloudRedirect   "
        "by Potatoes9411 | App by SelectivelyGood" = "by Potatoes9411 | App by SelectivelyGood"
        "GUI, or runs it if already installed " = "GUI, or runs it if already installed "
        "Millennium & SteamTools Reinstaller" = "Millennium & SteamTools Reinstaller"
        "Reinstalls Millennium + SteamTools,  " = "Reinstalls Millennium + SteamTools,  "
        "by clem.la & melly" = "by clem.la & melly"
        "fixes hardlink errors on reinstall   " = "fixes hardlink errors on reinstall   "
        "Quit" = "Quit"
        "Select an option" = "Select an option"
        "Skip Windows Defender exclusions? (y/N)" = "Skip Windows Defender exclusions? (y/N)"
        "Choose option" = "Choose option"
        "Press Enter to exit" = "Press Enter to exit"
        "Press Enter to go back" = "Press Enter to go back"
        "Toggle option or run" = "Toggle option or run"
        "Restart Steam? (y/n)" = "Restart Steam? (y/n)"
        "Are you sure you want to continue? (Y/N)" = "Are you sure you want to continue? (Y/N)"
        "Invalid selection" = "Invalid selection"
        "Select language:" = "Select language:"
        "Language set to English" = "Language set to English"
        "Language set to Español" = "Language set to Español"
        "Language set to Português" = "Language set to Português"
        "Hey! Just letting you know that i'm working on a new version combining various scripts of the server" = "Hey! Just letting you know that i'm working on a new version combining various scripts of the server"
        "Will include language support on THIS script too, luv y'all brazilians" = "Will include language support on THIS script too, luv y'all brazilians"
    }
    es = @{ 
        "Luatools Tool Suite  |  .gg/luatools" = "  Luatools Tool Suite  |  .gg/luatools"
        "  INSTALL / UPDATE" = "  INSTALAR / ACTUALIZAR"
        "  FIXES" = "  ARREGLA"
        "  OTHER" = "  OTROS"
        "Install Luatools plugin" = "Instalar plugin de Luatools"
        "Install steamtools-collection" = "Instalar steamtools-collection"
        "Spacetheme Block Remover" = "Eliminador de bloqueo Spacetheme"
        "Steam Offline Fix" = "Arreglo de Steam sin conexión"
        "Steam Bulk Fixer" = "Arreglo masivo de Steam"
        "ST Uninstaller" = "Desinstalador ST"
        "Steam Manifest Downloader" = "Descargador de manifiestos de Steam"
        "No Internet Connection Fix" = "Arreglo de conexión sin Internet"
        "Download / Launch CloudRedirect (GUI)" = "Descargar / iniciar CloudRedirect (GUI)"
        "Millennium & SteamTools Reinstaller" = "Reinstalador de Millennium y SteamTools"
        "Language / Idioma / Português" = "Idioma / Español / Português"
        "Removes the 'get a job loser' block by waike" = "Elimina el bloqueo 'get a job loser' por waike"
        "Fixes Steam stuck on loading icon by waike" = "Corrige Steam atascado en el icono de carga por waike"
        "Runs various Steam/Steamtools fixes by waike" = "Ejecuta varios arreglos de Steam/Steamtools por waike"
        "Full Steamtools/Luatools uninstaller by Potatoes9411" = "Desinstalador completo de Steamtools/Luatools por Potatoes9411"
        "Downloads depot manifests when SteamTools servers are unavailable by Skyflare (Modified by Potatoes9411)" = "Descarga manifiestos cuando los servidores de SteamTools no están disponibles por Skyflare (Modificado por Potatoes9411)"
        "Fixes Steam 'No Internet' errors via Program by SelectivelyGood | Script by Peron CloudRedirectCLI /stfixer" = "Corrige errores de Steam 'Sin Internet' mediante Program by SelectivelyGood | Script by Peron CloudRedirectCLI /stfixer"
        "Downloads & launches CloudRedirect by Potatoes9411 | App by SelectivelyGood GUI, or runs it if already installed" = "Descarga e inicia CloudRedirect by Potatoes9411 | App by SelectivelyGood GUI, o lo ejecuta si ya está instalado"
        "Reinstalls Millennium + SteamTools, by clem.la & melly fixes hardlink errors on reinstall" = "Reinstala Millennium + SteamTools, por clem.la & melly corrige errores de hardlink al reinstalar"
        "Quit" = "Salir"
        "Select an option" = "Selecciona una opción"
        "Skip Windows Defender exclusions? (y/N)" = "¿Omitir exclusiones de Windows Defender? (s/N)"
        "Choose option" = "Elige una opción"
        "Press Enter to exit" = "Presiona Enter para salir"
        "Press Enter to go back" = "Presiona Enter para volver"
        "Toggle option or run" = "Activa opción o ejecuta"
        "Restart Steam? (y/n)" = "¿Reiniciar Steam? (s/n)"
        "Are you sure you want to continue? (Y/N)" = "¿Estás seguro de que quieres continuar? (S/N)"
        "Invalid selection" = "Selección inválida"
        "Select language:" = "Selecciona idioma:"
        "Language set to English" = "Idioma cambiado a Inglés"
        "Language set to Español" = "Idioma cambiado a Español"
        "Language set to Português" = "Idioma cambiado a Portugués"
        "Hey! Just letting you know that i'm working on a new version combining various scripts of the server" = "¡Oye! Solo para avisarte que estoy trabajando en una nueva versión combinando varios scripts del servidor"
        "Will include language support on THIS script too, luv y'all brazilians" = "También incluirá soporte de idioma en ESTE script, los amo brasileños"
        "DOWNLOAD COMPLETE" = "DESCARGA COMPLETA"
        "FAILED DOWNLOADS:" = "DESCARGAS FALLIDAS:"
        "What would you like to do next?" = "¿Qué quieres hacer ahora?"
        "Return to Main Menu" = "Volver al menú principal"
        "Done! (close PowerShell)" = "Listo. (cerrar PowerShell)"
        "Run the fix now" = "Ejecutar la corrección ahora"
        "View the PowerShell command manually" = "Ver el comando de PowerShell manualmente"
        "Back to Main Menu" = "Volver al menú principal"
        "HOW TO USE THIS FIX" = "CÓMO USAR ESTA CORRECCIÓN"
        "WHAT DOES THIS DO?" = "¿QUÉ HACE ESTO?"
        "Manual PowerShell Command" = "Comando manual de PowerShell"
        "Select download mode:" = "Selecciona el modo de descarga:"
        "Select processing mode:" = "Selecciona el modo de procesamiento:"
        "Enter choice (1-2)" = "Introduce una opción (1-2)"
        "Enter choice (1-3)" = "Introduce una opción (1-3)"
        "Enter ManifestHub API Key" = "Introduce la clave API de ManifestHub"
        "Enter Morrenus API Key" = "Introduce la clave API de Morrenus"
        "Enter Steam AppID (Not Depot ID or DLC ID)" = "Introduce el AppID de Steam (no el Depot ID ni DLC ID)"
        "Expected path:" = "Ruta esperada:"
        "Expected: smm_ followed by 96 hex characters (total 100 chars)" = "Se espera: smm_ seguido de 96 caracteres hexadecimales (100 caracteres en total)"
        "Steam installation not found. Is Steam installed?" = "No se encontró la instalación de Steam. ¿Steam está instalado?"
        "Steam not found." = "No se encontró Steam."
        "Steam stopped." = "Steam detenido."
        "Stopping Steam..." = "Deteniendo Steam..."
        "Removing conflicting files..." = "Eliminando archivos en conflicto..."
        "Cleanup done." = "Limpieza completada."
        "Clearing SteamTools registry flags..." = "Borrando banderas del registro de SteamTools..."
        "Registry flags cleared." = "Banderas del registro borradas."
        "Running Millennium & SteamTools Reinstaller..." = "Ejecutando reinstalador de Millennium y SteamTools..."
        "Running No Internet Connection Fix..." = "Ejecutando corrección de no conexión a Internet..."
        "Running uninstaller..." = "Ejecutando desinstalador..."
        "Downloading CloudRedirect..." = "Descargando CloudRedirect..."
        "CloudRedirectCLI completed successfully." = "CloudRedirectCLI se completó correctamente."
        "CloudRedirectCLI exited with code: " = "CloudRedirectCLI salió con código: "
        "Failed to run CloudRedirectCLI: " = "No se pudo ejecutar CloudRedirectCLI: "
        "Download failed: " = "La descarga falló: "
        "Downloaded to: " = "Descargado en: "
        "Cleaning up temp file..." = "Limpiando archivo temporal..."
    }
    pt = @{ 
        "Luatools Tool Suite  |  .gg/luatools" = "  Luatools Tool Suite  |  .gg/luatools"
        "  INSTALL / UPDATE" = "  INSTALAR / ATUALIZAR"
        "  FIXES" = "  CORREÇÕES"
        "  OTHER" = "  OUTROS"
        "Install Luatools plugin" = "Instalar plugin Luatools"
        "Install steamtools-collection" = "Instalar steamtools-collection"
        "Spacetheme Block Remover" = "Removedor de bloqueio Spacetheme"
        "Steam Offline Fix" = "Correção de Steam offline"
        "Steam Bulk Fixer" = "Corretor em massa do Steam"
        "ST Uninstaller" = "Desinstalador ST"
        "Steam Manifest Downloader" = "Baixador de manifestos do Steam"
        "No Internet Connection Fix" = "Correção de sem internet"
        "Download / Launch CloudRedirect (GUI)" = "Baixar / iniciar CloudRedirect (GUI)"
        "Millennium & SteamTools Reinstaller" = "Reinstalador de Millennium e SteamTools"
        "Language / Idioma / Português" = "Idioma / Español / Português"
        "Removes the 'get a job loser' block by waike" = "Remove o bloqueio 'get a job loser' por waike"
        "Fixes Steam stuck on loading icon by waike" = "Corrige Steam preso no ícone de carregamento por waike"
        "Runs various Steam/Steamtools fixes by waike" = "Executa várias correções de Steam/Steamtools por waike"
        "Full Steamtools/Luatools uninstaller by Potatoes9411" = "Desinstalador completo de Steamtools/Luatools por Potatoes9411"
        "Downloads depot manifests when SteamTools servers are unavailable by Skyflare (Modified by Potatoes9411)" = "Baixa manifestos quando os servidores do SteamTools não estão disponíveis por Skyflare (Modificado por Potatoes9411)"
        "Fixes Steam 'No Internet' errors via Program by SelectivelyGood | Script by Peron CloudRedirectCLI /stfixer" = "Corrige erros de Steam 'Sem Internet' via Program by SelectivelyGood | Script by Peron CloudRedirectCLI /stfixer"
        "Downloads & launches CloudRedirect by Potatoes9411 | App by SelectivelyGood GUI, or runs it if already installed" = "Baixa e inicia CloudRedirect by Potatoes9411 | App by SelectivelyGood GUI, ou o executa se já estiver instalado"
        "Reinstalls Millennium + SteamTools, by clem.la & melly fixes hardlink errors on reinstall" = "Reinstala Millennium + SteamTools, por clem.la & melly corrige erros de hardlink na reinstalação"
        "Quit" = "Sair"
        "Select an option" = "Selecione uma opção"
        "Skip Windows Defender exclusions? (y/N)" = "Pular exclusões do Windows Defender? (s/N)"
        "Choose option" = "Escolha uma opção"
        "Press Enter to exit" = "Pressione Enter para sair"
        "Press Enter to go back" = "Pressione Enter para voltar"
        "Toggle option or run" = "Alternar opção ou executar"
        "Restart Steam? (y/n)" = "Reiniciar Steam? (s/n)"
        "Are you sure you want to continue? (Y/N)" = "Tem certeza de que deseja continuar? (S/N)"
        "Invalid selection" = "Seleção inválida"
        "Select language:" = "Selecione o idioma:"
        "Language set to English" = "Idioma definido para Inglês"
        "Language set to Español" = "Idioma definido para Espanhol"
        "Language set to Português" = "Idioma definido para Português"
        "Hey! Just letting you know that i'm working on a new version combining various scripts of the server" = "Ei! Apenas avisando que estou trabalhando em uma nova versão combinando vários scripts do servidor"
        "Will include language support on THIS script too, luv y'all brazilians" = "Também incluirá suporte de idioma neste script, amo vocês brasileiros"
        "DOWNLOAD COMPLETE" = "DOWNLOAD CONCLUÍDO"
        "FAILED DOWNLOADS:" = "DOWNLOADS FALHADOS:"
        "What would you like to do next?" = "O que você quer fazer agora?"
        "Return to Main Menu" = "Voltar ao menu principal"
        "Done! (close PowerShell)" = "Concluído! (feche o PowerShell)"
        "Run the fix now" = "Executar a correção agora"
        "View the PowerShell command manually" = "Ver o comando do PowerShell manualmente"
        "Back to Main Menu" = "Voltar ao menu principal"
        "HOW TO USE THIS FIX" = "COMO USAR ESTA CORREÇÃO"
        "WHAT DOES THIS DO?" = "O QUE ISTO FAZ?"
        "Manual PowerShell Command" = "Comando manual do PowerShell"
        "Select download mode:" = "Selecione o modo de download:"
        "Select processing mode:" = "Selecione o modo de processamento:"
        "Enter choice (1-2)" = "Digite a opção (1-2)"
        "Enter choice (1-3)" = "Digite a opção (1-3)"
        "Enter ManifestHub API Key" = "Digite a chave API do ManifestHub"
        "Enter Morrenus API Key" = "Digite a chave API do Morrenus"
        "Enter Steam AppID (Not Depot ID or DLC ID)" = "Digite o AppID do Steam (não o Depot ID nem o DLC ID)"
        "Expected path:" = "Caminho esperado:"
        "Expected: smm_ followed by 96 hex characters (total 100 chars)" = "Esperado: smm_ seguido de 96 caracteres hexadecimais (100 caracteres no total)"
        "Steam installation not found. Is Steam installed?" = "Instalação do Steam não encontrada. O Steam está instalado?"
        "Steam not found." = "Steam não encontrado."
        "Steam stopped." = "Steam parado."
        "Stopping Steam..." = "Parando o Steam..."
        "Removing conflicting files..." = "Removendo arquivos conflitantes..."
        "Cleanup done." = "Limpeza concluída."
        "Clearing SteamTools registry flags..." = "Limpando flags do registro do SteamTools..."
        "Registry flags cleared." = "Flags do registro limpas."
        "Running Millennium & SteamTools Reinstaller..." = "Executando reinstalador de Millennium e SteamTools..."
        "Running No Internet Connection Fix..." = "Executando correção de sem conexão com a Internet..."
        "Running uninstaller..." = "Executando desinstalador..."
        "Downloading CloudRedirect..." = "Baixando CloudRedirect..."
        "CloudRedirectCLI completed successfully." = "CloudRedirectCLI concluído com sucesso."
        "CloudRedirectCLI exited with code: " = "CloudRedirectCLI saiu com o código: "
        "Failed to run CloudRedirectCLI: " = "Falha ao executar CloudRedirectCLI: "
        "Download failed: " = "Falha no download: "
        "Downloaded to: " = "Baixado em: "
        "Cleaning up temp file..." = "Limpando arquivo temporário..."
    }
}

$TranslationFragments = @{
    es = @(
        @{ From = "Attempt "; To = "Intento " }
        @{ From = " failed "; To = " falló " }
        @{ From = "Retrying in "; To = "Reintentando en " }
        @{ From = "Not on GitHub, trying Morrenus..."; To = "No está en GitHub, probando Morrenus..." }
        @{ From = "Not on GitHub, trying ManifestHub..."; To = "No está en GitHub, probando ManifestHub..." }
        @{ From = "Not Out-Of-Date"; To = "No está desactualizado" }
        @{ From = "DOWNLOAD COMPLETE"; To = "DESCARGA COMPLETA" }
        @{ From = "FAILED DOWNLOADS:"; To = "DESCARGAS FALLIDAS:" }
        @{ From = "Select download mode:"; To = "Selecciona el modo de descarga:" }
        @{ From = "Select processing mode:"; To = "Selecciona el modo de procesamiento:" }
        @{ From = "Running No Internet Connection Fix..."; To = "Ejecutando corrección de no conexión a Internet..." }
        @{ From = "Running Millennium & SteamTools Reinstaller..."; To = "Ejecutando reinstalador de Millennium y SteamTools..." }
        @{ From = "Running uninstaller..."; To = "Ejecutando desinstalador..." }
        @{ From = "Downloading CloudRedirect..."; To = "Descargando CloudRedirect..." }
        @{ From = "CloudRedirectCLI completed successfully."; To = "CloudRedirectCLI se completó correctamente." }
        @{ From = "CloudRedirectCLI exited with code: "; To = "CloudRedirectCLI salió con código: " }
        @{ From = "Failed to run CloudRedirectCLI: "; To = "No se pudo ejecutar CloudRedirectCLI: " }
        @{ From = "Steam installation not found. Is Steam installed?"; To = "No se encontró la instalación de Steam. ¿Steam está instalado?" }
        @{ From = "Steam not found."; To = "No se encontró Steam." }
        @{ From = "What would you like to do next?"; To = "¿Qué quieres hacer ahora?" }
        @{ From = "Return to Main Menu"; To = "Volver al menú principal" }
        @{ From = "Done! (close PowerShell)"; To = "Listo. (cerrar PowerShell)" }
        @{ From = "Run the fix now"; To = "Ejecutar la corrección ahora" }
        @{ From = "View the PowerShell command manually"; To = "Ver el comando de PowerShell manualmente" }
        @{ From = "Back to Main Menu"; To = "Volver al menú principal" }
        @{ From = "HOW TO USE THIS FIX"; To = "CÓMO USAR ESTA CORRECCIÓN" }
        @{ From = "WHAT DOES THIS DO?"; To = "¿QUÉ HACE ESTO?" }
        @{ From = "Manual PowerShell Command"; To = "Comando manual de PowerShell" }
        @{ From = "BATCH PROGRESS"; To = "PROGRESO POR LOTES" }
        @{ From = "Downloaded:"; To = "Descargado:" }
        @{ From = "Skipped:"; To = "Omitido:" }
        @{ From = "Failed:"; To = "Fallido:" }
        @{ From = "Apps Scanned:"; To = "Juegos analizados:" }
        @{ From = "Time Elapsed:"; To = "Tiempo transcurrido:" }
        @{ From = "Output:"; To = "Salida:" }
    )
    pt = @(
        @{ From = "Attempt "; To = "Tentativa " }
        @{ From = " failed "; To = " falhou " }
        @{ From = "Retrying in "; To = "Tentando novamente em " }
        @{ From = "Not on GitHub, trying Morrenus..."; To = "Não está no GitHub, tentando Morrenus..." }
        @{ From = "Not on GitHub, trying ManifestHub..."; To = "Não está no GitHub, tentando ManifestHub..." }
        @{ From = "Not Out-Of-Date"; To = "Não está desatualizado" }
        @{ From = "DOWNLOAD COMPLETE"; To = "DOWNLOAD CONCLUÍDO" }
        @{ From = "FAILED DOWNLOADS:"; To = "DOWNLOADS FALHADOS:" }
        @{ From = "Select download mode:"; To = "Selecione o modo de download:" }
        @{ From = "Select processing mode:"; To = "Selecione o modo de processamento:" }
        @{ From = "Running No Internet Connection Fix..."; To = "Executando correção de sem conexão com a Internet..." }
        @{ From = "Running Millennium & SteamTools Reinstaller..."; To = "Executando reinstalador de Millennium e SteamTools..." }
        @{ From = "Running uninstaller..."; To = "Executando desinstalador..." }
        @{ From = "Downloading CloudRedirect..."; To = "Baixando CloudRedirect..." }
        @{ From = "CloudRedirectCLI completed successfully."; To = "CloudRedirectCLI concluído com sucesso." }
        @{ From = "CloudRedirectCLI exited with code: "; To = "CloudRedirectCLI saiu com o código: " }
        @{ From = "Failed to run CloudRedirectCLI: "; To = "Falha ao executar CloudRedirectCLI: " }
        @{ From = "Steam installation not found. Is Steam installed?"; To = "Instalação do Steam não encontrada. O Steam está instalado?" }
        @{ From = "Steam not found."; To = "Steam não encontrado." }
        @{ From = "What would you like to do next?"; To = "O que você quer fazer agora?" }
        @{ From = "Return to Main Menu"; To = "Voltar ao menu principal" }
        @{ From = "Done! (close PowerShell)"; To = "Concluído! (feche o PowerShell)" }
        @{ From = "Run the fix now"; To = "Executar a correção agora" }
        @{ From = "View the PowerShell command manually"; To = "Ver o comando do PowerShell manualmente" }
        @{ From = "Back to Main Menu"; To = "Voltar ao menu principal" }
        @{ From = "HOW TO USE THIS FIX"; To = "COMO USAR ESTA CORREÇÃO" }
        @{ From = "WHAT DOES THIS DO?"; To = "O QUE ISTO FAZ?" }
        @{ From = "Manual PowerShell Command"; To = "Comando manual do PowerShell" }
        @{ From = "BATCH PROGRESS"; To = "PROGRESSO DO LOTE" }
        @{ From = "Downloaded:"; To = "Baixado:" }
        @{ From = "Skipped:"; To = "Ignorado:" }
        @{ From = "Failed:"; To = "Falhou:" }
        @{ From = "Apps Scanned:"; To = "Jogos verificados:" }
        @{ From = "Time Elapsed:"; To = "Tempo decorrido:" }
        @{ From = "Output:"; To = "Saída:" }
    )
}

function Translate {
    param([string]$Text)
    if (-not $Text) { return $Text }
    if (-not $Translations.ContainsKey($script:ScriptLanguage)) { return $Text }
    $langTable = $Translations[$script:ScriptLanguage]
    if ($langTable.ContainsKey($Text)) { return $langTable[$Text] }
    if ($TranslationFragments.ContainsKey($script:ScriptLanguage)) {
        foreach ($rule in $TranslationFragments[$script:ScriptLanguage]) {
            if ($Text.Contains($rule.From)) {
                $Text = $Text.Replace($rule.From, $rule.To)
            }
        }
    }
    return $Text
}

function Write-Host {
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [object]$Object,
        [System.ConsoleColor]$ForegroundColor,
        [System.ConsoleColor]$BackgroundColor,
        [switch]$NoNewline,
        [string]$Separator
    )

    if ($Object -is [string]) {
        $Object = Translate $Object
    }

    $params = @{}
    if ($PSBoundParameters.ContainsKey('Object')) { $params.Object = $Object }
    if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $params.ForegroundColor = $ForegroundColor }
    if ($PSBoundParameters.ContainsKey('BackgroundColor')) { $params.BackgroundColor = $BackgroundColor }
    if ($PSBoundParameters.ContainsKey('NoNewline')) { $params.NoNewline = $true }
    if ($PSBoundParameters.ContainsKey('Separator')) { $params.Separator = $Separator }

    Microsoft.PowerShell.Utility\Write-Host @params
}

function WriteLocalized {
    param(
        [string]$Text,
        [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::White,
        [switch]$NoNewline
    )
    Write-Host $Text -ForegroundColor $ForegroundColor -NoNewline:$NoNewline
}

function Ask {
    param([string]$Prompt)
    return Microsoft.PowerShell.Utility\Read-Host -Prompt (Translate $Prompt)
}

function Read-Host {
    param(
        [Parameter(Mandatory=$true, Position=0)][string]$Prompt
    )
    return Microsoft.PowerShell.Utility\Read-Host -Prompt (Translate $Prompt)
}

function Set-Language {
    Clear-Host
    Sep
    WriteLocalized "Select language:" -ForegroundColor Cyan
    Sep
    Blank
    $index = 1
    foreach ($code in $SupportedLanguages.Keys) {
        WriteLocalized "  $index. $($SupportedLanguages[$code])"
        $index++
    }
    Blank
    $choice = Ask "Choose option"
    switch ($choice.Trim()) {
        "1" { $script:ScriptLanguage = "en"; Log "OK" "Language set to English"; return }
        "2" { $script:ScriptLanguage = "es"; Log "OK" "Language set to Español"; return }
        "3" { $script:ScriptLanguage = "pt"; Log "OK" "Language set to Português"; return }
        default { Log "ERR" "Invalid selection"; Start-Sleep -Seconds 1; Set-Language; return }
    }
}

$ProgressPreference = 'SilentlyContinue'

Log "WARN" "Hey! Just letting you know that i'm working on a new version combining various scripts of the server"
Log "AUX"  "Will include language support on THIS script too, luv y'all brazilians"
Blank


#### Main menu ####
function Get-PluginRootPaths([string]$steamBase) {
    $roots = @()
    if ($steamBase) {
        $roots += Join-Path $steamBase "plugins"
        $roots += Join-Path $steamBase "millennium\plugins"
    }
    $roots += "C:\Program Files (x86)\Steam\plugins"
    $roots += "C:\Program Files (x86)\Steam\millennium\plugins"
    $roots += "C:\Program Files\Steam\plugins"
    $roots += "C:\Program Files\Steam\millennium\plugins"
    return $roots | Where-Object { Test-Path $_ }
}

function Get-PluginRootPath([string]$steamBase) {
    $paths = Get-PluginRootPaths -steamBase $steamBase
    return if ($paths.Count -gt 0) { $paths[0] } else { $null }
}

function Get-PluginStatus([string]$pluginName) {
    if (-not $steam) { return "[unknown]" }
    $roots = Get-PluginRootPaths -steamBase $steam
    if ($roots.Count -eq 0) { return "[not installed]" }
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

function Get-SpacethemeStatus {
    if (-not $steam) { return "[unknown]" }
    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if ($steamPath -and (Test-Path "$steamPath\steamui\skins\Steam\src\css\regular.css")) { return "[found]" }
    return "[not found]"
}

function Format-MenuText {
    param(
        [string]$Text,
        [int]$Width
    )

    $text = Translate $Text
    if ($Width -le 0) { return $text }
    return $text.PadRight($Width)
}

function Write-WrappedMenuText {
    param(
        [string]$Text,
        [int]$Width,
        [string]$Indent = "       ",
        [System.ConsoleColor]$Color = [System.ConsoleColor]::DarkGray
    )

    $translated = Translate $Text
    if (-not $translated) { return }

    $words = $translated -split '\s+'
    $line = ""
    foreach ($word in $words) {
        if (-not $word) { continue }
        $candidate = if ($line) { "$line $word" } else { $word }
        if ($candidate.Length -le $Width) {
            $line = $candidate
            continue
        }

        if ($line) {
            Write-Host ("{0}{1}" -f $Indent, $line) -ForegroundColor $Color
        }
        $line = $word
    }

    if ($line) {
        Write-Host ("{0}{1}" -f $Indent, $line) -ForegroundColor $Color
    }
}

function Write-MenuLine {
    param([string]$Text, [System.ConsoleColor]$Color = [System.ConsoleColor]::White)
    Write-Host (Translate $Text) -ForegroundColor $Color
}

function Write-MenuEntry {
    param(
        [string]$Number,
        [string]$Title,
        [string]$Status = "",
        [string]$Detail = ""
    )

    $titleText = Translate $Title
    $statusText = if ($Status) { Translate $Status } else { "" }

    if ($Status) {
        Write-Host ("  {0,-2}  {1} {2}" -f $Number, $titleText, $statusText)
    } else {
        Write-Host ("  {0,-2}  {1}" -f $Number, $titleText)
    }

    if ($Detail) {
        Write-WrappedMenuText $Detail 74
    }
}

function Write-MainMenu {
    Clear-Host
    Sep
    WriteLocalized "Luatools Tool Suite  |  .gg/luatools" -ForegroundColor Cyan
    Sep
    Blank

    Write-MenuLine "  INSTALL / UPDATE" DarkGray
    Write-MenuEntry "1" "Install Luatools plugin" (Get-PluginStatus "luatools")
    Write-MenuEntry "2" "Install steamtools-collection" (Get-PluginStatus "steamtools-collection")

    Blank
    Write-MenuLine "  FIXES" DarkGray
    Write-MenuEntry "3" "Spacetheme Block Remover" (Get-SpacethemeStatus) "Removes the 'get a job loser' block by waike"
    Write-MenuEntry "4" "Steam Offline Fix" "" "Fixes Steam stuck on loading icon by waike"
    Write-MenuEntry "6" "Steam Bulk Fixer" "" "Runs various Steam/Steamtools fixes by waike"

    Blank
    Write-MenuLine "  OTHER" DarkGray
    Write-MenuEntry "5" "ST Uninstaller" "" "Full Steamtools/Luatools uninstaller by Potatoes9411"
    Write-MenuEntry "7" "Steam Manifest Downloader" "" "Downloads depot manifests when SteamTools servers are unavailable by Skyflare (Modified by Potatoes9411)"
    Write-MenuEntry "8" "No Internet Connection Fix" "" "Fixes Steam 'No Internet' errors via Program by SelectivelyGood | Script by Peron CloudRedirectCLI /stfixer"
    Write-MenuEntry "9" "Download / Launch CloudRedirect (GUI)" "" "Downloads & launches CloudRedirect by Potatoes9411 | App by SelectivelyGood GUI, or runs it if already installed"
    Write-MenuEntry "10" "Millennium & SteamTools Reinstaller" "" "Reinstalls Millennium + SteamTools, by clem.la & melly fixes hardlink errors on reinstall"
    Write-MenuEntry "11" "Steamless Game Patcher" "" "Remove Steam DRM from a game using Steamless — interactive GUI, auto-detects game EXE"

    Blank
    Write-Host ("  {0,-2}  {1}" -f "L", (Translate "Language / Idioma / Português")) -ForegroundColor Cyan
    Write-Host ("  {0,-2}  {1}" -f "Q", (Translate "Quit")) -ForegroundColor DarkGray
    Blank
}

if (-not $Branch) {
    # ---- WPF Main Menu ----
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

    # Write the STA GUI launcher to a temp file
    $menuScript = Join-Path $env:TEMP "luatools_menu_gui.ps1"
    $menuResult = Join-Path $env:TEMP "luatools_menu_result.txt"
    Remove-Item $menuResult -Force -ErrorAction SilentlyContinue

    # Pass current plugin/spacetheme status so the GUI can show badges
    $plugStatus1  = Get-PluginStatus "luatools"
    $plugStatus2  = Get-PluginStatus "steamtools-collection"
    $spaceStatus  = Get-SpacethemeStatus
    $statusData   = @{ p1=$plugStatus1; p2=$plugStatus2; sp=$spaceStatus; lang=$script:ScriptLanguage }
    $statusJson   = $statusData | ConvertTo-Json -Compress
    $statusFile   = Join-Path $env:TEMP "luatools_menu_status.json"
    $statusJson | Set-Content $statusFile -Encoding UTF8

@'
param($ResultFile, $StatusFile)
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$st   = try { (Get-Content $StatusFile -Raw | ConvertFrom-Json) } catch { @{p1="[unknown]";p2="[unknown]";sp="[unknown]";lang="en"} }
$lang = if ($st.lang) { $st.lang } else { "en" }

# ── Translation tables for GUI card labels ───────────────────────────────────
$T = @{
    en = @{
        winTitle    = "Luatools Tool Suite  |  .gg/luatools"
        sec_install = "⬇  INSTALL / UPDATE  —  Start here if you're new or need to reinstall"
        sec_fixes   = "🔧  FIXES  —  Use these when something goes wrong after installing"
        sec_other   = "⚙  OTHER TOOLS  —  Advanced utilities and extras"
        qh_title    = "⚡  QUICK HELP — Having an issue? Find your problem below and click the option number."
        q_warp      = "☁  Get Cloudflare Warp (fix internet errors)"
        q_script    = "📋  All-in-One Fix Script"
        q_discord   = "💬  Join Discord"
        q_help      = "❓  Get Help"
        q_quit      = "Quit"
        c1_title="1  Install Luatools Plugin"; c2_title="2  Install steamtools-collection"
        c3_title="3  Spacetheme Block Remover"; c4_title="4  Steam Offline Fix"
        c5_title="5  ST Uninstaller"; c6_title="6  Steam Bulk Fixer"
        c7_title="7  Steam Manifest Downloader"; c8_title="8  No Internet Connection Fix"
        c9_title="9  CloudRedirect GUI Launcher"; c10_title="10  Millennium & SteamTools Reinstaller"
        c11_title="11  Steamless Game Patcher"
        lang_label = "Language:"
    }
    es = @{
        winTitle    = "Luatools Tool Suite  |  .gg/luatools"
        sec_install = "⬇  INSTALAR / ACTUALIZAR  —  Empieza aquí si eres nuevo o necesitas reinstalar"
        sec_fixes   = "🔧  ARREGLOS  —  Usa estos cuando algo falla después de instalar"
        sec_other   = "⚙  OTRAS HERRAMIENTAS  —  Utilidades avanzadas y extras"
        qh_title    = "⚡  AYUDA RÁPIDA — ¿Tienes un problema? Encuentra el tuyo abajo y haz clic en el número."
        q_warp      = "☁  Obtener Cloudflare Warp (arreglar errores de internet)"
        q_script    = "📋  Script todo-en-uno"
        q_discord   = "💬  Unirse a Discord"
        q_help      = "❓  Obtener ayuda"
        q_quit      = "Salir"
        c1_title="1  Instalar plugin Luatools"; c2_title="2  Instalar steamtools-collection"
        c3_title="3  Eliminador de bloqueo Spacetheme"; c4_title="4  Arreglo Steam offline"
        c5_title="5  Desinstalador ST"; c6_title="6  Arreglo masivo de Steam"
        c7_title="7  Descargador de manifiestos"; c8_title="8  Arreglo sin conexión a Internet"
        c9_title="9  Lanzador CloudRedirect GUI"; c10_title="10  Reinstalador Millennium y SteamTools"
        c11_title="11  Parcheador Steamless"
        lang_label = "Idioma:"
    }
    pt = @{
        winTitle    = "Luatools Tool Suite  |  .gg/luatools"
        sec_install = "⬇  INSTALAR / ATUALIZAR  —  Comece aqui se você é novo ou precisa reinstalar"
        sec_fixes   = "🔧  CORREÇÕES  —  Use estes quando algo der errado após instalar"
        sec_other   = "⚙  OUTRAS FERRAMENTAS  —  Utilitários avançados e extras"
        qh_title    = "⚡  AJUDA RÁPIDA — Tem um problema? Encontre o seu abaixo e clique no número."
        q_warp      = "☁  Obter Cloudflare Warp (corrigir erros de internet)"
        q_script    = "📋  Script tudo-em-um"
        q_discord   = "💬  Entrar no Discord"
        q_help      = "❓  Obter ajuda"
        q_quit      = "Sair"
        c1_title="1  Instalar plugin Luatools"; c2_title="2  Instalar steamtools-collection"
        c3_title="3  Removedor de bloqueio Spacetheme"; c4_title="4  Correção Steam offline"
        c5_title="5  Desinstalador ST"; c6_title="6  Corretor em massa do Steam"
        c7_title="7  Baixador de manifestos"; c8_title="8  Correção sem conexão à Internet"
        c9_title="9  Lançador CloudRedirect GUI"; c10_title="10  Reinstalador Millennium e SteamTools"
        c11_title="11  Patcher Steamless"
        lang_label = "Idioma:"
    }
}
$tl = if ($T[$lang]) { $T[$lang] } else { $T["en"] }

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Luatools Tool Suite  |  .gg/luatools"
        Width="1060" Height="780" MinWidth="820" MinHeight="600"
        WindowStartupLocation="CenterScreen"
        Background="#08040f" FontFamily="Segoe UI" FontSize="13"
        ResizeMode="CanMinimize">
  <Window.Resources>
    <!-- Glow effect for cards on hover -->
    <Style x:Key="Card" TargetType="Border">
      <Setter Property="Background" Value="#1a0a0a1e"/>
      <Setter Property="CornerRadius" Value="10"/>
      <Setter Property="Padding" Value="0"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#44c026d4"/>
      <Setter Property="Effect">
        <Setter.Value>
          <DropShadowEffect Color="#c026d4" BlurRadius="0" ShadowDepth="0" Opacity="0"/>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background" Value="#33c026d4"/>
          <Setter Property="BorderBrush" Value="#ffe040fb"/>
          <Setter Property="Effect">
            <Setter.Value>
              <DropShadowEffect Color="#e040fb" BlurRadius="18" ShadowDepth="0" Opacity="0.7"/>
            </Setter.Value>
          </Setter>
        </Trigger>
      </Style.Triggers>
    </Style>
    <Style x:Key="CardBtn" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
      <Setter Property="VerticalContentAlignment" Value="Stretch"/>
      <Setter Property="Padding" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <ContentPresenter/>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="SectionLabel" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#e040fb"/>
      <Setter Property="FontSize" Value="10"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Margin" Value="8,14,0,4"/>
    </Style>
    <Style x:Key="ActionBtn" TargetType="Button">
      <Setter Property="Background" Value="#22c026d4"/>
      <Setter Property="Foreground" Value="#e040fb"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#88c026d4"/>
      <Setter Property="Padding" Value="10,6"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Margin" Value="0,3,6,3"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="5"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#55e040fb"/>
                <Setter Property="BorderBrush" Value="#ffe040fb"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="WarpBtn" TargetType="Button">
      <Setter Property="Background" Value="#226bdc8a"/>
      <Setter Property="Foreground" Value="#6bdc8a"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#886bdc8a"/>
      <Setter Property="Padding" Value="10,6"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="5"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#446bdc8a"/>
                <Setter Property="BorderBrush" Value="#ff6bdc8a"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="LangBtn" TargetType="Button">
      <Setter Property="Background" Value="#881e1e2e"/>
      <Setter Property="Foreground" Value="#44445a"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding" Value="10,5"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Margin" Value="3,0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#cc2a1a4a"/>
                <Setter Property="Foreground" Value="#a78bfa"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="LangBtnActive" TargetType="Button">
      <Setter Property="Background" Value="#cc1a4a8a"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#a78bfa"/>
      <Setter Property="Padding" Value="10,5"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Margin" Value="3,0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="4"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="HelpRow" TargetType="Border">
      <Setter Property="Background" Value="#660f0f18"/>
      <Setter Property="CornerRadius" Value="5"/>
      <Setter Property="Padding" Value="10,7"/>
      <Setter Property="Margin" Value="0,2"/>
    </Style>
    <Style x:Key="HelpArrow" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#e040fb"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="VerticalAlignment" Value="Top"/>
      <Setter Property="Margin" Value="0,0,6,0"/>
    </Style>
    <Style x:Key="HelpText" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#f0eeff"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="TextWrapping" Value="Wrap"/>
    </Style>
    <Style x:Key="HelpSub" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#9999bb"/>
      <Setter Property="FontSize" Value="10"/>
      <Setter Property="TextWrapping" Value="Wrap"/>
      <Setter Property="Margin" Value="0,2,0,0"/>
    </Style>
  </Window.Resources>

  <Grid>
    <!-- ══ SPLASH BACKGROUND IMAGE (blurred, dark overlay) ══ -->
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- Background image spans all rows — not interactive -->
    <Image x:Name="SplashBg" Grid.Row="0" Grid.RowSpan="3"
           Stretch="UniformToFill" Opacity="0.45"
           RenderOptions.BitmapScalingMode="HighQuality"
           IsHitTestVisible="False"
           HorizontalAlignment="Center" VerticalAlignment="Center"/>
    <!-- Dark purple tint overlay — not interactive, passes clicks through -->
    <Border Grid.Row="0" Grid.RowSpan="3" Background="#aa08040f" IsHitTestVisible="False"/>

    <!-- ═══ HEADER ═══ -->
    <Border Grid.Row="0" Background="#55080410" Padding="18,14,18,12">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Grid Grid.Row="0">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <!-- Server icon: simple Content button, no ControlTemplate so Content is settable at runtime -->
          <Button x:Name="ServerIconBtn" Grid.Column="0" Width="52" Height="52" Padding="0" Cursor="Hand"
                  BorderThickness="0" Background="Transparent" Margin="0,0,14,0"
                  ToolTip="Join discord.gg/luatools">
            <Border CornerRadius="14" ClipToBounds="True" Width="52" Height="52" Background="#1a0a2e">
              <TextBlock Text="L" FontSize="22" FontWeight="Bold" Foreground="#e040fb" HorizontalAlignment="Center" VerticalAlignment="Center"><TextBlock.Effect><DropShadowEffect Color="#e040fb" BlurRadius="16" ShadowDepth="0" Opacity="1.0"/></TextBlock.Effect></TextBlock>
            </Border>
          </Button>
          <StackPanel Grid.Column="1" VerticalAlignment="Center">
            <StackPanel Orientation="Horizontal">
              <TextBlock Text="Luatools" FontSize="24" FontWeight="Bold" Foreground="#e040fb">
                <TextBlock.Effect><DropShadowEffect Color="#e040fb" BlurRadius="14" ShadowDepth="0" Opacity="0.9"/></TextBlock.Effect>
              </TextBlock>
              <TextBlock Text=" Tool Suite" FontSize="24" FontWeight="Light" Foreground="#c084fc">
                <TextBlock.Effect><DropShadowEffect Color="#a78bfa" BlurRadius="10" ShadowDepth="0" Opacity="0.6"/></TextBlock.Effect>
              </TextBlock>
            </StackPanel>
            <TextBlock Foreground="#c084fc" FontSize="11" Margin="0,2,0,0">
              <Run Foreground="#9575cd" Text="discord.gg/luatools  ·  by Potatoes9411 + contributors"/>
            </TextBlock>
          </StackPanel>
          <!-- Lang + action buttons -->
          <StackPanel Grid.Column="2" VerticalAlignment="Center" HorizontalAlignment="Right">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,0,6">
              <TextBlock x:Name="LangLabel" Text="Language:" Foreground="#9575cd" FontSize="11" VerticalAlignment="Center" Margin="0,0,5,0"/>
              <Button x:Name="LangEN" Content="EN"/>
              <Button x:Name="LangES" Content="ES"/>
              <Button x:Name="LangPT" Content="PT"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
              <Button x:Name="WarpBtn"    Style="{StaticResource WarpBtn}"   Content="☁  Cloudflare Warp" Margin="0,0,6,0"/>
              <Button x:Name="DiscordBtn" Style="{StaticResource ActionBtn}" Content="💬  Discord" Margin="0,0,6,0"/>
              <Button x:Name="ScriptBtn"  Style="{StaticResource ActionBtn}" Content="📋  Fix Script"/>
            </StackPanel>
          </StackPanel>
        </Grid>

        <!-- Quick Help panel -->
        <Border Grid.Row="1" Background="#660a0418" CornerRadius="8" Padding="14,10" Margin="0,12,0,0" BorderBrush="#33e040fb" BorderThickness="1">
          <StackPanel>
            <TextBlock x:Name="QHTitle" Foreground="#e040fb" FontSize="11" FontWeight="Bold" Margin="0,0,0,8"><TextBlock.Effect><DropShadowEffect Color="#e040fb" BlurRadius="10" ShadowDepth="0" Opacity="0.8"/></TextBlock.Effect></TextBlock>
            <UniformGrid Columns="2" Margin="0,0,0,4">
              <StackPanel Margin="0,0,8,0">
                <Border Style="{StaticResource HelpRow}">
                  <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Style="{StaticResource HelpArrow}" Text="[1]  "/>
                    <StackPanel Grid.Column="1">
                      <TextBlock Style="{StaticResource HelpText}" Text="❌  Luatools plugin is RED or not working"/>
                      <TextBlock Style="{StaticResource HelpSub}"  Text="Use Option 1 to reinstall the Luatools plugin via Millennium + SteamTools."/>
                    </StackPanel>
                  </Grid>
                </Border>
                <Border Style="{StaticResource HelpRow}">
                  <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Style="{StaticResource HelpArrow}" Text="[3]  "/>
                    <StackPanel Grid.Column="1">
                      <TextBlock Style="{StaticResource HelpText}" Text="🚫  Spacetheme shows 'Remove Piracy Plugin' overlay"/>
                      <TextBlock Style="{StaticResource HelpSub}"  Text="Use Option 3 to patch the CSS file and remove the block. Close Steam first."/>
                    </StackPanel>
                  </Grid>
                </Border>
                <Border Style="{StaticResource HelpRow}">
                  <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Style="{StaticResource HelpArrow}" Text="[8]  "/>
                    <StackPanel Grid.Column="1">
                      <TextBlock Style="{StaticResource HelpText}" Text="🌐  Steam says 'No Internet Connection' / Content still encrypted"/>
                      <TextBlock Style="{StaticResource HelpSub}"  Text="Use Option 8 to install CloudRedirect. Runs CloudRedirectCLI /stfixer automatically."/>
                    </StackPanel>
                  </Grid>
                </Border>
              </StackPanel>
              <StackPanel Margin="8,0,0,0">
                <Border Style="{StaticResource HelpRow}">
                  <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Style="{StaticResource HelpArrow}" Text="[8]  "/>
                    <StackPanel Grid.Column="1">
                      <TextBlock Style="{StaticResource HelpText}" Text="💳  Steam shows 'Purchase Error' / payment refused"/>
                      <TextBlock Style="{StaticResource HelpSub}"  Text="Rerun Option 8. If it still fails, use Cloudflare Warp (☁ button above) or ProtonVPN."/>
                    </StackPanel>
                  </Grid>
                </Border>
                <Border Style="{StaticResource HelpRow}">
                  <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Style="{StaticResource HelpArrow}" Text="[6]  "/>
                    <StackPanel Grid.Column="1">
                      <TextBlock Style="{StaticResource HelpText}" Text="🔧  SteamTools stopped working after a Steam update"/>
                      <TextBlock Style="{StaticResource HelpSub}"  Text="Use Option 6 to re-download DLLs, add Defender exclusions, and run the bulk fixer."/>
                    </StackPanel>
                  </Grid>
                </Border>
                <Border Style="{StaticResource HelpRow}">
                  <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Style="{StaticResource HelpArrow}" Text="☁   "/>
                    <StackPanel Grid.Column="1">
                      <TextBlock Style="{StaticResource HelpText}" Text="⚡  Script errors / download failures / timeouts"/>
                      <TextBlock Style="{StaticResource HelpSub}"  Text="Install Cloudflare Warp (free, one.one.one.one) — it fixes ISP blocks on our servers."/>
                    </StackPanel>
                  </Grid>
                </Border>
              </StackPanel>
            </UniformGrid>
          </StackPanel>
        </Border>
      </Grid>
    </Border>

    <!-- ═══ CARD GRID ═══ -->
    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Padding="8,0,8,0">
      <StackPanel>
        <TextBlock x:Name="SecInstall" Style="{StaticResource SectionLabel}"><TextBlock.Effect><DropShadowEffect Color="#e040fb" BlurRadius="8" ShadowDepth="0" Opacity="0.7"/></TextBlock.Effect></TextBlock>
        <UniformGrid Columns="2">
          <Button x:Name="Btn1" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}" BorderBrush="#22222a4a" BorderThickness="1">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                  <StackPanel Orientation="Horizontal">
                    <TextBlock Text="1" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                    <TextBlock x:Name="C1Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                  </StackPanel>
                  <Border x:Name="Badge1" Grid.Column="1" CornerRadius="3" Padding="6,2" Background="#226bdc8a">
                    <TextBlock x:Name="BadgeText1" FontSize="10" FontWeight="SemiBold"/>
                  </Border>
                </Grid>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by Potatoes9411  |  Full install: SteamTools + Millennium + Luatools plugin</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Installs everything you need from scratch. Automatically downloads and sets up SteamTools, Millennium (the plugin loader), and the Luatools plugin. Closes Steam, installs, then relaunches it.</TextBlock>
                <Border Grid.Row="3" Background="#22e040fb" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#a78bfa" FontSize="10" TextWrapping="Wrap">👆  NEW USER? START HERE — if the Luatools plugin appears RED after installing, run this again or try Option 6.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn2" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                  <StackPanel Orientation="Horizontal">
                    <TextBlock Text="2" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                    <TextBlock x:Name="C2Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                  </StackPanel>
                  <Border x:Name="Badge2" Grid.Column="1" CornerRadius="3" Padding="6,2" Background="#22ff4444">
                    <TextBlock x:Name="BadgeText2" FontSize="10" FontWeight="SemiBold"/>
                  </Border>
                </Grid>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by Potatoes9411  |  Alternative plugin — same install process as Option 1</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Installs the steamtools-collection plugin instead of Luatools. Same full process — SteamTools + Millennium + the collection plugin. Use this if you specifically want steamtools-collection.</TextBlock>
                <Border Grid.Row="3" Background="#22ff4444" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#f87171" FontSize="10" TextWrapping="Wrap">ℹ  Only use this instead of Option 1 — not both. They serve the same purpose.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
        </UniformGrid>

        <TextBlock x:Name="SecFixes" Style="{StaticResource SectionLabel}"><TextBlock.Effect><DropShadowEffect Color="#e040fb" BlurRadius="8" ShadowDepth="0" Opacity="0.7"/></TextBlock.Effect></TextBlock>
        <UniformGrid Columns="2">
          <Button x:Name="Btn3" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                  <StackPanel Orientation="Horizontal">
                    <TextBlock Text="3" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                    <TextBlock x:Name="C3Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                  </StackPanel>
                  <Border x:Name="Badge3" Grid.Column="1" CornerRadius="3" Padding="6,2" Background="#22ffaa00">
                    <TextBlock x:Name="BadgeText3" FontSize="10" FontWeight="SemiBold"/>
                  </Border>
                </Grid>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by waike (waike.dev)  |  Patches Spacetheme CSS</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Some versions of Spacetheme show a big 'Remove piracy plugin' overlay blocking your Steam. This patches the CSS file directly to remove it. Steam will be closed during patching.</TextBlock>
                <Border Grid.Row="3" Background="#22ffaa00" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#f59e0b" FontSize="10" TextWrapping="Wrap">ℹ  Only needed if you see a 'remove piracy plugin' overlay on Steam.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn4" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="4" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C4Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by waike (waike.dev)  |  Fixes loginusers.vdf</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">SteamTools sometimes forces Steam into offline mode, causing it to spin on the loading screen forever. This sets WantsOfflineMode=0 in loginusers.vdf so Steam starts normally.</TextBlock>
                <Border Grid.Row="3" Background="#22ff4444" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#f87171" FontSize="10" TextWrapping="Wrap">ℹ  Use this if Steam loads forever and gets stuck on the spinning loading screen.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn6" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="6" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C6Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by waike (waike.dev)  |  Re-downloads DLLs, adds Defender exclusions</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Re-downloads xinput1_4.dll and dwmapi.dll, adds Defender exclusions for Steam, runs the Luatools temp fixer, and reinstalls the Luatools plugin. Run as Administrator for best results.</TextBlock>
                <Border Grid.Row="3" Background="#22ff4444" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#f87171" FontSize="10" TextWrapping="Wrap">ℹ  Use this if SteamTools stopped working after a Steam update, or games aren't unlocking.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn8" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="8" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C8Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">Program by SelectivelyGood  |  Script by Peron  |  Installs CloudRedirect</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Downloads CloudRedirectCLI and cloud_redirect.dll from GitHub, runs /stfixer to fix server routing, and installs the DLL into Steam. Also fixes Purchase Errors. If it still fails after running, use Cloudflare Warp or ProtonVPN.</TextBlock>
                <Border Grid.Row="3" Background="#226bdc8a" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#6bdc8a" FontSize="10" TextWrapping="Wrap">ℹ  Use if Steam shows 'No internet connection', content is still encrypted, or you get purchase errors.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn10" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="10" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C10Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by clem.la &amp; melly  |  Full clean reinstall</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Full clean reinstall: removes conflicting DLLs, clears registry unlock flags, adds Defender exclusions, re-downloads fresh DLLs, reinstalls Millennium silently, then relaunches Steam.</TextBlock>
                <Border Grid.Row="3" Background="#22ff4444" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#f87171" FontSize="10" TextWrapping="Wrap">ℹ  Use if you're getting hardlink errors, a broken install, or Option 1 keeps failing.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
        </UniformGrid>

        <TextBlock x:Name="SecOther" Style="{StaticResource SectionLabel}"><TextBlock.Effect><DropShadowEffect Color="#e040fb" BlurRadius="8" ShadowDepth="0" Opacity="0.7"/></TextBlock.Effect></TextBlock>
        <UniformGrid Columns="2">
          <Button x:Name="Btn5" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="5" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C5Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by Potatoes9411  |  Toggle-based — choose exactly what to remove</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,6,0,0">Lets you tick checkboxes for what to uninstall: Luatools plugin, SteamTools DLLs, Millennium files, Lua game files. Nothing is removed until you confirm.</TextBlock>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn7" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="7" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C7Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by Skyflare, modified by Potatoes9411  |  3 sources: GitHub Mirror, Morrenus, ManifestHub</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">When SteamTools servers are down, games show 'Manifest unavailable'. This downloads the .manifest files from GitHub Mirror first (no key needed), then falls back to Morrenus or ManifestHub if needed.</TextBlock>
                <Border Grid.Row="3" Background="#22ffaa00" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#f59e0b" FontSize="10" TextWrapping="Wrap">ℹ  Try GitHub Mirror first (free, no key). Only use Morrenus/ManifestHub if GitHub Mirror fails.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn9" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="9" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C9Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">App by SelectivelyGood  |  Script by Potatoes9411  |  Standalone GUI tool</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,7,0,0">Downloads and launches CloudRedirect — a standalone GUI app for diagnosing and fixing Steam server routing issues. Different from Option 8 (that's the CLI fixer; this is the full GUI app).</TextBlock>
                <Border Grid.Row="3" Background="#22a78bfa" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
                  <TextBlock Foreground="#6b6b88" FontSize="10" TextWrapping="Wrap">ℹ  For advanced network troubleshooting. Try Option 8 first — it's usually enough.</TextBlock>
                </Border>
              </Grid>
            </Border>
          </Button>
          <Button x:Name="Btn11" Style="{StaticResource CardBtn}">
            <Border Style="{StaticResource Card}">
              <Grid Margin="16,14,16,14">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <StackPanel Grid.Row="0" Orientation="Horizontal">
                  <TextBlock Text="11" Foreground="#e040fb" FontWeight="Bold" FontSize="15" Margin="0,0,6,0"/>
                  <TextBlock x:Name="C11Title" FontWeight="SemiBold" Foreground="#ffffff" FontSize="14" VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock Grid.Row="1" Foreground="#9575cd" FontSize="10" Margin="0,3,0,0" FontStyle="Italic">by atom0s  |  Removes Steam DRM from game EXEs</TextBlock>
                <TextBlock Grid.Row="2" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,6,0,0">Lists all your Lua-enabled games, auto-detects the main EXE, and strips Steam DRM using Steamless CLI. Lets you browse for the EXE manually if auto-detection fails. Games show Ready/Not installed/Disabled badges.</TextBlock>
              </Grid>
            </Border>
          </Button>
        </UniformGrid>
        <Rectangle Height="12"/>
      </StackPanel>
    </ScrollViewer>

    <!-- ═══ FOOTER ═══ -->
    <Border Grid.Row="2" Background="#55080410" Padding="16,10">
      <Grid>
        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        <TextBlock Foreground="#22223a" FontSize="10" VerticalAlignment="Center">
          <Run Text="Luatools Tool Suite  |  discord.gg/luatools  |  potatoes-dev.com  |  Potatoes9411 + contributors"/>
        </TextBlock>
        <Button x:Name="HelpBtn" Grid.Column="1" Style="{StaticResource ActionBtn}" Margin="0"/>
        <Button x:Name="QuitBtn" Grid.Column="3" Background="#880f0f18" Foreground="#c084fc"
                BorderThickness="0" Padding="14,6" FontSize="11" Cursor="Hand">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#cc1e1e2e"/><Setter Property="Foreground" Value="White"/></Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
        </Button>
      </Grid>
    </Border>
  </Grid>
</Window>
"@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# ── Apply translated strings ──────────────────────────────────────────────────
$window.FindName("QHTitle").Text    = $tl.qh_title
$window.FindName("SecInstall").Text = $tl.sec_install
$window.FindName("SecFixes").Text   = $tl.sec_fixes
$window.FindName("SecOther").Text   = $tl.sec_other
$window.FindName("C1Title").Text    = $tl.c1_title;  $window.FindName("C2Title").Text  = $tl.c2_title
$window.FindName("C3Title").Text    = $tl.c3_title;  $window.FindName("C4Title").Text  = $tl.c4_title
$window.FindName("C5Title").Text    = $tl.c5_title;  $window.FindName("C6Title").Text  = $tl.c6_title
$window.FindName("C7Title").Text    = $tl.c7_title;  $window.FindName("C8Title").Text  = $tl.c8_title
$window.FindName("C9Title").Text    = $tl.c9_title;  $window.FindName("C10Title").Text = $tl.c10_title
$window.FindName("C11Title").Text   = $tl.c11_title
$window.FindName("WarpBtn").Content    = $tl.q_warp
$window.FindName("DiscordBtn").Content = $tl.q_discord
$window.FindName("ScriptBtn").Content  = $tl.q_script
$window.FindName("HelpBtn").Content    = $tl.q_help
$window.FindName("QuitBtn").Content    = $tl.q_quit
$window.FindName("LangLabel").Text     = $tl.lang_label

# ── Language buttons — highlight active language ──────────────────────────────
$langEN = $window.FindName("LangEN"); $langES = $window.FindName("LangES"); $langPT = $window.FindName("LangPT")
$activeStyle = $window.Resources["LangBtnActive"]
$inactStyle  = $window.Resources["LangBtn"]
$langEN.Style = if ($lang -eq "en") { $activeStyle } else { $inactStyle }
$langES.Style = if ($lang -eq "es") { $activeStyle } else { $inactStyle }
$langPT.Style = if ($lang -eq "pt") { $activeStyle } else { $inactStyle }

# ── Badges ────────────────────────────────────────────────────────────────────
function Set-Badge($border, $tb, $text) {
    $tb.Text = $text
    if ($text -eq "[installed]" -or $text -eq "[found]") {
        $border.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromArgb(0x99,0x1a,0x2a,0x1a))
        $tb.Foreground     = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x6b,0xdc,0x8a))
    } elseif ($text -eq "[not installed]" -or $text -eq "[not found]") {
        $border.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromArgb(0x99,0x2a,0x1a,0x1a))
        $tb.Foreground     = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xf8,0x71,0x71))
    } else {
        $border.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromArgb(0x99,0x2a,0x2a,0x1a))
        $tb.Foreground     = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xf5,0x9e,0x0b))
    }
}
Set-Badge ($window.FindName("Badge1")) ($window.FindName("BadgeText1")) $st.p1
Set-Badge ($window.FindName("Badge2")) ($window.FindName("BadgeText2")) $st.p2
Set-Badge ($window.FindName("Badge3")) ($window.FindName("BadgeText3")) $st.sp
# ── Load images synchronously on STA thread before ShowDialog ─────────────────
$iconBtn  = $window.FindName("ServerIconBtn")
$splashBg = $window.FindName("SplashBg")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-UrlBytes([string]$url) {
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 `
             -Headers @{"User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"} -EA Stop
        return ,[byte[]]$r.Content
    } catch {}
    try {
        $wc = [System.Net.WebClient]::new()
        $wc.Headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        $b = $wc.DownloadData($url); $wc.Dispose(); return ,$b
    } catch {}
    return $null
}
function New-WpfBitmap([byte[]]$bytes) {
    $ms = [System.IO.MemoryStream]::new($bytes)
    $bmp = [System.Windows.Media.Imaging.BitmapImage]::new()
    $bmp.BeginInit()
    $bmp.StreamSource = $ms
    $bmp.CacheOption  = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bmp.EndInit()
    $ms.Dispose()
    return $bmp
}

# Server icon
$iconBytes = Get-UrlBytes "https://cdn.discordapp.com/icons/1408201417834893385/f5c9265968b03ac3e554063df0aa1d03.png?size=256"
if ($iconBytes -and $iconBytes.Length -gt 0) {
    try {
        $iconBmp = New-WpfBitmap $iconBytes
        $iconImg = [System.Windows.Controls.Image]::new()
        $iconImg.Source  = $iconBmp
        $iconImg.Stretch = [System.Windows.Media.Stretch]::UniformToFill
        $iconImg.Width = 52; $iconImg.Height = 52
        $iconBorder = [System.Windows.Controls.Border]::new()
        $iconBorder.CornerRadius = [System.Windows.CornerRadius]::new(14)
        $iconBorder.ClipToBounds = $true
        $iconBorder.Width = 52; $iconBorder.Height = 52
        $iconBorder.Child = $iconImg
        $iconBtn.Content = $iconBorder
    } catch {}
}

# Splash background
$splashBytes = Get-UrlBytes "https://cdn.discordapp.com/discovery-splashes/1408201417834893385/7d797088d8f69ba1895d66daee4f6ce7.jpg?size=512"
if ($splashBytes -and $splashBytes.Length -gt 0) {
    try { $splashBg.Source = New-WpfBitmap $splashBytes } catch {}
}


$chosen = $null
function Choose($n) { $script:chosen = $n; $window.Close() }

$window.FindName("Btn1").Add_Click({  Choose 1  })
$window.FindName("Btn2").Add_Click({  Choose 2  })
$window.FindName("Btn3").Add_Click({  Choose 3  })
$window.FindName("Btn4").Add_Click({  Choose 4  })
$window.FindName("Btn5").Add_Click({  Choose 5  })
$window.FindName("Btn6").Add_Click({  Choose 6  })
$window.FindName("Btn7").Add_Click({  Choose 7  })
$window.FindName("Btn8").Add_Click({  Choose 8  })
$window.FindName("Btn9").Add_Click({  Choose 9  })
$window.FindName("Btn10").Add_Click({ Choose 10 })
$window.FindName("Btn11").Add_Click({ Choose 11 })
$window.FindName("QuitBtn").Add_Click({ $script:chosen = "Q"; $window.Close() })

# Language buttons — write result and close; parent reruns menu with new lang
$window.FindName("LangEN").Add_Click({ $script:chosen = "LEN"; $window.Close() })
$window.FindName("LangES").Add_Click({ $script:chosen = "LES"; $window.Close() })
$window.FindName("LangPT").Add_Click({ $script:chosen = "LPT"; $window.Close() })

$window.FindName("WarpBtn").Add_Click({    try { Start-Process "https://one.one.one.one/" } catch {} })
$window.FindName("DiscordBtn").Add_Click({ try { Start-Process "https://discord.gg/luatools" } catch {} })
$window.FindName("ScriptBtn").Add_Click({  try { Start-Process "https://potatoes-dev.com/scripts/scmp9guj7b" } catch {} })
$window.FindName("HelpBtn").Add_Click({    try { Start-Process "https://discord.gg/luatools" } catch {} })

$window.ShowDialog() | Out-Null
if ($script:chosen) { $script:chosen | Set-Content $ResultFile -Encoding UTF8 }
'@ | Set-Content $menuScript -Encoding UTF8

    $menuLoop = $true
    while ($menuLoop) {
        # Refresh status each loop — include active language so GUI can show it
        $plugStatus1 = Get-PluginStatus "luatools"
        $plugStatus2 = Get-PluginStatus "steamtools-collection"
        $spaceStatus = Get-SpacethemeStatus
        @{ p1=$plugStatus1; p2=$plugStatus2; sp=$spaceStatus; lang=$script:ScriptLanguage } | ConvertTo-Json -Compress | Set-Content $statusFile -Encoding UTF8
        Remove-Item $menuResult -Force -ErrorAction SilentlyContinue

        Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$menuScript`" -ResultFile `"$menuResult`" -StatusFile `"$statusFile`"" `
            -Wait | Out-Null

        if (-not (Test-Path $menuResult)) { exit 0 }
        $menuChoice = (Get-Content $menuResult -Raw -Encoding UTF8).Trim()
        Remove-Item $menuResult -Force -ErrorAction SilentlyContinue

        switch ($menuChoice) {
            "1"   { $Branch = 1;  $menuLoop = $false }
            "2"   { $Branch = 2;  $menuLoop = $false }
            "3"   { $Branch = 3;  $menuLoop = $false }
            "4"   { $Branch = 4;  $menuLoop = $false }
            "5"   { $Branch = 5;  $menuLoop = $false }
            "6"   { $Branch = 6;  $menuLoop = $false }
            "7"   { $Branch = 7;  $menuLoop = $false }
            "8"   { $Branch = 8;  $menuLoop = $false }
            "9"   { $Branch = 9;  $menuLoop = $false }
            "10"  { $Branch = 10; $menuLoop = $false }
            "11"  { $Branch = 11; $menuLoop = $false }
            "LEN" { $script:ScriptLanguage = "en" }
            "LES" { $script:ScriptLanguage = "es" }
            "LPT" { $script:ScriptLanguage = "pt" }
            "Q"   { Remove-Item $menuScript -Force -ErrorAction SilentlyContinue; Remove-Item $statusFile -Force -ErrorAction SilentlyContinue; exit 0 }
            ""    { exit 0 }
            $null { exit 0 }
        }
        # menuLoop stays true for language changes — window will reopen with updated lang
    }
    Remove-Item $menuScript  -Force -ErrorAction SilentlyContinue
    Remove-Item $statusFile  -Force -ErrorAction SilentlyContinue
    Blank
}

:MainLoop while ($true) {

# Apply branch 2 name/link (works for both -Branch 2 and menu selection)
if ($Branch -eq 2) {
    $name = "steamtools-collection"
    $link = "https://github.com/clemdotla/steamtools-collection/releases/download/Latest/steamtools-collection.zip"
    $upperName = "Steamtools-collection"
}


#### Branch 3: Spacetheme Block Remover (by waike - waike.dev) ####
if ($Branch -eq 3) {
    $b3Script = Join-Path $env:TEMP "luatools_b3.ps1"
    $b3Steam  = if ($steam) { $steam } else { "" }
@"
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
`$steamPath = '$b3Steam'
if (-not `$steamPath -or -not (Test-Path `$steamPath)) {
    `$k = @("HKCU:\Software\Valve\Steam","HKLM:\SOFTWARE\WOW6432Node\Valve\Steam","HKLM:\SOFTWARE\Valve\Steam")
    foreach (`$r in `$k) { try { `$v=(Get-ItemProperty `$r -EA Stop).SteamPath; if(`$v -and (Test-Path `$v)){`$steamPath=`$v;break} } catch{} }
    foreach (`$r in `$k) { try { `$v=(Get-ItemProperty `$r -EA Stop).InstallPath; if(`$v -and (Test-Path `$v)){`$steamPath=`$v;break} } catch{} }
}

[xml]`$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Spacetheme Block Remover  |  .gg/luatools"
        Width="660" Height="500" MinWidth="480" MinHeight="380"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>
    <StackPanel Grid.Row="0" Margin="0,0,0,14">
      <TextBlock Text="Spacetheme Block Remover" FontSize="20" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Text="Removes the 'get a job loser' CSS overlay from Spacetheme  |  by waike" Foreground="#44445a" FontSize="11" Margin="0,3,0,0"/>
      <TextBlock Text="Steam will be closed, the CSS file patched, then you can reopen Steam." Foreground="#6b6b88" FontSize="11" Margin="0,2,0,0" TextWrapping="Wrap"/>
    </StackPanel>
    <Border Grid.Row="1" Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,10">
      <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap">Click Run to start.</TextBlock>
    </Border>
    <Border Grid.Row="2" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                 TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>
    <Grid Grid.Row="3">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <Button x:Name="RunBtn" Grid.Column="1" Content="▶  Run" Width="110" Height="34" Cursor="Hand"
              Background="#4f46e5" Foreground="White" BorderThickness="0" FontWeight="SemiBold">
        <Button.Template><ControlTemplate TargetType="Button">
          <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6">
            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <ControlTemplate.Triggers>
            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger>
            <Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger>
          </ControlTemplate.Triggers>
        </ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="3" Content="Close" Width="90" Height="34" Cursor="Hand" IsEnabled="False"
              Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button">
          <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6">
            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <ControlTemplate.Triggers>
            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger>
            <Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1a1a26"/><Setter Property="Foreground" Value="#33334a"/></Trigger>
          </ControlTemplate.Triggers>
        </ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
'@
`$rd = [System.Xml.XmlNodeReader]::new(`$xaml)
`$win = [System.Windows.Markup.XamlReader]::Load(`$rd)
`$stepLabel = `$win.FindName("StepLabel")
`$logBox    = `$win.FindName("LogBox")
`$logScroll = `$win.FindName("LogScroll")
`$runBtn    = `$win.FindName("RunBtn")
`$closeBtn  = `$win.FindName("CloseBtn")

function GL(`$m) { `$win.Dispatcher.Invoke([action]{ `$logBox.AppendText("`$m``n"); `$logScroll.ScrollToBottom() }) }
function GS(`$m) { `$win.Dispatcher.Invoke([action]{ `$stepLabel.Text = `$m }) }

`$closeBtn.Add_Click({ `$win.Close() })
`$runBtn.Add_Click({
    `$runBtn.IsEnabled = `$false
    `$t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            if (-not `$steamPath -or -not (Test-Path `$steamPath)) { GL "[ERR]  Steam not found."; GS "Error — Steam not found."; `$win.Dispatcher.Invoke([action]{ `$closeBtn.IsEnabled=`$true }); return }
            GS "Scanning for Spacetheme..."; GL "[INFO] Steam path: `$steamPath"
            `$roots = @("`$steamPath\steamui\skins\Steam","`$steamPath\steamui\skins\spacetheme","`$steamPath\millennium\themes","`$steamPath\millennium\themes\Steam","C:\Program Files (x86)\Steam\millennium\themes","C:\Program Files (x86)\Steam\millennium\themes\Steam","C:\Program Files\Steam\millennium\themes","C:\Program Files\Steam\millennium\themes\Steam") | Where-Object { Test-Path `$_ }
            if (`$roots.Count -eq 0) { GL "[ERR]  Spacetheme not found in any standard location."; GS "Error — Spacetheme not found."; `$win.Dispatcher.Invoke([action]{ `$closeBtn.IsEnabled=`$true }); return }
            GL "[OK]   Found `$(`$roots.Count) theme root(s)."
            GS "Closing Steam..."; GL "[WARN] Closing Steam..."
            Get-Process "steam" -EA SilentlyContinue | ForEach-Object { `$_.CloseMainWindow() | Out-Null }; Start-Sleep 1
            Get-Process "steam","steamwebhelper","steamerrorreporter" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue; Start-Sleep 1
            Stop-Service "Steam Client Service" -EA SilentlyContinue; Start-Sleep 1
            Get-Process "steam","steamwebhelper","steamservice","steamerrorreporter" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue; Start-Sleep 1
            GL "[OK]   Steam closed."
            GS "Patching CSS files..."
            `$pat = '(?is)/\*\s*\r?\n?\s*&\s*Ban piracy plugins.*?color:\s*#fff\s*!important;\s*\}'
            `$count = 0
            foreach (`$root in `$roots) {
                foreach (`$f in Get-ChildItem `$root -Recurse -Filter "*.css" -EA SilentlyContinue) {
                    `$c = Get-Content `$f.FullName -Raw
                    if (`$c -match `$pat) {
                        `$c = `$c -replace `$pat, '/* Patched piracy warning block */'
                        Set-Content `$f.FullName `$c -NoNewline -Encoding UTF8; `$count++
                        GL "[OK]   Patched: `$(`$f.Name)"
                    }
                }
            }
            if (`$count -gt 0) { GL "[OK]   Patched `$count CSS file(s)."; GS "Done! `$count file(s) patched — reopen Steam." }
            else { GL "[INFO] Nothing to patch — block may already be removed."; GS "Nothing to patch — already clean." }
        } catch { GL "[ERR]  `$(`$_.Exception.Message)"; GS "Error — see log." }
        `$win.Dispatcher.Invoke([action]{ `$closeBtn.IsEnabled=`$true })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})
`$win.ShowDialog() | Out-Null
"@ | Set-Content $b3Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b3Script`"" -Wait
    Remove-Item $b3Script -Force -ErrorAction SilentlyContinue
    $Branch = 0
}


#### Branch 4: Steam Offline Fix (by waike - waike.dev) ####
if ($Branch -eq 4) {
    $b4Script = Join-Path $env:TEMP "luatools_b4.ps1"
@'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Steam Offline Fix  |  .gg/luatools"
        Width="620" Height="420" MinWidth="460" MinHeight="320"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>
    <StackPanel Grid.Row="0" Margin="0,0,0,14">
      <TextBlock Text="Steam Offline Fix" FontSize="20" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Text="Fixes Steam stuck on the loading icon  |  by waike" Foreground="#44445a" FontSize="11" Margin="0,3,0,0"/>
      <TextBlock Text="Sets WantsOfflineMode=0 in loginusers.vdf so Steam starts normally." Foreground="#6b6b88" FontSize="11" Margin="0,2,0,0" TextWrapping="Wrap"/>
    </StackPanel>
    <Border Grid.Row="1" Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,10">
      <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap">Click Run to apply the fix.</TextBlock>
    </Border>
    <Border Grid.Row="2" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>
    <Grid Grid.Row="3">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <Button x:Name="RunBtn" Grid.Column="1" Content="▶  Run" Width="110" Height="34" Cursor="Hand" Background="#4f46e5" Foreground="White" BorderThickness="0" FontWeight="SemiBold">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="3" Content="Close" Width="90" Height="34" Cursor="Hand" IsEnabled="False" Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1a1a26"/><Setter Property="Foreground" Value="#33334a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
"@
$rd=$([System.Xml.XmlNodeReader]::new($xaml)); $win=[System.Windows.Markup.XamlReader]::Load($rd)
$stepLabel=$win.FindName("StepLabel"); $logBox=$win.FindName("LogBox"); $logScroll=$win.FindName("LogScroll"); $runBtn=$win.FindName("RunBtn"); $closeBtn=$win.FindName("CloseBtn")
function GL($m){ $win.Dispatcher.Invoke([action]{ $logBox.AppendText("$m`n"); $logScroll.ScrollToBottom() }) }
function GS($m){ $win.Dispatcher.Invoke([action]{ $stepLabel.Text=$m }) }
$closeBtn.Add_Click({ $win.Close() })
$runBtn.Add_Click({
    $runBtn.IsEnabled=$false
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            $sp=(Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -EA SilentlyContinue).InstallPath
            if(-not $sp){ $sp=(Get-ItemProperty "HKLM:\SOFTWARE\Valve\Steam" -EA SilentlyContinue).InstallPath }
            if(-not $sp -or -not (Test-Path $sp)){ GL "[ERR]  Steam path not found."; GS "Error — Steam not found."; $win.Dispatcher.Invoke([action]{ $closeBtn.IsEnabled=$true }); return }
            GL "[INFO] Steam path: $sp"
            $luf=Join-Path $sp "config\loginusers.vdf"
            if(Test-Path $luf){
                GS "Patching loginusers.vdf..."
                $c=Get-Content $luf -Raw
                if($c -match '"WantsOfflineMode"\s+"1"'){
                    $c=$c -replace '("WantsOfflineMode"\s+)"1"','$1"0"'
                    Set-Content $luf $c -Encoding UTF8
                    GL "[OK]   Fixed — WantsOfflineMode set to 0."; GS "Done! Steam should now start online."
                } else { GL "[INFO] Steam was not in offline mode — nothing changed."; GS "Already online — nothing to change." }
            } else { GL "[ERR]  loginusers.vdf not found at: $luf"; GS "Error — loginusers.vdf not found." }
        } catch { GL "[ERR]  $($_.Exception.Message)"; GS "Error — see log." }
        $win.Dispatcher.Invoke([action]{ $closeBtn.IsEnabled=$true })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})
$win.ShowDialog() | Out-Null
'@ | Set-Content $b4Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b4Script`"" -Wait
    Remove-Item $b4Script -Force -ErrorAction SilentlyContinue
    $Branch = 0
}


#### Branch 5: ST Uninstaller (by Potatoes9411) ####
if ($Branch -eq 5) {
    $b5SteamPath = $null
    foreach ($e in @(
        @{P="HKCU:\Software\Valve\Steam";K="SteamPath"},
        @{P="HKLM:\SOFTWARE\Valve\Steam";K="InstallPath"},
        @{P="HKLM:\SOFTWARE\WOW6432Node\Valve\Steam";K="InstallPath"})) {
        if (Test-Path $e.P) {
            $v = (Get-ItemProperty -Path $e.P -Name $e.K -ErrorAction SilentlyContinue).($e.K)
            if ($v -and (Test-Path $v)) { $b5SteamPath = $v; break }
        }
    }
    if (-not $b5SteamPath) { $b5SteamPath = "" }
    $b5Name = $name
    $b5Script = Join-Path $env:TEMP "luatools_b5.ps1"
    $b5DataFile = Join-Path $env:TEMP "luatools_b5_data.json"
    @{ steam=$b5SteamPath; pluginName=$b5Name } | ConvertTo-Json | Set-Content $b5DataFile -Encoding UTF8

@'
param($DataFile)
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$d = Get-Content $DataFile -Raw | ConvertFrom-Json
$steam = $d.steam
$pluginName = $d.pluginName

function Test-PluginInst {
    if (-not $steam) { return $false }
    $dir = Join-Path $steam "plugins"
    if (-not (Test-Path $dir)) { $dir = Join-Path $steam "millennium\plugins" }
    if (-not (Test-Path $dir)) { return $false }
    foreach ($p in Get-ChildItem $dir -Directory -EA SilentlyContinue) {
        $jp = Join-Path $p.FullName "plugin.json"
        if (Test-Path $jp) {
            $j = try { Get-Content $jp -Raw | ConvertFrom-Json } catch { $null }
            if ($j -and $j.name -eq $pluginName) { return $true }
        }
    }
    return $false
}
function Test-StInst { if (-not $steam) { return $false }; (@("dwmapi.dll","xinput1_4.dll") | Where-Object { Test-Path (Join-Path $steam $_) }).Count -gt 0 -or (Test-Path "C:\Program Files\SteamTools") }
function Test-MillInst { if (-not $steam) { return $false }; (@("millennium.dll","python311.dll","version.dll","user32.dll","winmm.dll","millennium_bootstrap.dll","ext","millennium","pkg") | Where-Object { Test-Path (Join-Path $steam $_) }).Count -gt 0 }
function Get-LuaCount { $p = Join-Path $steam "config\stplug-in"; if (-not (Test-Path $p)) { return 0 }; @(Get-ChildItem $p -Filter "*.lua" -EA SilentlyContinue).Count }

$plugOk = Test-PluginInst; $stOk = Test-StInst; $millOk = Test-MillInst; $luaCount = Get-LuaCount

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ST Uninstaller  |  .gg/luatools"
        Width="720" Height="620" MinWidth="560" MinHeight="500"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Window.Resources>
    <Style x:Key="ToggleCard" TargetType="Border">
      <Setter Property="Background" Value="#14141d"/>
      <Setter Property="CornerRadius" Value="7"/>
      <Setter Property="Padding" Value="14,11"/>
      <Setter Property="Margin" Value="0,4"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1c1c2a"/></Trigger></Style.Triggers>
    </Style>
    <Style TargetType="CheckBox">
      <Setter Property="Foreground" Value="#c8c8d4"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
    </Style>
  </Window.Resources>
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Margin="0,0,0,14">
      <TextBlock Text="ST Uninstaller" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Text="Toggle what you want to remove, then click Run. Nothing is deleted until you confirm.  |  by Potatoes9411" Foreground="#44445a" FontSize="11" Margin="0,3,0,0" TextWrapping="Wrap"/>
      <Border Background="#1a1010" CornerRadius="5" Padding="10,7" Margin="0,8,0,0">
        <TextBlock Foreground="#f87171" FontSize="11" TextWrapping="Wrap">
          ⚠  Make sure Steam is closed before running. Tick the items you want to uninstall below.
        </TextBlock>
      </Border>
    </StackPanel>

    <TextBlock Grid.Row="1" Text="WHAT TO UNINSTALL" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,4"/>

    <StackPanel Grid.Row="2">
      <Border Style="{StaticResource ToggleCard}">
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <CheckBox x:Name="ChkPlugin" Grid.Column="0" Margin="0,0,10,0"/>
          <StackPanel Grid.Column="1">
            <TextBlock Text="Luatools Plugin" FontWeight="SemiBold" Foreground="#e2e2f0"/>
            <TextBlock Foreground="#6b6b88" FontSize="10" TextWrapping="Wrap">Removes the plugin folder and disables it in Millennium config. Does not remove SteamTools or Millennium itself.</TextBlock>
          </StackPanel>
          <Border x:Name="BadgePlugin" Grid.Column="2" CornerRadius="3" Padding="6,2" VerticalAlignment="Center">
            <TextBlock x:Name="BadgeTxtPlugin" FontSize="10" FontWeight="SemiBold"/>
          </Border>
        </Grid>
      </Border>

      <Border Style="{StaticResource ToggleCard}">
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <CheckBox x:Name="ChkST" Grid.Column="0" Margin="0,0,10,0"/>
          <StackPanel Grid.Column="1">
            <TextBlock Text="SteamTools" FontWeight="SemiBold" Foreground="#e2e2f0"/>
            <TextBlock Foreground="#6b6b88" FontSize="10" TextWrapping="Wrap">Removes dwmapi.dll + xinput1_4.dll from Steam folder, plus C:\Program Files\SteamTools directory, registry entries, and Start Menu shortcuts.</TextBlock>
          </StackPanel>
          <Border x:Name="BadgeST" Grid.Column="2" CornerRadius="3" Padding="6,2" VerticalAlignment="Center">
            <TextBlock x:Name="BadgeTxtST" FontSize="10" FontWeight="SemiBold"/>
          </Border>
        </Grid>
      </Border>

      <Border Style="{StaticResource ToggleCard}">
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <CheckBox x:Name="ChkMill" Grid.Column="0" Margin="0,0,10,0"/>
          <StackPanel Grid.Column="1">
            <TextBlock Text="Millennium" FontWeight="SemiBold" Foreground="#e2e2f0"/>
            <TextBlock Foreground="#6b6b88" FontSize="10" TextWrapping="Wrap">Removes millennium.dll, python311.dll, version.dll, winmm.dll and related files. Also removes the ext/, pkg/, and millennium/ folders from Steam.</TextBlock>
          </StackPanel>
          <Border x:Name="BadgeMill" Grid.Column="2" CornerRadius="3" Padding="6,2" VerticalAlignment="Center">
            <TextBlock x:Name="BadgeTxtMill" FontSize="10" FontWeight="SemiBold"/>
          </Border>
        </Grid>
      </Border>

      <TextBlock Text="OPTIONS" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,10,0,4"/>

      <Border Style="{StaticResource ToggleCard}">
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
          <CheckBox x:Name="ChkLuas" Grid.Column="0" Margin="0,0,10,0"/>
          <StackPanel Grid.Column="1">
            <TextBlock Text="Remove SteamTools Lua Files" FontWeight="SemiBold" Foreground="#e2e2f0"/>
            <TextBlock Foreground="#6b6b88" FontSize="10" TextWrapping="Wrap">Removes all .lua files in Steam\config\stplug-in. These are your game unlock files — only tick this if you want a full clean wipe.</TextBlock>
          </StackPanel>
          <Border x:Name="BadgeLua" Grid.Column="2" CornerRadius="3" Padding="6,2" VerticalAlignment="Center" Background="#2a2a1a">
            <TextBlock x:Name="BadgeTxtLua" FontSize="10" FontWeight="SemiBold" Foreground="#f59e0b"/>
          </Border>
        </Grid>
      </Border>

      <Border Style="{StaticResource ToggleCard}">
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
          <CheckBox x:Name="ChkKeepPlugins" Grid.Column="0" Margin="0,0,10,0"/>
          <StackPanel Grid.Column="1">
            <TextBlock Text="Keep Millennium plugins folder" FontWeight="SemiBold" Foreground="#e2e2f0"/>
            <TextBlock Foreground="#6b6b88" FontSize="10" TextWrapping="Wrap">When removing Millennium, keep the plugins/ folder so you don't lose other installed plugins. Only applies if Millennium is ticked above.</TextBlock>
          </StackPanel>
        </Grid>
      </Border>
    </StackPanel>

    <Border Grid.Row="3" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,10,0,10" Height="80">
      <ScrollViewer VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                 TextWrapping="Wrap" AcceptsReturn="True" Text="Tick items above, then click Run Uninstaller."/>
      </ScrollViewer>
    </Border>

    <Grid Grid.Row="4">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="8"/>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="8"/>
        <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <CheckBox x:Name="ChkRestart" Grid.Column="0" Content="Restart Steam after uninstall" Foreground="#6b6b88" VerticalAlignment="Center"/>
      <Button x:Name="RunBtn" Grid.Column="1" Content="▶  Run Uninstaller" Width="160" Height="36" Cursor="Hand" FontWeight="SemiBold" Background="#c0392b" Foreground="White" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,8"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#e74c3c"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="3" Content="Close" Width="90" Height="36" Cursor="Hand" Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,8"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
"@
$rd=[System.Xml.XmlNodeReader]::new($xaml); $win=[System.Windows.Markup.XamlReader]::Load($rd)
$chkPlugin=$win.FindName("ChkPlugin"); $chkST=$win.FindName("ChkST"); $chkMill=$win.FindName("ChkMill")
$chkLuas=$win.FindName("ChkLuas"); $chkKeep=$win.FindName("ChkKeepPlugins"); $chkRestart=$win.FindName("ChkRestart")
$logBox=$win.FindName("LogBox"); $runBtn=$win.FindName("RunBtn"); $closeBtn=$win.FindName("CloseBtn")
$bPlugin=$win.FindName("BadgePlugin"); $btPlugin=$win.FindName("BadgeTxtPlugin")
$bST=$win.FindName("BadgeST"); $btST=$win.FindName("BadgeTxtST")
$bMill=$win.FindName("BadgeMill"); $btMill=$win.FindName("BadgeTxtMill")
$bLua=$win.FindName("BadgeLua"); $btLua=$win.FindName("BadgeTxtLua")

function SetBadge($b,$tb,$found) {
    if ($found) { $b.Background=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x1a,0x2a,0x1a)); $tb.Text="[installed]"; $tb.Foreground=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x6b,0xdc,0x8a)) }
    else { $b.Background=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x2a,0x2a,0x2a)); $tb.Text="[not found]"; $tb.Foreground=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x44,0x44,0x5a)) }
}
SetBadge $bPlugin $btPlugin $plugOk; SetBadge $bST $btST $stOk; SetBadge $bMill $btMill $millOk
$chkPlugin.IsChecked=$plugOk; $chkST.IsChecked=$stOk; $chkMill.IsChecked=$millOk
$btLua.Text="$luaCount .lua file(s)"; if ($luaCount -eq 0) { $btLua.Foreground=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x44,0x44,0x5a)) }

function GL($m){ $logBox.AppendText("$m`n"); $logBox.ScrollToEnd() }

$closeBtn.Add_Click({ $win.Close() })
$runBtn.Add_Click({
    if (-not $chkPlugin.IsChecked -and -not $chkST.IsChecked -and -not $chkMill.IsChecked) {
        $logBox.Text = "[WARN] Nothing selected to uninstall. Tick at least one item above.`n"; return
    }
    $runBtn.IsEnabled=$false
    $logBox.Text=""
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        function GLW($m){ $win.Dispatcher.Invoke([action]{ $logBox.AppendText("$m`n"); $logBox.ScrollToEnd() }) }
        try {
            if (-not $steam) { GLW "[ERR]  Steam not found."; $win.Dispatcher.Invoke([action]{ $runBtn.IsEnabled=$true }); return }
            GLW "[WARN] Killing Steam..."
            Get-Process "steam","steamwebhelper","SteamTools" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
            Start-Sleep 2
            GLW "[OK]   Steam closed."

            if ($chkPlugin.IsChecked) {
                GLW "[INFO] Uninstalling plugin: $pluginName..."
                $pdir = Join-Path $steam "plugins"
                if (-not (Test-Path $pdir)) { $pdir = Join-Path $steam "millennium\plugins" }
                $found=$null
                if (Test-Path $pdir) {
                    foreach ($p in Get-ChildItem $pdir -Directory -EA SilentlyContinue) {
                        $jp=Join-Path $p.FullName "plugin.json"
                        if (Test-Path $jp) { $j=try{Get-Content $jp -Raw|ConvertFrom-Json}catch{$null}; if($j-and$j.name-eq$pluginName){$found=$p.FullName;break} }
                    }
                }
                if ($found) { Remove-Item $found -Recurse -Force -EA SilentlyContinue; GLW "[OK]   Plugin folder removed." }
                else { GLW "[WARN] Plugin folder not found — already removed?" }
                # Remove from config
                foreach ($cfgPath in @((Join-Path $steam "ext\config.json"),(Join-Path $steam "millennium\config\config.json"))) {
                    if (Test-Path $cfgPath) {
                        $cfg=try{Get-Content $cfgPath -Raw|ConvertFrom-Json}catch{$null}
                        if ($cfg-and$cfg.plugins-and$cfg.plugins.enabledPlugins) {
                            $before=@($cfg.plugins.enabledPlugins); $after=$before|Where-Object{$_ -ne $pluginName}
                            if ($before.Count -ne $after.Count) { $cfg.plugins.enabledPlugins=$after; $cfg|ConvertTo-Json -Depth 10|Set-Content $cfgPath -Encoding UTF8; GLW "[OK]   Removed from enabled plugins list." }
                        }
                    }
                }
                GLW "[OK]   Plugin uninstalled."
            }

            if ($chkST.IsChecked) {
                GLW "[INFO] Uninstalling SteamTools..."
                @("dwmapi.dll","xinput1_4.dll") | ForEach-Object {
                    $t=Join-Path $steam $_; if(Test-Path $t){try{Remove-Item $t -Force -EA Stop;GLW "[OK]   Removed: $_"}catch{GLW "[ERR]  Cannot remove $_`: $($_.Exception.Message)"}}
                }
                if ($chkLuas.IsChecked) {
                    $lp=Join-Path $steam "config\stplug-in"
                    if (Test-Path $lp) { Get-ChildItem $lp -Filter "*.lua" -EA SilentlyContinue | ForEach-Object { try{Remove-Item $_.FullName -Force;GLW "[OK]   Removed: $($_.Name)"}catch{GLW "[ERR]  $($_.Name): $($_.Exception.Message)"} } }
                }
                @("C:\Program Files\SteamTools") | Where-Object {Test-Path $_} | ForEach-Object { try{Remove-Item $_ -Recurse -Force;GLW "[OK]   Removed: $_"}catch{GLW "[WARN] $_`: $($_.Exception.Message)"} }
                Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SteamTools" -Recurse -Force -EA SilentlyContinue
                $smd="$env:APPDATA\Microsoft\Windows\Start Menu\Programs\SteamTools"; if(Test-Path $smd){Remove-Item $smd -Recurse -Force -EA SilentlyContinue; GLW "[OK]   Start Menu folder removed."}
                GLW "[OK]   SteamTools uninstalled."
            }

            if ($chkMill.IsChecked) {
                GLW "[INFO] Uninstalling Millennium..."
                @("millennium.dll","python311.dll","python311.zip","version.dll","user32.dll","winmm.dll","millennium_bootstrap.dll") | ForEach-Object {
                    $t=Join-Path $steam $_; if(Test-Path $t){try{Remove-Item $t -Force -EA Stop;GLW "[OK]   Removed: $_"}catch{GLW "[ERR]  $_`: $($_.Exception.Message)"}}
                }
                @("ext","millennium","pkg") | ForEach-Object {
                    $t=Join-Path $steam $_; if(Test-Path $t){try{Remove-Item $t -Recurse -Force -EA Stop;GLW "[OK]   Removed: $_\"}catch{GLW "[ERR]  $_\`: $($_.Exception.Message)"}}
                }
                if (-not $chkKeep.IsChecked) {
                    $pd=Join-Path $steam "plugins"; if(Test-Path $pd){try{Remove-Item $pd -Recurse -Force -EA Stop;GLW "[OK]   Removed: plugins\"}catch{GLW "[ERR]  plugins\: $($_.Exception.Message)"}}
                } else { GLW "[INFO] Keeping plugins\ folder (option checked)." }
                GLW "[OK]   Millennium uninstalled."
            }

            if ($chkRestart.IsChecked) {
                $exe=Join-Path $steam "steam.exe"; if(Test-Path $exe){ Start-Process $exe; GLW "[OK]   Steam restarted." } else { GLW "[WARN] steam.exe not found." }
            }
            GLW "[OK]   Done! You can now close this window."
        } catch { GLW "[ERR]  $($_.Exception.Message)" }
        $win.Dispatcher.Invoke([action]{ $runBtn.IsEnabled=$true })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})
$win.ShowDialog() | Out-Null
'@ | Set-Content $b5Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b5Script`" -DataFile `"$b5DataFile`"" -Wait
    Remove-Item $b5Script   -Force -ErrorAction SilentlyContinue
    Remove-Item $b5DataFile -Force -ErrorAction SilentlyContinue
    $Branch = 0
}


#### Branch 6: Steam Bulk Fixer (by waike - waike.dev) ####
if ($Branch -eq 6) {
    $b6Script = Join-Path $env:TEMP "luatools_b6.ps1"
@'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Steam Bulk Fixer  |  .gg/luatools"
        Width="700" Height="560" MinWidth="520" MinHeight="440"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>
    <StackPanel Grid.Row="0" Margin="0,0,0,10">
      <TextBlock Text="Steam Bulk Fixer" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Text="Runs a collection of fixes for Steam and SteamTools  |  by waike (waike.dev)" Foreground="#44445a" FontSize="11" Margin="0,3,0,0"/>
    </StackPanel>
    <Border Grid.Row="1" Background="#12121a" CornerRadius="6" Padding="12,10" Margin="0,0,0,10">
      <StackPanel>
        <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,6">
          This tool does the following in order:
        </TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Closes Steam completely</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Adds Windows Defender exclusion for the Steam folder (admin only)</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Re-downloads xinput1_4.dll and dwmapi.dll (SteamTools DLLs)</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Runs the Luatools temporary fixer script</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Reinstalls the Luatools plugin</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Relaunches Steam</TextBlock>
        <Border Background="#1a1a10" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
          <TextBlock x:Name="AdminNote" Foreground="#f59e0b" FontSize="10" TextWrapping="Wrap"/>
        </Border>
      </StackPanel>
    </Border>
    <Border Grid.Row="2" Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,8">
      <StackPanel>
        <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap">Click Run to start all fixes.</TextBlock>
        <ProgressBar x:Name="ProgressBar" Height="6" Minimum="0" Maximum="100" Value="0"
                     Background="#1a1a26" Foreground="#a78bfa" BorderThickness="0" Margin="0,6,0,0"/>
      </StackPanel>
    </Border>
    <Border Grid.Row="3" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                 TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>
    <Grid Grid.Row="4">
      <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <CheckBox x:Name="SkipDefChk" Grid.Column="0" Content="Skip Defender exclusions" Foreground="#6b6b88" VerticalAlignment="Center" Margin="0,0,12,0"/>
      <Button x:Name="RunBtn" Grid.Column="2" Content="▶  Run All Fixes" Width="140" Height="34" Cursor="Hand" FontWeight="SemiBold" Background="#4f46e5" Foreground="White" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="4" Content="Close" Width="90" Height="34" Cursor="Hand" Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
"@
$rd=[System.Xml.XmlNodeReader]::new($xaml); $win=[System.Windows.Markup.XamlReader]::Load($rd)
$stepLabel=$win.FindName("StepLabel"); $pb=$win.FindName("ProgressBar")
$logBox=$win.FindName("LogBox"); $logScroll=$win.FindName("LogScroll")
$runBtn=$win.FindName("RunBtn"); $closeBtn=$win.FindName("CloseBtn")
$skipDefChk=$win.FindName("SkipDefChk"); $adminNote=$win.FindName("AdminNote")

if ($IsAdmin) { $adminNote.Text = "✓  Running as Administrator — Defender exclusions will be applied." }
else { $adminNote.Text = "⚠  Not running as Administrator — Defender exclusion step will be skipped. Right-click the script and choose 'Run as Administrator' for full effect." }

function GL($m){ $win.Dispatcher.Invoke([action]{ $logBox.AppendText("$m`n"); $logScroll.ScrollToBottom() }) }
function GS($m,$p){ $win.Dispatcher.Invoke([action]{ $stepLabel.Text=$m; if($p -ge 0){$pb.Value=$p} }) }

$closeBtn.Add_Click({ $win.Close() })
$runBtn.Add_Click({
    $runBtn.IsEnabled=$false; $skipDef=$skipDefChk.IsChecked
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            GS "Finding Steam..." 5
            $sp=(Get-ItemProperty "HKCU:\Software\Valve\Steam" -EA SilentlyContinue).SteamPath
            if(-not $sp-or-not(Test-Path $sp)){ GL "[ERR]  Steam not found."; GS "Error — Steam not found." -1; $win.Dispatcher.Invoke([action]{$closeBtn.IsEnabled=$true}); return }
            GL "[INFO] Steam path: $sp"

            GS "Closing Steam..." 10
            GL "[WARN] Closing Steam..."
            while(Get-Process "steam","steamwebhelper" -EA SilentlyContinue){ Get-Process "steam","steamwebhelper" -EA SilentlyContinue|Stop-Process -Force; Start-Sleep 1 }
            GL "[OK]   Steam closed."

            if($IsAdmin -and -not $skipDef){
                GS "Adding Defender exclusion..." 25
                GL "[INFO] Adding Defender exclusion for Steam folder..."
                try{ Add-MpPreference -ExclusionPath $sp -EA Stop; GL "[OK]   Defender exclusion added." }
                catch{ GL "[WARN] Defender change failed: $($_.Exception.Message)" }
            } else { GL "[INFO] Skipping Defender exclusion." }

            GS "Downloading SteamTools DLLs..." 40
            GL "[INFO] Downloading SteamTools DLLs..."
            @{"xinput1_4.dll"="http://update.steamox.com/update";"dwmapi.dll"="http://update.steamox.com/dwmapi"}.GetEnumerator()|ForEach-Object{
                $dest=Join-Path $sp $_.Key; GL "[LOG]  Getting $($_.Key)..."
                try{ Invoke-RestMethod -Uri $_.Value -OutFile $dest; GL "[OK]   $($_.Key) done." }
                catch{ GL "[ERR]  Failed to download $($_.Key): $($_.Exception.Message)" }
            }
            GL "[OK]   DLLs finished."

            GS "Running Luatools temp fixer..." 60
            GL "[INFO] Running Luatools temporary fixer..."
            try{ Invoke-Expression (Invoke-RestMethod "https://luatools.vercel.app/temporary-fixer.ps1"); GL "[OK]   Temp fixer done." }
            catch{ GL "[WARN] Temp fixer failed: $($_.Exception.Message)" }

            GS "Reinstalling Luatools plugin..." 75
            GL "[INFO] Reinstalling Luatools plugin..."
            try{ Invoke-Expression (Invoke-RestMethod "https://luatools.vercel.app/install-plugin.ps1"); GL "[OK]   Plugin install done." }
            catch{ GL "[WARN] Plugin install failed: $($_.Exception.Message)" }

            GS "Launching Steam..." 95
            GL "[INFO] Launching Steam..."
            Start-Process (Join-Path $sp "steam.exe")
            GL "[OK]   Steam launched."
            GS "All fixes complete!" 100
        } catch { GL "[ERR]  $($_.Exception.Message)"; GS "Error — see log." -1 }
        $win.Dispatcher.Invoke([action]{ $closeBtn.IsEnabled=$true })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})
$win.ShowDialog() | Out-Null
'@ | Set-Content $b6Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b6Script`"" -Wait
    Remove-Item $b6Script -Force -ErrorAction SilentlyContinue
    $Branch = 0
}


#### Branch 7: Steam Manifest Downloader (by Skyflare - Modified by Potatoes9411) ####
if ($Branch -eq 7) {
    $b7Script   = Join-Path $env:TEMP "luatools_b7.ps1"
    $b7ApiKey   = if ($ApiKey)         { $ApiKey }         else { "" }
    $b7MorrKey  = if ($MorrenusApiKey) { $MorrenusApiKey } else { "" }
    $b7AppId    = if ($AppId)          { $AppId }          else { "" }
    $b7Mode     = if ($env:MANIFEST_MODE) { $env:MANIFEST_MODE } else { "" }
    $b7DataFile = Join-Path $env:TEMP "luatools_b7_data.json"
    @{ apiKey=$b7ApiKey; morrKey=$b7MorrKey; appId=$b7AppId; mode=$b7Mode } | ConvertTo-Json | Set-Content $b7DataFile -Encoding UTF8

@'
param($DataFile)
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$d = Get-Content $DataFile -Raw | ConvertFrom-Json
$initApiKey  = $d.apiKey
$initMorrKey = $d.morrKey
$initAppId   = $d.appId
$initMode    = $d.mode

# ── Pure logic helpers (no console output) ──────────────────────────────────
function Get-ManifestSteamPath {
    foreach ($p in @("HKLM:\SOFTWARE\WOW6432Node\Valve\Steam","HKLM:\SOFTWARE\Valve\Steam","HKCU:\SOFTWARE\Valve\Steam")) {
        try { $sp=(Get-ItemProperty $p -EA Stop).InstallPath; if($sp -and (Test-Path $sp)){ return $sp } } catch {}
    }
    return $null
}
function Get-DepotIdsFromLua([string]$p) {
    $out=@()
    foreach($l in (Get-Content $p -EA Stop)){ if($l -match 'addappid\s*\(\s*(\d+)\s*,\s*\d+\s*,\s*"[a-fA-F0-9]+"'){ $out+=$matches[1] } }
    return $out|Select-Object -Unique
}
function Get-AppInfo([string]$aid) {
    try{ return Invoke-RestMethod "https://api.steamcmd.net/v1/info/$aid" -Method Get -TimeoutSec 30 }catch{ return $null }
}
function Get-ManifestIdForDepot($info,[string]$aid,[string]$did) {
    try{ $dep=$info.data.$aid.depots; if($dep.$did -and $dep.$did.manifests -and $dep.$did.manifests.public){ return $dep.$did.manifests.public.gid } }catch{}
    return $null
}
function Try-DownloadUrl([string]$Url,[string]$Out,[int]$Max,[int]$Delay=3) {
    $last=$null
    for($a=1;$a-le$Max;$a++){
        try{
            if(Test-Path $Out){ Remove-Item $Out -Force -EA SilentlyContinue }
            Invoke-WebRequest $Url -Method Get -TimeoutSec 120 -OutFile $Out -EA Stop
            if((Test-Path $Out)-and((Get-Item $Out).Length-gt 0)){ return @{Success=$true;Is404=$false;Size=(Get-Item $Out).Length;Attempts=$a} }
            $last="Empty file"
        } catch {
            $sc=$null; if($_.Exception.Response){$sc=[int]$_.Exception.Response.StatusCode}
            if($sc-eq 404){ if(Test-Path $Out){Remove-Item $Out -Force -EA SilentlyContinue}; return @{Success=$false;Is404=$true;Error="Not found (404)";Attempts=$a} }
            $last=$_.Exception.Message
        }
        if($a-lt$Max){ Start-Sleep $Delay }
    }
    return @{Success=$false;Is404=$false;Error=$last;Attempts=$Max}
}
function Download-Manifest([string]$did,[string]$mid,[string]$outPath,[string]$Mode,[string]$ApiKey) {
    $f=Join-Path $outPath "${did}_${mid}.manifest"
    $r=Try-DownloadUrl "https://raw.githubusercontent.com/qwe213312/k25FCdfEOoEJ42S6/main/${did}_${mid}.manifest" $f 2
    if($r.Success){ return @{Success=$true;FilePath=$f;Size=$r.Size;Attempts=$r.Attempts;Source="GitHub"} }
    if($r.Is404 -and $Mode -ne "github") {
        if($Mode -eq "github+morrenus"){ $u="https://hubcapmanifest.com/api/v1/generate/manifest?depot_id=${did}&manifest_id=${mid}&api_key=${ApiKey}"; $lbl="Morrenus" }
        else { $u="https://api.manifesthub1.filegear-sg.me/manifest?apikey=${ApiKey}&depotid=${did}&manifestid=${mid}"; $lbl="ManifestHub" }
        $r2=Try-DownloadUrl $u $f 5
        if($r2.Success){ return @{Success=$true;FilePath=$f;Size=$r2.Size;Attempts=$r2.Attempts;Source=$lbl} }
        return @{Success=$false;Error=$r2.Error;Attempts=$r2.Attempts}
    }
    return @{Success=$false;Error=$r.Error;Attempts=$r.Attempts}
}
function Format-MFS([long]$b) { if($b-ge 1MB){"{0:N2} MB"-f($b/1MB)}elseif($b-ge 1KB){"{0:N2} KB"-f($b/1KB)}else{"$b B"} }

# ── XAML ────────────────────────────────────────────────────────────────────
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Steam Manifest Downloader  |  .gg/luatools"
        Width="860" Height="700" MinWidth="660" MinHeight="560"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Window.Resources>
    <Style x:Key="ModeCard" TargetType="Border">
      <Setter Property="Background" Value="#14141d"/>
      <Setter Property="CornerRadius" Value="7"/>
      <Setter Property="Padding" Value="14,11"/>
      <Setter Property="Margin" Value="0,3"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="Transparent"/>
      <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1c1c2a"/></Trigger></Style.Triggers>
    </Style>
    <Style x:Key="PriBtn" TargetType="Button">
      <Setter Property="Background" Value="#4f46e5"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value><ControlTemplate TargetType="Button">
          <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <ControlTemplate.Triggers>
            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger>
            <Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger>
          </ControlTemplate.Triggers>
        </ControlTemplate></Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="SecBtn" TargetType="Button">
      <Setter Property="Background" Value="#1e1e2e"/>
      <Setter Property="Foreground" Value="#c8c8d4"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value><ControlTemplate TargetType="Button">
          <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <ControlTemplate.Triggers>
            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/></Trigger>
            <Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1a1a26"/><Setter Property="Foreground" Value="#33334a"/></Trigger>
          </ControlTemplate.Triggers>
        </ControlTemplate></Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="FieldLbl" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#6b6b88"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="Margin" Value="0,0,0,3"/>
    </Style>
    <Style x:Key="FieldBox" TargetType="TextBox">
      <Setter Property="Background" Value="#14141d"/>
      <Setter Property="Foreground" Value="#e2e2f0"/>
      <Setter Property="BorderBrush" Value="#2a2a3f"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="8,6"/>
      <Setter Property="FontFamily" Value="Cascadia Code,Consolas,monospace"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="CaretBrush" Value="#a78bfa"/>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- Header -->
    <Border Grid.Row="0" Background="#0f0f18" Padding="18,14,18,12">
      <StackPanel>
        <StackPanel Orientation="Horizontal" Margin="0,0,0,2">
          <TextBlock Text="Steam Manifest Downloader" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
        </StackPanel>
        <TextBlock Foreground="#44445a" FontSize="11">by Skyflare, modified by Potatoes9411  |  Tries GitHub Mirror first (free), then Morrenus or ManifestHub as fallback</TextBlock>
        <Border Background="#12121a" CornerRadius="5" Padding="10,6" Margin="0,8,0,0">
          <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">
            Use this when your games show 'Manifest unavailable' in Luatools. Always try GitHub Mirror first — it's free and requires no key. Only use Morrenus or ManifestHub if GitHub Mirror says 'Not found (404)' for your game.
          </TextBlock>
        </Border>
      </StackPanel>
    </Border>

    <!-- Main content panels (tab-style, switched by code) -->
    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
      <StackPanel Margin="18,14,18,14">

        <!-- ═══ PANEL 1: Mode Selection ═══ -->
        <StackPanel x:Name="PanelMode">
          <TextBlock Text="STEP 1 — Choose a download source" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>

          <Button x:Name="BtnGitHub" Style="{StaticResource SecBtn}" Padding="0" Margin="0,3">
            <Border Style="{StaticResource ModeCard}" x:Name="CardGH" HorizontalAlignment="Stretch">
              <Grid>
                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <Border Grid.Column="0" Background="#1a2a1a" CornerRadius="4" Padding="8,4" Margin="0,0,12,0" VerticalAlignment="Center">
                  <TextBlock Text="FREE" Foreground="#6bdc8a" FontSize="10" FontWeight="Bold"/>
                </Border>
                <StackPanel Grid.Column="1">
                  <TextBlock Text="1 — GitHub Mirror" FontWeight="SemiBold" Foreground="#e2e2f0" FontSize="13"/>
                  <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,0">No API key needed. Downloads directly from github.com/qwe213312/k25FCdfEOoEJ42S6. Try this first. If the manifest is not there, it will tell you.</TextBlock>
                </StackPanel>
                <TextBlock Grid.Column="2" Text="→" Foreground="#a78bfa" FontSize="16" VerticalAlignment="Center" Margin="12,0,0,0"/>
              </Grid>
            </Border>
          </Button>

          <Button x:Name="BtnMorrenus" Style="{StaticResource SecBtn}" Padding="0" Margin="0,3">
            <Border Style="{StaticResource ModeCard}" x:Name="CardMorr" HorizontalAlignment="Stretch">
              <Grid>
                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <Border Grid.Column="0" Background="#1a1a2a" CornerRadius="4" Padding="8,4" Margin="0,0,12,0" VerticalAlignment="Center">
                  <TextBlock Text="KEY" Foreground="#a78bfa" FontSize="10" FontWeight="Bold"/>
                </Border>
                <StackPanel Grid.Column="1">
                  <TextBlock Text="2 — GitHub Mirror + Morrenus fallback" FontWeight="SemiBold" Foreground="#e2e2f0" FontSize="13"/>
                  <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,0">Tries GitHub first, falls back to Morrenus (hubcapmanifest.com) if not found. Requires a free API key from hubcapmanifest.com — log in with Discord, go to /api-keys/user.</TextBlock>
                </StackPanel>
                <TextBlock Grid.Column="2" Text="→" Foreground="#a78bfa" FontSize="16" VerticalAlignment="Center" Margin="12,0,0,0"/>
              </Grid>
            </Border>
          </Button>

          <Button x:Name="BtnManifestHub" Style="{StaticResource SecBtn}" Padding="0" Margin="0,3">
            <Border Style="{StaticResource ModeCard}" x:Name="CardMH" HorizontalAlignment="Stretch">
              <Grid>
                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <Border Grid.Column="0" Background="#1a1a2a" CornerRadius="4" Padding="8,4" Margin="0,0,12,0" VerticalAlignment="Center">
                  <TextBlock Text="KEY" Foreground="#a78bfa" FontSize="10" FontWeight="Bold"/>
                </Border>
                <StackPanel Grid.Column="1">
                  <TextBlock Text="3 — GitHub Mirror + ManifestHub fallback" FontWeight="SemiBold" Foreground="#e2e2f0" FontSize="13"/>
                  <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,0">Tries GitHub first, falls back to ManifestHub (manifesthub1.filegear-sg.me) if not found. Requires a free API key from that site.</TextBlock>
                </StackPanel>
                <TextBlock Grid.Column="2" Text="→" Foreground="#a78bfa" FontSize="16" VerticalAlignment="Center" Margin="12,0,0,0"/>
              </Grid>
            </Border>
          </Button>
        </StackPanel>

        <!-- ═══ PANEL 2: API Key Entry (Morrenus) ═══ -->
        <StackPanel x:Name="PanelMorrKey" Visibility="Collapsed">
          <TextBlock Text="STEP 2 — Enter your Morrenus API Key" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>
          <Border Background="#12121a" CornerRadius="6" Padding="14,12" Margin="0,0,0,10">
            <StackPanel>
              <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,8">How to get your free Morrenus API key:</TextBlock>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">① Go to <Run Foreground="#a78bfa">hubcapmanifest.com</Run> and log in with your Discord account</TextBlock>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">② Go to <Run Foreground="#a78bfa">hubcapmanifest.com/api-keys/user</Run> and generate your key</TextBlock>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">③ It starts with <Run Foreground="#e2e2f0" FontFamily="Consolas">smm_</Run> followed by 96 hex characters (100 chars total)</TextBlock>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,4,0,0">④ Paste it below — it will be validated against the Morrenus API before continuing</TextBlock>
            </StackPanel>
          </Border>
          <TextBlock Style="{StaticResource FieldLbl}" Text="Morrenus API Key (starts with smm_...)"/>
          <TextBox x:Name="TxtMorrKey" Style="{StaticResource FieldBox}" Margin="0,0,0,8"/>
          <TextBlock x:Name="MorrKeyError" Foreground="#f87171" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,8" Visibility="Collapsed"/>
          <Button x:Name="BtnMorrKeyNext" Content="Validate Key and Continue  →" Padding="14,9" HorizontalAlignment="Left" Style="{StaticResource PriBtn}"/>
          <Button x:Name="BtnMorrKeyOpen" Content="☁  Open hubcapmanifest.com" Padding="10,7" HorizontalAlignment="Left" Style="{StaticResource SecBtn}" Margin="0,6,0,0"/>
        </StackPanel>

        <!-- ═══ PANEL 3: API Key Entry (ManifestHub) ═══ -->
        <StackPanel x:Name="PanelMHKey" Visibility="Collapsed">
          <TextBlock Text="STEP 2 — Enter your ManifestHub API Key" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>
          <Border Background="#12121a" CornerRadius="6" Padding="14,12" Margin="0,0,0,10">
            <StackPanel>
              <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,8">How to get your free ManifestHub API key:</TextBlock>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">① Go to <Run Foreground="#a78bfa">manifesthub1.filegear-sg.me</Run> and register</TextBlock>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">② Find your API key on your account page and paste it below</TextBlock>
            </StackPanel>
          </Border>
          <TextBlock Style="{StaticResource FieldLbl}" Text="ManifestHub API Key"/>
          <TextBox x:Name="TxtMHKey" Style="{StaticResource FieldBox}" Margin="0,0,0,8"/>
          <TextBlock x:Name="MHKeyError" Foreground="#f87171" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,8" Visibility="Collapsed"/>
          <Button x:Name="BtnMHKeyNext" Content="Continue  →" Padding="14,9" HorizontalAlignment="Left" Style="{StaticResource PriBtn}"/>
          <Button x:Name="BtnMHKeyOpen" Content="☁  Open manifesthub1.filegear-sg.me" Padding="10,7" HorizontalAlignment="Left" Style="{StaticResource SecBtn}" Margin="0,6,0,0"/>
        </StackPanel>

        <!-- ═══ PANEL 4: Process Mode + AppID ═══ -->
        <StackPanel x:Name="PanelProcess" Visibility="Collapsed">
          <TextBlock x:Name="StepProcessLbl" Text="STEP 3 — Choose what to download" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>
          <Border Background="#12121a" CornerRadius="6" Padding="14,12" Margin="0,0,0,10">
            <StackPanel>
              <TextBlock x:Name="ModeSummary" Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,6"/>
              <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">Manifests are saved to your Steam depotcache folder and picked up automatically by SteamTools the next time you try to download the game.</TextBlock>
            </StackPanel>
          </Border>

          <Grid Margin="0,0,0,12">
            <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="16"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Button x:Name="BtnSingle" Grid.Column="0" Style="{StaticResource SecBtn}" Padding="0">
              <Border Background="#14141d" CornerRadius="7" Padding="16,13" HorizontalAlignment="Stretch" x:Name="CardSingle">
                <StackPanel>
                  <TextBlock Text="Single Game" FontWeight="SemiBold" Foreground="#e2e2f0" FontSize="13"/>
                  <TextBlock Text="Enter one Steam AppID manually. Use this when you know exactly which game needs its manifest fixed." Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,5,0,0"/>
                </StackPanel>
              </Border>
            </Button>
            <Button x:Name="BtnBatch" Grid.Column="2" Style="{StaticResource SecBtn}" Padding="0">
              <Border Background="#14141d" CornerRadius="7" Padding="16,13" HorizontalAlignment="Stretch" x:Name="CardBatch">
                <StackPanel>
                  <TextBlock Text="All Games (Batch)" FontWeight="SemiBold" Foreground="#e2e2f0" FontSize="13"/>
                  <TextBlock Text="Scans all .lua files in stplug-in and downloads manifests for every game at once. Can take a while." Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap" Margin="0,5,0,0"/>
                </StackPanel>
              </Border>
            </Button>
          </Grid>

          <StackPanel x:Name="AppIdPanel" Visibility="Collapsed">
            <TextBlock Style="{StaticResource FieldLbl}" Text="Steam AppID (numbers only — this is the App ID, NOT the Depot ID)"/>
            <Grid Margin="0,0,0,10">
              <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
              <TextBox x:Name="TxtAppId" Grid.Column="0" Style="{StaticResource FieldBox}"/>
              <Button x:Name="BtnStartSingle" Grid.Column="2" Content="▶  Download" Padding="14,9" Style="{StaticResource PriBtn}"/>
            </Grid>
            <TextBlock x:Name="AppIdError" Foreground="#f87171" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,8" Visibility="Collapsed"/>
          </StackPanel>

          <Button x:Name="BtnStartBatch" Content="▶  Download All Games" Padding="14,9" HorizontalAlignment="Left" Style="{StaticResource PriBtn}" Visibility="Collapsed"/>
        </StackPanel>

        <!-- ═══ PANEL 5: Progress / Log ═══ -->
        <StackPanel x:Name="PanelProgress" Visibility="Collapsed">
          <TextBlock Text="DOWNLOADING" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,8"/>
          <Border Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,8">
            <StackPanel>
              <TextBlock x:Name="ProgressLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap" Margin="0,0,0,6">Starting...</TextBlock>
              <ProgressBar x:Name="BatchPB" Height="6" Minimum="0" Maximum="100" Value="0" Background="#1a1a26" Foreground="#a78bfa" BorderThickness="0" Margin="0,0,0,4"/>
              <TextBlock x:Name="BatchEta" Foreground="#44445a" FontSize="10" Margin="0,2,0,0"/>
            </StackPanel>
          </Border>
          <Border Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,8" Height="240">
            <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
              <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                       FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                       TextWrapping="Wrap" AcceptsReturn="True"/>
            </ScrollViewer>
          </Border>
        </StackPanel>

        <!-- ═══ PANEL 6: Summary ═══ -->
        <StackPanel x:Name="PanelSummary" Visibility="Collapsed">
          <TextBlock Text="DOWNLOAD COMPLETE" Foreground="#44445a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>
          <Border Background="#12121a" CornerRadius="7" Padding="16,13" Margin="0,0,0,10">
            <StackPanel>
              <Grid Margin="0,0,0,6">
                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0">
                  <TextBlock Text="Downloaded" Foreground="#44445a" FontSize="10"/>
                  <TextBlock x:Name="SumDownloaded" Foreground="#6bdc8a" FontSize="22" FontWeight="Bold"/>
                </StackPanel>
                <StackPanel Grid.Column="1">
                  <TextBlock Text="Skipped (up-to-date)" Foreground="#44445a" FontSize="10"/>
                  <TextBlock x:Name="SumSkipped" Foreground="#a78bfa" FontSize="22" FontWeight="Bold"/>
                </StackPanel>
              </Grid>
              <Grid>
                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0">
                  <TextBlock Text="Failed" Foreground="#44445a" FontSize="10"/>
                  <TextBlock x:Name="SumFailed" Foreground="#f87171" FontSize="22" FontWeight="Bold"/>
                </StackPanel>
                <StackPanel Grid.Column="1">
                  <TextBlock Text="Total size / time" Foreground="#44445a" FontSize="10"/>
                  <TextBlock x:Name="SumSize" Foreground="#c8c8d4" FontSize="14" FontWeight="SemiBold" Margin="0,4,0,0"/>
                </StackPanel>
              </Grid>
              <TextBlock x:Name="SumOutput" Foreground="#44445a" FontSize="10" TextWrapping="Wrap" Margin="0,10,0,0"/>
            </StackPanel>
          </Border>
          <Border x:Name="FailedPanel" Background="#1a1010" CornerRadius="6" Padding="12,10" Margin="0,0,0,10" Visibility="Collapsed">
            <StackPanel>
              <TextBlock Text="FAILED DOWNLOADS" Foreground="#f87171" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,6"/>
              <TextBox x:Name="FailedBox" Background="Transparent" BorderThickness="0" Foreground="#f87171"
                       FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                       TextWrapping="Wrap" AcceptsReturn="True"/>
            </StackPanel>
          </Border>
          <StackPanel Orientation="Horizontal">
            <Button x:Name="BtnDownloadAnother" Content="← Download Another Game" Padding="14,9" Style="{StaticResource PriBtn}" Margin="0,0,8,0"/>
            <Button x:Name="BtnSummaryClose"    Content="Close" Padding="14,9" Style="{StaticResource SecBtn}"/>
          </StackPanel>
        </StackPanel>

      </StackPanel>
    </ScrollViewer>

    <!-- Footer -->
    <Border Grid.Row="2" Background="#0f0f18" Padding="16,10">
      <Grid>
        <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        <Button x:Name="BtnBack" Grid.Column="0" Content="← Back" Padding="12,7" Style="{StaticResource SecBtn}" Visibility="Collapsed"/>
        <TextBlock Grid.Column="1" Foreground="#2a2a3f" FontSize="10" VerticalAlignment="Center" Margin="8,0">
          by Skyflare, modified by Potatoes9411  |  discord.gg/luatools
        </TextBlock>
        <Button x:Name="BtnClose" Grid.Column="2" Content="Close" Padding="14,7" Style="{StaticResource SecBtn}"/>
      </Grid>
    </Border>
  </Grid>
</Window>
"@

$rd=[System.Xml.XmlNodeReader]::new($xaml); $win=[System.Windows.Markup.XamlReader]::Load($rd)

# Named elements
$panelMode    = $win.FindName("PanelMode")
$panelMorrKey = $win.FindName("PanelMorrKey")
$panelMHKey   = $win.FindName("PanelMHKey")
$panelProcess = $win.FindName("PanelProcess")
$panelProgress= $win.FindName("PanelProgress")
$panelSummary = $win.FindName("PanelSummary")
$btnGitHub    = $win.FindName("BtnGitHub")
$btnMorrenus  = $win.FindName("BtnMorrenus")
$btnManifestHub=$win.FindName("BtnManifestHub")
$txtMorrKey   = $win.FindName("TxtMorrKey")
$morrKeyErr   = $win.FindName("MorrKeyError")
$btnMorrKeyNext=$win.FindName("BtnMorrKeyNext")
$btnMorrKeyOpen=$win.FindName("BtnMorrKeyOpen")
$txtMHKey     = $win.FindName("TxtMHKey")
$mhKeyErr     = $win.FindName("MHKeyError")
$btnMHKeyNext = $win.FindName("BtnMHKeyNext")
$btnMHKeyOpen = $win.FindName("BtnMHKeyOpen")
$modeSummary  = $win.FindName("ModeSummary")
$btnSingle    = $win.FindName("BtnSingle")
$btnBatch     = $win.FindName("BtnBatch")
$appIdPanel   = $win.FindName("AppIdPanel")
$txtAppId     = $win.FindName("TxtAppId")
$appIdErr     = $win.FindName("AppIdError")
$btnStartSingle=$win.FindName("BtnStartSingle")
$btnStartBatch= $win.FindName("BtnStartBatch")
$progressLabel= $win.FindName("ProgressLabel")
$batchPB      = $win.FindName("BatchPB")
$batchEta     = $win.FindName("BatchEta")
$logBox       = $win.FindName("LogBox")
$logScroll    = $win.FindName("LogScroll")
$sumDownloaded= $win.FindName("SumDownloaded")
$sumSkipped   = $win.FindName("SumSkipped")
$sumFailed    = $win.FindName("SumFailed")
$sumSize      = $win.FindName("SumSize")
$sumOutput    = $win.FindName("SumOutput")
$failedPanel  = $win.FindName("FailedPanel")
$failedBox    = $win.FindName("FailedBox")
$btnDownloadAnother=$win.FindName("BtnDownloadAnother")
$btnSummaryClose=$win.FindName("BtnSummaryClose")
$btnBack      = $win.FindName("BtnBack")
$btnClose     = $win.FindName("BtnClose")

# State
$script:mode      = "github"
$script:activeKey = ""
$script:steamPath = $null
$script:appIdList = @()

# Helpers
function ShowOnly($panel) {
    foreach ($p in @($panelMode,$panelMorrKey,$panelMHKey,$panelProcess,$panelProgress,$panelSummary)) {
        $p.Visibility = [System.Windows.Visibility]::Collapsed
    }
    $panel.Visibility = [System.Windows.Visibility]::Visible
    $btnBack.Visibility = if($panel -eq $panelMode){ [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
}
function GL($m) { $win.Dispatcher.Invoke([action]{ $logBox.AppendText("$m`n"); $logScroll.ScrollToBottom() }) }
function GP($msg,$pct,$eta="") {
    $win.Dispatcher.Invoke([action]{
        $progressLabel.Text=$msg
        if($pct -ge 0){ $batchPB.Value=$pct }
        $batchEta.Text=$eta
    })
}

# Pre-fill from params
if ($initMorrKey) { $txtMorrKey.Text=$initMorrKey }
if ($initApiKey)  { $txtMHKey.Text=$initApiKey }
if ($initAppId)   { $txtAppId.Text=$initAppId }

# ── Startup: skip mode selection if env var set ──────────────────────────────
if ($initMode -eq "github") {
    $script:mode="github"; $script:activeKey=""
    $script:steamPath=Get-ManifestSteamPath
    $modeSummary.Text="Mode: GitHub Mirror (no key required)  |  Steam: $($script:steamPath)"
    ShowOnly $panelProcess
} elseif ($initMode -eq "github+morrenus") {
    $script:mode="github+morrenus"
    if ($initMorrKey) { $script:activeKey=$initMorrKey; $script:steamPath=Get-ManifestSteamPath; $modeSummary.Text="Mode: GitHub + Morrenus  |  Steam: $($script:steamPath)"; ShowOnly $panelProcess }
    else { ShowOnly $panelMorrKey }
} elseif ($initMode -eq "github+manifesthub") {
    $script:mode="github+manifesthub"
    if ($initApiKey) { $script:activeKey=$initApiKey; $script:steamPath=Get-ManifestSteamPath; $modeSummary.Text="Mode: GitHub + ManifestHub  |  Steam: $($script:steamPath)"; ShowOnly $panelProcess }
    else { ShowOnly $panelMHKey }
} else { ShowOnly $panelMode }

# ── Buttons: Mode panel ──────────────────────────────────────────────────────
$btnGitHub.Add_Click({
    $script:mode="github"; $script:activeKey=""
    $script:steamPath=Get-ManifestSteamPath
    if(-not $script:steamPath){ [System.Windows.MessageBox]::Show("Steam installation not found. Is Steam installed?","Error",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)|Out-Null; return }
    $modeSummary.Text="Mode: GitHub Mirror (no key required)  |  Steam: $($script:steamPath)"
    ShowOnly $panelProcess
})
$btnMorrenus.Add_Click({ ShowOnly $panelMorrKey })
$btnManifestHub.Add_Click({ ShowOnly $panelMHKey })

# ── Buttons: Morrenus key panel ──────────────────────────────────────────────
$btnMorrKeyOpen.Add_Click({ try{Start-Process "https://hubcapmanifest.com/api-keys/user"}catch{} })
$btnMorrKeyNext.Add_Click({
    $key=$txtMorrKey.Text.Trim()
    $morrKeyErr.Visibility=[System.Windows.Visibility]::Collapsed
    if([string]::IsNullOrWhiteSpace($key)){ $morrKeyErr.Text="Key is required."; $morrKeyErr.Visibility=[System.Windows.Visibility]::Visible; return }
    if($key -notmatch '^smm_[0-9a-f]{96}$'){ $morrKeyErr.Text="Invalid format. Expected smm_ + 96 hex chars (100 total)."; $morrKeyErr.Visibility=[System.Windows.Visibility]::Visible; return }
    $btnMorrKeyNext.IsEnabled=$false; $btnMorrKeyNext.Content="Validating..."
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            $resp=Invoke-RestMethod "https://hubcapmanifest.com/api/v1/user/stats?api_key=$key" -Method Get -TimeoutSec 15 -EA Stop
            if(-not $resp.can_make_requests){
                $win.Dispatcher.Invoke([action]{
                    $morrKeyErr.Text="Daily limit reached ($($resp.daily_usage)/$($resp.daily_limit) requests). Try again tomorrow."
                    $morrKeyErr.Visibility=[System.Windows.Visibility]::Visible
                    $btnMorrKeyNext.IsEnabled=$true; $btnMorrKeyNext.Content="Validate Key and Continue  →"
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start(); return
            }
            $script:mode="github+morrenus"; $script:activeKey=$key
            $script:steamPath=Get-ManifestSteamPath
            $win.Dispatcher.Invoke([action]{
                $modeSummary.Text="Mode: GitHub + Morrenus  |  Logged in as: $($resp.username)  |  Requests left: $($resp.daily_limit - $resp.daily_usage)  |  Steam: $($script:steamPath)"
                $btnMorrKeyNext.IsEnabled=$true; $btnMorrKeyNext.Content="Validate Key and Continue  →"
                ShowOnly $panelProcess
            })
        } catch {
            $sc=$null; if($_.Exception.Response){$sc=[int]$_.Exception.Response.StatusCode}
            $msg=if($sc -in @(401,403,404)){"Key not found or expired."}else{"Validation failed: $($_.Exception.Message)"}
            $win.Dispatcher.Invoke([action]{ $morrKeyErr.Text=$msg; $morrKeyErr.Visibility=[System.Windows.Visibility]::Visible; $btnMorrKeyNext.IsEnabled=$true; $btnMorrKeyNext.Content="Validate Key and Continue  →" })
        }
    })
})

# ── Buttons: ManifestHub key panel ───────────────────────────────────────────
$btnMHKeyOpen.Add_Click({ try{Start-Process "https://manifesthub1.filegear-sg.me/"}catch{} })
$btnMHKeyNext.Add_Click({
    $key=$txtMHKey.Text.Trim()
    $mhKeyErr.Visibility=[System.Windows.Visibility]::Collapsed
    if([string]::IsNullOrWhiteSpace($key)){ $mhKeyErr.Text="Key is required."; $mhKeyErr.Visibility=[System.Windows.Visibility]::Visible; return }
    $script:mode="github+manifesthub"; $script:activeKey=$key
    $script:steamPath=Get-ManifestSteamPath
    if(-not $script:steamPath){ $mhKeyErr.Text="Steam not found."; $mhKeyErr.Visibility=[System.Windows.Visibility]::Visible; return }
    $modeSummary.Text="Mode: GitHub + ManifestHub  |  Steam: $($script:steamPath)"
    ShowOnly $panelProcess
})

# ── Buttons: Process panel ───────────────────────────────────────────────────
$btnSingle.Add_Click({ $appIdPanel.Visibility=[System.Windows.Visibility]::Visible; $btnStartBatch.Visibility=[System.Windows.Visibility]::Collapsed })
$btnBatch.Add_Click({  $appIdPanel.Visibility=[System.Windows.Visibility]::Collapsed; $btnStartBatch.Visibility=[System.Windows.Visibility]::Visible })

function Start-Download([string[]]$appIds) {
    $logBox.Text=""
    ShowOnly $panelProgress
    $batchPB.Value=0
    $m=$script:mode; $k=$script:activeKey; $sp=$script:steamPath; $mode_=$m; $key_=$k
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        $ok=0; $sk=0; $fail=@(); $totalSz=0L; $t0=Get-Date
        for($ai=0;$ai-lt$appIds.Count;$ai++){
            $aid=$appIds[$ai]
            $pctBase=[int](($ai/$appIds.Count)*90)
            GP "[$($ai+1)/$($appIds.Count)]  AppID $aid — looking up Lua file..." $pctBase
            $luaPath=Join-Path $sp "config\stplug-in\$aid.lua"
            if(-not(Test-Path $luaPath)){ GL "[WARN] No Lua file for AppID $aid — skipping."; continue }
            GL "[INFO] AppID $aid — parsing Lua file..."
            $dids=Get-DepotIdsFromLua $luaPath
            if($dids.Count-eq 0){ GL "[WARN] No depot IDs found in Lua for AppID $aid."; continue }
            GL "[LOG]  Depots: $($dids -join ', ')"
            GP "[$($ai+1)/$($appIds.Count)]  AppID $aid — fetching app info..." $pctBase
            $ai2=Get-AppInfo $aid
            if(-not $ai2 -or $ai2.status -ne "success"){ GL "[ERR]  Failed to fetch app info for $aid."; continue }
            $queue=@()
            foreach($d in $dids){ $mid=Get-ManifestIdForDepot $ai2 $aid $d; if($mid){$queue+=@{D=$d;M=$mid}} }
            if($queue.Count-eq 0){ GL "[WARN] No manifests matched for AppID $aid."; continue }
            GL "[OK]   $($queue.Count) depot(s) queued for AppID $aid."
            $dcPath=Join-Path $sp "depotcache"; if(-not(Test-Path $dcPath)){New-Item $dcPath -ItemType Directory -Force|Out-Null}
            for($qi=0;$qi-lt$queue.Count;$qi++){
                $dep=$queue[$qi]; $did=$dep.D; $mid=$dep.M
                $subPct=$pctBase+[int]((($qi+1)/$queue.Count)*([int](90/$appIds.Count)))
                GP "[$($ai+1)/$($appIds.Count)]  Depot $did..." $subPct "Elapsed: $([int]((Get-Date)-$t0).TotalSeconds)s"
                $ex=Join-Path $dcPath "${did}_${mid}.manifest"
                if((Test-Path $ex)-and((Get-Item $ex).Length-gt 0)){ $sk++; GL "[=]    Depot $did — already up-to-date, skipping."; continue }
                $res=Download-Manifest $did $mid $dcPath $mode_ $key_
                if($res.Success){
                    $ok++; $totalSz+=$res.Size
                    GL "[OK]   Depot $did — downloaded $(Format-MFS $res.Size) from $($res.Source)"
                } else {
                    $fail+=@{App=$aid;Depot=$did;Manifest=$mid;Error=$res.Error}
                    GL "[ERR]  Depot $did — failed after $($res.Attempts) attempt(s): $($res.Error)"
                }
            }
        }
        $elapsed=(Get-Date)-$t0
        $failTxt=if($fail.Count-gt 0){ ($fail|ForEach-Object{"App $($_.App) | Depot $($_.Depot) | $($_.Error)"})-join"`n" }else{""}
        $win.Dispatcher.Invoke([action]{
            $batchPB.Value=100
            $sumDownloaded.Text="$ok"
            $sumSkipped.Text="$sk"
            $sumFailed.Text="$($fail.Count)"
            $sumSize.Text="$(Format-MFS $totalSz)  ·  $($elapsed.ToString('mm\:ss'))s"
            $sumOutput.Text="Output → $sp\depotcache"
            if($fail.Count-gt 0){ $failedBox.Text=$failTxt; $failedPanel.Visibility=[System.Windows.Visibility]::Visible }
            else { $failedPanel.Visibility=[System.Windows.Visibility]::Collapsed }
            ShowOnly $panelSummary
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
    })
}

$btnStartSingle.Add_Click({
    $appIdErr.Visibility=[System.Windows.Visibility]::Collapsed
    $aid=$txtAppId.Text.Trim()
    if([string]::IsNullOrWhiteSpace($aid)-or$aid-notmatch'^\d+$'){ $appIdErr.Text="Enter a valid numeric Steam AppID."; $appIdErr.Visibility=[System.Windows.Visibility]::Visible; return }
    Start-Download @($aid)
})

$btnStartBatch.Add_Click({
    $luaDir=Join-Path $script:steamPath "config\stplug-in"
    if(-not(Test-Path $luaDir)){ [System.Windows.MessageBox]::Show("stplug-in directory not found at: $luaDir`n`nMake sure you have at least one game's Lua file installed.","Not found",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null; return }
    $luaFiles=@(Get-ChildItem $luaDir -Filter "*.lua" -EA SilentlyContinue)
    if($luaFiles.Count-eq 0){ [System.Windows.MessageBox]::Show("No .lua files found in stplug-in. Nothing to batch-download.","Empty",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null; return }
    $ids=@($luaFiles|Where-Object{$_.BaseName-match'^\d+$'}|ForEach-Object{$_.BaseName})
    if($ids.Count-eq 0){ [System.Windows.MessageBox]::Show("No numeric AppIDs found in filenames.","Empty",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null; return }
    if([System.Windows.MessageBox]::Show("Found $($ids.Count) game(s). Download manifests for all of them?`n`nThis may take a while.","Confirm batch download",[System.Windows.MessageBoxButton]::YesNo,[System.Windows.MessageBoxImage]::Question) -eq [System.Windows.MessageBoxResult]::No){ return }
    Start-Download $ids
})

# ── Navigation ────────────────────────────────────────────────────────────────
$btnBack.Add_Click({ ShowOnly $panelMode })
$btnClose.Add_Click({ $win.Close() })
$btnSummaryClose.Add_Click({ $win.Close() })
$btnDownloadAnother.Add_Click({ ShowOnly $panelProcess })

$win.ShowDialog() | Out-Null
'@ | Set-Content $b7Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b7Script`" -DataFile `"$b7DataFile`"" -Wait
    Remove-Item $b7Script   -Force -ErrorAction SilentlyContinue
    Remove-Item $b7DataFile -Force -ErrorAction SilentlyContinue
    $Branch = 0
}
#### Branch 8: No Internet Connection Fix (Program by SelectivelyGood | Script by Peron) ####
if ($Branch -eq 8) {
    $b8Script = Join-Path $env:TEMP "luatools_b8.ps1"
@'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="No Internet Connection Fix  |  .gg/luatools"
        Width="720" Height="580" MinWidth="540" MinHeight="460"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Margin="0,0,0,10">
      <TextBlock Text="No Internet Connection Fix" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Foreground="#44445a" FontSize="11" Margin="0,3,0,0">
        <Run Text="Program by SelectivelyGood  |  Script by Peron  |  discord.gg/luatools"/>
      </TextBlock>
    </StackPanel>

    <Border Grid.Row="1" Background="#12121a" CornerRadius="6" Padding="12,10" Margin="0,0,0,10">
      <StackPanel>
        <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,6">What this fix does:</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Closes Steam so files can be replaced safely</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Downloads the latest CloudRedirectCLI.exe + cloud_redirect.dll from GitHub</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Runs CloudRedirectCLI /stfixer to fix Steam server routing</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Installs cloud_redirect.dll into your Steam folder</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">• Cleans up temp files and relaunches Steam</TextBlock>
        <Border Background="#101a10" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
          <TextBlock Foreground="#6bdc8a" FontSize="10" TextWrapping="Wrap">
            ℹ  Use this if Steam says 'No Internet Connection', content is still encrypted, or you get purchase errors. If it still fails afterwards, install Cloudflare Warp from one.one.one.one — it's free and fixes ISP-level blocks.
          </TextBlock>
        </Border>
      </StackPanel>
    </Border>

    <Border Grid.Row="2" Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,8">
      <StackPanel>
        <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap">Click Run to download and apply the CloudRedirect fix.</TextBlock>
        <ProgressBar x:Name="ProgressBar" Height="6" Minimum="0" Maximum="100" Value="0"
                     Background="#1a1a26" Foreground="#a78bfa" BorderThickness="0" Margin="0,6,0,0"/>
      </StackPanel>
    </Border>

    <Border Grid.Row="3" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                 TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>

    <Grid Grid.Row="4">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <Button x:Name="WarpBtn" Grid.Column="0" Content="☁  Get Cloudflare Warp (free internet fix)" HorizontalAlignment="Left" Height="34" Cursor="Hand" Background="#1a2a1a" Foreground="#6bdc8a" BorderThickness="1" BorderBrush="#2a4a2a" FontSize="11">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="5" Padding="12,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1e3a1e"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="RunBtn" Grid.Column="1" Content="▶  Run Fix" Width="120" Height="34" Cursor="Hand" FontWeight="SemiBold" Background="#4f46e5" Foreground="White" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="3" Content="Close" Width="90" Height="34" Cursor="Hand" Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
"@

$rd=[System.Xml.XmlNodeReader]::new($xaml); $win=[System.Windows.Markup.XamlReader]::Load($rd)
$stepLabel=$win.FindName("StepLabel"); $pb=$win.FindName("ProgressBar")
$logBox=$win.FindName("LogBox"); $logScroll=$win.FindName("LogScroll")
$runBtn=$win.FindName("RunBtn"); $closeBtn=$win.FindName("CloseBtn"); $warpBtn=$win.FindName("WarpBtn")

function GL($m){ $win.Dispatcher.Invoke([action]{ $logBox.AppendText("$m`n"); $logScroll.ScrollToBottom() }) }
function GS($m,$p=-1){ $win.Dispatcher.Invoke([action]{ $stepLabel.Text=$m; if($p -ge 0){$pb.Value=$p} }) }

$closeBtn.Add_Click({ $win.Close() })
$warpBtn.Add_Click({ try{ Start-Process "https://one.one.one.one/" }catch{} })

$runBtn.Add_Click({
    $runBtn.IsEnabled=$false
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            GS "Finding Steam..." 5
            $PossiblePaths=@()
            try{ $r=Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -EA Stop; if($r.InstallPath){$PossiblePaths+=$r.InstallPath} }catch{}
            try{ $r=Get-ItemProperty "HKCU:\Software\Valve\Steam" -EA Stop; if($r.SteamPath){$PossiblePaths+=($r.SteamPath -replace '\\\\','\')} }catch{}
            if(Test-Path "C:\Program Files (x86)\Steam"){ $PossiblePaths+="C:\Program Files (x86)\Steam" }
            $steam=($PossiblePaths|Select-Object -Unique|Where-Object{Test-Path $_}|Select-Object -First 1)
            if(-not $steam){ GL "[ERR]  Steam not found."; GS "Error — Steam not found." 0; $win.Dispatcher.Invoke([action]{$closeBtn.IsEnabled=$true}); return }
            GL "[OK]   Steam found: $steam"

            GS "Closing Steam..." 10
            GL "[INFO] Closing Steam..."
            Get-Process "steam" -EA SilentlyContinue | Stop-Process -Force; Start-Sleep 3
            GL "[OK]   Steam closed."

            GS "Fetching latest CloudRedirect release..." 20
            GL "[INFO] Fetching latest CloudRedirect release from GitHub..."
            $apiUrl="https://api.github.com/repos/Selectively11/CloudRedirect/releases/latest"
            $cliFile=Join-Path $env:TEMP "CloudRedirectCLI.exe"
            $dllFile=Join-Path $env:TEMP "cloud_redirect.dll"
            try {
                $rel=Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -EA Stop
                GL "[LOG]  Latest version: $($rel.tag_name)"

                GS "Downloading CloudRedirectCLI.exe..." 35
                $cliAsset=$rel.assets|Where-Object{$_.name -eq "CloudRedirectCLI.exe"}|Select-Object -First 1
                if($cliAsset){ Invoke-WebRequest -Uri $cliAsset.browser_download_url -OutFile $cliFile -UseBasicParsing -TimeoutSec 60 -EA Stop; GL "[OK]   CloudRedirectCLI.exe downloaded." }

                GS "Downloading cloud_redirect.dll..." 50
                $dllAsset=$rel.assets|Where-Object{$_.name -eq "cloud_redirect.dll"}|Select-Object -First 1
                if($dllAsset){ Invoke-WebRequest -Uri $dllAsset.browser_download_url -OutFile $dllFile -UseBasicParsing -TimeoutSec 60 -EA Stop; GL "[OK]   cloud_redirect.dll downloaded." }
            } catch {
                GL "[ERR]  Download failed: $($_.Exception.Message)"; GL "[INFO] If this keeps failing, try installing Cloudflare Warp (click the ☁ button)."
                GS "Download failed — check log." 0; $win.Dispatcher.Invoke([action]{$closeBtn.IsEnabled=$true}); return
            }

            GS "Running CloudRedirect fixer..." 65
            GL "[INFO] Running CloudRedirectCLI /stfixer (this may take a few seconds)..."
            Start-Sleep 2
            try { & $cliFile /stfixer; GL "[OK]   CloudRedirectCLI completed successfully." }
            catch { GL "[WARN] CloudRedirectCLI error: $($_.Exception.Message)" }

            GS "Installing cloud_redirect.dll..." 80
            GL "[INFO] Installing cloud_redirect.dll to Steam folder..."
            $targetDll=Join-Path $steam "cloud_redirect.dll"
            try { Copy-Item -Path $dllFile -Destination $targetDll -Force -EA Stop; GL "[OK]   cloud_redirect.dll installed to: $targetDll" }
            catch { GL "[ERR]  Failed to copy DLL: $($_.Exception.Message)" }

            GS "Cleaning up..." 90
            Remove-Item $cliFile -Force -EA SilentlyContinue
            Remove-Item $dllFile -Force -EA SilentlyContinue
            GL "[OK]   Temp files removed."

            GS "Launching Steam..." 95
            GL "[WARN] Steam startup may take slightly longer than usual after this fix — that is normal."
            $exe=Join-Path $steam "steam.exe"
            if(Test-Path $exe){ Start-Process $exe -ArgumentList "-clearbeta"; GL "[OK]   Steam launched." }
            GS "Fix complete!" 100
            GL "[OK]   All done! If you still see 'No Internet' after this, install Cloudflare Warp (click the ☁ button above)."
        } catch { GL "[ERR]  $($_.Exception.Message)"; GS "Error — see log." 0 }
        $win.Dispatcher.Invoke([action]{ $closeBtn.IsEnabled=$true })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})
$win.ShowDialog() | Out-Null
'@ | Set-Content $b8Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b8Script`"" -Wait
    Remove-Item $b8Script -Force -ErrorAction SilentlyContinue
    $Branch = 0
}



#### Branch 9: Download / Launch CloudRedirect GUI (App by SelectivelyGood | Script by Potatoes9411) ####
if ($Branch -eq 9) {
    $b9Script = Join-Path $env:TEMP "luatools_b9.ps1"
@'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$cloudRedirectDir = "C:\Program Files (x86)\Steam\CloudRedirect"
$cloudRedirectExe = Join-Path $cloudRedirectDir "CloudRedirect.exe"
$cloudRedirectUrl = "https://github.com/Selectively11/CloudRedirect/releases/latest/download/CloudRedirect.exe"

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CloudRedirect GUI Launcher  |  .gg/luatools"
        Width="680" Height="520" MinWidth="520" MinHeight="420"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Margin="0,0,0,10">
      <TextBlock Text="CloudRedirect GUI Launcher" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Foreground="#44445a" FontSize="11" Margin="0,3,0,0">App by SelectivelyGood  |  Script by Potatoes9411  |  discord.gg/luatools</TextBlock>
    </StackPanel>

    <Border Grid.Row="1" Background="#12121a" CornerRadius="6" Padding="12,10" Margin="0,0,0,10">
      <StackPanel>
        <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,6">
          CloudRedirect is a standalone GUI application for diagnosing and fixing Steam server routing problems. It's different from Option 8 — Option 8 runs a quick automated fix, while this is the full GUI app for advanced troubleshooting.
        </TextBlock>
        <Grid>
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
          <TextBlock Grid.Column="0" Foreground="#44445a" FontSize="11" Margin="0,0,8,0">Install path:</TextBlock>
          <TextBlock Grid.Column="1" x:Name="InstallPathTxt" Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap"/>
        </Grid>
        <Grid Margin="0,4,0,0">
          <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
          <TextBlock Grid.Column="0" Foreground="#44445a" FontSize="11" Margin="0,0,8,0">Status:</TextBlock>
          <TextBlock x:Name="StatusTxt" Grid.Column="1" FontSize="11" FontWeight="SemiBold"/>
        </Grid>
        <Border Background="#1a1a10" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
          <TextBlock Foreground="#f59e0b" FontSize="10" TextWrapping="Wrap">
            ℹ  Tip: Try Option 8 (No Internet Fix) first — it usually solves the problem automatically. Use this option if you want to dig deeper into routing issues.
          </TextBlock>
        </Border>
      </StackPanel>
    </Border>

    <Border Grid.Row="2" Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,8">
      <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap">Choose an action below.</TextBlock>
    </Border>

    <Border Grid.Row="3" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                 TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>

    <Grid Grid.Row="4">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <Button x:Name="DownloadBtn" Grid.Column="1" Content="⬇  Download &amp; Launch (latest)" Width="210" Height="34" Cursor="Hand" FontWeight="SemiBold" Background="#4f46e5" Foreground="White" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="LaunchBtn" Grid.Column="3" Content="▶  Launch (if installed)" Width="170" Height="34" Cursor="Hand" Background="#1e1e2e" Foreground="#c8c8d4" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1a1a26"/><Setter Property="Foreground" Value="#33334a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="5" Content="Close" Width="90" Height="34" Cursor="Hand" Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
"@

$rd=[System.Xml.XmlNodeReader]::new($xaml); $win=[System.Windows.Markup.XamlReader]::Load($rd)
$stepLabel=$win.FindName("StepLabel"); $logBox=$win.FindName("LogBox"); $logScroll=$win.FindName("LogScroll")
$downloadBtn=$win.FindName("DownloadBtn"); $launchBtn=$win.FindName("LaunchBtn"); $closeBtn=$win.FindName("CloseBtn")
$installPathTxt=$win.FindName("InstallPathTxt"); $statusTxt=$win.FindName("StatusTxt")
$installPathTxt.Text = $cloudRedirectDir

function GL($m){ $logBox.AppendText("$m`n"); $logScroll.ScrollToBottom() }
function GS($m){ $stepLabel.Text=$m }
function RefreshStatus {
    $installed = Test-Path $cloudRedirectExe
    if($installed){
        $statusTxt.Text="[installed]"
        $statusTxt.Foreground=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x6b,0xdc,0x8a))
        $launchBtn.IsEnabled=$true
    } else {
        $statusTxt.Text="[not installed — click Download & Launch]"
        $statusTxt.Foreground=[System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xf5,0x9e,0x0b))
        $launchBtn.IsEnabled=$false
    }
}
RefreshStatus

$closeBtn.Add_Click({ $win.Close() })

$downloadBtn.Add_Click({
    $downloadBtn.IsEnabled=$false; $launchBtn.IsEnabled=$false
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            $win.Dispatcher.Invoke([action]{ GS "Creating install directory..." })
            try { New-Item -Path $cloudRedirectDir -ItemType Directory -Force -EA Stop | Out-Null; $win.Dispatcher.Invoke([action]{ GL "[OK]   Directory ready: $cloudRedirectDir" }) }
            catch { $win.Dispatcher.Invoke([action]{ GL "[ERR]  Could not create directory: $($_.Exception.Message)" }); $win.Dispatcher.Invoke([action]{$downloadBtn.IsEnabled=$true; RefreshStatus}); return }

            $win.Dispatcher.Invoke([action]{ GS "Downloading CloudRedirect.exe from GitHub..."; GL "[INFO] Downloading latest CloudRedirect.exe..." })
            try {
                Invoke-WebRequest -Uri $cloudRedirectUrl -OutFile $cloudRedirectExe -EA Stop
                $win.Dispatcher.Invoke([action]{ GL "[OK]   Saved to: $cloudRedirectExe" })
            } catch {
                $win.Dispatcher.Invoke([action]{ GL "[ERR]  Download failed: $($_.Exception.Message)" }); $win.Dispatcher.Invoke([action]{$downloadBtn.IsEnabled=$true; RefreshStatus}); return
            }

            $win.Dispatcher.Invoke([action]{ GS "Launching CloudRedirect..."; GL "[INFO] Starting CloudRedirect..." })
            try { Start-Process -FilePath $cloudRedirectExe -EA Stop; $win.Dispatcher.Invoke([action]{ GL "[OK]   CloudRedirect launched."; GS "CloudRedirect is running." }) }
            catch { $win.Dispatcher.Invoke([action]{ GL "[ERR]  Failed to launch: $($_.Exception.Message)" }) }
        } catch { $win.Dispatcher.Invoke([action]{ GL "[ERR]  $($_.Exception.Message)" }) }
        $win.Dispatcher.Invoke([action]{ $downloadBtn.IsEnabled=$true; RefreshStatus })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})

$launchBtn.Add_Click({
    if(-not (Test-Path $cloudRedirectExe)){ GS "Not installed yet — use Download & Launch."; return }
    try { Start-Process -FilePath $cloudRedirectExe; GL "[OK]   CloudRedirect launched."; GS "CloudRedirect is running." }
    catch { GL "[ERR]  Failed to launch: $($_.Exception.Message)" }
})

$win.ShowDialog() | Out-Null
'@ | Set-Content $b9Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b9Script`"" -Wait
    Remove-Item $b9Script -Force -ErrorAction SilentlyContinue
    $Branch = 0
}


#### Branch 10: Millennium & SteamTools Reinstaller (by clem.la & melly) ####
if ($Branch -eq 10) {
    $b10Script = Join-Path $env:TEMP "luatools_b10.ps1"
@'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Resolve Steam path
$b10SP = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -EA SilentlyContinue).InstallPath
if(-not $b10SP){ $b10SP=(Get-ItemProperty "HKLM:\SOFTWARE\Valve\Steam" -EA SilentlyContinue).InstallPath }
if(-not $b10SP){ $b10SP=(Get-ItemProperty "HKCU:\Software\Valve\Steam" -EA SilentlyContinue).SteamPath }

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Millennium &amp; SteamTools Reinstaller  |  .gg/luatools"
        Width="740" Height="620" MinWidth="560" MinHeight="500"
        WindowStartupLocation="CenterScreen" Background="#0c0c11" FontFamily="Segoe UI" FontSize="13">
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Margin="0,0,0,10">
      <TextBlock Text="Millennium &amp; SteamTools Reinstaller" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
      <TextBlock Foreground="#44445a" FontSize="11" Margin="0,3,0,0">by clem.la &amp; melly  |  Full clean reinstall  |  discord.gg/luatools</TextBlock>
    </StackPanel>

    <Border Grid.Row="1" Background="#12121a" CornerRadius="6" Padding="12,10" Margin="0,0,0,10">
      <StackPanel>
        <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,6">This performs a full clean reinstall. Here is exactly what it does, step by step:</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">① Stops Steam and all related processes completely</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">② Removes conflicting files: steam.cfg, beta flag, version.dll, user32.dll, old DLLs, Tencent cache</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">③ Clears SteamTools registry unlock flags (ActivateUnlockMode, AlwaysStayUnlocked, notUnlockDepot)</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">④ Adds Windows Defender exclusions for new xinput1_4.dll and dwmapi.dll</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">⑤ Downloads fresh xinput1_4.dll + dwmapi.dll from SteamTools servers</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">⑥ Reinstalls Millennium silently (no restart needed)</TextBlock>
        <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">⑦ Sets iscdkey=false and relaunches Steam</TextBlock>
        <Border Background="#1a1010" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
          <TextBlock Foreground="#f87171" FontSize="10" TextWrapping="Wrap">
            ⚠  Use this if you're getting hardlink errors, DLL conflicts, or Option 1 keeps failing to install. This is a full wipe and reinstall — your plugins folder is preserved.
          </TextBlock>
        </Border>
      </StackPanel>
    </Border>

    <Border Grid.Row="2" Background="#16161f" CornerRadius="6" Padding="14,10" Margin="0,0,0,8">
      <StackPanel>
        <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" TextWrapping="Wrap">Click Run to begin the clean reinstall.</TextBlock>
        <ProgressBar x:Name="ProgressBar" Height="6" Minimum="0" Maximum="100" Value="0"
                     Background="#1a1a26" Foreground="#a78bfa" BorderThickness="0" Margin="0,6,0,0"/>
      </StackPanel>
    </Border>

    <Border Grid.Row="3" Background="#16161f" CornerRadius="6" Padding="10,8" Margin="0,0,0,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0" Foreground="#6bdc8a"
                 FontFamily="Cascadia Code,Consolas,monospace" FontSize="11" IsReadOnly="True"
                 TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>

    <Grid Grid.Row="4">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <Button x:Name="RunBtn" Grid.Column="1" Content="▶  Run Clean Reinstall" Width="180" Height="34" Cursor="Hand" FontWeight="SemiBold" Background="#4f46e5" Foreground="White" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#1e1e2e"/><Setter Property="Foreground" Value="#44445a"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
      <Button x:Name="CloseBtn" Grid.Column="3" Content="Close" Width="90" Height="34" Cursor="Hand" Background="#1e1e2e" Foreground="#44445a" BorderThickness="0">
        <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="14,6"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#2a2a3f"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>
      </Button>
    </Grid>
  </Grid>
</Window>
"@

$rd=[System.Xml.XmlNodeReader]::new($xaml); $win=[System.Windows.Markup.XamlReader]::Load($rd)
$stepLabel=$win.FindName("StepLabel"); $pb=$win.FindName("ProgressBar")
$logBox=$win.FindName("LogBox"); $logScroll=$win.FindName("LogScroll")
$runBtn=$win.FindName("RunBtn"); $closeBtn=$win.FindName("CloseBtn")

function GL($m){ $win.Dispatcher.Invoke([action]{ $logBox.AppendText("$m`n"); $logScroll.ScrollToBottom() }) }
function GS($m,$p=-1){ $win.Dispatcher.Invoke([action]{ $stepLabel.Text=$m; if($p -ge 0){$pb.Value=$p} }) }

$closeBtn.Add_Click({ $win.Close() })
$runBtn.Add_Click({
    $runBtn.IsEnabled=$false
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        try {
            if(-not $b10SP -or -not(Test-Path $b10SP)){ GL "[ERR]  Steam not found. Is Steam installed?"; GS "Error — Steam not found." 0; $win.Dispatcher.Invoke([action]{$closeBtn.IsEnabled=$true}); return }
            GL "[INFO] Steam path: $b10SP"
            $stRegPath='HKCU:\Software\Valve\Steamtools'
            $localPath=Join-Path $env:LOCALAPPDATA "steam"

            # ① Stop Steam
            GS "① Stopping Steam..." 5
            GL "[WARN] Stopping Steam..."
            $forceStop={param($n) Get-Process $n -EA SilentlyContinue|Stop-Process -Force -EA SilentlyContinue; Start-Sleep 2
                if(Get-Process $n -EA SilentlyContinue){ Start-Process cmd -ArgumentList "/c taskkill /f /im $n.exe" -WindowStyle Hidden -EA SilentlyContinue }}
            &$forceStop "steam"; &$forceStop "steamwebhelper"; &$forceStop "steamerrorreporter"
            Start-Sleep 1; GL "[OK]   Steam stopped."

            if(-not(Test-Path $localPath)){ New-Item $localPath -ItemType Directory -Force -EA SilentlyContinue|Out-Null }

            # ② Remove conflicting files
            GS "② Removing conflicting files..." 18
            GL "[INFO] Removing conflicting files..."
            @((Join-Path $b10SP "steam.cfg"),(Join-Path $b10SP "package\beta"),(Join-Path $env:LOCALAPPDATA "Microsoft\Tencent"),
              (Join-Path $b10SP "version.dll"),(Join-Path $b10SP "user32.dll"),(Join-Path $b10SP "xinput1_4.dll"),(Join-Path $b10SP "dwmapi.dll")) | ForEach-Object {
                if(Test-Path $_){ try{ Remove-Item $_ -Force -Recurse -EA Stop; GL "[OK]   Removed: $(Split-Path $_ -Leaf)" }catch{ GL "[WARN] Could not remove $(Split-Path $_ -Leaf): $($_.Exception.Message)" } }
            }
            GL "[OK]   Cleanup done."

            # ③ Clear registry flags
            GS "③ Clearing registry flags..." 32
            GL "[INFO] Clearing SteamTools registry flags..."
            if(-not(Test-Path $stRegPath)){ New-Item -Path $stRegPath -Force|Out-Null }
            Remove-ItemProperty -Path $stRegPath -Name "ActivateUnlockMode" -EA SilentlyContinue
            Remove-ItemProperty -Path $stRegPath -Name "AlwaysStayUnlocked" -EA SilentlyContinue
            Remove-ItemProperty -Path $stRegPath -Name "notUnlockDepot"     -EA SilentlyContinue
            Set-ItemProperty    -Path $stRegPath -Name "iscdkey" -Value "false" -Type String
            GL "[OK]   Registry flags cleared."

            # ④ Defender exclusions
            GS "④ Adding Defender exclusions..." 45
            GL "[INFO] Adding Defender exclusions..."
            $xp=Join-Path $b10SP "xinput1_4.dll"; $dp=Join-Path $b10SP "dwmapi.dll"
            try{ Add-MpPreference -ExclusionPath $xp -EA SilentlyContinue }catch{}
            try{ Add-MpPreference -ExclusionPath $dp -EA SilentlyContinue }catch{}
            GL "[OK]   Exclusions added."

            # ⑤ Download fresh DLLs
            GS "⑤ Downloading SteamTools DLLs..." 58
            GL "[INFO] Downloading fresh SteamTools DLLs..."
            @{$xp="http://update.steamcdn.com/update";$dp="http://update.steamcdn.com/dwmapi"}.GetEnumerator()|ForEach-Object{
                $n=Split-Path $_.Key -Leaf; GL "[LOG]  Downloading $n..."
                try{ Invoke-RestMethod -Uri $_.Value -OutFile $_.Key -EA Stop; GL "[OK]   $n downloaded." }
                catch{
                    if(Test-Path $_.Key){ Move-Item $_.Key "$($_.Key).old" -Force -EA SilentlyContinue
                        try{ Invoke-RestMethod -Uri $_.Value -OutFile $_.Key -EA SilentlyContinue; GL "[OK]   $n downloaded (after backup)." }
                        catch{ GL "[WARN] Could not download $n: $($_.Exception.Message)" }
                    } else { GL "[WARN] Could not download $n: $($_.Exception.Message)" }
                }
            }
            GL "[OK]   DLLs done."

            # ⑥ Reinstall Millennium
            GS "⑥ Reinstalling Millennium..." 75
            GL "[INFO] Downloading and running Millennium installer (silent)..."
            try{
                $mc=[ScriptBlock]::Create((Invoke-RestMethod "https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1"))
                &$mc -NoLog -DontStart -SteamPath $b10SP
                GL "[OK]   Millennium reinstalled."
            } catch { GL "[WARN] Millennium reinstall failed: $($_.Exception.Message)"; GL "[WARN] You can reinstall manually at https://steambrew.app/" }

            # ⑦ Launch Steam
            GS "⑦ Launching Steam..." 92
            GL "[INFO] Launching Steam..."
            $exe=Join-Path $b10SP "steam.exe"
            if(Test-Path $exe){ Start-Process $exe; Start-Process "steam://"; GL "[OK]   Steam launched. Log in to complete activation." }
            else { GL "[WARN] steam.exe not found — launch Steam manually." }

            GS "Reinstall complete!" 100
            GL "[OK]   All done! Steam is starting. You may close this window."
        } catch { GL "[ERR]  $($_.Exception.Message)"; GS "Error — see log." 0 }
        $win.Dispatcher.Invoke([action]{ $closeBtn.IsEnabled=$true })
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
})
$win.ShowDialog() | Out-Null
'@ | Set-Content $b10Script -Encoding UTF8
    Start-Process "powershell.exe" "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b10Script`"" -Wait
    Remove-Item $b10Script -Force -ErrorAction SilentlyContinue
    $Branch = 0
}





#### Branch 11: Steamless Game Patcher (GUI) ####
if ($Branch -eq 11) {
    $Host.UI.RawUI.WindowTitle = "Steamless Patcher | .gg/luatools"

    # =========================================================================
    # HELPERS
    # =========================================================================

    function Get-B11SteamRoot {
        foreach ($reg in @("HKCU:\Software\Valve\Steam","HKLM:\SOFTWARE\WOW6432Node\Valve\Steam","HKLM:\SOFTWARE\Valve\Steam")) {
            try {
                $v = (Get-ItemProperty $reg -Name "SteamPath" -ErrorAction Stop).SteamPath
                if ($v) { return ($v.Trim('"') -replace '/','\') }
            } catch {}
        }
        return "C:\Program Files (x86)\Steam"
    }

    function Get-B11LibraryPaths([string]$SteamRoot) {
        $libs = @($SteamRoot)
        $vdf  = Join-Path $SteamRoot "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            $raw = Get-Content $vdf -Raw -ErrorAction SilentlyContinue
            [regex]::Matches($raw, '"path"\s+"([^"]+)"') | ForEach-Object {
                $p = $_.Groups[1].Value -replace '\\\\','\' -replace '/','\' 
                if ($p -and (Test-Path $p)) { $libs += $p }
            }
        }
        return $libs | Select-Object -Unique
    }

    # Build a lookup table: AppId -> installed game info (from appmanifest_*.acf files)
    function Get-B11InstalledIndex([string[]]$LibPaths) {
        $index = @{}
        foreach ($lib in $LibPaths) {
            $appsDir = Join-Path $lib "steamapps"
            if (-not (Test-Path $appsDir)) { continue }
            Get-ChildItem $appsDir -Filter "appmanifest_*.acf" -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    $mc    = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                    $idM   = [regex]::Match($mc, '"appid"\s+"(\d+)"')
                    $nameM = [regex]::Match($mc, '"name"\s+"([^"]+)"')
                    $dirM  = [regex]::Match($mc, '"installdir"\s+"([^"]+)"')
                    if ($idM.Success -and $nameM.Success -and $dirM.Success) {
                        $appId   = $idM.Groups[1].Value
                        $gameDir = Join-Path $lib "steamapps\common\$($dirM.Groups[1].Value)"
                        if (Test-Path $gameDir) {
                            $index[$appId] = [PSCustomObject]@{
                                AppId   = $appId
                                Name    = $nameM.Groups[1].Value
                                GameDir = $gameDir
                                LibPath = $lib
                            }
                        }
                    }
                } catch {}
            }
        }
        return $index
    }

    # Scan stplug-in — the canonical source of truth for what luas exist.
    # Files named <appid>.lua are ENABLED. Files named <appid>.lua.disabled are DISABLED.
    function Get-B11LuaFiles([string]$SteamRoot) {
        $stPluginDir = Join-Path $SteamRoot "config\stplug-in"
        $results = @()
        if (-not (Test-Path $stPluginDir)) { return $results }

        Get-ChildItem $stPluginDir -ErrorAction SilentlyContinue | ForEach-Object {
            $fname = $_.Name
            $appId = $null
            $enabled = $false

            # Enabled: exactly <digits>.lua  (one dot, ends in .lua)
            if ($fname -match '^(\d+)\.lua$') {
                $appId   = $matches[1]
                $enabled = $true
            }
            # Disabled: exactly <digits>.lua.disabled  (two dots)
            elseif ($fname -match '^(\d+)\.lua\.disabled$') {
                $appId   = $matches[1]
                $enabled = $false
            }

            if ($appId) {
                $results += [PSCustomObject]@{
                    AppId    = $appId
                    Enabled  = $enabled
                    LuaPath  = $_.FullName
                    FileName = $fname
                }
            }
        }
        return $results
    }

    # Get the exe Steam uses to launch the game — 3 strategies.
    function Get-B11LaunchExe([string]$AppId, [string]$SteamRoot, [string]$GameDir, [string]$GameName) {

        # Strategy 1: appinfo.vdf binary — find the "executable" key in the launch config section
        $vdf = Join-Path $SteamRoot "appcache\appinfo.vdf"
        if (Test-Path $vdf) {
            try {
                $bytes   = [IO.File]::ReadAllBytes($vdf)
                $idBytes = [BitConverter]::GetBytes([uint32]$AppId)
                $idx = 0
                for ($i = 0; $i -lt $bytes.Length - 4; $i++) {
                    if ($bytes[$i] -eq $idBytes[0] -and $bytes[$i+1] -eq $idBytes[1] -and
                        $bytes[$i+2] -eq $idBytes[2] -and $bytes[$i+3] -eq $idBytes[3]) { $idx = $i; break }
                }
                if ($idx -gt 0) {
                    $window  = [Math]::Min($idx + 30000, $bytes.Length - 1)
                    $str     = [System.Text.Encoding]::ASCII.GetString($bytes[$idx..$window])
                    $exeHits = [regex]::Matches($str, "\x00executable\x00([^\x00]+\.exe)")
                    foreach ($m in $exeHits) {
                        $candidate = $m.Groups[1].Value.Trim() -replace '/','\' 
                        $full = if ($candidate -match '\\') { Join-Path $GameDir $candidate }
                                else {
                                    $f = Get-ChildItem $GameDir -Filter $candidate -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                                    if ($f) { $f.FullName } else { Join-Path $GameDir $candidate }
                                }
                        if (Test-Path $full) { return $full }
                    }
                }
            } catch {}
        }

        # Strategy 2: localconfig.vdf per-user override
        $userdataDir = Join-Path $SteamRoot "userdata"
        if (Test-Path $userdataDir) {
            Get-ChildItem $userdataDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $lcPath = Join-Path $_.FullName "config\localconfig.vdf"
                if (Test-Path $lcPath) {
                    try {
                        $lc         = Get-Content $lcPath -Raw -ErrorAction SilentlyContinue
                        $appSection = [regex]::Match($lc, "(?s)`"$AppId`".*?(?=`"\d{6,}`"|$)")
                        if ($appSection.Success) {
                            $exeM = [regex]::Match($appSection.Value, '"[Ee]xe"\s+"([^"]+\.exe)"')
                            if ($exeM.Success) {
                                $rel  = $exeM.Groups[1].Value -replace '/','\' 
                                $full = if (Test-Path $rel) { $rel } else { Join-Path $GameDir $rel }
                                if (Test-Path $full) { return $full }
                            }
                        }
                    } catch {}
                }
            }
        }

        # Strategy 3: Scan game folder — prefer root-level exes matching game name, then largest
        if (Test-Path $GameDir) {
            $blacklist = 'unins|setup|redist|vcredist|directx|crash|report|UnityCrashHandler|dxsetup|vc_redist|dotnet'
            $exes = Get-ChildItem $GameDir -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -notmatch $blacklist }
            if ($exes) {
                $words  = ($GameName -replace '[^a-zA-Z0-9 ]',' ').ToLower() -split '\s+' | Where-Object { $_.Length -gt 2 }
                $scored = $exes | ForEach-Object {
                    $lower = $_.BaseName.ToLower()
                    $score = ($words | Where-Object { $lower -like "*$_*" }).Count
                    $depth = if ($_.DirectoryName -eq $GameDir) { 2 } else { 0 }
                    [PSCustomObject]@{ File = $_; Score = ($score + $depth); Size = $_.Length }
                }
                $best = ($scored | Sort-Object Score,Size -Descending | Select-Object -First 1).File
                if ($best) { return $best.FullName }
            }
        }
        return $null
    }

    # Download Steamless CLI once, cache in %TEMP%
    function Get-B11SteamlessCli {
        $tmp     = Join-Path $env:TEMP "steamless_patcher"
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        # Search recursively — the zip extracts into a versioned subfolder
        $existing = Get-ChildItem $tmp -Filter "Steamless.CLI.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $existing) {
            $zipPath = Join-Path $tmp "steamless.zip"
            Invoke-WebRequest "https://github.com/atom0s/Steamless/releases/download/v3.1.0.5/Steamless.v3.1.0.5.-.by.atom0s.zip" -OutFile $zipPath -ErrorAction Stop
            Expand-Archive $zipPath $tmp -Force
            $existing = Get-ChildItem $tmp -Filter "Steamless.CLI.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }
        if (-not $existing) { throw "Steamless.CLI.exe not found after extraction." }
        return $existing.FullName
    }

    # Run Steamless CLI against an exe, stream output to the WPF log box
    function Invoke-B11Steamless([string]$ExePath, [System.Windows.Controls.TextBox]$LogBox) {
        function B11Log([string]$msg) {
            $LogBox.Dispatcher.Invoke([action]{
                $LogBox.AppendText("$msg`n")
                $LogBox.ScrollToEnd()
            })
        }

        B11Log "Target: $ExePath"
        $tmp = Join-Path $env:TEMP "steamless_patcher"

        B11Log "Getting Steamless CLI..."
        try {
            $cliPath = Get-B11SteamlessCli
            B11Log "CLI ready."
        } catch {
            B11Log "ERROR: $($_.Exception.Message)"
            return $false
        }

        B11Log "Patching — please wait..."
        try {
            Start-Process -FilePath $cliPath -ArgumentList "`"$ExePath`"" -Wait -NoNewWindow `
                -RedirectStandardOutput "$tmp\out.txt" -RedirectStandardError "$tmp\err.txt" -ErrorAction Stop
            (Get-Content "$tmp\out.txt" -ErrorAction SilentlyContinue) | ForEach-Object { B11Log $_ }
            (Get-Content "$tmp\err.txt" -ErrorAction SilentlyContinue) | ForEach-Object { B11Log "[err] $_" }
        } catch {
            B11Log "ERROR: $($_.Exception.Message)"
            return $false
        }

        $unpacked = "$ExePath.unpacked.exe"
        if (Test-Path $unpacked) {
            B11Log "Replacing original exe..."
            try {
                Remove-Item $ExePath -Force -ErrorAction Stop
                Rename-Item $unpacked $ExePath -ErrorAction Stop
                B11Log "Done!  $([System.IO.Path]::GetFileName($ExePath)) patched successfully."
                return $true
            } catch {
                B11Log "ERROR: Could not replace exe: $($_.Exception.Message)"
                return $false
            }
        } else {
            B11Log "WARNING: No .unpacked.exe produced. The game may already be DRM-free, or Steamless does not support this exe."
            return $false
        }
    }

    # =========================================================================
    # DATA LOAD  — lua files are the primary list; installed games are the index
    # =========================================================================
    # ---- Load data in current process ----
    Log "INFO" "Scanning Steam library and stplug-in folder..."
    $b11SteamRoot = Get-B11SteamRoot
    $b11LibPaths  = Get-B11LibraryPaths   $b11SteamRoot
    $b11Installed = Get-B11InstalledIndex $b11LibPaths
    $b11LuaFiles  = Get-B11LuaFiles       $b11SteamRoot

    if ($b11LuaFiles.Count -eq 0) {
        Log "WARN" "No .lua files found in $b11SteamRoot\config\stplug-in"
        Log "INFO" "Install SteamTools and add some games first."
        Blank
        Read-Host "Press Enter to go back to the menu"
    } else {
        Log "INFO" "Found $($b11LuaFiles.Count) lua file(s). Building item list..."

        $b11AllItems = $b11LuaFiles | ForEach-Object {
            $lua       = $_
            $appId     = $lua.AppId
            $game      = $b11Installed[$appId]
            $installed = $null -ne $game

            $displayName = if ($installed) { $game.Name } else { "AppID $appId (not installed)" }
            $exePath     = $null
            if ($installed) {
                $exePath = Get-B11LaunchExe $appId $b11SteamRoot $game.GameDir $game.Name
            }

            if (-not $lua.Enabled) {
                $badge = "Disabled";      $badgeColor = "#44445a"; $canPatch = $false
            } elseif (-not $installed) {
                $badge = "Not installed"; $badgeColor = "#f59e0b"; $canPatch = $false
            } elseif (-not $exePath) {
                $badge = "EXE not found"; $badgeColor = "#f87171"; $canPatch = $false
            } else {
                $badge = "Ready";         $badgeColor = "#6bdc8a"; $canPatch = $true
            }

            [PSCustomObject]@{
                AppId       = $appId
                Name        = $displayName
                IconUrl     = "https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/capsule_sm_120.jpg"
                LuaPath     = $lua.LuaPath
                LuaEnabled  = $lua.Enabled
                Installed   = $installed
                GameDir     = if ($installed) { $game.GameDir } else { $null }
                ExePath     = $exePath
                CanPatch    = $canPatch
                StatusLabel = $badge
                StatusColor = $badgeColor
            }
        } | Sort-Object { if ($_.CanPatch) { 0 } elseif ($_.Installed) { 1 } else { 2 } }, Name

        # Serialize data to a temp JSON file so the STA child process can read it
        $b11DataFile = Join-Path $env:TEMP "luatools_b11_data.json"
        $b11AllItems | ConvertTo-Json -Depth 5 | Set-Content $b11DataFile -Encoding UTF8

        Log "OK"   "Data ready. Launching GUI (STA mode)..."

    # =========================================================================
    # WPF GUI — runs in a child powershell.exe -STA process
    # WPF requires Single-Threaded Apartment mode which the parent shell may not be.
    # We write the full GUI script to a temp file and spawn it with -STA.
    # =========================================================================

    $b11GuiScript = Join-Path $env:TEMP "luatools_b11_gui.ps1"

    @'
param($DataFile, $SteamRoot)

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# ---- Load serialized item list ----
$allItems = (Get-Content $DataFile -Raw -Encoding UTF8 | ConvertFrom-Json)

# Re-attach mutable fields WPF needs (ConvertFrom-Json gives us read-only NoteProperties)
$b11AllItems = $allItems | ForEach-Object {
    [PSCustomObject]@{
        AppId       = $_.AppId
        Name        = $_.Name
        IconUrl     = $_.IconUrl
        LuaPath     = $_.LuaPath
        LuaEnabled  = $_.LuaEnabled
        Installed   = $_.Installed
        GameDir     = $_.GameDir
        ExePath     = $_.ExePath
        CanPatch    = $_.CanPatch
        StatusLabel = $_.StatusLabel
        StatusColor = $_.StatusColor
        _ManualExe  = $null
    }
}

# ---- Steamless patcher ----
function Invoke-Steamless([string]$ExePath, [System.Windows.Controls.TextBox]$LogBox) {
    function SL([string]$m) {
        $LogBox.Dispatcher.Invoke([action]{ $LogBox.AppendText("$m`n"); $LogBox.ScrollToEnd() })
    }
    SL "Target: $ExePath"
    $tmp     = Join-Path $env:TEMP "steamless_patcher"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null

    # Search recursively — the zip extracts into a versioned subfolder
    $cliFound = Get-ChildItem $tmp -Filter "Steamless.CLI.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cliFound) {
        SL "Downloading Steamless v3.1.0.5..."
        try {
            Invoke-WebRequest "https://github.com/atom0s/Steamless/releases/download/v3.1.0.5/Steamless.v3.1.0.5.-.by.atom0s.zip" `
                -OutFile "$tmp\steamless.zip" -ErrorAction Stop
            Expand-Archive "$tmp\steamless.zip" $tmp -Force
            SL "Download complete."
        } catch { SL "ERROR: $($_.Exception.Message)"; return $false }
        $cliFound = Get-ChildItem $tmp -Filter "Steamless.CLI.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    } else { SL "Steamless already cached." }

    if (-not $cliFound) { SL "ERROR: Steamless.CLI.exe missing after extraction."; return $false }
    $cliPath = $cliFound.FullName

    SL "Patching — please wait..."
    try {
        Start-Process -FilePath $cliPath -ArgumentList "`"$ExePath`"" -Wait -NoNewWindow `
            -RedirectStandardOutput "$tmp\out.txt" -RedirectStandardError "$tmp\err.txt" -ErrorAction Stop
        (Get-Content "$tmp\out.txt" -ErrorAction SilentlyContinue) | ForEach-Object { SL $_ }
        (Get-Content "$tmp\err.txt" -ErrorAction SilentlyContinue) | ForEach-Object { SL "[err] $_" }
    } catch { SL "ERROR: $($_.Exception.Message)"; return $false }

    $unpacked = "$ExePath.unpacked.exe"
    if (Test-Path $unpacked) {
        SL "Replacing original exe..."
        try {
            Remove-Item $ExePath -Force -ErrorAction Stop
            Rename-Item $unpacked $ExePath -ErrorAction Stop
            SL "Done!  $([System.IO.Path]::GetFileName($ExePath)) patched successfully."
            return $true
        } catch { SL "ERROR: Could not replace exe: $($_.Exception.Message)"; return $false }
    } else {
        SL "WARNING: No .unpacked.exe produced. Game may already be DRM-free or Steamless does not support this exe."
        return $false
    }
}

# ---- XAML ----
[xml]$xamlDoc = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Steamless Patcher  |  .gg/luatools"
        Width="860" Height="640" MinWidth="620" MinHeight="480"
        WindowStartupLocation="CenterScreen"
        Background="#0f0f14" FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <Style x:Key="Card" TargetType="Border">
            <Setter Property="Background" Value="#16161f"/>
            <Setter Property="CornerRadius" Value="6"/>
            <Setter Property="Padding" Value="14,10"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
        </Style>
        <Style x:Key="Row" TargetType="ListBoxItem">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#c8c8d4"/>
            <Setter Property="Padding" Value="10,7"/>
            <Setter Property="Margin" Value="0,1"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1e1e2e"/></Trigger>
                <Trigger Property="IsSelected"  Value="True">
                    <Setter Property="Background" Value="#2a2a4a"/>
                    <Setter Property="Foreground" Value="#a78bfa"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#4f46e5"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="16,8"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6366f1"/></Trigger>
                            <Trigger Property="IsPressed"   Value="True"><Setter Property="Background" Value="#3730a3"/></Trigger>
                            <Trigger Property="IsEnabled"   Value="False">
                                <Setter Property="Background" Value="#1e1e2e"/>
                                <Setter Property="Foreground" Value="#44445a"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#1a1a26"/>
            <Setter Property="Foreground" Value="#c8c8d4"/>
            <Setter Property="BorderBrush" Value="#2a2a3f"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="CaretBrush" Value="#a78bfa"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#6b6b88"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
    </Window.Resources>
    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="150"/>
        </Grid.RowDefinitions>
        <StackPanel Grid.Row="0" Margin="0,0,0,12">
            <TextBlock Text="Steamless Game Patcher" FontSize="20" FontWeight="Bold" Foreground="#a78bfa" Margin="0,0,0,3"/>
            <TextBlock Foreground="#6b6b88" FontSize="11" TextWrapping="Wrap">
                Shows every .lua file in your stplug-in folder. Ready = game installed + EXE found. Not installed = install the game on Steam first.
            </TextBlock>
        </StackPanel>
        <Border Grid.Row="1" Style="{StaticResource Card}">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBox x:Name="SearchBox" Grid.Column="0" FontSize="13"/>
                <TextBlock x:Name="SearchPH" Grid.Column="0" Text="Search by name or AppID..."
                           Foreground="#44445a" IsHitTestVisible="False"
                           VerticalAlignment="Center" Margin="10,0,0,0" FontSize="13"/>
                <CheckBox x:Name="OnlyReady"    Grid.Column="1" Content="Ready only"   Margin="12,0,8,0"/>
                <CheckBox x:Name="HideDisabled" Grid.Column="2" Content="Hide disabled" Margin="0,0,8,0"/>
                <TextBlock x:Name="CountLabel"  Grid.Column="3" Foreground="#44445a" VerticalAlignment="Center" FontSize="11"/>
            </Grid>
        </Border>
        <Border Grid.Row="2" Style="{StaticResource Card}" Padding="0">
            <ListBox x:Name="GameList" Background="Transparent" BorderThickness="0"
                     ScrollViewer.HorizontalScrollBarVisibility="Disabled"
                     VirtualizingPanel.IsVirtualizing="True"
                     VirtualizingPanel.VirtualizationMode="Recycling"
                     ItemContainerStyle="{StaticResource Row}">
                <ListBox.ItemTemplate>
                    <DataTemplate>
                        <Grid Margin="0,1">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="36"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="110"/>
                            </Grid.ColumnDefinitions>
                            <Border Grid.Column="0" Width="30" Height="30" CornerRadius="4" Background="#1a1a26">
                                <Image Source="{Binding IconUrl}" Stretch="UniformToFill"
                                       RenderOptions.BitmapScalingMode="HighQuality">
                                    <Image.Clip>
                                        <RectangleGeometry Rect="0,0,30,30" RadiusX="4" RadiusY="4"/>
                                    </Image.Clip>
                                </Image>
                            </Border>
                            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="10,0,8,0">
                                <TextBlock Text="{Binding Name}"
                                           Foreground="{Binding RelativeSource={RelativeSource AncestorType=ListBoxItem}, Path=Foreground}"
                                           FontWeight="Medium" TextTrimming="CharacterEllipsis"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="{Binding AppId}" Foreground="#44445a" FontSize="10"/>
                                    <TextBlock Text=" · " Foreground="#2a2a3f" FontSize="10"/>
                                    <TextBlock Text="{Binding LuaPath}" Foreground="#2a2a4a" FontSize="10"
                                               TextTrimming="CharacterEllipsis" MaxWidth="400"/>
                                </StackPanel>
                            </StackPanel>
                            <Border Grid.Column="2" CornerRadius="3" Padding="7,3"
                                    HorizontalAlignment="Right" VerticalAlignment="Center" Background="#0f0f14">
                                <TextBlock Text="{Binding StatusLabel}" Foreground="{Binding StatusColor}"
                                           FontSize="10" FontWeight="SemiBold"/>
                            </Border>
                        </Grid>
                    </DataTemplate>
                </ListBox.ItemTemplate>
            </ListBox>
        </Border>
        <Grid Grid.Row="3" Margin="0,0,0,8">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="SelLabel" Grid.Column="0" Foreground="#6b6b88" VerticalAlignment="Center"
                       FontSize="11" Text="No game selected" TextTrimming="CharacterEllipsis"/>
            <Button x:Name="BrowseBtn" Grid.Column="1" Content="Browse EXE" Background="#1e1e2e" Margin="0,0,8,0" IsEnabled="False"/>
            <Button x:Name="PatchBtn"  Grid.Column="2" Content="Patch Game" IsEnabled="False"/>
        </Grid>
        <Border Grid.Row="4" Style="{StaticResource Card}" Padding="10,8">
            <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0"
                         Foreground="#6bdc8a" FontFamily="Cascadia Code, Consolas, monospace"
                         FontSize="11" IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True"/>
            </ScrollViewer>
        </Border>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlNodeReader]::new($xamlDoc)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$searchBox    = $window.FindName("SearchBox")
$searchPH     = $window.FindName("SearchPH")
$onlyReady    = $window.FindName("OnlyReady")
$hideDisabled = $window.FindName("HideDisabled")
$countLabel   = $window.FindName("CountLabel")
$gameList     = $window.FindName("GameList")
$selLabel     = $window.FindName("SelLabel")
$browseBtn    = $window.FindName("BrowseBtn")
$patchBtn     = $window.FindName("PatchBtn")
$logBox       = $window.FindName("LogBox")

$filtered = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
$gameList.ItemsSource = $filtered

$ready   = ($b11AllItems | Where-Object { $_.CanPatch }).Count
$noInst  = ($b11AllItems | Where-Object { -not $_.Installed -and $_.LuaEnabled }).Count
$dis     = ($b11AllItems | Where-Object { -not $_.LuaEnabled }).Count
$logBox.Text = "Found $($b11AllItems.Count) lua file(s).  Ready: $ready  |  Not installed: $noInst  |  Disabled: $dis`nSteam root: $SteamRoot`n"

function Update-List {
    $q  = $searchBox.Text.Trim().ToLower()
    $ro = $onlyReady.IsChecked
    $hd = $hideDisabled.IsChecked
    $filtered.Clear()
    $b11AllItems | Where-Object {
        ($q -eq '' -or $_.Name.ToLower() -like "*$q*" -or $_.AppId -like "*$q*") -and
        (-not $ro -or $_.CanPatch) -and
        (-not $hd -or $_.LuaEnabled)
    } | ForEach-Object { $filtered.Add($_) }
    $countLabel.Text = "$($filtered.Count) / $($b11AllItems.Count)"
}
Update-List

$searchBox.Add_TextChanged({
    $searchPH.Visibility = if ($searchBox.Text) { "Collapsed" } else { "Visible" }
    Update-List
})
$onlyReady.Add_Checked({    Update-List })
$onlyReady.Add_Unchecked({  Update-List })
$hideDisabled.Add_Checked({   Update-List })
$hideDisabled.Add_Unchecked({ Update-List })

$gameList.Add_SelectionChanged({
    $sel = $gameList.SelectedItem
    if (-not $sel) {
        $selLabel.Text = "No game selected"; $patchBtn.IsEnabled = $false; $browseBtn.IsEnabled = $false; return
    }
    $exeDisplay  = if ($sel._ManualExe) { "(manual) $([IO.Path]::GetFileName($sel._ManualExe))" }
                   elseif ($sel.ExePath) { [IO.Path]::GetFileName($sel.ExePath) }
                   else { "EXE not found" }
    $instDisplay = if ($sel.Installed) { $sel.GameDir } else { "not installed on Steam" }
    $selLabel.Text = "$($sel.Name)  |  $exeDisplay  |  $instDisplay"
    $hasExe = ($sel._ManualExe -and (Test-Path $sel._ManualExe)) -or ($sel.ExePath -and (Test-Path $sel.ExePath))
    $patchBtn.IsEnabled  = $sel.Installed -and $hasExe
    $browseBtn.IsEnabled = [bool]$sel.Installed
})

$browseBtn.Add_Click({
    $sel = $gameList.SelectedItem
    if (-not $sel -or -not $sel.Installed) { return }
    $dlg = [System.Windows.Forms.OpenFileDialog]::new()
    $dlg.Title = "Select EXE for $($sel.Name)"
    $dlg.Filter = "Executables (*.exe)|*.exe"
    $dlg.InitialDirectory = if ($sel.GameDir -and (Test-Path $sel.GameDir)) { $sel.GameDir } else { "C:\" }
    if ($dlg.ShowDialog() -eq "OK") {
        $sel._ManualExe     = $dlg.FileName
        $logBox.Text        = "Manual EXE set: $($dlg.FileName)`n"
        $patchBtn.IsEnabled = $true
        $selLabel.Text      = "$($sel.Name)  |  (manual) $([IO.Path]::GetFileName($dlg.FileName))"
    }
})

$patchBtn.Add_Click({
    $sel = $gameList.SelectedItem
    if (-not $sel) { return }
    $exePath = if ($sel._ManualExe -and (Test-Path $sel._ManualExe)) { $sel._ManualExe }
               elseif ($sel.ExePath -and (Test-Path $sel.ExePath))   { $sel.ExePath }
               else { $null }
    if (-not $exePath) { $logBox.Text = "ERROR: No valid EXE. Use Browse EXE to set it manually.`n"; return }
    $patchBtn.IsEnabled = $false; $browseBtn.IsEnabled = $false
    $logBox.Text = ""
    $disp = $window.Dispatcher
    $t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
        $ok = Invoke-Steamless $exePath $logBox
        $disp.Invoke([action]{
            $sel.StatusLabel = if ($ok) { "Patched" } else { "Failed" }
            $sel.StatusColor = if ($ok) { "#6bdc8a" } else { "#f87171" }
            $patchBtn.IsEnabled = $true; $browseBtn.IsEnabled = $true
    }.GetNewClosure()))
    `$t.IsBackground = `$true
    `$t.Start()
    })
})

$window.ShowDialog() | Out-Null
'@ | Set-Content $b11GuiScript -Encoding UTF8

        # Launch the GUI in a new STA PowerShell window and wait for it to close
        $b11Proc = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b11GuiScript`" -DataFile `"$b11DataFile`" -SteamRoot `"$b11SteamRoot`"" `
            -Wait -PassThru
        Remove-Item $b11GuiScript  -Force -ErrorAction SilentlyContinue
        Remove-Item $b11DataFile   -Force -ErrorAction SilentlyContinue
        $Branch = 0
    }

}




#### Plugin install flow (branches 1 & 2) ####

if ($Branch -eq 1 -or $Branch -eq 2) {

    # Wire install-plugin vars to the main script's already-resolved values
    $Script:DownloadLink = $DownloadLink
    $Script:PluginName   = $PluginName
    $Script:Branch       = $Branch   # use the Branch already chosen in the main menu — do NOT reset it
    $Script:Culture      = $env:LT_CULTURE
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # fix SSL/TSL Error
    $Script:ProgressPreference = 'SilentlyContinue'
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $null = chcp 65001
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    Add-Type -AssemblyName System.Net.Http

    # ---------------------------------------------------------------------------
    # Locale defaults
    # ---------------------------------------------------------------------------
    function Get-DefaultStrings {
        param([string]$Culture)

        $tables = @{
            "en" = @{
                Title                 = "Luatools plugin installer | .gg/luatools"
                SteamRegNotFound      = "Steam registry key not found. Is Steam installed?"
                SteamKilling          = "Stopping Steam"
                SteamKilled           = "Steam stopped"
                SteamtoolsFound       = "Steamtools already installed"
                SteamtoolsNotFound    = "Steamtools not found"
                SteamtoolsInstalling  = "Installing Steamtools"
                SteamtoolsInstalled   = "Steamtools installed"
                SteamtoolsRetrying    = "Steamtools installation failed, retrying..."
                SteamtoolsFailed      = "Steamtools installation failed after 5 attempts"
                MillenniumNotFound    = "Millennium not found"
                MillenniumCountdown   = "Millennium will be installed in {0} second(s)... Press any key to cancel"
                MillenniumCancelled   = "Installation cancelled by user"
                MillenniumInstalling  = "Installing Millennium"
                MillenniumInstalled   = "Millennium installed"
                MillenniumAlready     = "Millennium already installed"
                MillenniumFirstBoot   = "Steam startup may be slower on first boot -- let it sit."
                PluginUpdating        = "Plugin already installed, updating"
                PluginDownloading     = "Downloading {0}"
                PluginDownloadFailed  = "Failed to download {0}"
                PluginExtracting      = "Extracting {0}"
                PluginExtractFailed   = "Extraction failed, trying built-in Expand-Archive"
                PluginInstalled       = "{0} installed"
                PluginEnabled         = "Plugin enabled"
                RemovingBeta          = "Cleaning up beta flag"
                RemovingCfg           = "Cleaning up steam.cfg"
                RemovingForceX86      = "Cleaning up ForceX86 registry flags (32 bits)"
                StartingSteam         = "Starting Steam"
                UpdateCheckDisabled   = "Millennium auto-updates disabled to prevent startup hangs."
                UpdateCheckManual     = "Check for Millennium updates manually if you want the latest."

                ErrorTitle            = "Luatools installer - ERROR"
                ErrorHeader           = "AN ERROR OCCURRED"
                ErrorBody             = "The Luatools plugin installer encountered a problem and could not complete. This is often caused by your ISP blocking the download servers we use."
                ErrorFaq              = "Visit the server (.gg/luatools) for more information & fixes."
                ErrorExit             = "Press any key to exit."
            }

            "pt-BR" = @{
                Title                 = "Instalador do Luatools | .gg/luatools"
                SteamRegNotFound      = "Steam não encontrada no registro. Sua Steam ta instalada?"
                SteamKilling          = "Parando a Steam"
                SteamKilled           = "Steam Encerrada"
                SteamtoolsFound       = "Steamtools ja instalado"
                SteamtoolsNotFound    = "Steamtools não encontrado"
                SteamtoolsInstalling  = "Instalando Steamtools"
                SteamtoolsInstalled   = "Steamtools instalado"
                SteamtoolsRetrying    = "Falha ao instalar Steamtools, tentando denovo..."
                SteamtoolsFailed      = "Falha ao instalar Steamtools após 5 tentativas"
                MillenniumNotFound    = "Millennium não encontrado"
                MillenniumCountdown   = "Millennium vai ser instalado em {0} segundo(s)... Aperte qualquer tecla pra cancelar"
                MillenniumCancelled   = "Instalação cancelada pelo usuário"
                MillenniumInstalling  = "Instalando Millennium"
                MillenniumInstalled   = "Millennium instalado"
                MillenniumAlready     = "O Millennium ja está instalado"
                MillenniumFirstBoot   = "A Steam pode demorar um pouco pra abrir pela primeira vez -- deixa rolar."
                PluginUpdating        = "Plugin já instalado, atualizando"
                PluginDownloading     = "Baixando {0}"
                PluginDownloadFailed  = "Falha ao baixar {0}"
                PluginExtracting      = "Extraindo {0}"
                PluginExtractFailed   = "Falha ao extrair, tentando via Expand-Archive"
                PluginInstalled       = "{0} instalado"
                PluginEnabled         = "Plugin habilitado"
                RemovingBeta          = "Limpando flag de beta da Steam"
                RemovingCfg           = "Apagando steam.cfg"
                RemovingForceX86      = "limpando as flags de registro do ForceX86 (32 bits)"
                StartingSteam         = "Abrindo a Steam"
                UpdateCheckDisabled   = "Atualizações automáticas do Millennium desabilitadas pra evitar travamentos ao iniciar"
                UpdateCheckManual     = "Verifique manualmente por atualizações do Millennium caso você queira a ultima versão"

                ErrorTitle            = "Instalador do Luatools - ERRO"
                ErrorHeader           = "OCORREU UM ERRO"
                ErrorBody             = "O instalador do Luatools encontrou um problema e não pôde ser concluído. Isso geralmente é causado pela tua internet bloqueando nossos servidores de Download"
                ErrorFaq              = "Visite o servidor (.gg/luatools) pra mais informações e detalhes em como consertar"
                ErrorExit             = "Aperte qualquer botão pra sair."
            }

            "es" = @{
                Title                 = "Instalador del plugin de Luatools | .gg/luatools"
                SteamRegNotFound      = "La clave de registro de Steam no se ha encontrado. Está Steam instalado?"
                SteamKilling          = "Deteniendo Steam"
                SteamKilled           = "Steam se ha detenido"
                SteamtoolsFound       = "Steamtools ya está instalado"
                SteamtoolsNotFound    = "Steamtools no se ha encontrado"
                SteamtoolsInstalling  = "Instalando Steamtools"
                SteamtoolsInstalled   = "Steamtools se ha instalado"
                SteamtoolsRetrying    = "La instalación de Steamtools ha fallado, reintentando..."
                SteamtoolsFailed      = "La instalación de Steamtools ha fallado despues de 5 intentos"
                MillenniumNotFound    = "Millenium no encontrado"
                MillenniumCountdown   = "Millenium sera instalado en {0} segundo(s) ... Presiona cualquier tecla para cancelar"
                MillenniumCancelled   = "Instalación cancelada por el usuario"
                MillenniumInstalling  = "Instalando Millenium"
                MillenniumInstalled   = "Millenium instalado"
                MillenniumAlready     = "Millenium ya estaba instalado"
                MillenniumFirstBoot   = "La carga de steam puede ser más lenta la primera vez para cargar las dependencias -- espera pacientemente"
                PluginUpdating        = "El plugin ya esta instalado, actualizando"
                PluginDownloading     = "Descargando {0}"
                PluginDownloadFailed  = "Error al descargar {0}"
                PluginExtracting      = "Extrayendo {0}"
                PluginExtractFailed   = "Extracción fallida, intentando descomprimir archivos"
                PluginInstalled       = "{0} instalado"
                PluginEnabled         = "Plugin establecido"
                RemovingBeta          = "Limpiando indicador beta"
                RemovingCfg           = "Limpiando steam.cfg"
                RemovingForceX86      = "Limpiando los registros de ForceX86 (32 bits)"
                StartingSteam         = "Iniciando Steam"
                UpdateCheckDisabled   = "Las auto-actualizaciones de Millenium están deshabilitadas para prevenir cuelgues al inicio"
                UpdateCheckManual     = "Comprueba las actualizaciones de Millenium manualmente si necesitas la última versión"

                ErrorTitle            = "Error con el instalador Luatools - ERROR"
                ErrorHeader           = "UN ERROR HA OCURRIDO"
                ErrorBody             = "El instalador del plugin Luatools encontró un problema y no pudo completarse. Esto suele ocurrir cuando tu proveedor de internet (ISP) bloquea los servidores de descarga que utilizamos."
                ErrorFaq              = "Visita el servidor (.gg/luatools) para mas información o fixes."
                ErrorExit             = "Presiona cualquier tecla para salir."
            }

            "fr" = @{
                Title                 = "Installateur du plugin Luatools | .gg/luatools"
                SteamRegNotFound      = "Clé de registre steam introuvable. Est ce que Steam est installé?"
                SteamKilling          = "Arrêt de Steam"
                SteamKilled           = "Steam arreté"
                SteamtoolsFound       = "Steamtools déjà installé"
                SteamtoolsNotFound    = "Steamtools introuvable"
                SteamtoolsInstalling  = "Installation de Steamtools"
                SteamtoolsInstalled   = "Steamtools installé"
                SteamtoolsRetrying    = "L'instalation de Steamtools a echoué, nouvelle tentative..."
                SteamtoolsFailed      = "L'installation de Steamtools a echoué apres 5 tentatives"
                MillenniumNotFound    = "Millennium introuvable"
                MillenniumCountdown   = "Millennium sera installé dans {0} seconde(s)... Appuyez sur une touche pour annuler"
                MillenniumCancelled   = "Installation annuléee par l'utilisateur"
                MillenniumInstalling  = "Installation de Millennium"
                MillenniumInstalled   = "Millennium installé"
                MillenniumAlready     = "Millennium déjà installé"
                MillenniumFirstBoot   = "Le prochain lancement de Steam sera plus long -- laisser le temps."
                PluginUpdating        = "Plugin déjà installé, mise à jour"
                PluginDownloading     = "Installation {0}"
                PluginDownloadFailed  = "Echec de l'installation {0}"
                PluginExtracting      = "Extraction {0}"
                PluginExtractFailed   = "Extraction echouée, tentative avec la fonction native"
                PluginInstalled       = "{0} installé"
                PluginEnabled         = "Plugin activé"
                RemovingBeta          = "Nettoyage de la beta"
                RemovingCfg           = "Nettoyage de steam.cfg"
                RemovingForceX86      = "Nettoyage des registres ForceX86 (32 bits)"
                StartingSteam         = "Lancement de Steam"
                UpdateCheckDisabled   = "Les mises à jour de Millennium ont été désactivée pour éviter les blocages au demarrage."
                UpdateCheckManual     = "Vérifiez manuellement les mises à jour de Millennium si vous souhaitez la derniere version."

                ErrorTitle            = "Installateur Luatools - ERREUR"
                ErrorHeader           = "UNE ERREUR EST SURVENUE"
                ErrorBody             = "L'installation du plugin Luatools a rencontré un problème et n'a pas pu se terminer. Ça se produit souvent quand votre fournisseur d'internet (ISP) bloque les serveurs de téléchargement."
                ErrorFaq              = "Allez voir le serveur (.gg/luatools) pour plus d'informations & corrections."
                ErrorExit             = "Appuyez sur une touche pour quitter."
            }
        }

        foreach ($key in @($Culture, $Culture.Split('-')[0], "en")) {
            if ($tables.ContainsKey($key)) {
                return $tables[$key]
            }
        }
        return $tables["en"]
    }

    # ---------------------------------------------------------------------------
    # Resolve messages based on locale
    # ---------------------------------------------------------------------------
    $DetectedCulture = if ($Script:Culture) { $Script:Culture } else { [System.Globalization.CultureInfo]::CurrentUICulture.Name }
    $L = Get-DefaultStrings -Culture $DetectedCulture

    # ---------------------------------------------------------------------------
    # Global error trap -- catches ANY terminating error and shows error page
    # MUST be placed after $L is populated so error strings are available
    # ---------------------------------------------------------------------------
    $Script:OriginalErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    trap {
        $errMsg = $_.Exception.Message

        # Ensure $L has something even if the hashtable failed
        if (-not $L) { $L = Get-DefaultStrings -Culture "en" }

        $host.UI.RawUI.CursorPosition = @{ X=0; Y=0 }
        $errTitle = if ($L.ContainsKey("ErrorTitle")) { $L["ErrorTitle"] } else { "Luatools installer - ERROR" }
        $host.UI.RawUI.WindowTitle = $errTitle
        Clear-Host

        $width = $host.UI.RawUI.WindowSize.Width

        Write-Host ("=" * $width) -ForegroundColor Red
        Write-Host ""

        $header = if ($L.ContainsKey("ErrorHeader")) { $L["ErrorHeader"] } else { "AN ERROR OCCURRED" }
        $pad = [Math]::Max(0, [int](($width - $header.Length) / 2))
        Write-Host (" " * $pad) -NoNewline
        Write-Host $header -ForegroundColor Red -BackgroundColor Black
        Write-Host ""

        $body = if ($L.ContainsKey("ErrorBody")) { $L["ErrorBody"] } else { "The installer encountered a problem." }
        Write-Host $body -ForegroundColor White
        Write-Host ""

        Write-Host ">>> " -NoNewline -ForegroundColor Yellow
        Write-Host $errMsg -ForegroundColor Gray
        Write-Host ""

        $faq = if ($L.ContainsKey("ErrorFaq")) { $L["ErrorFaq"] } else { "Visit (.gg/luatools)" }
        Write-Host $faq -ForegroundColor Cyan
        Write-Host ""

        Write-Host ("=" * $width) -ForegroundColor Red
        Write-Host ""

        $exitMsg = if ($L.ContainsKey("ErrorExit")) { $L["ErrorExit"] } else { "Press any key to exit." }
        Write-Host $exitMsg -ForegroundColor Yellow
        try { $null = [System.Console]::ReadKey($true) } catch {}

        $ErrorActionPreference = $Script:OriginalErrorAction
        break
    }

    # ---------------------------------------------------------------------------
    # Console helpers
    # ---------------------------------------------------------------------------
    $Host.UI.RawUI.WindowTitle = $L["Title"]

    $LogColors = @{
        "OK"   = "Green"
        "INFO" = "Cyan"
        "ERR"  = "Red"
        "WARN" = "Yellow"
        "LOG"  = "Magenta"
        "AUX"  = "DarkGray"
    }

    function Write-Log {
        param(
            [ValidateSet("OK","INFO","ERR","WARN","LOG","AUX")]
            [string]$Type,
            [string]$Message,
            [switch]$NoNewline
        )
        $color = $LogColors[$Type]
        $ts = Get-Date -Format "HH:mm:ss"
        if ($NoNewline) {
            Write-Host "`r[$ts] " -ForegroundColor Cyan -NoNewline
            Write-Host "[$Type] $Message" -ForegroundColor $color -NoNewline
        } else {
            Write-Host "[$ts] " -ForegroundColor Cyan -NoNewline
            Write-Host "[$Type] $Message" -ForegroundColor $color
        }
    }

    # ---------------------------------------------------------------------------
    # Config -- use the main script's already-resolved $name / $link / $upperName
    # ---------------------------------------------------------------------------
    $Script:Name = $name
    $Script:Link = $link
    $MillenniumTimer  = 5

    # $name and $link are already set correctly by the main script
    # (branch 2 override happens before this block in the main :MainLoop)
    if ($Script:DownloadLink) { $Script:Link = $Script:DownloadLink }
    if ($Script:PluginName)   { $Script:Name = $Script:PluginName }

    $DisplayName = $upperName

    # ---------------------------------------------------------------------------
    # Steam path
    # ---------------------------------------------------------------------------
    function Get-SteamPath {
        $registries = @(
            "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam",
            "HKLM:\SOFTWARE\Valve\Steam",
            "HKCU:\SOFTWARE\Valve\Steam"
        )

        foreach ($reg in $registries) {
            if (!(Test-Path $reg)) { continue }

            $path = (Get-ItemProperty -Path $reg -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
            $potentialExe = Join-Path $path "steam.exe"
            if ((Test-Path $path) -and (Test-Path $potentialExe)) {
                return $path
            }
        }
        Write-Log -Type ERR -Message $L["SteamRegNotFound"]
    }

    # ---------------------------------------------------------------------------
    # Option-8 logic (No Internet / CloudRedirect fixer) — callable as a function
    # so it can be invoked from within the Branch 1 flow after st-setup fallback.
    # ---------------------------------------------------------------------------
    function Invoke-CloudRedirectFix {
        param([string]$SteamPath)

        Write-Log -Type INFO -Message "Running No Internet Connection Fix (CloudRedirect)..."

        $ApiUrl  = "https://api.github.com/repos/Selectively11/CloudRedirect/releases/latest"
        $CliFile = Join-Path $env:TEMP "CloudRedirectCLI.exe"
        $DllFile = Join-Path $env:TEMP "cloud_redirect.dll"

        try {
            $Release  = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing -ErrorAction Stop
            $CliAsset = $Release.assets | Where-Object { $_.name -eq "CloudRedirectCLI.exe" } | Select-Object -First 1
            if ($CliAsset) {
                Write-Log -Type LOG -Message "Downloading CloudRedirectCLI.exe..."
                Invoke-WebRequest -Uri $CliAsset.browser_download_url -OutFile $CliFile -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
                Write-Log -Type OK -Message "CloudRedirectCLI.exe downloaded."
            }
            $DllAsset = $Release.assets | Where-Object { $_.name -eq "cloud_redirect.dll" } | Select-Object -First 1
            if ($DllAsset) {
                Write-Log -Type LOG -Message "Downloading cloud_redirect.dll..."
                Invoke-WebRequest -Uri $DllAsset.browser_download_url -OutFile $DllFile -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
                Write-Log -Type OK -Message "cloud_redirect.dll downloaded."
            }
        } catch {
            Write-Log -Type WARN -Message "CloudRedirect download failed: $($_.Exception.Message)"
            return
        }

        # Run CloudRedirectCLI /stfixer
        for ($i = 3; $i -ge 1; $i--) {
            Write-Log -Type INFO -Message "Starting CloudRedirect fixer in $i..." $true
            Start-Sleep -Seconds 1
        }
        Write-Host ""
        try {
            & $CliFile /stfixer
            Write-Log -Type OK -Message "CloudRedirectCLI completed."
        } catch {
            Write-Log -Type WARN -Message "CloudRedirectCLI error: $($_.Exception.Message)"
        }

        # Install cloud_redirect.dll into Steam folder
        if (![string]::IsNullOrWhiteSpace($SteamPath)) {
            $TargetDll = Join-Path $SteamPath "cloud_redirect.dll"
            try {
                Copy-Item -Path $DllFile -Destination $TargetDll -Force -ErrorAction Stop
                Write-Log -Type OK -Message "cloud_redirect.dll installed."
            } catch {
                Write-Log -Type WARN -Message "Could not install cloud_redirect.dll: $($_.Exception.Message)"
            }
        }

        # Cleanup
        Remove-Item -Path $CliFile -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $DllFile -Force -ErrorAction SilentlyContinue
        Write-Log -Type OK -Message "CloudRedirect fix complete."
    }

    # ---------------------------------------------------------------------------
    # Steamtools -- REQUIRED, no user choice
    # ---------------------------------------------------------------------------
    function Test-Steamtools {
        param([string]$SteamPath)
        foreach ($f in @("dwmapi.dll", "xinput1_4.dll")) {
            if (Test-Path (Join-Path $SteamPath $f)) { return $true }
        }
        return $false
    }

    # Todo: add ost compatibility
    function Install-Steamtools {
        param([string]$SteamPath)

        Write-Log -Type WARN -Message $L["SteamtoolsInstalling"]

        # ---- st.ps1 logic embedded directly (by SelectivelyGood / Potatoes9411) ----
        # Steam is already stopped by the main script before this is called.
        # We do NOT launch Steam here — the main script does that after everything is installed.

        $stLocalPath        = Join-Path $env:LOCALAPPDATA "steam"
        $stSteamRegPath     = 'HKCU:\Software\Valve\Steam'
        $stSteamToolsRegPath = 'HKCU:\Software\Valve\Steamtools'

        function ST-RemoveIfExists($path) {
            if (Test-Path $path) {
                Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
            }
        }

        # Clean up leftover get.ps1
        ST-RemoveIfExists (Join-Path $env:USERPROFILE "get.ps1")

        # Resolve the Steam path from registry (same as st.ps1 does)
        $stSteamPath = $SteamPath
        if ([string]::IsNullOrWhiteSpace($stSteamPath)) {
            if (Test-Path $stSteamRegPath) {
                $props = Get-ItemProperty -Path $stSteamRegPath -ErrorAction SilentlyContinue
                if ($props -and 'SteamPath' -in $props.PSObject.Properties.Name) {
                    $stSteamPath = $props.SteamPath
                }
            }
        }
        if ([string]::IsNullOrWhiteSpace($stSteamPath) -or -not (Test-Path $stSteamPath -PathType Container)) {
            throw $L["SteamtoolsFailed"]
        }

        $stHidPath    = Join-Path $stSteamPath "xinput1_4.dll"
        $stXinputPath = Join-Path $stSteamPath "user32.dll"
        ST-RemoveIfExists $stHidPath
        ST-RemoveIfExists $stXinputPath

        if (-not (Test-Path $stLocalPath)) {
            New-Item $stLocalPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        }

        ST-RemoveIfExists (Join-Path $stSteamPath "steam.cfg")
        ST-RemoveIfExists "$stSteamPath\package\beta"
        ST-RemoveIfExists (Join-Path $env:LOCALAPPDATA "Microsoft\Tencent")

        try { Add-MpPreference -ExclusionPath $stHidPath -ErrorAction SilentlyContinue } catch {}

        ST-RemoveIfExists (Join-Path $stSteamPath "version.dll")

        $downloadHidDll = "http://update.steamcdn.com/update"
        try {
            Invoke-RestMethod -Uri $downloadHidDll -OutFile $stHidPath -ErrorAction Stop
        } catch {
            if (Test-Path $stHidPath) {
                Move-Item -Path $stHidPath -Destination "$stHidPath.old" -Force -ErrorAction SilentlyContinue
                Invoke-RestMethod -Uri $downloadHidDll -OutFile $stHidPath -ErrorAction SilentlyContinue
            }
        }

        $stDwmapiPath    = Join-Path $stSteamPath "dwmapi.dll"
        $downloadDwmapi  = "http://update.steamcdn.com/dwmapi"
        try { Add-MpPreference -ExclusionPath $stDwmapiPath -ErrorAction SilentlyContinue } catch {}
        try {
            Invoke-RestMethod -Uri $downloadDwmapi -OutFile $stDwmapiPath -ErrorAction Stop
        } catch {
            if (Test-Path $stDwmapiPath) {
                Move-Item -Path $stDwmapiPath -Destination "$stDwmapiPath.old" -Force -ErrorAction SilentlyContinue
                Invoke-RestMethod -Uri $downloadDwmapi -OutFile $stDwmapiPath -ErrorAction SilentlyContinue
            }
        }

        if (-not (Test-Path $stSteamToolsRegPath)) {
            New-Item -Path $stSteamToolsRegPath -Force | Out-Null
        }

        Remove-ItemProperty -Path $stSteamToolsRegPath -Name "ActivateUnlockMode"  -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $stSteamToolsRegPath -Name "AlwaysStayUnlocked"  -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $stSteamToolsRegPath -Name "notUnlockDepot"      -ErrorAction SilentlyContinue
        Set-ItemProperty    -Path $stSteamToolsRegPath -Name "iscdkey" -Value "false" -Type String

        # --- Try up to 4 times, then fall back to st-setup installer ---
        $stMaxAttempts = 4
        for ($attempt = 1; $attempt -le $stMaxAttempts; $attempt++) {
            Write-Log -Type LOG -Message "$($L['SteamtoolsInstalling']) (attempt $attempt/$stMaxAttempts)..."
            if (Test-Steamtools $SteamPath) {
                Write-Log -Type OK -Message $L["SteamtoolsInstalled"]
                return
            }
            Write-Log -Type ERR -Message $L["SteamtoolsRetrying"]
            Start-Sleep -Seconds 2
        }

        # All 4 attempts failed — download and run the st-setup installer
        Write-Log -Type WARN -Message "All $stMaxAttempts SteamTools fetch attempts failed. Falling back to st-setup installer..."
        $stSetupUrl  = "https://github.com/Potatoes9411/luatools-installer/releases/download/1.8.30/st-setup-1.8.30.exe"
        $stSetupPath = Join-Path $env:TEMP "st-setup-1.8.30.exe"

        Write-Log -Type LOG -Message "Downloading st-setup-1.8.30.exe..."
        try {
            Invoke-WebRequest -Uri $stSetupUrl -OutFile $stSetupPath -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
            Write-Log -Type OK -Message "st-setup downloaded."
        } catch {
            Write-Log -Type ERR -Message "Failed to download st-setup: $($_.Exception.Message)"
            throw $L["SteamtoolsFailed"]
        }

        Write-Log -Type INFO -Message "Running st-setup — please complete the installer, then close it to continue..."
        $stSetupProc = Start-Process -FilePath $stSetupPath -PassThru
        $stSetupProc.WaitForExit()
        Write-Log -Type OK -Message "st-setup installer closed."
        Remove-Item $stSetupPath -Force -ErrorAction SilentlyContinue

        # After st-setup: run CloudRedirect fix (option 8 logic) before continuing
        Write-Log -Type INFO -Message "Running No Internet Connection Fix (option 8) post-setup..."
        Invoke-CloudRedirectFix -SteamPath $SteamPath

        # Check if SteamTools is now present; if not, throw
        if (-not (Test-Steamtools $SteamPath)) {
            throw $L["SteamtoolsFailed"]
        }
        Write-Log -Type OK -Message $L["SteamtoolsInstalled"]
        # Execution returns here — Main will continue with Install-Millennium next
    }
    # ---------------------------------------------------------------------------
    # Millennium
    # ---------------------------------------------------------------------------
    function Test-Millennium {
        param([string]$SteamPath)
        foreach ($f in @("millennium.dll", "python311.dll")) {
            if (-not (Test-Path (Join-Path $SteamPath $f))) { return $false }
        }
        return $true
    }

    function Install-Millennium {
        param([string]$SteamPath)

        Write-Log -Type INFO -Message $L["MillenniumInstalling"]
        $msUrls = @(
            # "https://github.com/madoiscool/lt_api_links/raw/refs/heads/main/millennium-py.ps1",
            # "https://luatools.vercel.app/millennium-py.ps1",
            "https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1"
        )
        $msCode = $null
        foreach ($url in $msUrls) {
            try {
                $msCode = Invoke-RestMethod $url -TimeoutSec 30
                if ($msCode) { break }
            } catch {}
        }
        if (-not $msCode) { throw $L["MillenniumNotFound"] }
        Invoke-Expression "& { $msCode } -NoLog -DontStart -SteamPath '$SteamPath'"

        if (Test-Millennium $SteamPath) {
            Write-Log -Type OK -Message $L["MillenniumInstalled"]
        }
    }

    # ---------------------------------------------------------------------------
    # Plugin install / update
    # ---------------------------------------------------------------------------
    function Install-Plugin {
        param([string]$SteamPath, [string]$Name, [string]$Link)

        $pluginsDir = Join-Path $millDir "plugins"
        if (-not (Test-Path $pluginsDir)) {
            $null = New-Item -Path $pluginsDir -ItemType Directory -Force
        }

        $targetDir = Join-Path $pluginsDir $Name
        foreach ($dir in (Get-ChildItem $pluginsDir -Directory)) {
            $j = Join-Path $dir.FullName "plugin.json"
            if (Test-Path $j) {
                try {
                    $m = Get-Content $j -Raw -Encoding UTF8 | ConvertFrom-Json
                    if ($m.name -eq $Name) {
                        Write-Log -Type INFO -Message $L["PluginUpdating"]
                        $targetDir = $dir.FullName
                        break
                    }
                } catch {}
            }
        }

        $zipPath = Join-Path $env:TEMP "$Name.zip"

        Write-Log -Type LOG -Message ($L["PluginDownloading"] -f $Name)
        $client = [System.Net.Http.HttpClient]::new()
        $client.Timeout = [System.TimeSpan]::FromSeconds(60)
        $client.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Luatools Installer)")

        $stream = $client.GetStreamAsync($Link).Result
        $fileStream = [System.IO.File]::Create($zipPath)
        $stream.CopyTo($fileStream)

        $fileStream.Close()
        $stream.Close()
        $client.Dispose()

        # Invoke-WebRequest -Uri $Link -OutFile $zipPath -TimeoutSec 60

        if (-not (Test-Path $zipPath)) {
            throw ($L["PluginDownloadFailed"] -f $Name)
        }

        Write-Log -Type LOG -Message ($L["PluginExtracting"] -f $Name)

        # Kill any processes that may be locking files inside the target directory
        $lockKillNames = @("steam","steamwebhelper","steamservice","steamerrorreporter","millennium","millennium.luavm64","GameOverlayUI","steamtours")
        foreach ($lkn in $lockKillNames) {
            Get-Process -Name $lkn -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 1

        $zip = $null
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
            foreach ($entry in $zip.Entries) {
                if ($entry.FullName.EndsWith('/') -or $entry.FullName.EndsWith('\')) { continue }
                $dest   = Join-Path $targetDir $entry.FullName
                $parent = Split-Path $dest -Parent

                $relParts = $parent.Substring($targetDir.Length).TrimStart('\','/') -split '[/\\]' | Where-Object { $_ }
                $cursor = $targetDir
                foreach ($part in $relParts) {
                    $cursor = Join-Path $cursor $part
                    if (Test-Path $cursor) {
                        $item = Get-Item $cursor -ErrorAction SilentlyContinue
                        if ($item -and -not $item.PSIsContainer) {
                            # Retry delete up to 3 times in case file is briefly locked
                            for ($rd = 1; $rd -le 3; $rd++) {
                                try { Remove-Item $cursor -Force -ErrorAction Stop; break } catch { Start-Sleep -Milliseconds 500 }
                            }
                        }
                    }
                }

                $null = [System.IO.Directory]::CreateDirectory($parent)

                # Retry extract up to 3 times in case file is briefly locked
                for ($re = 1; $re -le 3; $re++) {
                    try {
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
                        break
                    } catch {
                        if ($re -eq 3) { throw }
                        Start-Sleep -Milliseconds 500
                    }
                }
            }
            $zip.Dispose()
            $zip = $null
        } catch {
            if ($zip) { $zip.Dispose(); $zip = $null }
            Write-Log -Type WARN -Message $L["PluginExtractFailed"]
            Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force
        }

        if (Test-Path $zipPath) { Remove-Item $zipPath -ErrorAction SilentlyContinue }
        Write-Log -Type OK -Message ($L["PluginInstalled"] -f $DisplayName)
    }

    # ---------------------------------------------------------------------------
    # Config
    # ---------------------------------------------------------------------------
    function Enable-Plugin {
        param([string]$SteamPath, [string]$Name)


        $configDir = Join-Path $millDir "config"
        $configPath = Join-Path $configDir "config.json"
        # Brang back old code cause newest wasn't working for some reason..
        # + Attempt to turn back on updates, hopefully the bug is fixed

        if (-not (Test-Path $configPath)) {
        $config = @{
            plugins = @{
                enabledPlugins = @($name)
            }
            # general = @{
            #     checkForMillenniumUpdates = $false
            # }
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

        # _EnsureProperty $config "general" @{}
        # _EnsureProperty $config "general.checkForMillenniumUpdates" $false
        # $config.general.checkForMillenniumUpdates = $false

        _EnsureProperty $config "plugins" @{ enabledPlugins = @() }
        _EnsureProperty $config "plugins.enabledPlugins" @()

        $pluginsList = @($config.plugins.enabledPlugins)
        if ($pluginsList -notcontains $name) {
            $pluginsList += $name
            $config.plugins.enabledPlugins = $pluginsList
        }

        $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
    }

        Write-Log -Type OK -Message $L["PluginEnabled"]
    }

    # ---------------------------------------------------------------------------
    # Cleanup
    # ---------------------------------------------------------------------------
    function Remove-BetaFlag {
        param([string]$SteamPath)
        $beta = Join-Path $SteamPath "package\beta"
        if (Test-Path $beta) {
            Write-Log -Type AUX -Message $L["RemovingBeta"]
            Remove-Item $beta -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    function Remove-ForceX86Flags {
        Write-Log -Type AUX -Message $L["RemovingForceX86"]
        @("HKCU:\Software\Valve\Steam","HKLM:\SOFTWARE\Valve\Steam","HKLM:\SOFTWARE\WOW6432Node\Valve\Steam") | ForEach-Object {
            Remove-ItemProperty -Path $_ -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
        }
    }

    function Remove-SteamCfg {
        param([string]$SteamPath)
        $cfg = Join-Path $SteamPath "steam.cfg"
        if (Test-Path $cfg) {
            Write-Log -Type AUX -Message $L["RemovingCfg"]
            Remove-Item $cfg -Force -ErrorAction SilentlyContinue
        }
    }

    # ---------------------------------------------------------------------------
    # WPF GUI Installer — Branch 1 / 2
    # Runs in STA mode (spawned child process) so WPF works correctly.
    # ---------------------------------------------------------------------------
    function Main {

        $steamPath = Get-SteamPath
        $script:millDir = Join-Path $steamPath "millennium"
        if (-not (Test-Path $millDir)) {
            $null = New-Item -Path $millDir -ItemType Directory -Force
        }

        # ---- Serialize state for the STA GUI child ----
        $b1Data = @{
            SteamPath   = $steamPath
            MillDir     = $millDir
            Name        = $Script:Name
            UpperName   = $DisplayName
            Link        = $Script:Link
            Branch      = $Script:Branch
            Culture     = $DetectedCulture
        }
        $b1DataFile   = Join-Path $env:TEMP "luatools_b1_data.json"
        $b1DataFile2  = Join-Path $env:TEMP "luatools_b1_done.flag"
        Remove-Item $b1DataFile2 -Force -ErrorAction SilentlyContinue
        $b1Data | ConvertTo-Json -Depth 5 | Set-Content $b1DataFile -Encoding UTF8

        $b1GuiScript = Join-Path $env:TEMP "luatools_b1_gui.ps1"

@"
param(`$DataFile, `$DoneFlag)
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Net.Http
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
`$d        = Get-Content `$DataFile -Raw | ConvertFrom-Json
`$steamPath = `$d.SteamPath
`$millDir   = `$d.MillDir
`$plugName  = `$d.Name
`$plugLink  = `$d.Link
`$culture   = `$d.Culture
`$plugLabel = if (`$plugName -eq "luatools") { "Luatools" } else { `$plugName }

[xml]`$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Luatools Installer  |  .gg/luatools"
        Width="780" Height="660" MinWidth="580" MinHeight="500"
        WindowStartupLocation="CenterScreen"
        Background="#0c0c11" FontFamily="Segoe UI" FontSize="13"
        ResizeMode="CanMinimize">
  <Window.Resources>
    <Style x:Key="ActionBtn" TargetType="Button">
      <Setter Property="Background" Value="#16161f"/>
      <Setter Property="Foreground" Value="#a78bfa"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#2a2a4a"/>
      <Setter Property="Padding" Value="10,6"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="5"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#2a1a4a"/>
                <Setter Property="BorderBrush" Value="#a78bfa"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Background" Value="#0f0f18"/>
                <Setter Property="Foreground" Value="#33334a"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="WarpBtn" TargetType="Button">
      <Setter Property="Background" Value="#1a1a2e"/>
      <Setter Property="Foreground" Value="#6bdc8a"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#2a2a4a"/>
      <Setter Property="Padding" Value="10,6"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="5"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Background" Value="#1c1a2e"/>
                <Setter Property="BorderBrush" Value="#6bdc8a"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="CloseStyle" TargetType="Button">
      <Setter Property="Background" Value="#4f46e5"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding" Value="18,9"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#a78bfa"/></Trigger>
              <Trigger Property="IsEnabled"   Value="False"><Setter Property="Background" Value="#16161f"/><Setter Property="Foreground" Value="#33334a"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- ═══ HEADER ═══ -->
    <Border Grid.Row="0" Background="#0f0f18" Padding="18,14,18,12">
      <Grid>
        <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        <!-- Server icon loaded from Discord CDN (fallback: purple L) -->
        <Border Grid.Column="0" Width="52" Height="52" CornerRadius="14" Background="#1a0a2e" Margin="0,0,14,0" ClipToBounds="True">
          <Grid>
            <TextBlock Text="L" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"
                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
            <Image x:Name="ServerIconImg" Stretch="UniformToFill" RenderOptions.BitmapScalingMode="HighQuality"/>
          </Grid>
        </Border>
        <StackPanel Grid.Column="1" VerticalAlignment="Center">
          <StackPanel Orientation="Horizontal">
            <TextBlock Text="Luatools" FontSize="22" FontWeight="Bold" Foreground="#a78bfa"/>
            <TextBlock Text=" Installer" FontSize="22" FontWeight="Light" Foreground="#44445a"/>
          </StackPanel>
          <TextBlock x:Name="SubTitle" Foreground="#33334a" FontSize="11" Margin="0,2,0,0" TextWrapping="Wrap">Preparing...</TextBlock>
        </StackPanel>
        <StackPanel Grid.Column="2" VerticalAlignment="Center" HorizontalAlignment="Right">
          <Button x:Name="WarpBtn"    Style="{StaticResource WarpBtn}"   Content="☁  Get Cloudflare Warp" Margin="0,0,0,5"/>
          <Button x:Name="DiscordBtn" Style="{StaticResource ActionBtn}" Content="💬  Join Discord (.gg/luatools)" Margin="0,0,0,5"/>
          <Button x:Name="HelpBtn"    Style="{StaticResource ActionBtn}" Content="❓  Get Help" Margin="0,0,0,0"/>
        </StackPanel>
      </Grid>
    </Border>

    <!-- ═══ WHAT THIS DOES info panel ═══ -->
    <Border Grid.Row="1" Background="#12121a" Padding="18,10,18,10" x:Name="InfoPanel">
      <StackPanel>
        <TextBlock Foreground="#33334a" FontSize="10" FontWeight="SemiBold" Margin="0,0,0,6">WHAT THIS INSTALLER DOES — IN ORDER</TextBlock>
        <UniformGrid Columns="2">
          <TextBlock Foreground="#44445a" FontSize="11">① Closes Steam completely</TextBlock>
          <TextBlock Foreground="#44445a" FontSize="11">② Installs SteamTools (xinput1_4.dll + dwmapi.dll)</TextBlock>
          <TextBlock Foreground="#44445a" FontSize="11">③ Installs Millennium (plugin loader)</TextBlock>
          <TextBlock Foreground="#44445a" FontSize="11" x:Name="StepPluginTxt">④ Installs the plugin</TextBlock>
          <TextBlock Foreground="#44445a" FontSize="11">⑤ Enables plugin in Millennium config</TextBlock>
          <TextBlock Foreground="#44445a" FontSize="11">⑥ Cleans up leftover files and relaunches Steam</TextBlock>
        </UniformGrid>
        <Border Background="#16161f" CornerRadius="4" Padding="8,5" Margin="0,8,0,0">
          <TextBlock Foreground="#a78bfa" FontSize="10" TextWrapping="Wrap">
            ⚡  If the installer fails to download anything, install Cloudflare Warp (☁ button top-right) — it bypasses ISP blocks on our servers. It is free.
          </TextBlock>
        </Border>
      </StackPanel>
    </Border>

    <!-- ═══ PROGRESS BAR + STEP LABEL ═══ -->
    <Border Grid.Row="2" Background="#16161f" CornerRadius="0" Padding="18,12,18,12">
      <StackPanel>
        <TextBlock x:Name="StepLabel" Foreground="#c8c8d4" FontWeight="SemiBold" Margin="0,0,0,8" TextWrapping="Wrap">Starting...</TextBlock>
        <ProgressBar x:Name="ProgressBar" Height="8" Minimum="0" Maximum="100" Value="0"
                     Background="#12121a" Foreground="#a78bfa" BorderThickness="0"/>
        <TextBlock x:Name="StepHint" Foreground="#33334a" FontSize="10" Margin="0,5,0,0" TextWrapping="Wrap"/>
      </StackPanel>
    </Border>

    <!-- ═══ LOG BOX ═══ -->
    <Border Grid.Row="3" Background="#0c0c11" Padding="12,10">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
        <TextBox x:Name="LogBox" Background="Transparent" BorderThickness="0"
                 Foreground="#6bdc8a" FontFamily="Cascadia Code, Consolas, monospace"
                 FontSize="11" IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True"/>
      </ScrollViewer>
    </Border>

    <!-- ═══ ERROR PANEL (hidden until error) ═══ -->
    <Border Grid.Row="4" x:Name="ErrorPanel" Background="#1a0808" Padding="18,12" Visibility="Collapsed">
      <StackPanel>
        <TextBlock Foreground="#f87171" FontSize="13" FontWeight="Bold" Margin="0,0,0,6">❌  Installation failed — see log above for details</TextBlock>
        <TextBlock Foreground="#c8c8d4" FontSize="11" TextWrapping="Wrap" Margin="0,0,0,10">
          Most failures are caused by your ISP blocking our download servers. Try these fixes in order:
        </TextBlock>
        <StackPanel Orientation="Horizontal" Margin="0,0,0,6">
          <Button x:Name="ErrWarpBtn"    Style="{StaticResource WarpBtn}"   Content="☁  Install Cloudflare Warp (fixes most issues)" Margin="0,0,8,0"/>
          <Button x:Name="ErrScriptBtn"  Style="{StaticResource ActionBtn}" Content="📋  All-in-One Fix Script" Margin="0,0,8,0"/>
          <Button x:Name="ErrDiscordBtn" Style="{StaticResource ActionBtn}" Content="💬  Get Help on Discord"/>
        </StackPanel>
        <TextBlock Foreground="#33334a" FontSize="10" TextWrapping="Wrap">
          If Cloudflare Warp does not help, join discord.gg/luatools and post your error log. Run the All-in-One Fix Script from potatoes-dev.com/scripts/scmp9guj7b for additional options.
        </TextBlock>
      </StackPanel>
    </Border>

    <!-- ═══ FOOTER ═══ -->
    <Border Grid.Row="5" Background="#0f0f18" Padding="16,10">
      <Grid>
        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        <TextBlock Foreground="#22223a" FontSize="10" VerticalAlignment="Center">
          discord.gg/luatools  |  by Potatoes9411, clem.la, waike + contributors
        </TextBlock>
        <Button x:Name="CloseBtn" Grid.Column="1" Content="Close" IsEnabled="False"
                Style="{StaticResource CloseStyle}" Width="130"/>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

`$reader     = [System.Xml.XmlNodeReader]::new(`$xaml)
`$window     = [System.Windows.Markup.XamlReader]::Load(`$reader)
`$subTitle   = `$window.FindName("SubTitle")
`$stepLabel  = `$window.FindName("StepLabel")
`$stepHint   = `$window.FindName("StepHint")
`$progressBar = `$window.FindName("ProgressBar")
`$logBox     = `$window.FindName("LogBox")
`$logScroll  = `$window.FindName("LogScroll")
`$closeBtn   = `$window.FindName("CloseBtn")
`$errorPanel = `$window.FindName("ErrorPanel")
`$warpBtn    = `$window.FindName("WarpBtn")
`$discordBtn = `$window.FindName("DiscordBtn")
`$helpBtn    = `$window.FindName("HelpBtn")
`$errWarpBtn = `$window.FindName("ErrWarpBtn")
`$errScriptBtn=`$window.FindName("ErrScriptBtn")
`$errDiscBtn = `$window.FindName("ErrDiscordBtn")
`$stepPlugTxt= `$window.FindName("StepPluginTxt")
`$serverIcon = `$window.FindName("ServerIconImg")
`$stepPlugTxt.Text = "④ Installs the `$plugLabel plugin"
`$subTitle.Text = "Installing: `$plugLabel  |  Steam: `$steamPath"

# ── Load server icon synchronously on STA thread before ShowDialog ────────────
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    `$iconUrl = "https://cdn.discordapp.com/icons/1408201417834893385/f5c9265968b03ac3e554063df0aa1d03.png?size=256"
    `$iconBytes = `$null
    try {
        `$r = Invoke-WebRequest -Uri `$iconUrl -UseBasicParsing -TimeoutSec 10 `
             -Headers @{"User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"} -EA Stop
        `$iconBytes = [byte[]]`$r.Content
    } catch {
        `$wc = [System.Net.WebClient]::new()
        `$wc.Headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        `$iconBytes = `$wc.DownloadData(`$iconUrl); `$wc.Dispose()
    }
    if (`$iconBytes -and `$iconBytes.Length -gt 0) {
        `$ms = [System.IO.MemoryStream]::new(`$iconBytes)
        `$bmp = [System.Windows.Media.Imaging.BitmapImage]::new()
        `$bmp.BeginInit()
        `$bmp.StreamSource = `$ms
        `$bmp.CacheOption  = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        `$bmp.EndInit()
        `$ms.Dispose()
        `$serverIcon.Source = `$bmp
    }
} catch {}

function GLog([string]`$msg) {
    `$window.Dispatcher.Invoke([action]{
        `$logBox.AppendText("`$msg``n")
        `$logScroll.ScrollToBottom()
    })
}
function GStep([string]`$msg, [int]`$pct, [string]`$hint = "") {
    `$window.Dispatcher.Invoke([action]{
        `$stepLabel.Text    = `$msg
        `$progressBar.Value = `$pct
        `$stepHint.Text     = `$hint
    })
}
function GError {
    `$window.Dispatcher.Invoke([action]{
        `$progressBar.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xf8,0x71,0x71))
        `$errorPanel.Visibility  = [System.Windows.Visibility]::Visible
        `$closeBtn.IsEnabled     = `$true
    })
}
function GDone {
    `$window.Dispatcher.Invoke([action]{
        `$stepLabel.Text         = "✅  Done! Steam is launching..."
        `$progressBar.Value      = 100
        `$progressBar.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xa7,0x8b,0xfa))
        `$closeBtn.IsEnabled     = `$true
    })
}

`$closeBtn.Add_Click({    `$window.Close() })
`$warpBtn.Add_Click({     try { Start-Process "https://one.one.one.one/" } catch {} })
`$discordBtn.Add_Click({  try { Start-Process "https://discord.gg/luatools" } catch {} })
`$helpBtn.Add_Click({     try { Start-Process "https://discord.gg/luatools" } catch {} })
`$errWarpBtn.Add_Click({  try { Start-Process "https://one.one.one.one/" } catch {} })
`$errScriptBtn.Add_Click({ try { Start-Process "https://potatoes-dev.com/scripts/scmp9guj7b" } catch {} })
`$errDiscBtn.Add_Click({  try { Start-Process "https://discord.gg/luatools" } catch {} })

`$t = [System.Threading.Thread]::new([System.Threading.ThreadStart]({
    try {

        # ── ① Kill Steam ──────────────────────────────────────────────────────
        GStep "① Stopping Steam..." 5 "Closing all Steam processes before installing..."
        GLog "[INFO] Stopping Steam processes..."
        `$killNames = @("steam","steamwebhelper","steamservice","steamerrorreporter","millennium","millennium.luavm64","GameOverlayUI","steamtours")
        foreach (`$kn in `$killNames) { Get-Process -Name `$kn -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue }
        Start-Sleep 2
        foreach (`$kn in `$killNames) { Get-Process -Name `$kn -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue }
        Start-Sleep -Milliseconds 500
        GLog "[OK]   Steam stopped."

        # ── Helpers ───────────────────────────────────────────────────────────
        function ST-Rm(`$p) { if (Test-Path `$p) { Remove-Item `$p -Force -EA SilentlyContinue } }
        function Test-ST([string]`$sp) {
            foreach (`$f in @("dwmapi.dll","xinput1_4.dll")) { if (Test-Path (Join-Path `$sp `$f)) { return `$true } }
            return `$false
        }

        # ── ② SteamTools ──────────────────────────────────────────────────────
        GStep "② Installing SteamTools..." 15 "Downloading xinput1_4.dll and dwmapi.dll from SteamTools servers..."
        if (Test-ST `$steamPath) {
            GLog "[OK]   SteamTools already installed — skipping download."
        } else {
            GLog "[WARN] SteamTools not found — installing..."
            `$stReg    = 'HKCU:\Software\Valve\Steam'
            `$stTReg   = 'HKCU:\Software\Valve\Steamtools'
            `$localSt  = Join-Path `$env:LOCALAPPDATA "steam"
            if (-not (Test-Path `$localSt)) { New-Item `$localSt -ItemType Directory -Force | Out-Null }
            ST-Rm (Join-Path `$steamPath "xinput1_4.dll"); ST-Rm (Join-Path `$steamPath "user32.dll")
            ST-Rm (Join-Path `$steamPath "steam.cfg");    ST-Rm "`$steamPath\package\beta"
            ST-Rm (Join-Path `$env:LOCALAPPDATA "Microsoft\Tencent")
            ST-Rm (Join-Path `$steamPath "version.dll")
            `$hidPath = Join-Path `$steamPath "xinput1_4.dll"
            `$dwmPath = Join-Path `$steamPath "dwmapi.dll"
            try { Add-MpPreference -ExclusionPath `$hidPath -EA SilentlyContinue } catch {}
            try { Add-MpPreference -ExclusionPath `$dwmPath -EA SilentlyContinue } catch {}
            `$stOk = `$false
            for (`$att = 1; `$att -le 4; `$att++) {
                GStep "② SteamTools — attempt `$att / 4..." (15 + `$att * 3) "Downloading from update.steamcdn.com..."
                GLog "[LOG]  Attempt `$att / 4 — downloading DLLs..."
                try {
                    Invoke-RestMethod "http://update.steamcdn.com/update" -OutFile `$hidPath -EA Stop
                    Invoke-RestMethod "http://update.steamcdn.com/dwmapi" -OutFile `$dwmPath -EA Stop
                } catch { GLog "[WARN] Attempt `$att download error: `$(`$_.Exception.Message)" }
                if (Test-ST `$steamPath) { `$stOk = `$true; GLog "[OK]   SteamTools DLLs installed on attempt `$att."; break }
                GLog "[WARN] Attempt `$att — DLLs not confirmed yet, retrying in 2s..."
                Start-Sleep 2
            }

            if (-not `$stOk) {
                GStep "② Downloading st-setup fallback installer..." 32 "All 4 attempts failed — downloading the SteamTools setup EXE..."
                GLog "[WARN] All 4 DLL download attempts failed. Falling back to st-setup installer..."
                `$setupUrl  = "https://github.com/Potatoes9411/luatools-installer/releases/download/1.8.30/st-setup-1.8.30.exe"
                `$setupPath = Join-Path `$env:TEMP "st-setup-1.8.30.exe"
                try {
                    Invoke-WebRequest `$setupUrl -OutFile `$setupPath -UseBasicParsing -TimeoutSec 120 -EA Stop
                    GLog "[OK]   st-setup-1.8.30.exe downloaded."
                } catch {
                    GLog "[ERR]  Failed to download st-setup: `$(`$_.Exception.Message)"
                    throw "SteamTools installation failed — could not download st-setup."
                }
                `$window.Dispatcher.Invoke([action]{
                    `$stepLabel.Text   = "② Complete the SteamTools installer window that just opened, then close it to continue..."
                    `$progressBar.Value = 36
                    `$stepHint.Text    = "👆  A separate installer window has opened. Follow its steps, then close it. The installer will continue automatically."
                })
                GLog "[INFO] Running st-setup — complete and close the installer window to continue here..."
                `$proc = Start-Process `$setupPath -PassThru; `$proc.WaitForExit()
                GLog "[OK]   st-setup installer closed."
                Remove-Item `$setupPath -Force -EA SilentlyContinue

                GStep "② Running No Internet Connection Fix (CloudRedirect)..." 40 "Running CloudRedirectCLI /stfixer to fix server routing..."
                GLog "[INFO] Running CloudRedirect fix (option 8 logic) post-setup..."
                `$apiUrl  = "https://api.github.com/repos/Selectively11/CloudRedirect/releases/latest"
                `$cliFile = Join-Path `$env:TEMP "CloudRedirectCLI.exe"
                `$dllFile = Join-Path `$env:TEMP "cloud_redirect.dll"
                try {
                    `$rel = Invoke-RestMethod `$apiUrl -UseBasicParsing -EA Stop
                    `$cla = `$rel.assets | Where-Object { `$_.name -eq "CloudRedirectCLI.exe" } | Select-Object -First 1
                    `$dla = `$rel.assets | Where-Object { `$_.name -eq "cloud_redirect.dll"  } | Select-Object -First 1
                    if (`$cla) { Invoke-WebRequest `$cla.browser_download_url -OutFile `$cliFile -UseBasicParsing -TimeoutSec 60 -EA Stop; GLog "[OK]   CloudRedirectCLI.exe downloaded." }
                    if (`$dla) { Invoke-WebRequest `$dla.browser_download_url -OutFile `$dllFile -UseBasicParsing -TimeoutSec 60 -EA Stop; GLog "[OK]   cloud_redirect.dll downloaded." }
                    Start-Sleep 1; & `$cliFile /stfixer; GLog "[OK]   CloudRedirectCLI /stfixer done."
                    `$tgt = Join-Path `$steamPath "cloud_redirect.dll"
                    if (Test-Path `$dllFile) { Copy-Item `$dllFile `$tgt -Force -EA SilentlyContinue; GLog "[OK]   cloud_redirect.dll installed to Steam folder." }
                    Remove-Item `$cliFile -Force -EA SilentlyContinue; Remove-Item `$dllFile -Force -EA SilentlyContinue
                    GLog "[OK]   CloudRedirect fix complete."
                } catch { GLog "[WARN] CloudRedirect fix failed: `$(`$_.Exception.Message) — continuing anyway." }
            }

            if (-not (Test-Path `$stTReg)) { New-Item -Path `$stTReg -Force | Out-Null }
            Remove-ItemProperty -Path `$stTReg -Name "ActivateUnlockMode" -EA SilentlyContinue
            Remove-ItemProperty -Path `$stTReg -Name "AlwaysStayUnlocked" -EA SilentlyContinue
            Remove-ItemProperty -Path `$stTReg -Name "notUnlockDepot"     -EA SilentlyContinue
            Set-ItemProperty    -Path `$stTReg -Name "iscdkey" -Value "false" -Type String
        }

        # ── ③ Millennium ──────────────────────────────────────────────────────
        GStep "③ Installing Millennium..." 55 "Downloading Millennium (the plugin loader that hosts Luatools) from steambrew.app..."
        GLog "[INFO] Downloading and running Millennium installer (silent)..."
        `$msCode = `$null
        try { `$msCode = Invoke-RestMethod "https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1" -TimeoutSec 30 } catch { GLog "[WARN] Millennium download failed: `$(`$_.Exception.Message)" }
        if (`$msCode) {
            Invoke-Expression "& { `$msCode } -NoLog -DontStart -SteamPath '`$steamPath'"
            GLog "[OK]   Millennium installed."
        } else { GLog "[WARN] Millennium installer could not be downloaded — Millennium may already be installed or install may be incomplete." }

        # ── ④ Plugin ──────────────────────────────────────────────────────────
        GStep "④ Downloading plugin: `$plugName..." 70 "Downloading the plugin zip and extracting it into Millennium's plugins folder..."
        GLog "[INFO] Downloading plugin: `$plugName from `$plugLink"
        `$pluginsDir = Join-Path `$millDir "plugins"
        if (-not (Test-Path `$pluginsDir)) { New-Item `$pluginsDir -ItemType Directory -Force | Out-Null }
        `$targetDir = Join-Path `$pluginsDir `$plugName
        foreach (`$dir in (Get-ChildItem `$pluginsDir -Directory -EA SilentlyContinue)) {
            `$jf = Join-Path `$dir.FullName "plugin.json"
            if (Test-Path `$jf) {
                try { `$m = Get-Content `$jf -Raw | ConvertFrom-Json; if (`$m.name -eq `$plugName) { `$targetDir = `$dir.FullName; GLog "[INFO] Plugin already exists — updating in place."; break } } catch {}
            }
        }
        `$zipPath = Join-Path `$env:TEMP "`$plugName.zip"
        `$client  = [System.Net.Http.HttpClient]::new(); `$client.Timeout = [TimeSpan]::FromSeconds(60)
        `$client.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Luatools Installer)")
        `$stream = `$client.GetStreamAsync(`$plugLink).Result
        `$fs = [IO.File]::Create(`$zipPath); `$stream.CopyTo(`$fs); `$fs.Close(); `$stream.Close(); `$client.Dispose()
        GLog "[LOG]  Plugin downloaded — extracting..."
        `$zip = [IO.Compression.ZipFile]::OpenRead(`$zipPath)
        foreach (`$entry in `$zip.Entries) {
            if (`$entry.FullName.EndsWith('/') -or `$entry.FullName.EndsWith('\')) { continue }
            `$dest = Join-Path `$targetDir `$entry.FullName
            [IO.Directory]::CreateDirectory((Split-Path `$dest -Parent)) | Out-Null
            for (`$re = 1; `$re -le 3; `$re++) {
                try { [IO.Compression.ZipFileExtensions]::ExtractToFile(`$entry, `$dest, `$true); break }
                catch { if (`$re -eq 3) { throw }; Start-Sleep -Milliseconds 500 }
            }
        }
        `$zip.Dispose()
        if (Test-Path `$zipPath) { Remove-Item `$zipPath -EA SilentlyContinue }
        GLog "[OK]   Plugin extracted to: `$targetDir"

        # ── ⑤ Enable plugin ───────────────────────────────────────────────────
        GStep "⑤ Enabling plugin in Millennium config..." 85 "Writing plugin name to Millennium's config.json enabled plugins list..."
        `$cfgDir  = Join-Path `$millDir "config"; `$cfgPath = Join-Path `$cfgDir "config.json"
        if (-not (Test-Path `$cfgPath)) {
            New-Item -Path `$cfgDir -ItemType Directory -Force | Out-Null
            @{ plugins = @{ enabledPlugins = @(`$plugName) } } | ConvertTo-Json -Depth 10 | Set-Content `$cfgPath -Encoding UTF8
        } else {
            `$cfg = (Get-Content `$cfgPath -Raw) | ConvertFrom-Json
            if (-not `$cfg.plugins) { `$cfg | Add-Member -MemberType NoteProperty -Name plugins -Value @{ enabledPlugins = @() } -Force }
            `$pl = @(`$cfg.plugins.enabledPlugins)
            if (`$pl -notcontains `$plugName) { `$pl += `$plugName; `$cfg.plugins.enabledPlugins = `$pl }
            `$cfg | ConvertTo-Json -Depth 10 | Set-Content `$cfgPath -Encoding UTF8
        }
        GLog "[OK]   Plugin enabled in config."

        # ── ⑥ Cleanup + launch ────────────────────────────────────────────────
        GStep "⑥ Cleaning up and launching Steam..." 94 "Removing leftover files (steam.cfg, beta flag, ForceX86 registry keys)..."
        `$betaF = Join-Path `$steamPath "package\beta"; if (Test-Path `$betaF) { Remove-Item `$betaF -Recurse -Force -EA SilentlyContinue }
        `$cfgF  = Join-Path `$steamPath "steam.cfg";    if (Test-Path `$cfgF)  { Remove-Item `$cfgF  -Force -EA SilentlyContinue }
        @("HKCU:\Software\Valve\Steam","HKLM:\SOFTWARE\Valve\Steam","HKLM:\SOFTWARE\WOW6432Node\Valve\Steam") | ForEach-Object {
            Remove-ItemProperty -Path `$_ -Name "SteamCmdForceX86" -EA SilentlyContinue
        }
        GLog "[OK]   Cleanup done."
        GLog "[INFO] Starting Steam..."
        Start-Process (Join-Path `$steamPath "steam.exe") -ArgumentList "-clearbeta"
        GLog "[OK]   Steam launched. First boot after a new Millennium install may take an extra 10-20 seconds — this is normal."
        GLog "[OK]   ✅  All done! You can close this window."
        "done" | Set-Content `$DoneFlag -Encoding UTF8
        GDone

    } catch {
        GLog "[ERR]  FATAL: `$(`$_.Exception.Message)"
        `$window.Dispatcher.Invoke([action]{
            `$stepLabel.Text = "❌  Installation failed — see log and error panel below."
        })
        GError
    }
    }.GetNewClosure()))
`$t.IsBackground = `$true
`$t.Start()

`$window.ShowDialog() | Out-Null
"@ | Set-Content $b1GuiScript -Encoding UTF8

        Write-Log -Type INFO -Message "Launching GUI installer (STA mode)..."
        $b1Proc = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$b1GuiScript`" -DataFile `"$b1DataFile`" -DoneFlag `"$b1DataFile2`"" `
            -Wait -PassThru
        Remove-Item $b1GuiScript  -Force -ErrorAction SilentlyContinue
        Remove-Item $b1DataFile   -Force -ErrorAction SilentlyContinue
        Remove-Item $b1DataFile2  -Force -ErrorAction SilentlyContinue

        $ErrorActionPreference = $Script:OriginalErrorAction
    }

    Main
    $Branch = 0

    # By clem
    # Waike contributed a lot

} # end if Branch 1 or 2

} # end :MainLoop
