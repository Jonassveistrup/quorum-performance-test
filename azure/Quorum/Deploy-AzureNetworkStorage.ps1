
Param(
    
    [string] $ResourceGroupName = 'Performance_Test_Quorum',
	[string] $deployNetworkAndStorage =  $true,
	[string] $fileForNetworkAndStorage = "C:\Users\jsveistrup\source\repos\Scalability_test\Quorum\AzureDeloymentFile_metafile.csv"
)

# Create virtual network groups and storage accounts for all regions

if($deployNetworkAndStorage){
	
	#read from csv-file
	#headers for meta file: Displayname;AzLocationName;VirtualNetworkName;StorageAccountName; AddressPrefix

	$file = Get-Content -Path $fileForNetworkAndStorage | Select-Object -Skip 1
	

	foreach ($line in $file){
		#Write-Output ([string]$line)

		$arr = ([string]$line).split(';')
		
		$name = $arr[2]
		$location = $arr[1]
		$storageAccName = $arr[3]
		$addressPrefix = $arr[4]
		$subNetAddressPrefix = $arr[5]
		
		#Write-Output "Name: " $name ", location: " $location ", storage: " $storageAccName ", address: " $addressPrefix ", count of arr: " $arr.Count

		#check if virtual network exists and creates a new one if not
		if((Get-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroupName -Verbose -ErrorAction SilentlyContinue) -eq $null){

			$subnet  = New-AzVirtualNetworkSubnetConfig -Name default  -AddressPrefix $subNetAddressPrefix
			New-AzVirtualNetwork -Name $name -ResourceGroupName $ResourceGroupName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet -Verbose -Force -ErrorAction Stop
		}
		#check if storage account exists and creates a new one if not
		if((Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $storageAccName -Verbose -ErrorAction SilentlyContinue) -eq $null){

			New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $storageAccName -Location $location -SkuName Standard_GRS -Verbose

		}

		$arr = @()
		
	}

}