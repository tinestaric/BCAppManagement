Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

$ServerInstance = $settings.serverInstance
Import-Module $settings.NavAdminToolPath
Install-module bccontainerhelper -force

$ReleasePath = $settings.BeTernaAppPath+"\Release"
$ArchivePath = $settings.BeTernaAppPath+"\Archive"

$apps = (Get-ChildItem -Path $ReleasePath -Filter '*.app' -Recurse).FullName |? { $_ -notmatch 'runtime' }
$apps = Sort-AppFilesByDependencies -appFiles $apps
$appNames = @()

$DesignerApps = Get-NAVAppInfo -ServerInstance $ServerInstance -Publisher "Designer"
foreach($DesignerApp in $DesignerApps)
{
    Uninstall-NAVApp -ServerInstance $ServerInstance -Name $DesignerApp.Name
    Unpublish-NAVApp -ServerInstance $ServerInstance -Name $DesignerApp.Name
}

foreach ($app in $apps) {
    $AppFileName = ($app -split '\\')[-1]
    $AppName = ($AppFileName -split '_')[1]
    $appNames = $appNames + $appName
}
[array]::Reverse($appNames)


"Uninstall and Unpublish all ld Be-terna Apps"
foreach ($app in $appNames)
{
    "Uninstalling: $app"
    Uninstall-NAVApp -ServerInstance $ServerInstance -Name $app -Force
    UnPublish-NAVApp -ServerInstance $ServerInstance -Name $app
}

"Publish New Version of Be-terna Apps"
foreach ($app in $apps)
{
    $AppFileName = ($app -split '\\')[-1]
    $AppName = ($AppFileName -split '_')[1]  
    Write-Host "Installing App: $app"  
    Publish-NAVApp -ServerInstance $ServerInstance -Path $app -SkipVerification
    Sync-NAVApp -ServerInstance $ServerInstance -Name $AppName
    Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $AppName    
    Move-Item -Path $app -Destination $ArchivePath
}