<#
.Synopsis
    Creates a new shared mailbox with the specified name and email address.

.Description
    This function takes a mailbox name and an email address as input and creates a new shared mailbox using the provided information.

.Parameters
    -MailboxName (Mandatory, accepts pipeline input): The name of the shared mailbox to be created.
    -MailboxEmailAddress (Mandatory, accepts pipeline input): The email address for the new shared mailbox.

.Examples
    New-SharedMailbox-Mailbox -MailboxName "HR Support" -MailboxEmailAddress "hrsupport@contoso.com"
    Get-Content -Path "C:\shared_mailboxes.csv" | ForEach-Object { New-SharedMailbox-Mailbox -MailboxName $_.Name -MailboxEmailAddress $_.EmailAddress }

.Notes
    This function requires Exchange Online PowerShell module to be installed and an active connection to Exchange Online.
#>
function New-SharedMailbox-Mailbox {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The name of the shared mailbox to be created."
        )]
        [string]$MailboxName,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The email address for the new shared mailbox."
        )]
        [string]$MailboxEmailAddress
    )

    process {
        if ($MailboxName -and $MailboxEmailAddress) {
            try {
                Write-Verbose -Message "Attempting to Create Shared Mailbox $MailboxName With Email Address $MailboxEmailAddress"
                New-Mailbox -Shared -Name "$MailboxName" -DisplayName $MailboxName -PrimarySmtpAddress "$MailboxEmailAddress"
            }
            catch {
                Write-Warning -Message "Unable to Create Shared Mailbox $MailboxName With Email Address $MailboxEmailAddress."
            }
        }
        else {
            Write-Output "You have not entered in a MailboxName or MailboxEmailAddress variable."
        }
    }
}
