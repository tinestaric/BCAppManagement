Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }
$ServerInstance = $settings.serverInstance
$DatabaseName = $settings.databaseName
$DatabaseServer = $settings.databaseServer

$Today = Get-Date -UFormat "%Y-%m-%d"
$BackupLocation =  $settings.databaseBackupPath + "\Backup-$Today.bak"

$appsArray = $settings.appList.Split(';').Trim()

Import-Module $settings.NavAdminToolPath

Backup-SqlDatabase -ServerInstance $DatabaseServer -Database $DatabaseName -BackupFile $BackupLocation

foreach($appName in $appsArray)
{
    Uninstall-NAVApp -ServerInstance $ServerInstance -Name $appName -Force
    UnPublish-NAVApp -ServerInstance $ServerInstance -Name $appName
}

Get-NAVAppInfo -ServerInstance $ServerInstance | % { 
    Uninstall-NAVApp -ServerInstance $ServerInstance -Name $_.Name -Version $_.Version -Force
    UnPublish-NAVApp -ServerInstance $ServerInstance -Name $_.Name -Version $_.Version    
}

Unpublish-NAVApp -ServerInstance $ServerInstance -Name System

Stop-NAVServerInstance -ServerInstance $ServerInstance

Write-Host "---------------------"
Write-Host "Manually Reinstall BC via the Setup.exe on the Installation DVD"