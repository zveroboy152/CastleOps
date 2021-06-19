

$global:ErrLog

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

function Remove-Host
{
	param
	(
		[string]$path,
		[string]$host
	)
	
	if (Test-Path)
	{
		$ConfigXML = [xml](Get-Content $path)
		$CurrentHosts = $ConfigXML.configuration.Hosts.VM.Hostname
		$HostExistsInConfig = $false
		
		foreach ($Name in $CurrentHosts)
		{
			if ($Name -eq $host)
			{
				$HostExistsInConfig = $true
			}
		}
		
		if ($HostExistsInConfig -eq $true)
		{
			$ConfigXML.Configuration.Hosts.RemoveChild($host)
		}
	}
	else
	{
		return 1
	}
}

function Set-ErrLogLocation
{
	param
	(
		[string]$LogLocation
	)
	
	if (Test-Path $LogLocation)
	{
		$global:ErrLog = $LogLocation
		return 0
	}
	else
	{
		if ($LogLocation -like "*.txt")
		{
			try
			{
				New-Item $LogLocation
			}
			catch
			{
				return 1
			}
		}
	}
}

function Write-ErrLog
{
	param
	(
		[string]$ErrMessage
	)
	
	try
	{
		Add-Content -Path $global:ErrLog -Value $ErrMessage
		return 0
	}
	catch
	{
		return 1
	}
}