Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

$serverInstance = $settings.serverInstance

$installationMedia = $settings.MicrosoftAppPath
$BeTernaAppPath = $settings.BeTernaAppPath
$archivePath = $settings.BeTernaArchive
$customAppPath = $settings.outputFolder
$appsArray = $settings.appList.Split(';').Trim()

$devLicence = Get-ChildItem $settings.devLicence -Filter '*.flf'
$clientLicence = Get-ChildItem $settings.clientLicence -Filter '*.flf'

Import-Module $settings.NavAdminToolPath

Sync-NAVTenant -ServerInstance $serverInstance

Import-NAVServerLicense $serverInstance -LicenseData ([Byte[]]$(Get-Content -Path $devLicence.FullName -Encoding Byte))
Restart-NAVserverInstance $serverInstance

Write-Host "Publishing System Symbols"
Publish-NAVApp -serverInstance $serverInstance -Path "$installationMedia\ModernDev\program files\Microsoft Dynamics NAV\190\AL Development Environment\System.app" -PackageType SymbolsOnly

Write-Host "Installing System App"
Publish-NAVApp -serverInstance $serverInstance -Path "$installationMedia\Applications\system application\Source\Microsoft_System Application.app"
Sync-NAVApp -serverInstance $serverInstance -Name "System Application"
Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name "System Application"

Write-Host "Installing Base App"
Publish-NAVApp -serverInstance $serverInstance -Path "$installationMedia\Applications\BaseApp\Source\Microsoft_Base Application.app"
Sync-NAVApp -serverInstance $serverInstance -Name "Base Application"
Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name "Base Application"

Write-Host "Installing Application"
Publish-NAVApp -serverInstance $serverInstance -Path "$installationMedia\Applications\Application\Source\Microsoft_Application.app"
Sync-NAVApp -serverInstance $serverInstance -Name "Application"
Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name "Application"

Write-Host "Installing Be-Terna Apps"

[array]::Reverse($appsArray)

foreach($app in $appsArray)
{
    $appFile = Get-ChildItem $BeTernaAppPath -Filter "*$app*.app"
    if ($null -eq $appFile) {continue}

    Write-Host "Installing $app"
        
    Publish-NAVApp -serverInstance $serverInstance -Path $appFile.FullName
    Sync-NAVApp -serverInstance $serverInstance -Name $app
    Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name $app
    Move-Item -Path $appFile.FullName -Destination $archivePath
}

Write-Host "Installing Custom Apps"
$customApp = Get-ChildItem -Path "$customAppPath\" -Filter "*.app"
$appFileName = ($customApp -split '\\')[-1]
$appName = ($appFileName -split '_')[1]

Write-Host "Installing: $appName"
Publish-NAVApp -serverInstance $serverInstance -Path $customApp.FullName -SkipVerification
Sync-NAVApp -serverInstance $serverInstance -Name $appName
Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name $appName
Move-Item -Path $customApp.FullName -Destination $archivePath


Import-NAVServerLicense $serverInstance -LicenseData ([Byte[]]$(Get-Content -Path $clientLicence.FullName -Encoding Byte))
Restart-NAVserverInstance $serverInstance
