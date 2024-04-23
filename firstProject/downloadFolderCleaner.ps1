$downloadsPath = "D:\Downloads"


Get-ChildItem $downloadsPath | Select-Object -ExpandProperty Extension | Select-Object -Unique