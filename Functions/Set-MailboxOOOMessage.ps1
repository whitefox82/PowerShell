<#
.SYNOPSIS
    Configures the Out of Office (OOO) message for given mailboxes.

.DESCRIPTION
    The Set-MailboxOOOMessage function sets the Out of Office (OOO) message for one or more mailboxes, 
    identified by their email addresses. Both the email addresses and the OOO message can be provided as parameters.

.PARAMETER MailboxEmails
    An array of email addresses to configure the OOO message for.

.PARAMETER OOOMessage
    The OOO message to set for the specified email addresses.

.EXAMPLE
    Set-MailboxOOOMessage -MailboxEmails "user1@contoso.com", "user2@contoso.com" -OOOMessage "I am currently out of the office and will not be able to respond to emails until my return. Thank you for your understanding."

.EXAMPLE
    $emailAddresses = "user1@contoso.com", "user2@contoso.com", "user3@contoso.com"
    $OOOMessage = "I am currently out of the office and will not be able to respond to emails until my return. Thank you for your understanding."
    Set-MailboxOOOMessage -MailboxEmails $emailAddresses -OOOMessage $OOOMessage

.NOTES
    This function uses the Set-MailboxAutoReplyConfiguration cmdlet to set the Out of Office message.
#>

function Set-MailboxOOOMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of email addresses for the mailboxes to configure the OOO message for.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$MailboxEmails,

        [Parameter(Mandatory, HelpMessage="The OOO message to set for the specified email addresses.")]
        [ValidateNotNullOrEmpty()]
        [string]$OOOMessage
    )

    process {
        foreach ($email in $MailboxEmails) {
            try {
                Write-Verbose "Attempting to set OOO Message for $email"
                Set-MailboxAutoReplyConfiguration -Identity $email -AutoReplyState Enabled -InternalMessage $OOOMessage -ExternalMessage $OOOMessage
            }
            catch {
                Write-Error "Failed to set OOO Message for $email. Error: $_"
            }
        }
    }
}
