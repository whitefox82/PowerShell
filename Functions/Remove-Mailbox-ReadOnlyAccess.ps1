function Remove-Mailbox-ReadOnlyAccess {
    <#
    .SYNOPSIS
        Removes read-only access for the specified recipient email addresses on the specified mailbox email addresses.

    .DESCRIPTION
        The Remove-Mailbox-ReadOnlyAccess function removes read-only access for the specified recipient email addresses on the specified mailbox email addresses.

    .PARAMETER MailboxEmailAddress
        The email addresses of the mailboxes to remove read-only access.

    .PARAMETER RecipientEmail
        The email addresses of the recipients to revoke read-only access.

    .EXAMPLE
        Remove-Mailbox-ReadOnlyAccess -MailboxEmailAddress "mailbox@contoso.com" -RecipientEmail "user@contoso.com"
        Removes read-only access for the user@contoso.com on the mailbox@contoso.com.

    .EXAMPLE
        "mailbox1@contoso.com", "mailbox2@contoso.com" | Remove-Mailbox-ReadOnlyAccess -RecipientEmail "user@contoso.com"
        Removes read-only access for the user@contoso.com on the mailbox1@contoso.com and mailbox2@contoso.com using the pipeline.

    .NOTES
        The function uses the Remove-MailboxPermission cmdlet to remove read-only access for the specified recipients on the specified mailboxes.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$MailboxEmailAddress,

        [Parameter(Mandatory)]
        [string[]]$RecipientEmail
    )

    process {
        foreach ($mailbox in $MailboxEmailAddress) {
            foreach ($Email in $RecipientEmail) {
                try {
                    Write-Verbose -Message "Attempting to remove $Email read only permission from mailbox $mailbox"
                    Remove-MailboxPermission -Identity "$mailbox" -user $Email -AccessRights ReadPermission
                }
                catch {
                    Write-Warning -Message "Unable to remove $Email read only permission from mailbox $mailbox."
                }
            }
        }
    }
}
