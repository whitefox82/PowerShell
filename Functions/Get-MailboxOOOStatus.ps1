<#
.SYNOPSIS
    Retrieves the Out of Office (OOO) state and message for the given mailboxes.

.DESCRIPTION
    The Get-MailboxOOOStatus function retrieves the Out of Office (OOO) state and message for one or more mailboxes,
    identified by their email addresses. The email addresses can be provided as parameters.

.PARAMETER MailboxEmails
    An array of email addresses for which to get the OOO state and message.

.EXAMPLE
    Get-MailboxOOOStatus -MailboxEmails "user1@contoso.com"

.EXAMPLE
    $emailAddresses = "user1@contoso.com", "user2@contoso.com"
    Get-MailboxOOOStatus -MailboxEmails $emailAddresses

.NOTES
    This function uses the Get-MailboxAutoReplyConfiguration cmdlet to get the Out of Office message and state.
#>

function Get-MailboxOOOStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of email addresses for which to get the OOO state and message.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$MailboxEmails
    )

    process {
        foreach ($email in $MailboxEmails) {
            try {
                Write-Verbose -Message "Attempting to retrieve the OOO state of $email"
                Get-MailboxAutoReplyConfiguration -Identity $email | Select-Object Identity, AutoReplyState, ExternalMessage, InternalMessage | Format-List
            }
            catch {
                Write-Error -Message "Failed to retrieve the OOO state for $email. Error: $_"
            }
        }
    }
}
