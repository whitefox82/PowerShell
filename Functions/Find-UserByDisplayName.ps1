<#
.SYNOPSIS
    Searches for users where the display name contains specified keywords.

.DESCRIPTION
    The Find-UserByDisplayName function searches for users where the display name contains one or more specified keywords. 
    The keywords can be passed as parameters or through the pipeline.

.PARAMETER Keywords
    An array of keywords to look for in the display names of users.

.EXAMPLE
    Find-UserByDisplayName -Keywords "Jane Doe"
    Searches for users where the display name contains "Jane Doe".

.NOTES
    The function uses the Get-User cmdlet to search for users and filters the results based on the display name.
#>
function Find-UserByDisplayName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="An array of keywords to look for in the display names of users.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Keywords
    )

    process {
        foreach ($keyword in $Keywords) {
            try {
                Write-Verbose -Message "Searching for users with display names containing $keyword"
                Get-User -Filter "DisplayName -like '*$keyword*'" | Select-Object DisplayName, UserPrincipalName, EmailAddresses | Format-Table
            }
            catch {
                Write-Error -Message "Failed to find users with display names containing $keyword. Error: $_"
            }
        }
    }
}
