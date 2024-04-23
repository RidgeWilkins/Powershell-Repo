function folderCleanUp {
    param(
        $filePath
    )
    $extensions = Get-ChildItem $filePath | Select-Object -ExpandProperty Extension | Select-Object -Unique

    foreach ($ext in $extensions) {
        $trimmedExtention = $ext.TrimStart(".")
        
        if (!(Test-Path $filePath\$trimmedExtention)) {
            New-Item -Path "$filePath\$trimmedExtention" -ItemType Directory
            Write-Output "Path $trimmedExtention created, moving files into folder"
            $files = Get-ChildItem $filePath -Filter "*$ext"
            foreach ($file in $files) {
                Move-Item $file "$filePath\$trimmedExtention"
            }
        }
        else {
            Write-Output "Path Already Exists, moving files into folder"
            $files = Get-ChildItem $filePath -Filter "*$ext"
            foreach ($file in $files) {
                Move-Item $file "$filePath\$trimmedExtention"
            }
        }
    }
    Write-Output "Done"
    Read-Host
    exit
}

$filePath = Read-Host "Enter File Path, or q to quit"

while ($filePath -ne 'q') {
    while (!(Test-Path $filePath)) {
        Write-Output "$filePath does not exist, please enter a filepath that exists"
        $filePath = Read-Host "Enter File Path, or q to quit"
    }
    folderCleanUp $filePath
} exit
