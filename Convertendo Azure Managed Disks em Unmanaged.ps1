# Variaveis
$RG = "RG-teste" 
$VMNAME = "VM-01"
$location = "Central US"
$stoname = "stof0547"
$disknameconvestido = "testeconvertido.vhd"
$containerName = "vhds"

# Criar Storage Account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RG `
  -Name $stoname `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind StorageV2 

$ctx = $storageAccount.Context

# Criar o Container
New-AzStorageContainer -Name $containerName -Context $ctx -Permission blob

# Mostrar o nome dos discos 
$vm = Get-AzVM -ResourceGroupName $RG -Name $VMNAME
$vm.StorageProfile.OsDisk | Where-Object {$_.ManagedDisk -ne $null} | Select-Object Name
$vm.StorageProfile.DataDisks | Where-Object {$_.ManagedDisk -ne $null} | Select-Object Name

# Recuperar a chave da conta de armazenamento 
 Get-AzureRmStorageAccountKey -ResourceGroupName $RG -StorageAccountName $stoname

# Criar um contexto de armazenamento que pode ser usado posteriormente para copiar os VHDs
$StorageAccountKey = "pfmxtclFD9bi1Ig14wljJLdznPKziVM4BNyAEpkfhwwWPnfUatEdt1KqC81Y1Ny3TvjplrD0cRBJaJPJ2CNLmg=="
$context = New-AzureStorageContext -StorageAccountName $stoname -StorageAccountKey $StorageAccountKey

#  Conceder acesso e iniciar a cópia do blob
$diskname = "disco-date02" 
$sas = Grant-AzureRmDiskAccess -ResourceGroupName $RG  -DiskName $diskname -Access Read -DurationInSecond (60*60*24)
$blobcopyresult = Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestinationContainer $containerName -DestinationBlob $disknameconvestido -DestinationContext $context

# Ver o Status da copia do VHD para o container
$blobcopyresult | Get-AzureStorageBlobCopyState


# Obter o status após reiniciar o Cloud shell

Set-AzureRmCurrentStorageAccount -ResourceGroupName $RG -Name $stoname
Get-AzureStorageBlobCopyState -Container $containerName -Blob $disknameconvestido