[CmdletBinding(DefaultParameterSetName = "ExchangeDiscovery", SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path,
    [Parameter(Mandatory)]
    [string]$Server
)

    

. $PSScriptRoot\Utils\BuildHTMLReport.ps1

function Main 
{
    $Encoding="UTF8"
    $Runtime=(Get-Date).ToString("yyyyMMddhhmmss")
    $FolderName="EXSRV_$Runtime"
    $ReportTitle="Exchange Server $Server Report"
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
    $folder
    try{
        $folder=New-Item -Path $Path -Name $FolderName -itemType Directory -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to create output folder"
        throw $_
    }

    #Start
    foreach($ExchangeServerCmdlet in $ExchangeServerCmdlets)
    {   
        Write-Verbose "Working on cmdlet $ExchangeServerCmdlet"
        $filename=$ExchangeServerCmdlet.cmdlet+".XML"
        try{
            if($ExchangeServerCmdlet.parameter -eq "org"){
                (Invoke-Expression $ExchangeServerCmdlet.cmdlet) | Export-Clixml -Path "$Path\$FolderName\$filename" -Encoding $Encoding -Depth $ExchangeServerCmdlet.depth -ErrorAction Stop

            }
            else
            {
                $cmdlet=$ExchangeServerCmdlet.cmdlet
                $cmdletToRun="$cmdlet -Server $Server"
                (Invoke-Expression $cmdletToRun) | Export-Clixml -Path "$Path\$FolderName\$filename" -Encoding $Encoding -Depth $ExchangeServerCmdlet.depth -ErrorAction Stop
            }
        }
        catch{
            $cmdletError=$ExchangeServerCmdlet.cmdlet
            Write-Warning "Failed to properly run $cmdletError"
        }


    }

    BuildHTMLReport -XMLPath $folder.FullName -ReportTitle $ReportTitle
    
}
Main
