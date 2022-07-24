[CmdletBinding(DefaultParameterSetName = "ExchangeDiscovery", SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path
    )


$Encoding="UTF8"

#Import cmdlets CSV file
$ExchangeServerCmdlets=Import-Csv -Delimiter ";" -Path ".\Cmdlets\ExchangeServer.csv"

#Start
foreach($ExchangeServerCmdlet in $ExchangeServerCmdlets)
{   
    Write-Verbose "Working on cmdlet $ExchangeServerCmdlet"
    $filename=$ExchangeServerCmdlet.filename+".XML"
    try{
        (Invoke-Expression $ExchangeServerCmdlet.cmdlet) | Export-Clixml -Path "$Path\$filename" -Encoding $Encoding -Depth $ExchangeServerCmdlet.depth -Verbose
    }
    catch{
        Write-Host "Failed to properly run $ExchangeServerCmdlet"
    }

}
