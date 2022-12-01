Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

$serverInstance = $settings.serverInstance

$installationMedia = $settings.MicrosoftAppPath
$BCVersion = $settings.BCVersion
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
Publish-NAVApp -serverInstance $serverInstance -Path "$installationMedia\ModernDev\program files\Microsoft Dynamics NAV\$BCVersion\AL Development Environment\System.app" -PackageType SymbolsOnly

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
        
    Publish-NAVApp -serverInstance $serverInstance -Path $appFile.FullName -SkipVerification
    Sync-NAVApp -serverInstance $serverInstance -Name $app
    Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name $app
    Move-Item -Path $appFile.FullName -Destination $archivePath
}

foreach($appFile in Get-ChildItem $BeTernaAppPath -Filter "*Language*.app")
{
    $app = $appFile.Name.Split('_')[1]
    Write-Host "Installing Translations $app"

    Publish-NAVApp -serverInstance $serverInstance -Path $appFile.FullName -SkipVerification
    Sync-NAVApp -serverInstance $serverInstance -Name $app
    Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name $app
    Move-Item -Path $appFile.FullName -Destination $archivePath
}

Write-Host "Installing Custom Apps"
foreach($app in Get-ChildItem -Path "$customAppPath\" -Filter "*.app")
{ 
    $appName = ($app -split '_')[1]

    Write-Host "Installing: $appName"
    Publish-NAVApp -serverInstance $serverInstance -Path $app.FullName -SkipVerification
    Sync-NAVApp -serverInstance $serverInstance -Name $appName
    Start-NAVAppDataUpgrade -serverInstance $serverInstance -Name $appName
    Move-Item -Path $app.FullName -Destination $archivePath
}

Import-NAVServerLicense $serverInstance -LicenseData ([Byte[]]$(Get-Content -Path $clientLicence.FullName -Encoding Byte))
Restart-NAVserverInstance $serverInstance
