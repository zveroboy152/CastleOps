<#

This is CastleOps.  I wrote this to help myself, and others, in automating their systems, auto snapshot, update, and backup their
infrastructure.  This script, as of V1, can be used and installed as a service on a server to run in a scheduled automated sequence.

 -Zveroboy
#>
function bootstrapinstaller {
mkdir C:\CastleOps
$userpath = "C:\CastleOps\nssm-2.24.zip"
$userpath2 = "C:\CastleOps\CastleOps-Core.ps1"
$CastleOpsCore ="https://github.com/zveroboy152/CastleOps/blob/main/CastleOps-Core.ps1"
#https://nssm.cc/release/nssm-2.24.zip
(New-Object System.Net.WebClient).DownloadFile("https://nssm.cc/release/nssm-2.24.zip", "$userpath")  
 Expand-Archive -LiteralPath 'C:\CastleOps\nssm-2.24.zip' -DestinationPath "C:\CastleOps\nssm-2.24"
 rm $userpath
 (New-Object System.Net.WebClient).DownloadFile("$CastleOpsCore", "$userpath2") 

}

function vmware-cli-update {
	Clear-host
'Checking for Updates for PowerCLI... Please Wait...'
	Start-sleep -seconds 2
Install-Module VMware.PowerCLI 
	Start-sleep -seconds 2
'Update Completed!'
clear-Host

}
function Connect-VIServers {
    clear-host
    'What hows would you like to connect to?
    Example: esxi1, esxi2, esxi3 '
    $vihosts = read-host -prompt " "
    "Testing connection..."
    foreach ($singlehost in  $vihosts) {
        if (Test-Connection -Computername $singlehost -BufferSize 16 -Count 1 -Quiet) {
            Write-Host $singlehost is online
        }
    }
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
    Connect-VIServer -Server "$vihosts" -Verbose
    "You're now connected to your virtual infastructure..."
    $currentvhosts
    'Returnging to main menu in 5 seconds...'
    Start-Sleep -Seconds 15
    #refreshes host list
    #loops to main menu
    mainmenu
}

function Install-Service {
cd 'C:\CastleOps\nssm-2.24\nssm-2.24\win64\'
Start-Process -FilePath .\nssm.exe -ArgumentList 'install CastleOps-Core "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "-command "& { . C:\CastleOps\CastleOps-Core.ps1; Start-Monitoring }"" ' -NoNewWindow -Wait
}