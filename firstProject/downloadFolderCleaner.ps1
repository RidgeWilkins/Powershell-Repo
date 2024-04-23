Clear-Host
# File path to organise into folders
$filePath = "D:\Downloads"

# Get all file extensions in thefolder path
$extensions = Get-ChildItem $filePath | Select-Object -ExpandProperty Extension | Select-Object -Unique

# Create a folder for each extension
foreach ($ext in $extensions) {
    $folder = $ext -replace "\.", ""
    if (!(Test-Path "$filePath\$folder")) {
        New-Item -Path "$filePath\$folder" -ItemType Directory
    }
}

$files = Get-ChildItem "D:\Downloads" -Filter "*.pdf" | ForEach-Object { Move-Item "D:\Downloads\pdf" }
$files

# # Move files into the folders
# foreach ($ext in $extensions) {
#     $files = Get-ChildItem $downloadsPath -Filter "*.$ext"
#     try {
#         Move-Item $files "$downloadsPath\$folder" 
#     }
#     catch [System.Management.Automation.ParameterBindingValidationException] {
#         # No files found
#     }
# }
