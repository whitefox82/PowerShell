function sharedmailbox {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$action,

        [Parameter(Position=1, ValueFromPipeline=$true)]
        [string]$variable
    )

    begin {
        $itemsToDelete = @()
        $helpMessage = @"
Usage: sharedmailbox [--add | --convert | --list | --delete | --search | --help]

Actions:
  --add <name>                                                                  Adds a new shared mailbox with the specified name.
  --convert <variable>                                                         Converts a regular mailbox to a shared mailbox.
  --list                                                                       Lists all shared mailboxes in the tenant.
  --delete <variable>                                                          Deletes the specified shared mailbox.
  --search <variable>                                                          Searches for shared mailboxes that match the specified search string.
  --help                                                                       Displays this help message.
"@
        $validActions = @("--add", "--convert", "--list", "--delete", "--search", "--help")
    }

    process {
        if ($validActions -notcontains $action) {
            Write-Output "Invalid action. Use --help to see the list of available actions."
            Write-Output $helpMessage
            return
        }

        if ($action -eq "--delete" -and $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('variable')) {
            $itemsToDelete += $variable
        } elseif ($action -eq "--delete" -and !$PSCmdlet.MyInvocation.BoundParameters.ContainsKey('variable')) {
            $itemsToDelete += $_
        } else {
            switch ($action) {
                "--add" {
                    if (-not $variable) {
                        Write-Error "Please specify the name of the new shared mailbox."
                    } else {
                        $UserPrincipalName = Read-Host "Please enter the User Principal Name (UPN)"
                        $PrimarySmtpAddress = Read-Host "Please enter the Primary SMTP Address (optional, press Enter to skip)"
                        
                        try {
                            if ($PrimarySmtpAddress) {
                                New-Mailbox -Name $variable -Alias $variable -PrimarySmtpAddress $PrimarySmtpAddress -Shared
                            } else {
                                New-Mailbox -Name $variable -Alias $variable -PrimarySmtpAddress $UserPrincipalName -Shared
                            }
                            Write-Output "Shared mailbox '$variable' created successfully."
                        } catch {
                            Write-Error "Failed to create shared mailbox: $_"
                        }
                    }
                }
                "--convert" {
                    if (-not $variable) {
                        Write-Error "Please specify the UPN of the mailbox to convert."
                    } else {
                        try {
                            Set-Mailbox -Identity $variable -Type Shared
                            Write-Output "Mailbox '$variable' converted to shared mailbox successfully."
                        } catch {
                            Write-Error "Failed to convert mailbox: $_"
                        }
                    }
                }
                "--list" {
                    # List all shared mailboxes
                    $sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox
                    $sharedMailboxes | ForEach-Object { Write-Output $_.UserPrincipalName }
                }
                "--search" {
                    if (-not $variable) {
                        Write-Error "Please specify a search string."
                    } else {
                        $sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox
                        $matches = $sharedMailboxes | Where-Object { $_.UserPrincipalName -like "*$variable*" }
                        if ($matches) {
                            $matches | ForEach-Object { Write-Output $_.UserPrincipalName }
                        } else {
                            Write-Output "No matches found for '$variable'"
                        }
                    }
                }
                "--help" {
                    Write-Output $helpMessage
                }
            }
        }
    }

    end {
        if ($action -eq "--delete") {
            foreach ($item in $itemsToDelete) {
                try {
                    Remove-Mailbox -Identity $item -Confirm:$false
                    Write-Output "Shared mailbox '$item' deleted successfully."
                } catch {
                    Write-Error "Failed to delete shared mailbox '$item': $_"
                }
            }
        }
    }
}
