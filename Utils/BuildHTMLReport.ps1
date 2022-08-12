    # Thanks to AdamTheAutomator for how to add CSS to HTML
    # https://adamtheautomator.com/html-report/

    function BuildHTMLReport 
    {
        param(
        [string]$XMLPath,
        [string]$ReportTitle

        )
        $header = @"
        <style> 
        h1 {
                font-family: Tahoma, Helvetica, sans-serif;
                color: #000000;
                font-size: 26px;
            }
            h2 {
                font-family: Tahoma, Helvetica, sans-serif;
                color: #4b4ec1;
                font-size: 24px;
            }
            table {
                font-size: 12px;
                border: 0px; 
                font-family: Tahoma, Helvetica, sans-serif;
            } 
            
            td {
                padding: 4px;
                margin: 0px;
                border: 0;
            }
            
            th {
                background: #99959b;
                color: #fff;
                font-size: 11px;
                text-transform: uppercase;
                padding: 10px 15px;
                vertical-align: middle;
            }
        
            tbody tr:nth-child(even) {
                background: #f0f0f2;
            }
        
                #CreationDate {
        
                font-family: Tahoma, Helvetica, sans-serif;
                color: #000000;
                font-size: 12px;
        
            }
              
        </style> 
"@

        

        $tables=@()
        $tables+=,"<H1>$($ReportTitle)</H1>"
        $tables+=,"<p id='CreationDate'>Report Generation Time: $(Get-Date)</p>"
        $pattern=".+?(?=.XML)"
        $files=Get-ChildItem -Path $XMLPath | Sort-Object CreationTime
        $folder=Get-Item -Path $XMLPath
        $HTMLFile=$folder.FullName+"\Report.html"

        Write-Host ""
        Write-Host "-----Found and Processing:-----"
        Write-Host ""
        foreach($file in $files){
            Write-Host $file.Name
            $objectName=[regex]::Matches($file.name, $pattern).Value

            $tables+=,(Import-Clixml -Path $file.fullname | ConvertTo-Html -As list -Fragment -PreContent "<h2>$objectName</h2>") 
        }
        ConvertTo-Html -Body $(foreach ($table in $tables){$table}) -Head $header -Title $ReportTitle | Out-File $HTMLFile
        Write-Host ""
        Write-Host "----- Generated HTML Report -----"
        Write-Host ""
        Get-ChildItem -Filter "*.html" -Path $XMLPath
    }