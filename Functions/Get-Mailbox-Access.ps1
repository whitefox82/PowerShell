function Get-Mailbox-Access {
    <#
    .SYNOPSIS
        Retrieves the permissions for the specified mailbox email addresses.
        
    .DESCRIPTION
        The Get-Mailbox-Access function retrieves the permissions for one or more specified mailbox email addresses.
        The email addresses can be passed as parameters or via the pipeline.

    .PARAMETER EmailAddress
        An array of email addresses of the mailboxes you want to retrieve permissions for.

    .EXAMPLE
        Get-Mailbox-Access -EmailAddress "mailbox1@contoso.com", "mailbox2@contoso.com"
        
        Retrieves the permissions for the mailbox1@contoso.com and mailbox2@contoso.com mailboxes.

    .EXAMPLE
        "mailbox1@contoso.com", "mailbox2@contoso.com" | Get-Mailbox-Access
        
        Retrieves the permissions for the mailbox1@contoso.com and mailbox2@contoso.com mailboxes.

    .NOTES
        This cmdlet requires the Identity parameter of the Get-MailboxPermission cmdlet to be set to the email address of the mailbox you want to retrieve permissions for. The Select-Object and Format-List cmdlets are used to select the Identity, User, and AccessRights properties of the mailbox permission objects and format the output as a list.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$EmailAddress
    )

    process {
        foreach ($email in $EmailAddress) {
            try {
                Write-Verbose -Message "Searching for permissions for mailbox $email"
                Get-MailboxPermission -Identity "$email" | Select-Object Identity, User, AccessRights | Format-List
            }
            catch {
                Write-Warning -Message "Unable to find permissions for mailbox $email."
            }
        }
    }
}
