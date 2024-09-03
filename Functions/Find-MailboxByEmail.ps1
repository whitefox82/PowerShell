<#
.SYNOPSIS
    Searches for mailboxes with email addresses containing specified keywords.

.DESCRIPTION
    The Find-MailboxByEmail function searches for mailboxes with email addresses that contain one or more specified keywords.
    The keywords can be passed as parameters or through the pipeline.

.PARAMETER Keywords
    An array of keywords to search for in the email addresses of mailboxes.

.EXAMPLE
    Find-MailboxByEmail -Keywords "john@contoso.com", "doe@contoso.com"
    Searches for mailboxes with email addresses containing either "john@contoso.com" or "doe@contoso.com".

.NOTES
    The function uses the Get-EXOMailbox cmdlet to search for mailboxes and filters the results based on the email addresses.
#>
function Find-MailboxByEmail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of keywords to search for in the email addresses of mailboxes.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Keywords
    )

    process {
        foreach ($keyword in $Keywords) {
            try {
                Write-Verbose -Message "Searching for Email Addresses containing $keyword"
                Get-EXOMailbox -Filter "EmailAddresses -like '*$keyword*'" | Select-Object DisplayName, UserPrincipalName, EmailAddresses | Format-Table
            }
            catch {
                Write-Error -Message "Failed to find Email Addresses containing $keyword. Error: $_"
            }
        }
    }
}
