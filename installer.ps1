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

    Blank
    Write-Host ("  {0,-2}  {1}" -f "L", (Translate "Language / Idioma / Português")) -ForegroundColor Cyan
    Write-Host ("  {0,-2}  {1}" -f "Q", (Translate "Quit")) -ForegroundColor DarkGray
    Blank
}

if (-not $Branch) {
    while ($true) {
        Write-MainMenu
        $sel = Ask "Select an option"
        switch ($sel.Trim().ToUpper()) {
            "1" { $Branch = 1; break }
            "2" { $Branch = 2; break }
            "3" { $Branch = 3; break }
            "4" { $Branch = 4; break }
            "5" { $Branch = 5; break }
            "6" {
                $Branch = 6
                $defChoice = Ask "Skip Windows Defender exclusions? (y/N)"
                if ($defChoice.Trim() -ieq "y") { $SkipDefender = $true }
                break
            }
            "7" { $Branch = 7; break }
            "8" { $Branch = 8; break }
            "9" { $Branch = 9; break }
            "10" { $Branch = 10; break }
            "L" { Set-Language; continue }
            "Q" { exit 0 }
            default { continue }
        }
        if ($Branch -ne 0) { break }
    }
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
    Log "INFO" "Spacetheme Block Remover"
    Log "AUX"  "Removes the 'get a job loser' text blocking your Steam client."
    Log "AUX"  "Credit: waike (waike.dev)"
    Blank

    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if (-not $steamPath -or -not (Test-Path $steamPath)) {
        Log "ERR" "Steam not found."
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Find all possible Spacetheme roots
    $themeRoots = @()
    $possibleRoots = @(
        "$steamPath\steamui\skins\Steam",
        "$steamPath\steamui\skins\spacetheme",
        "$steamPath\millennium\themes",
        "$steamPath\millennium\themes\Steam",
        "C:\Program Files (x86)\Steam\millennium\themes",
        "C:\Program Files (x86)\Steam\millennium\themes\Steam",
        "C:\Program Files\Steam\millennium\themes",
        "C:\Program Files\Steam\millennium\themes\Steam"
    )
    
    foreach ($root in $possibleRoots) {
        if (Test-Path $root) { $themeRoots += $root }
    }

    if ($themeRoots.Count -eq 0) {
        Log "ERR" "Spacetheme was not found in any standard location."
        Read-Host "Press Enter to exit"
        exit 1
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
    $patchedCount = 0

    foreach ($root in $themeRoots) {
        foreach ($cssFile in Get-ChildItem -Path $root -Recurse -Filter "*.css" -ErrorAction SilentlyContinue) {
            $content = Get-Content $cssFile.FullName -Raw
            if ($content -match $pattern) {
                $content = $content -replace $pattern, '/* Patched piracy warning block */'
                Set-Content -Path $cssFile.FullName -Value $content -NoNewline -Encoding UTF8
                $patchedCount++
                Log "OK" "Patched $($cssFile.Name)"
            }
        }
    }

    if ($patchedCount -gt 0) {
        Log "OK" "Patched $patchedCount CSS file(s)"
    } else {
        Log "INFO" "Nothing to patch — block may already be removed."
    }

    Blank
    Read-Host "Press Enter to exit"
    exit
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
    Read-Host "Press Enter to exit"
    exit
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
        Blank; Read-Host "Press Enter to exit"
        exit 1
    }

    function Test-PluginInstalled {
        $dir = Join-Path $steam "plugins"
        if (-not (Test-Path $dir)) { return $false }
        foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
            $jp = Join-Path $p.FullName "plugin.json"
            if (Test-Path $jp) {
                $j = try { Get-Content $jp -Raw | ConvertFrom-Json } catch { $null }
                if ($j -and $j.name -eq $name) { return $true }
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

        $dir = Join-Path $steam "plugins"
        if (-not (Test-Path $dir)) { Log "WARN" "Plugins directory not found."; return }

        $pluginPath = $null
        foreach ($p in Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue) {
            $jp = Join-Path $p.FullName "plugin.json"
            if (Test-Path $jp) {
                $j = try { Get-Content $jp -Raw | ConvertFrom-Json } catch { $null }
                if ($j -and $j.name -eq $name) { $pluginPath = $p.FullName; break }
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
    Read-Host "Press Enter to exit"
    exit
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
    $Host.UI.RawUI.WindowTitle = "CloudRedirect Installer | .gg/luatools"

    # ---- Branch 8: CloudRedirect Installer (by SelectivelyGood | Script by Peron) ----

    # ==============================
    # CloudRedirect Installer
    # ==============================
    $Host.UI.RawUI.WindowTitle = "CloudRedirect Installer | .gg/luatools"

    # ===================== LOGGING =====================
    function Log {
        param (
            [string]$Type,
            [string]$Message,
            [boolean]$NoNewline = $false
        )
        $Type = $Type.ToUpper()
        $color = switch ($Type) {
            "OK"   { "Green" }
            "INFO" { "Cyan" }
            "ERR"  { "Red" }
            "WARN" { "Yellow" }
            "LOG"  { "Magenta" }
            default { "White" }
        }
        $date = Get-Date -Format "HH:mm:ss"
        $prefix = if ($NoNewline) { "`r[$date] " } else { "[$date] " }
        Write-Host $prefix -ForegroundColor Cyan -NoNewline
        Write-Host "[$Type] $Message" -ForegroundColor $color -NoNewline:$NoNewline
    }

    # ===================== STEAM DETECTION =====================
    Log "INFO" "Searching for Steam installation..."

    function Find-SteamPath {
        $PossiblePaths = @()
        try {
            $reg = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue
            if ($reg.InstallPath) { $PossiblePaths += $reg.InstallPath }
        } catch {}

        try {
            $reg = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue
            if ($reg.SteamPath) { $PossiblePaths += $reg.SteamPath -replace '\\\\', '\' }
        } catch {}

        $DefaultPath = "C:\Program Files (x86)\Steam"
        if (Test-Path $DefaultPath) { $PossiblePaths += $DefaultPath }

        $PossiblePaths = $PossiblePaths | Select-Object -Unique | Where-Object { Test-Path $_ }

        if ($PossiblePaths.Count -eq 0) {
            Log "ERR" "Steam installation not found. Please install Steam first."
            exit 1
        }

        $SteamPath = $PossiblePaths[0]
        Log "OK" "Steam found at: $SteamPath"
        return $SteamPath
    }

    $steam = Find-SteamPath

    # ===================== CLOSE STEAM =====================
    Log "INFO" "Closing Steam if running..."
    Get-Process -Name "steam" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 3
    Write-Host ""

    # ===================== DOWNLOAD LATEST FILES =====================
    Log "INFO" "Fetching latest CloudRedirect files..."

    $ApiUrl = "https://api.github.com/repos/Selectively11/CloudRedirect/releases/latest"
    $CliFile = Join-Path $env:TEMP "CloudRedirectCLI.exe"
    $DllFile = Join-Path $env:TEMP "cloud_redirect.dll"

    try {
        $Release = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing -ErrorAction Stop
        Log "LOG" "Latest version: $($Release.tag_name)"

        # Download CloudRedirectCLI.exe
        $CliAsset = $Release.assets | Where-Object { $_.name -eq "CloudRedirectCLI.exe" } | Select-Object -First 1
        if ($CliAsset) {
            Log "LOG" "Downloading CloudRedirectCLI.exe..."
            Invoke-WebRequest -Uri $CliAsset.browser_download_url -OutFile $CliFile -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
            Log "OK" "CloudRedirectCLI.exe downloaded"
        }

        # Download cloud_redirect.dll
        $DllAsset = $Release.assets | Where-Object { $_.name -eq "cloud_redirect.dll" } | Select-Object -First 1
        if ($DllAsset) {
            Log "LOG" "Downloading cloud_redirect.dll..."
            Invoke-WebRequest -Uri $DllAsset.browser_download_url -OutFile $DllFile -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
            Log "OK" "cloud_redirect.dll downloaded"
        }
    }
    catch {
        Log "ERR" "Failed to download latest files"
        Log "ERR" $_.Exception.Message
        exit 1
    }

    # ===================== EXECUTE CLI =====================
    for ($i = 5; $i -ge 1; $i--) {
        Log "INFO" "Starting CloudRedirect Fixer in $i second$(if($i -gt 1){'s'})..." $true
        Start-Sleep -Seconds 1
    }
    Write-Host ""

    Log "INFO" "Running CloudRedirect Fixer..."
    try {
        & $CliFile /stfixer
        Log "OK" "CloudRedirectCLI executed successfully"
    }
    catch {
        Log "ERR" "Error while executing CloudRedirectCLI"
        Log "ERR" $_.Exception.Message
    }

    # ===================== INSTALL DLL =====================
    Log "INFO" "Installing cloud_redirect.dll to Steam folder..."
    $TargetDll = Join-Path $steam "cloud_redirect.dll"

    try {
        Copy-Item -Path $DllFile -Destination $TargetDll -Force -ErrorAction Stop
        Log "OK" "cloud_redirect.dll installed successfully"
    }
    catch {
        Log "ERR" "Failed to copy cloud_redirect.dll"
        Log "ERR" $_.Exception.Message
    }

    # ===================== CLEANUP =====================
    Start-Sleep -Seconds 2
    Log "INFO" "Cleaning temporary files..."
    Remove-Item -Path $CliFile -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $DllFile -Force -ErrorAction SilentlyContinue
    Log "OK" "Temporary files removed"

    Write-Host ""

    # ===================== FINAL =====================
    Log "OK" "Operation completed successfully!"
    Log "WARN" "Steam startup may take longer than usual."
    Write-Host ""

    $exe = Join-Path $steam "steam.exe"
    if (Test-Path $exe) {
        Log "INFO" "Starting Steam..."
        Start-Process $exe -ArgumentList "-clearbeta"
    }

    Write-Host ""
    Log "INFO" "Press any key to close this window..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit

    # ---- Return to main menu after Branch 8 ----
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

    # Configuration -- edit these before running, or override via env vars:
    #   $env:LT_DOWNLOAD_LINK, $env:LT_PLUGIN_NAME, $env:LT_BRANCH, $env:LT_CULTURE
    $Script:DownloadLink = $env:LT_DOWNLOAD_LINK
    $Script:PluginName   = $env:LT_PLUGIN_NAME
    $Script:Branch       = if ($env:LT_BRANCH) { [int]$env:LT_BRANCH } else { 1 }
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
    # Config
    # ---------------------------------------------------------------------------
    $Script:Name      = "luatools"
    $Script:Link      = "https://github.com/piqseu/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"
    $MillenniumTimer  = 5

    if ($Script:Branch -eq 2) {
        $Script:Name = "steamtools-collection"
        $Script:Link = "https://github.com/clemdotla/steamtools-collection/releases/download/Latest/steamtools-collection.zip"
    }
    if ($Script:DownloadLink) { $Script:Link = $Script:DownloadLink }
    if ($Script:PluginName)   { $Script:Name = $Script:PluginName }

    $DisplayName = $Script:Name.Substring(0,1).ToUpper() + $Script:Name.Substring(1).ToLower()

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

        $raw   = Invoke-RestMethod "https://luatools.vercel.app/st.ps1" -TimeoutSec 30
        if (!($raw)) {
            $raw = Invoke-Expression (curl.exe -s --doh-url https://1.1.1.1/dns-query https://luatools.vercel.app/st.ps1 | Out-String)
            if (!($raw)) {
                throw $L["SteamtoolsFailed"]
            }
        }
        $lines = $raw -split "`n"

        $filtered = $lines | Where-Object {
            ($_ -inotmatch "Start-Process.*steam") -and
            ($_ -inotmatch "steam\.exe")           -and
            ($_ -inotmatch "Start-Sleep|Write-Host") -and
            ($_ -inotmatch "cls|exit")             -and
            (-not ($_ -imatch "Stop-Process" -and $_ -inotmatch "Get-Process"))
        }

        $scriptBlock = $filtered -join "`n"

        for ($attempt = 1; $attempt -le 5; $attempt++) {
            Write-Log -Type LOG -Message $L["SteamtoolsInstalling"]
            Invoke-Expression $scriptBlock *> $null
            if (Test-Steamtools $SteamPath) {
                Write-Log -Type OK -Message $L["SteamtoolsInstalled"]
                return
            }
            Write-Log -Type ERR -Message $L["SteamtoolsRetrying"]
        }

        throw $L["SteamtoolsFailed"]
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

        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
            foreach ($entry in $zip.Entries) {
                if ($entry.FullName.EndsWith('/') -or $entry.FullName.EndsWith('\')) { continue }
                $dest   = Join-Path $targetDir $entry.FullName
                $parent = Split-Path $dest -Parent

                $relParts = $parent.Substring($targetDir.Length).TrimStart('\','/') -split '[\\/]' | Where-Object { $_ }
                $cursor = $targetDir
                foreach ($part in $relParts) {
                    $cursor = Join-Path $cursor $part
                    if (Test-Path $cursor) {
                        $item = Get-Item $cursor
                        if (-not $item.PSIsContainer) { Remove-Item $cursor -Force }
                    }
                }

                $null = [System.IO.Directory]::CreateDirectory($parent)
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
            }
            $zip.Dispose()
        } catch {
            if ($zip) { $zip.Dispose() }
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
    # Main
    # ---------------------------------------------------------------------------
    function Main {

        $steamPath = Get-SteamPath
        $script:millDir = Join-Path $steamPath "millennium"
        if (-not (Test-Path $millDir)) {
            $null = New-Item -Path $millDir -ItemType Directory -Force
        }

        Write-Log -Type INFO -Message $L["SteamKilling"]
        while (Get-Process steam -ErrorAction SilentlyContinue) {
            Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep -Milliseconds 500
        }

        if (Test-Steamtools $steamPath) {
            Write-Log -Type INFO -Message $L["SteamtoolsFound"]
        } else {
            Write-Log -Type ERR -Message $L["SteamtoolsNotFound"]
            Install-Steamtools $steamPath
        }

        # Temporary (or not) forcing to get stable lua only backend
        # $millenniumWasInstalled = Test-Millennium $steamPath
        # if ($millenniumWasInstalled) {
        #     Write-Log -Type INFO -Message $L["MillenniumAlready"]
        # }
        Install-Millennium $steamPath

        Install-Plugin $steamPath $Script:Name $Script:Link

        Remove-BetaFlag $steamPath
        Remove-SteamCfg $steamPath
        Remove-ForceX86Flags

        Enable-Plugin $steamPath $Script:Name

        Write-Host
        if (-not $millenniumWasInstalled) {
            Write-Log -Type WARN -Message $L["MillenniumFirstBoot"]
        }
        # Write-Log -Type WARN -Message $L["UpdateCheckDisabled"]
        # Write-Log -Type OK   -Message $L["UpdateCheckManual"]

        Write-Log -Type INFO -Message $L["StartingSteam"]
        Start-Process (Join-Path $steamPath "steam.exe") -ArgumentList "-clearbeta"
        $ErrorActionPreference = $Script:OriginalErrorAction
    }

    Main

    # By clem
    # Waike contributed a lot

} # end if Branch 1 or 2

} # end :MainLoop
