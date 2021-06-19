<#
	CastleOps-Core.psm
		Initial write of a module manifest to create baseline functions nessesary for castelops functionality.
#>


function bootstrapinstaller
{
	
	New-Item "$env:SystemDrive\CastleOps" -ItemType Directory
	
	$userpath = "$env:systemdrive\CastleOps\nssm-2.24.zip"
	$userpath2 = "$env:systemdrive\CastleOps\CastleOps-Core.ps1"
	$NSSMExe = "$env:systemdrive\CastleOps\nssm-2.24\nssm-2.24\win64\nssm.exe"
	$CastleOpsCore = "https://github.com/zveroboy152/CastleOps/blob/main/CastleOps-Core.ps1"
	#https://nssm.cc/release/nssm-2.24.zip
	
	
	(New-Object System.Net.WebClient).DownloadFile("https://nssm.cc/release/nssm-2.24.zip", "$userpath")
	Expand-Archive -LiteralPath "$env:systemdrive\CastleOps\nssm-2.24.zip" -DestinationPath "$env:systemdrive\CastleOps\nssm-2.24"
	Remove-Item $userpath -Recurse
	(New-Object System.Net.WebClient).DownloadFile("$CastleOpsCore", "$userpath2")
	
}

function vmware-cli-update
{
	
	write-host "Checking for Updates for PowerCLI... Please Wait..."
	
	try
	{
		Install-Module VMware.PowerCLI
		write-host "Update Complete!" -ForegroundColor Green
	}
	
	catch
	{
		write-host "Update Failed!" -ForegroundColor red
		return 1
	}
}

function Connect-VIServers
{
	param (
		[array]$HostList
	)
	
	$OnlineHosts = @()
	
	foreach ($Host in $HostList)
	{
		if (Test-Connection -Computername $Host -BufferSize 16 -Count 1 -Quiet)
		{
			Write-Host $Host ": online" -ForegroundColor green
			$OnlineHosts += $Host
		}
		else
		{
			Write-Host $Host ": offline" -ForegroundColor red
		}
	}
	
	Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
	
	
	foreach ($Host in $HostList)
	{
		try
		{
			Connect-VIServer -Server "$vihosts" -Verbose
		}
		catch
		{
			write-host "Failed to connect to: " $Host -ForegroundColor red
		}
	}
	
	write-host "Connection Complete" -ForegroundColor green
	
	Start-Sleep -Seconds 15
	
	return $OnlineHosts
}

function Install-Service
{
	Start-Process -FilePath $NSSMExe -ArgumentList 'install CastleOps-Core "$env:SystemDrive\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "-command "& {$env:SystemDrive\CastleOps\CastleOps-Core.ps1; Start-Monitoring }"" ' -NoNewWindow -Wait
}

function CreateVMSnapshot
{
	param ([string] $Host)
	
	$Date = Get-Date -Format ddmmmyyyy
	$Time = Get-Date -Format hh:mm
	$HostInfo = get-vm -name $Host
	
}




Export-ModuleMember -Function Install-Service
Export-ModuleMember -Function bootstrapinstaller
Export-ModuleMember -Function vmware-cli-update
Export-ModuleMember -Function Connect-VIServers
