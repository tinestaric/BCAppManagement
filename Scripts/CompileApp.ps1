Get-Content ".\Settings.ini" | foreach-object -begin {$settings=@{}} -process { $k = [regex]::split($_,' = ') ; if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $settings.Add($k[0], $k[1]) } }

$startTime = [DateTime]::Now

$binPath = $settings.binPath
$appProjectFolder = $settings.appProjectFolder
$outputFolder = $settings.outputFolder + "\Release"

$alcPath = Join-Path $binPath 'win32'

$appSymbolsFolder = (Join-Path $appProjectFolder ".alpackages")

$appJsonFile = Join-Path $appProjectFolder 'app.json'
$appJsonObject = [System.IO.File]::ReadAllLines($appJsonFile) | ConvertFrom-Json
$appName = "$($appJsonObject.Publisher)_$($appJsonObject.Name)_$($appJsonObject.Version).app".Split([System.IO.Path]::GetInvalidFileNameChars()) -join ''

$appOutputFile = Join-Path $outputFolder $appName

if (Test-Path -Path $appOutputFile -PathType Leaf) {
    Remove-Item -Path $appOutputFile -Force
}

Write-Host "Compiling..."
Set-Location -Path $alcPath

$alcParameters = @("/project:""$($appProjectFolder.TrimEnd('/\'))""", "/packagecachepath:""$($appSymbolsFolder.TrimEnd('/\'))""", "/out:""$appOutputFile""")

$alcParameters += @("/analyzer:$(Join-Path $binPath 'Analyzers\Microsoft.Dynamics.Nav.CodeCop.dll')")

#    $alcParameters += @("/analyzer:$(Join-Path $binPath 'Analyzers\Microsoft.Dynamics.Nav.AppSourceCop.dll')")

$alcParameters += @("/analyzer:$(Join-Path $binPath 'Analyzers\Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll')")

$alcParameters += @("/analyzer:$(Join-Path $binPath 'Analyzers\Microsoft.Dynamics.Nav.UICop.dll')")

#$alcParameters += @("/ruleset:$rulesetfile")

Write-Host ".\alc.exe $([string]::Join(' ', $alcParameters))"

$result = & .\alc.exe $alcParameters
        
if ($lastexitcode -ne 0 -and $lastexitcode -ne -1073740791) {
    "App generation failed with exit code $lastexitcode"
}
    
#if ($treatWarningsAsErrors) {
#$regexp = ($treatWarningsAsErrors | ForEach-Object { if ($_ -eq '*') { ".*" } else { $_ } }) -join '|'
#$result = $result | ForEach-Object { $_ -replace "^(.*)warning ($regexp):(.*)`$", '$1error $2:$3' }
#}
#
#$devOpsResult = ""
#if ($result) {
#$devOpsResult = Convert-ALCOutputToAzureDevOps -FailOn $FailOn -AlcOutput $result -DoNotWriteToHost -gitHubActions:$gitHubActions
#}
#if ($AzureDevOps -or $gitHubActions) {
#$devOpsResult | ForEach-Object { $outputTo.Invoke($_) }
#}
#else {
#$result | % { $outputTo.Invoke($_) }
#if ($devOpsResult -like "*task.complete result=Failed*") {
#    throw "App generation failed"
#}
#}

$result | Where-Object { $_ -like "App generation failed*" } | % { throw $_ }

$timespend = [Math]::Round([DateTime]::Now.Subtract($startTime).Totalseconds)
$appFile = Join-Path $outputFolder $appName
Write-Host "$appFile successfully created in $timespend seconds"