Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

Import-Module $settings.NavAdminToolPath

$licence = Get-ChildItem -Path $settings.devLicence -Filter '*.bclicense'
Import-NAVServerLicense $settings.serverInstance -LicenseData ([Byte[]]$(Get-Content -Path $licence.FullName -Encoding Byte))
Restart-NAVServerInstance -ServerInstance $settings.serverInstance