[CmdletBinding(DefaultParameterSetName = "ExchangeDiscovery", SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path

    )

function Main 
{
    $Encoding="UTF8"
    $Runtime=(Get-Date).ToString("yyyyMMddhhmmss")
    $FolderName="EXO_$Runtime"
    #Import cmdlets CSV file
    $ExchangeOnlineCmdlets=Import-Csv -Delimiter ";" -Path ".\Cmdlets\ExchangeOnline.csv"

    #Connect to Exchange Online
    Connect-ExchangeOnline -ErrorAction Stop

    #Create folder
    New-Item "$Path\$FolderName" -itemType Directory
    #Start
    foreach($ExchangeOnlineCmdlet in $ExchangeOnlineCmdlets)
    {   
        Write-Verbose "Working on cmdlet $ExchangeOnlineCmdlet"
        $filename=$ExchangeOnlineCmdlet.filename+".XML"
        try{
            (Invoke-Expression $ExchangeOnlineCmdlet.cmdlet) | Export-Clixml -Path "$Path\$FolderName\$filename" -Encoding $Encoding -Depth $ExchangeOnlineCmdlet.depth -Verbose
        }
        catch{
            Write-Host "Failed to properly run $ExchangeOnlineCmdlet"
        }

    }
}
Main
