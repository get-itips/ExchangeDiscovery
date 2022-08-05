[CmdletBinding(DefaultParameterSetName = "ExchangeDiscovery", SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

    

. $PSScriptRoot\Utils\BuildHTMLReport.ps1

function Main 
{
    $Encoding="UTF8"
    $Runtime=(Get-Date).ToString("yyyyMMddhhmmss")
    $FolderName="EXO_$Runtime"
    $ReportTitle="Exchange Online Report"
    #Import cmdlets CSV file
    try{
        $ExchangeOnlineCmdlets=Import-Csv -Delimiter ";" -Path ".\Cmdlets\ExchangeOnline.csv" -ErrorAction Stop
    }
    catch
    {
        Write-Warning "Failed to read CSV file"
        throw $_
    }

    #Connect to Exchange Online
    try {
        Connect-ExchangeOnline -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to connect to Exchange Online"
        throw $_
    }
    
    #Create folder
    $folder
    try{
        $folder=New-Item -Path $Path -Name $FolderName -itemType Directory -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to create output folder"
        throw $_
    }

    #Start
    foreach($ExchangeOnlineCmdlet in $ExchangeOnlineCmdlets)
    {   
        Write-Verbose "Working on cmdlet $ExchangeOnlineCmdlet"
        $filename=$ExchangeOnlineCmdlet.cmdlet+".XML"
        try{
            (Invoke-Expression $ExchangeOnlineCmdlet.cmdlet) | Export-Clixml -Path "$Path\$FolderName\$filename" -Encoding $Encoding -Depth $ExchangeOnlineCmdlet.depth -ErrorAction Stop
        }
        catch{
            Write-Warning "Failed to properly run $ExchangeOnlineCmdlet.cmdlet"
        }


    }
    Disconnect-ExchangeOnline -Confirm:$false
    BuildHTMLReport -XMLPath $folder.FullName -ReportTitle $ReportTitle
    
}
Main
