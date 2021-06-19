


function update-VM
{
	param
	([string]$Host)
	
	try
	{
		Enter-PSSession -ComputerName $Host
	}
	catch
	{
		Write-Host $Host "Failed to connect" -ForegroundColor Red
	}
}

function Read-cfg
{
	param
	([string]$FilePath)
	
	if (Test-Path $FilePath)
	{
		return [xml](Get-Content $FilePath)
	}
	else
	{
		return 1
	}
}

function Add-Host
{
	param
	(
		[string]$Path,
		[string]$newHost
	)
	
	if (Test-Path $Path)
	{
		$ConfigXML = [xml](Get-Content $Path)
		
		$newHostEntry = $ConfigXML.CreateElement("VM")
		
		$newHostnameElement = $newHostEntry.AppendChild($ConfigXML.CreateElement("HostName"))
		$newHostnameElement.AppendChild($ConfigXML.CreateTextNode($newHost))
		
		$newHostEntryAdd = $ConfigXML.configuration.Hosts.AppendChild($newHostEntry)
		
		$ConfigXML.Save($Path)
	}
	else
	{
		return 1
	}
}