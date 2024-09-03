<#
.SYNOPSIS
    Searches mailboxes for display names containing specified keywords.

.DESCRIPTION
    The Find-MailboxByDisplayName function searches for mailboxes with display names that contain one or more specified keywords.
    The keywords can be passed as parameters or through the pipeline.

.PARAMETER Keywords
    An array of keywords to look for in the display names of mailboxes.

.EXAMPLE
    Find-MailboxByDisplayName -Keywords "John", "Doe"
    Searches for mailboxes with display names containing either "John" or "Doe".

.NOTES
    The function uses the Get-EXOMailbox cmdlet to search for mailboxes and filters the results based on the display name.
#>

function Find-MailboxByDisplayName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of keywords to look for in the display names of mailboxes.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Keywords
    )

    process {
        foreach ($keyword in $Keywords) {
            try {
                Write-Verbose -Message "Searching for Display Names containing $keyword"
                Get-EXOMailbox -Filter "DisplayName -like '*$keyword*'" | Select-Object DisplayName, UserPrincipalName, EmailAddresses | Format-Table
            }
            catch {
                Write-Error -Message "Failed to find Display Names containing $keyword. Error: $_"
            }
        }
    }
}
