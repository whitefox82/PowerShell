<#
.SYNOPSIS
    Grants read-only access to recipients for the specified mailbox email addresses.

.DESCRIPTION
    The Grant-MailboxReadOnlyAccess function assigns read-only access for the specified recipient email addresses 
    on the specified mailbox email addresses. The mailbox and recipient email addresses can be passed as parameters 
    or piped into the function.

.PARAMETER MailboxEmails
    An array of email addresses for the mailboxes to which read-only access needs to be granted.

.PARAMETER RecipientEmails
    An array of recipient email addresses to be granted read-only access.

.EXAMPLE
    Grant-MailboxReadOnlyAccess -MailboxEmails "mailbox@contoso.com" -RecipientEmails "user@contoso.com"

.EXAMPLE
    "mailbox1@contoso.com", "mailbox2@contoso.com" | Grant-MailboxReadOnlyAccess -RecipientEmails "user@contoso.com"

.NOTES
    This function utilizes the Add-MailboxPermission cmdlet to grant read-only access to the specified recipients 
    on the specified mailboxes. In case of an error, the function will write a warning indicating the mailbox 
    and recipient for which the operation failed.
#>

function Add-MailboxReadOnlyAccess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="The email addresses of the mailboxes to grant read-only access.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$MailboxEmails,

        [Parameter(Mandatory, HelpMessage="The email addresses of the recipients to be granted read-only access.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$RecipientEmails
    )

    process {
        foreach ($mailbox in $MailboxEmails) {
            foreach ($recipient in $RecipientEmails) {
                try {
                    Write-Verbose -Message "Attempting to grant $recipient read-only access to mailbox $mailbox"
                    Add-MailboxPermission -Identity $mailbox -User $recipient -AccessRights ReadPermission -InheritanceType All
                }
                catch {
                    Write-Error -Message "Failed to grant $recipient read-only access to mailbox $mailbox. Error: $_"
                }
            }
        }
    }
}
