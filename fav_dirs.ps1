$FavDirFile = "$env:USERPROFILE\favorite_dirs.txt"

if (-not (Test-Path $FavDirFile)) {
    New-Item -Path $FavDirFile -ItemType File -Force | Out-Null
}

function List-Favorites {
    $favorites = Get-Content $FavDirFile | ForEach-Object {
        $parts = $_ -split ' ', 2
        [PSCustomObject]@{
            Name = $parts[0]
            Path = $parts[1]
        }
    }

    Write-Output "Favorite Directories:"
    $favorites | Format-Table -AutoSize
}

function Add-Favorite {
    param (
        [string]$Name,
        [string]$Path
    )
    if (-not $Name -or -not $Path) {
        Write-Output "Usage: Add-Favorite -Name <name> -Path <path>"
        return
    }

    $exists = Select-String -Path $FavDirFile -Pattern "^$Name "
    if ($exists) {
        Write-Output "Favorite directory '$Name' already exists."
        return
    }

    "$Name $Path" | Out-File -Append -FilePath $FavDirFile
    Write-Output "Added '$Name' with path '$Path'."
}

function Update-Favorite {
    param (
        [string]$Name,
        [string]$NewPath
    )
    if (-not $Name -or -not $NewPath) {
        Write-Output "Usage: Update-Favorite -Name <name> -NewPath <new_path>"
        return
    }

    $exists = Select-String -Path $FavDirFile -Pattern "^$Name "
    if (-not $exists) {
        Write-Output "Favorite directory '$Name' does not exist."
        return
    }

    (Get-Content $FavDirFile | Where-Object { $_ -notmatch "^$Name " }) | Set-Content $FavDirFile
    "$Name $NewPath" | Out-File -Append -FilePath $FavDirFile
    Write-Output "Updated '$Name' to path '$NewPath'."
}

function Rename-Favorite {
    param (
        [string]$OldName,
        [string]$NewName
    )
    if (-not $OldName -or -not $NewName) {
        Write-Output "Usage: Rename-Favorite -OldName <old_name> -NewName <new_name>"
        return
    }

    $exists = Select-String -Path $FavDirFile -Pattern "^$OldName "
    if (-not $exists) {
        Write-Output "Favorite directory '$OldName' does not exist."
        return
    }

    $newEntries = (Get-Content $FavDirFile | ForEach-Object {
        if ($_ -match "^$OldName ") {
            $_ -replace "^$OldName ", "$NewName "
        } else {
            $_
        }
    })

    $newEntries | Set-Content $FavDirFile
    Write-Output "Renamed '$OldName' to '$NewName'."
}

function Delete-Favorite {
    param (
        [string]$Name
    )
    if (-not $Name) {
        Write-Output "Usage: Delete-Favorite -Name <name>"
        return
    }

    $exists = Select-String -Path $FavDirFile -Pattern "^$Name "
    if (-not $exists) {
        Write-Output "Favorite directory '$Name' does not exist."
        return
    }

    (Get-Content $FavDirFile | Where-Object { $_ -notmatch "^$Name " }) | Set-Content $FavDirFile
    Write-Output "Deleted '$Name'."
}

function Change-Directory {
    param (
        [string]$Name
    )
    if (-not $Name) {
        Write-Output "Usage: Change-Directory -Name <name>"
        return
    }

    $path = (Select-String -Path $FavDirFile -Pattern "^$Name " | ForEach-Object { $_.Line.Split(' ', 2)[1] })
    if (-not $path) {
        Write-Output "Favorite directory '$Name' does not exist."
        return
    }

    Set-Location -Path $path
    Write-Output "Changed directory to '$path'."
}

function Prune-Favorites {
    $entries = Get-Content $FavDirFile
    $validEntries = @()

    foreach ($entry in $entries) {
        $parts = $entry -split ' ', 2
        $name = $parts[0]
        $path = $parts[1]

        if (Test-Path $path) {
            $validEntries += $entry
        } else {
            Write-Output "Directory '$path' does not exist. Removing '$name'."
        }
    }

    $validEntries | Set-Content $FavDirFile
}

function Show-Help {
    Write-Output "Usage: .\fav_dirs.ps1 {list|add|update|delete|cd|rename|prune|help} [arguments]"
    Write-Output ""
    Write-Output "Commands:"
    Write-Output "  list                        - List all favorite directories."
    Write-Output "  add <name> <path>           - Add a new favorite directory."
    Write-Output "  update <name> <new_path>    - Update the path of an existing favorite directory."
    Write-Output "  delete <name>               - Delete a favorite directory."
    Write-Output "  cd <name>                   - Change to the directory of a favorite directory."
    Write-Output "  rename <old_name> <new_name> - Rename a favorite directory."
    Write-Output "  prune                       - Remove entries with non-existent directories."
    Write-Output "  help                        - Show this help message."
}

# Check the number of arguments
if ($args.Count -eq 0 -or $args[0] -eq "help") {
    Show-Help
    exit
}

$Action = $args[0]
$Name = if ($args.Count -gt 1) { $args[1] } else { $null }
$Path = if ($args.Count -gt 2) { $args[2] } else { $null }
$NewName = if ($args.Count -gt 2) { $args[2] } else { $null }

switch ($Action) {
    "list" { List-Favorites }
    "add" { Add-Favorite -Name $Name -Path $Path }
    "update" { Update-Favorite -Name $Name -NewPath $Path }
    "delete" { Delete-Favorite -Name $Name }
    "cd" { Change-Directory -Name $Name }
    "rename" { Rename-Favorite -OldName $Name -NewName $NewName }
    "prune" { Prune-Favorites }
    "help" { Show-Help }
    default { Write-Output "Invalid command. Use 'help' to see usage instructions." }
}
