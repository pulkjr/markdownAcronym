param(
    [string]$ConfigurationPath,

    [string]$Type = 'Unit'
)

#TODO: Hardcoded path to module...YUCK!
Import-Module "C:\users\TAldrich\projects\github\PSMarkdig\source\PSMarkdig" -Force

if ($null -ne $BuildRoot) {
    $root = $BuildRoot
} else {
    $root = $pwd.Path
}

if ($null -eq $root) {
    $root = (Get-Location).Path
}

$testsFolder = (Join-Path $root 'tests')

if (Test-Path $testsFolder) {
    Import-Module "$testsFolder\TestHelpers.psm1"
} else {
    throw "Could not find the tests folder"
}

if ([string]::IsNullOrEmpty($ConfigurationPath)) {
    $ConfigurationPath = (Join-Path -Path '.build' -ChildPath 'pester')
}

$ConfigurationName = "${Type}Tests.config.psd1"

$ConfigurationPath = (Join-Path $ConfigurationPath $ConfigurationName)

if (Test-Path $ConfigurationPath) {
    Write-Verbose "Loading test configuration from $ConfigurationPath"
    $configInfo = Import-Psd $ConfigurationPath -Unsafe
    $pesterConfiguration = New-PesterConfiguration -Hashtable $configInfo
} else {
    $pesterConfiguration = New-PesterConfiguration
    $pesterConfiguration.Run.Path = "tests\$Type"
}

Invoke-Pester -Configuration $pesterConfiguration
