<#
.SYNOPSIS
    Searches for mailboxes where User Principal Name (UPN) contains specified keywords.

.DESCRIPTION
    The Find-MailboxByUPN function searches for mailboxes where the User Principal Name (UPN) contains one or more specified keywords.
    The keywords can be passed as parameters or through the pipeline.

.PARAMETER Keywords
    An array of keywords to search for in the User Principal Name (UPN).

.EXAMPLE
    Find-MailboxByUPN -Keywords "jdoe"
    Searches for mailboxes where User Principal Name contains "jdoe".

.NOTES
    The function uses the Get-EXOMailbox cmdlet to search for mailboxes and filters the results based on the User Principal Name (UPN).
#>
function Find-MailboxByUPN {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of keywords to search for in the User Principal Name (UPN).")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Keywords
    )

    process {
        foreach ($keyword in $Keywords) {
            try {
                Write-Verbose -Message "Searching for User Principal Name containing $keyword"
                Get-EXOMailbox -Filter "UserPrincipalName -like '*$keyword*'" | Select-Object DisplayName, UserPrincipalName, EmailAddresses | Format-Table
            }
            catch {
                Write-Error -Message "Failed to find User Principal Name containing $keyword. Error: $_"
            }
        }
    }
}
