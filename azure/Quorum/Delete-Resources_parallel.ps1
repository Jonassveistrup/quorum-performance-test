
#Array of machines to delete -> $resourceTags = "node0", "node1"
$resourceTags = "node0-Austria", "node1-Belgium", "node2-Bulgaria", "node3-Croatia", "node4-Cyprus", "node5-Czechia", "node6-Denmark", "node7-Estonia", "node8-Finland", "node9-France", "node10-Germany", "node11-Greece", "node12-Hungary", "node13-Ireland", "node14-Italy", "node15-Latvia", "node16-Lithuania", "node17-Luxembourg", "node18-Malta", "node19-Netherlands", "node20-Poland", "node21-Portugal", "node22-Romania", "node23-Slovakia", "node24-Slovenia", "node25-Spain", "node26-Sweden", "node27-UK"
#$resourceTags = "node0-Austria", "node1-Belgium", "node2-Bulgaria", "node3-Croatia", "node4-Cyprus"

#----Logic --------



foreach ($tagValue in $resourceTags){
	[string[]]$resources = (Get-AzResource -TagName "TagName" -TagValue $tagValue).ResourceId
	[string[]]$resourcesTypes = (Get-AzResource -TagName "TagName" -TagValue $tagValue).ResourceType

	For ($i=0; $i -lt $resources.Count; $i++) {
		$diskItem = ""
		$id = ""
		
		#making sure that the disk 
		if($resources[$i] -like 'disk'){
			$diskItem = $i
			continue
		}else{
			$id = $resources[$i]
		}
	
		if($i -eq $resources.Count-1){
			$id = $resources[$diskItem]
		}

		Start-Job -ScriptBlock {
				param($id)
				Remove-AzResource -ResourceId $id -Force
		} -ArgumentList @($id)
	}
}


<#

$path = ".\profile.json"
Login-AzureRmAccount
Save-AzureRmProfile -Path $path -Force

$resourceGroupName = "MyResourceGroup"
$deployments = Get-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName
$deploymentsToDelete = $deployments | where { $_.Timestamp -lt ((get-date).AddDays(-7)) }

foreach ($deployment in $deploymentsToDelete) {
	Start-Job -ScriptBlock {
		param($resourceGroupName, $deploymentName, $path)
		Select-AzureRmProfile -Path $path
		Remove-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -DeploymentName $deploymentName
	} -ArgumentList @($resourceGroupName, $deployment.DeploymentName, $path) | Out-Null
}

$resources = (Get-AzResource -TagName "TagName" -TagValue $tagValue).ResourceId

	Write-Output "Deleting resources with tag name: " $tagValue " Lenght: " $resources.Length
	
	For ($i=0; $i -lt $resources.Length; $i++) {
    
		$ScriptBlock = {
			Param (
				[string] [Parameter(Mandatory=$true)] $i
			)

			Get-AzResource -ResourceId $resources[$i] -force -verbose
		}

		Start-Job $ScriptBlock -ArgumentList $resources[$i]
	}

	Get-Job | Wait-Job | Receive-Job

Get-AzResourceGroup  | ForEach-Object { Start-Job -InputObject $_ -ScriptBlock { $Input | Remove-AzResourceGroup -Force } }

 Find-AzureRmResourceGroup -tag @{ "Environment" = $env } | ForEach-Object -Process {
        $rgname = $_.Name;
        Start-Job -ScriptBlock { Remove-AzureRmResourceGroup -Name $args[0] -Force } -ArgumentList $rgname;
        Start-Sleep 30 # Azure gets very upset if you slam too much work at it and randomly decides not to accept the request
    }
    Get-Job | Wait-Job | Receive-Job

<#
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

	$ScriptBlock = {
        Param (
            [string] [Parameter(Mandatory=$true)] $increment
        )

        Write-Host $increment
    }

    Start-Job $ScriptBlock -ArgumentList $i

	}
#>

