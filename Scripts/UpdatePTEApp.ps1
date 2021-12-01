Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

$ServerInstance = $settings.serverInstance

Import-Module $settings.NavAdminToolPath

$PTEAppPath = $settings.outputFolder + "\Release"
$ArchivePath = $settings.outputFolder + "\Archive"

$PTEApp = Get-ChildItem -Path "$PTEAppPath\" -Filter "*.app"
$appName = (($PTEApp -split '\\')[-1] -split '_')[1]

Uninstall-NAVApp -ServerInstance $ServerInstance -Name $appName -Force
UnPublish-NAVApp -ServerInstance $ServerInstance -Name $appName

Publish-NAVApp -ServerInstance $ServerInstance -Path $PTEApp.FullName -SkipVerification
Sync-NAVApp -ServerInstance $ServerInstance -Name $appName
Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $appName

Move-Item -Path $PTEApp.FullName -Destination $ArchivePath