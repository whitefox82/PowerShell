<#
.SYNOPSIS
    Retrieves mailboxes created within the specified duration.

.DESCRIPTION
    The Find-NewlyCreatedMailboxes function retrieves mailboxes created within a specified duration.
        
.PARAMETER PastDays
    The number of past days to search for mailbox creation. Default value is 30 days.

.EXAMPLE
    Find-NewlyCreatedMailboxes -PastDays 15
    Retrieves mailboxes created within the last 15 days.

.NOTES
    The function uses the Get-EXOMailbox cmdlet to search for mailboxes and filters the results based on the mailbox creation date.
#>
function Find-NewlyCreatedMailboxes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, HelpMessage="The number of past days to search for mailbox creation. Default value is 30 days.")]
        [ValidateNotNullOrEmpty()]
        [int]$PastDays = 30
    )

    begin {
        $lookBackDate = (Get-Date).AddDays(-$PastDays)
    }

    process {
        try {
            $mailboxResults = Get-EXOMailbox -ResultSize Unlimited -Filter "WhenMailboxCreated -gt '$lookBackDate'" -Properties WhenMailboxCreated | Select-Object UserPrincipalName, DisplayName, PrimarySmtpAddress
            if ($null -eq $mailboxResults) {
                Write-Output "No new mailboxes"
            }
            else {
                Write-Output $mailboxResults
            }
        }
        catch {
            Write-Error -Message "Failed to find newly created mailboxes. Error: $_"
        }
    }
}
