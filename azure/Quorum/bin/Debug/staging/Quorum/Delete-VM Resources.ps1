<#
Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupLocation,
    [string] $ResourceGroupName = 'Scalability_Quorum',
    [string] $StorageAccountName,
    [string] $StorageContainerName = $ResourceGroupName.ToLowerInvariant() + '-stageartifacts',
    [string] $TemplateFile = 'LinuxVirtualMachine.json',
    [string] $TemplateParametersFile = 'LinuxVirtualMachine.parameters.json',
)
#>
#Please use tags for deployment. 1 = tag, 0 = name

#-----Parameters------------
$tagOrName = 1
#Array of machines to delete -> $resourceTags = "node0", "node1"
$resourceTags = "node0-Austria"

#----Logic --------

foreach ($tagValue in $resourceTags){
	
	Write-Output "Deleting resources with tag name: " $tagValue
	$resourcesID = (Get-AzResource -TagName "TagName" -TagValue $tagValue).ResourceId
	$resourcesName = (Get-AzResource -Name "quorum2*").ResourceId

	if($tagOrName){
		$resources = $resourcesID
	}else{
		$resources = $resourcesName
	}

	$count = $resources.Length
	Write-Output "Number of resources found: " $count
	For ($i=0; $i -lt $resources.Length; $i++) {
		$diskItem = ""
	
		#making sure that the disk 
		if($resources[$i].contains("disk")){
			Write-Output "Name " $resources[$i]
			$diskItem = $i
			continue
		}else{
			Write-Output "Removing " $resources[$i]
			Remove-AzResource -ResourceId $resources[$i] -force
		}
	
	
		if($i -eq $count-1){
			Write-Output "Removing disk at last " $resources[$diskItem]
			Remove-AzResource -ResourceId $resources[$diskItem] -force
		}
	}
}


