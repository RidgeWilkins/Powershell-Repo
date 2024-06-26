# Creates the function used later on in the script
function folderCleanUp {
    param(
        $filePath
    )
    # Gets the list of all unique extensions in the file path
    $extensions = Get-ChildItem -Path $filePath | Select-Object -ExpandProperty Extension | Select-Object -Unique
    
    # For each unique extension found above runs through the following
    foreach ($ext in $extensions) {
        # Creates a trimmed version removing the . at the start for the folder name later
        $trimmedExtention = $ext.TrimStart(".")

        # Checks if the path exists - if it doesn't then it creates the path using the trimmed version above and then moves the files that have that extension
        if (!(Test-Path -Path $filePath\$trimmedExtention)) {
            New-Item -Path "$filePath\$trimmedExtention" -ItemType Directory
            Write-Output "Path $trimmedExtention created, moving files into folder"
            $files = Get-ChildItem -Path $filePath -Filter "*$ext"
            foreach ($file in $files) {
                Move-Item -Path $file -Destination "$filePath\$trimmedExtention"
            }
        }
        else {
            # If the path already existed then it just moves the files
            Write-Output "Path Already Exists, moving files into folder"
            $files = Get-ChildItem -Path $filePath -Filter "*$ext"
            foreach ($file in $files) {
                Move-Item -Path $file -Destination "$filePath\$trimmedExtention"
            }
        }
    }
    # Final output explaining that it has been completed and waits for the user to hit enter to exit the script
    Write-Output "Done"

    # Gets the list of all files that were not moved and outputs them to the user
    $filesRemaining = Get-ChildItem -Path $filePath
    foreach ($file in $filesRemaining) {
        if (!($file.PSIsContainer)) {
            Write-Output "$file could not be moved, please move it manually. This may be due to text in the file name"
        }
    }

    Write-Output "Press Enter to exit"

    Read-Host
    exit
}

# Takes the user input and tests it to see if it is valid, if it is then it runs the function above
do {
    $filePath = Read-Host "Enter File Path, or q to quit"
    # If user input is q then exits the script
    if ($filePath -eq 'q') {
        exit
    }
    # If the path does not exist then it will ask the user to enter a valid path
    if (!(Test-Path -Path $filePath)) { 
        Write-Output "$filePath does not exist, please try again"
        continue
    }
    # Runs the function with the filepath entered by the user
    folderCleanUp $filePath
} while ($true)