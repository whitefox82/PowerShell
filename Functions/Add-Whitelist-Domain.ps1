function Add-Whitelist-Domain {
    <#
    .SYNOPSIS
        Adds the specified domain names to the whitelist in the default hosted content filter policy.

    .DESCRIPTION
        The Add-Whitelist-Domain function adds the specified domain names to the whitelist in the default hosted content filter policy.

    .PARAMETER DomainName
        The domain names to add to the whitelist.

    .EXAMPLE
        Add-Whitelist-Domain -DomainName "contoso.com"
        Adds the contoso.com domain to the whitelist.

    .EXAMPLE
        "contoso1.com", "contoso2.com" | Add-Whitelist-Domain
        Adds the contoso1.com and contoso2.com domains to the whitelist using the pipeline.

    .NOTES
        The function uses the Set-HostedContentFilterPolicy cmdlet to add the specified domain names to the whitelist in the default hosted content filter policy.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="Enter the domain names to add to the whitelist.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$DomainName
    )

    Begin {
        Write-Verbose "Starting Add-Whitelist-Domain"
    }

    Process {
        foreach ($Domain in $DomainName) {
            try {
                Write-Verbose -Message "Adding $Domain to Whitelist"
                Set-HostedContentFilterPolicy -Identity Default -AllowedSenderDomains @{Add = "$Domain" }
            }
            catch {
                Write-Error -Message "Unable to add $Domain to Whitelist. Error: $_"
            }
        }
    }

    End {
        Write-Verbose "Finished Add-Whitelist-Domain"
    }
}
