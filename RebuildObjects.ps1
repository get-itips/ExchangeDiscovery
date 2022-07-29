[CmdletBinding(DefaultParameterSetName = "ExchangeDiscovery", SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path

    )

    function Main 
    {
        $objects=@()
        $pattern="(?<=Get).+?(?=.XML)"
        $files=Get-ChildItem -Path $Path
        Write-Host ""
        Write-Host "-----Found and Processing:-----"
        Write-Host ""
        foreach($file in $files){
            Write-Host $file.Name
            $objectName=[regex]::Matches($file.name, $pattern).Value
            $objects+=,$objectName
            Remove-Variable -Name $objectName -ErrorAction SilentlyContinue -Scope Global
            New-Variable -Name $objectName -Scope Global -value (Import-Clixml -Path $file.fullname)
        }
        Write-Host ""
        Write-Host "-----Now you can call these variables:-----"
        Write-Host ""
        foreach($object in $objects){"$"+$object}
    }
    Main