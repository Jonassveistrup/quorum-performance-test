#Requires -Version 3.0

Param(
    [string] $ResourceGroupName = 'Performance_Test_Quorum',
    [string] $TemplateFile = 'LinuxVirtualMachine.json',
    [string] $TemplateParametersFile = 'LinuxVirtualMachine.parameters.json',
    [switch] $ValidateOnly,
	[string] $deployNetworkAndStorage =  $false,
	[string] $fileForNetworkAndStorage = "C:\Users\jsveistrup\source\repos\Scalability_test\Quorum\AzureDeloymentFile_metefile.csv",
	[string] $fileForMultideployment = "C:\Users\jsveistrup\source\repos\Scalability_test\Quorum\AzureDeloymentFile.csv",
	[string] $subscriptionId= "a07d6b2b-0e71-44d3-9e8a-da985951616c",
	[string] $adminUsername = "admin_scalability",
	[string] $adminPassword = "Deloitte1234"
)


try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ','_'), '3.0.0')
} catch { }

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Format-ValidationOutput {
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

$OptionalParameters = New-Object -TypeName Hashtable
$paramObject = New-Object -TypeName Hashtable
$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))

   


if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                                                                  -TemplateFile $TemplateFile `
                                                                                  -TemplateParameterFile $TemplateParametersFile `
                                                                                  @OptionalParameters)
    if ($ErrorMessages) {new
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else {

	#Read from file

	$file = Get-Content -Path $fileForMultideployment | Select-Object -Skip 1
	

	foreach ($line in $file){
		#Write-Output ([string]$line)

		$arr = ([string]$line).split(';')
		
		$location = $arr[3]
		$virtualMachineName = $arr[2]
		$lowercaseRG = $ResourceGroupName.ToLower() -replace '_',''
		$virtualNetworkName = $arr[4]
		$storageAccountName = $arr[5]

		$paramObject = @{
			'location' = $location
			'virtualMachineName' = $virtualMachineName
			'adminUsername' = $adminUsername
			'adminPassword' = $adminPassword
			'virtualMachineRG' = $ResourceGroupName
			'lowercaseRG' = $lowercaseRG
			'virtualNetworkName' = $virtualNetworkName
			'storageAccountName' = $storageAccountName
			'subscriptionId' = $subscriptionId
		}

		#Write-Output $paramObject

		$parameters = @{
		'Name' = ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmmss')) + '-' + Get-Random
        'ResourceGroupName' = $ResourceGroupName
        'TemplateFile' =  $TemplateFile
        'TemplateParameterObject' = $paramObject
		'Verbose' = $true
		'Force' = $true
		}
		
		Write-Output $parameters

		Start-Job -ScriptBlock {
					param($parameters)
					New-AzResourceGroupDeployment @parameters
				} -ArgumentList @($parameters)
	}
}