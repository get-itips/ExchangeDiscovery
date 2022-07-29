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
    $FolderName="EXSRV_$Runtime"
    $ReportTitle="Exchange Server Report"
    #Import cmdlets CSV file
    try{
        $ExchangeServerCmdlets=Import-Csv -Delimiter ";" -Path ".\Cmdlets\ExchangeServer.csv" -ErrorAction Stop
    }
    catch
    {
        Write-Warning "Failed to read CSV file"
        throw $_
    }

    #TODO: Check if we are running in Exchange Server PowerShell


    #Create folder
    try{
        New-Item -Path $Path -Name $FolderName -itemType Directory -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to create output folder"
        throw $_
    }
    finally{
        Disconnect-ExchangeServer
    }
    #Start
    foreach($ExchangeServerCmdlet in $ExchangeServerCmdlets)
    {   
        Write-Verbose "Working on cmdlet $ExchangeServerCmdlet"
        $filename=$ExchangeServerCmdlet.cmdlet+".XML"
        try{
            (Invoke-Expression $ExchangeServerCmdlet.cmdlet) | Export-Clixml -Path "$Path\$FolderName\$filename" -Encoding $Encoding -Depth $ExchangeServerCmdlet.depth -ErrorAction Stop
        }
        catch{
            Write-Warning "Failed to properly run $ExchangeServerCmdlet.cmdlet"
        }


    }

    BuildHTMLReport -XMLPath "$Path$FolderName" -ReportTitle $ReportTitle
    
}
Main
