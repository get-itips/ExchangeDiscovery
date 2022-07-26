# ExchangeDiscovery

A series of PowerShell scripts to gather information about Exchange Server and Exchange Online deployments.

# How it works
The scripts read a .CSV file with the list of cmdlets to run, the cmdlets are then run and saved into XML files under a folder with this format, as an example, `C:\ExchangeDiscovery\EXO_20220725122545`

Then, you can rebuild these XML files into more readable objects using `RebuildObjects.ps1`.

# How To Use


## Exchange Server

```powershell
PS> .\ExchangeServerDiscovery.ps1 -Path "C:\ExchangeDiscovery\"
```

## Exchange Online

```powershell
PS> .\ExchangeOnlineDiscovery.ps1 -Path "C:\ExchangeDiscovery\"
```

# Rebuild exported information into objects
For convenience, the XML files can be loaded into objects that you can read and query inside a PowerShell window, you just have to pass this as a parameter:

```powershell
PS> .\RebuildObjects.ps1 -Path "C:\ExchangeDiscovery\EXO_20220725122545"
```
