<#
.SYNOPSIS
    Assigns full access permissions to recipients for the given mailbox email addresses.

.DESCRIPTION
    The Assign-MailboxFullAccess function provides full access permissions for one or more specified mailboxes 
    to one or more recipient email addresses. The mailbox and recipient email addresses can be provided as 
    parameters or piped into the function.

.PARAMETER MailboxEmails
    An array of email addresses for the mailboxes that need to be configured.

.PARAMETER RecipientEmails
    An array of recipient email addresses to be granted full access permissions.

.EXAMPLE
    Assign-MailboxFullAccess -MailboxEmails "mailbox@contoso.com" -RecipientEmails "recipient1@contoso.com", "recipient2@contoso.com"

.EXAMPLE
    "mailbox1@contoso.com", "mailbox2@contoso.com" | Assign-MailboxFullAccess -RecipientEmails "recipient@contoso.com"

.NOTES
    This function relies on the Add-MailboxPermission cmdlet. The Identity parameter of this cmdlet is assigned 
    the mailbox email address, and the User parameter specifies the recipient email addresses. The AccessRights 
    and InheritanceType parameters determine the level of access and inheritance behavior.
#>

function Add-MailboxFullAccess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="The email addresses of the mailboxes to configure.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$MailboxEmails,

        [Parameter(Mandatory, HelpMessage="The recipient email addresses to be granted full access.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$RecipientEmails
    )

    process {
        foreach ($mailbox in $MailboxEmails) {
            foreach ($recipient in $RecipientEmails) {
                try {
                    Write-Verbose -Message "Attempting to grant $recipient full access to mailbox $mailbox"
                    Add-MailboxPermission -Identity $mailbox -User $recipient -AccessRights FullAccess -InheritanceType All
                }
                catch {
                    Write-Error -Message "Failed to grant $recipient full access to mailbox $mailbox. Error: $_"
                }
            }
        }
    }
}
