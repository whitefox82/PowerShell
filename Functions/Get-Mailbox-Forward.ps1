<#
.Synopsis
    Retrieves forwarding mailboxes for specific users by their User Principal Names (UPNs) and displays them in the console.

.Description
    This function gets a list of users from a specified list of UPNs, checks if their mailboxes have forwarding enabled, and displays the results in the console.

.Parameters
    -UPNs (Mandatory): A comma-separated list of UPNs to filter the users.

.Examples
    Get-ForwardingMailboxes -UPNs "user1@contoso.com, user2@contoso.com"

.Notes
    This function requires Exchange Online PowerShell module to be installed and an active connection to Exchange Online.
#>
function Get-Mailbox-Forward {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="A comma-separated list of UPNs to filter the users.")]
        [ValidateNotNullOrEmpty()]
        [string]$UPNs
    )

    begin {
        Import-Module -Name ExchangeOnlineManagement
    }

    process {
        try {
            # Convert comma-separated UPNs into an array
            $upnArray = $UPNs -split ',' | ForEach-Object { $_.Trim() }

            # Initialize an empty results array
            $forwardingInfo = @()

            # Loop through the UPNs
            foreach ($upn in $upnArray) {
                $mailbox = Get-Mailbox -Identity $upn -ErrorAction SilentlyContinue
                
                # Check if the mailbox exists and if forwarding is enabled
                if ($mailbox -and $mailbox.DeliverToMailboxAndForward) {
                    $result = New-Object -TypeName PSObject -Property @{
                        UserPrincipalName = $upn
                        ForwardingAddress = $mailbox.ForwardingAddress
                        ForwardingSMTP = $mailbox.ForwardingSmtpAddress
                        DeliverToMailboxAndForward = $mailbox.DeliverToMailboxAndForward
                    }
                    $forwardingInfo += $result
                }
            }

            # Display the results in the console
            $forwardingInfo
        }
        catch {
            Write-Warning -Message "An error occurred while retrieving forwarding mailboxes."
        }
    }
}
