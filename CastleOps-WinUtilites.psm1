
$global:SuccessLog
$global:FailLog
$global:ErrLog


function update-VM
{	#Service Account stated in Documentation to be used (or domain admin of any sort) to remotely begin updates.  This will be stated in the XML
	$updatevmserviceaccount =
	$serviceaccountdomain = 
	param
	([string]$Host)
	$ConfigXML = [xml](Get-Content $path)
	try
	{
		Invoke-Command -ComputerName Server01 -Credential $serviceaccountdomain\$$updatevmserviceaccount -ScriptBlock { 
		Install-Module PSWindowsUpdate -Verbose -Force
		Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
		}
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

function SuccessLogLocation
{
	param
	(
		[string]$LogLocation
	)
	
	if (Test-Path $LogLocation)
	{
		$global:SuccessLog = $LogLocation
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

function Write-SuccessLog
{
	param
	(
		[string]$Log
	)
	
	try
	{
		Add-Content -Path $global:SuccessLog -Value $Log
		return 0
	}
	catch
	{
		return 1
	}
}

function Set-FailLogLocation
{
	param
	(
		[string]$LogLocation
	)
	
	if (Test-Path $LogLocation)
	{
		$global:FailLog = $LogLocation
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

function Write-FailLog
{
	param
	(
		[string]$Log
	)
	
	try
	{
		Add-Content -Path $global:FailLog -Value $Log
		return 0
	}
	catch
	{
		return 1
	}
}

function Send-Email
{
	param
	(
		[string]$ConfigLocation
	)
	
	$ConfigXML = [xml](Get-Content $ConfigLocation)
	
	$SMTPServ = $ConfigXML.configuration.email.SMTPServer
}