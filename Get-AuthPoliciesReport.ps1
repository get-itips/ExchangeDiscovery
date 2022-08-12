
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
    $FolderName="AuthPolicies_$Runtime"
    $ReportTitle="Exchange Online Authentication Policies Report"
    #Connect to Exchange Online
    try {
        Connect-ExchangeOnline -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to connect to Exchange Online"
        throw $_
    }

        Write-Host "--------------------------------------" -ForegroundColor Black -BackgroundColor DarkGreen
        Write-Host "--- Authentication Policies Report ---" -ForegroundColor Black -BackgroundColor DarkGreen
        Write-Host "--------------------------------------" -ForegroundColor Black -BackgroundColor DarkGreen

    # Get Authentication Policies
    $authPolicies=Get-AuthenticationPolicy

    if($authPolicies)
    {
        #Create folder
        $folder
        try{
            $folder=New-Item -Path $Path -Name $FolderName -itemType Directory -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to create output folder"
            throw $_
        }

        # Get the Default Authentication Policy
        $DefaultAuthPolicyName=(Get-OrganizationConfig).Defaultauthenticationpolicy
        $authPoliciesExceptDefault=$null
        
        Write-Host "----------------------" -ForegroundColor Blue
        Write-Host "--- Default Policy ---" -ForegroundColor Blue
        Write-Host "----------------------" -ForegroundColor Blue

        if($DefaultAuthPolicyName)
        {
            # Get all auth policies non default
            $authPoliciesExceptDefault= $authPolicies | Where-Object {$_.id -notlike $DefaultAuthPolicyName}

            $usersWithDefaultPolicy = (Get-User -Filter 'AuthenticationPolicy -eq $null' -ResultSize unlimited).count

            $DefaultAuthPolicy = Get-AuthenticationPolicy -Identity $DefaultAuthPolicyName

            $DefaultAuthPolicy  | Export-Clixml -Path "$Path\$FolderName\DefaultAuthPolicy.XML" -Encoding $Encoding -Depth 2 -ErrorAction Stop

            $DefaultAuthPolicy  | Format-List Name,*Allow*

            Write-Host "$usersWithDefaultPolicy users have the default policy"
        }
        else {
            Write-Host "No Default Authentication Policy found" -ForegroundColor Red
            $authPoliciesExceptDefault=Get-AuthenticationPolicy
        }



        Write-Host "----------------------" -ForegroundColor Cyan
        Write-Host "-Non Default Policies-" -ForegroundColor Cyan
        Write-Host "----------------------" -ForegroundColor Cyan

        foreach($authPolicy in $authPoliciesExceptDefault){

            $name=$authPolicy.Name
            $authPolicy | Export-Clixml -Path "$Path\$FolderName\$name.XML" -Encoding $Encoding -Depth 2 -ErrorAction Stop
            $authPolicy | Format-List Name,*Allow*
            $dn=$authPolicy.DistinguishedName
            $usersWithCustomPolicy=Get-User -Filter "AuthenticationPolicy -eq '$dn'"

            if($usersWithCustomPolicy)
            {
                if($usersWithCustomPolicy.GetType().name -eq "PSObject")
                {
                    Write-Host " 1 user has the" $authPolicy.Name "policy." 
                }
                else {
                    Write-Host $usersWithCustomPolicy.count "users have the" $authPolicy.Name "policy."
                }
                $prettierUsers = foreach ($user in $usersWithCustomPolicy)
                {
                    [PsCustomObject] @{
                        'UserPrincipalName'     = [string] $user.userprincipalname
                    }
                }
                $prettierUsers | Export-Clixml -Path "$Path\$FolderName\$name assigned users.XML" -Encoding $Encoding -Depth 3 -ErrorAction Stop
            }

        }
        BuildHTMLReport -XMLPath $folder.FullName -ReportTitle $ReportTitle
    }
    else
    {
        Write-Host "No Authentication Policies found, exiting..."
    }

}
Main