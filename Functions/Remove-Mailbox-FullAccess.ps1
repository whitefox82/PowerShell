function Remove-Mailbox-FullAccess {
    <#
    .SYNOPSIS
        Removes the full access permission for the specified recipients on the specified email addresses.

    .DESCRIPTION
        The Remove-Mailbox-FullAccess function removes the full access permission for the specified recipients on one or more specified email addresses.
        The email addresses and recipient email addresses can be passed as parameters or via the pipeline.

    .PARAMETER EmailAddress
        An array of email addresses of the mailboxes to remove the full access permissions from.

    .PARAMETER RecipientEmail
        An array of recipient email addresses to remove the full access permissions for.

    .EXAMPLE
        Remove-Mailbox-FullAccess -EmailAddress user1@contoso.com, user2@contoso.com -RecipientEmail recipient1@contoso.com, recipient2@contoso.com
        
        Removes the full access permission for the recipients `recipient1@contoso.com` and `recipient2@contoso.com` on the email addresses `user1@contoso.com` and `user2@contoso.com`.

    .EXAMPLE
        Get-Content C:\recipients.txt | Remove-Mailbox-FullAccess -EmailAddress user1@contoso.com, user2@contoso.com
        
        Removes the full access permission for all recipients in the file `C:\recipients.txt` on the email addresses `user1@contoso.com` and `user2@contoso.com`.

    .NOTES
        This cmdlet requires the Exchange Management Shell to be installed and properly configured.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$EmailAddress,
        [Parameter(Mandatory)]
        [string[]]$RecipientEmail
    )

    process {
        foreach ($recipient in $RecipientEmail) {
            try {
                Write-Verbose "Attempting to remove $recipient's full access permission to mailbox(es) $EmailAddress"
                Remove-MailboxPermission -Identity $EmailAddress -User $recipient -AccessRights FullAccess -InheritanceType All -Confirm:$false
            } catch {
                Write-Warning "Unable to find permissions for mailbox $recipient."
            }
        }
    }
}
