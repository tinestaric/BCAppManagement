Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

$ServerInstance = $settings.serverInstance
$DatabaseName = $settings.databaseName
$DatabaseServer = $settings.databaseServer

Import-Module $settings.NavAdminToolPath

Invoke-NAVApplicationDatabaseConversion -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName

Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DatabaseName -KeyValue $DatabaseName

Restart-NAVServerInstance -ServerInstance $ServerInstance