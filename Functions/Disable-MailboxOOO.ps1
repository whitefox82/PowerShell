<#
.SYNOPSIS
    Disables the Out Of Office (OOO) state for the specified mailboxes.

.DESCRIPTION
    The Disable-MailboxOOO function turns off the Out of Office state for one or more specified mailboxes,
    identified by their email addresses. These email addresses can be passed as parameters or via the pipeline.

.PARAMETER MailboxEmails
    An array of email addresses for which to disable the Out of Office state.

.EXAMPLE
    Disable-MailboxOOO -MailboxEmails "user1@contoso.com", "user2@contoso.com"

.EXAMPLE
    "user3@contoso.com", "user4@contoso.com" | Disable-MailboxOOO

.NOTES
    This function uses the Set-MailboxAutoReplyConfiguration cmdlet to disable the Out of Office state.
    If the cmdlet encounters an error, it will be caught and an error message will be written to the console indicating the failure.
#>

function Disable-MailboxOOO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of email addresses for which to disable the OOO state.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$MailboxEmails
    )

    process {
        foreach ($email in $MailboxEmails) {
            try {
                Write-Verbose -Message "Attempting to disable the Out Of Office state for $email"
                Set-MailboxAutoReplyConfiguration -Identity $email -AutoReplyState Disabled
            }
            catch {
                Write-Error -Message "Failed to disable the Out Of Office state for $email. Error: $_"
            }
        }
    }
}
