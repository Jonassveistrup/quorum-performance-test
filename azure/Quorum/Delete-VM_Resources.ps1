
#Please use tags for deployment. 1 = tag, 0 = name

#-----Parameters------------
$tagOrName = 1
#Array of machines to delete -> $resourceTags = "node0", "node1"
$resourceTags = "node0-Austria", "node1-Belgium", "node2-Bulgaria", "node3-Croatia", "node4-Cyprus", "node5-Czechia", "node6-Denmark", "node7-Estonia", "node8-Finland", "node9-France", "node10-Germany", "node11-Greece", "node12-Hungary", "node13-Ireland", "node14-Italy", "node15-Latvia", "node16-Lithuania", "node17-Luxembourg", "node18-Malta", "node19-Netherlands", "node20-Poland", "node21-Portugal", "node22-Romania", "node23-Slovakia", "node24-Slovenia", "node25-Spain", "node26-Sweden", "node27-UK"

#----Logic --------


	foreach ($tagValue in $resourceTags){
	
		Write-Output "Deleting resources with tag name: " $tagValue
		
		[string[]]$resources = @(Get-AzResource -TagName "TagName" -TagValue $tagValue).ResourceId
		
		$count = $resources.Count
		
		For ($i=0; $i -lt $count; $i++) {
			
			$diskItem = ""
	
			#making sure that the disk 
			
			if($resources[$i] -like 'disk'){
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



