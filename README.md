# ExchangeDiscovery

A series of PowerShell scripts to gather information about Exchange Server and Exchange Online deployments.

# How it works
The scripts read a .CSV file with the list of cmdlets to run, the cmdlets are then run and saved into XML files under a folder with this format, as an example, `C:\ExchangeDiscovery\EXO_20220725122545`

Then, the script generates an HTML report with the XML files as an input.

# How To Use


## Exchange Server

```powershell
PS> .\ExchangeServerDiscovery.ps1 -Path "C:\ExchangeDiscovery\"
```

## Exchange Online

```powershell
PS> .\ExchangeOnlineDiscovery.ps1 -Path "C:\ExchangeDiscovery\"
```

# Contributing
Contributions are very well welcomed.

# To-do
A lot, mostly error handling and better output.
