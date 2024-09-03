<#
.SYNOPSIS
    Manages the whitelist for email addresses and domains in hosted content filter policies.

.DESCRIPTION
    This function allows you to list, add, remove, or search for email addresses and domains in the whitelist
    of hosted content filter policies.

.PARAMETER action
    Specifies the action to perform. Valid values are "--list", "--add", "--remove", "--search", and "--help".

.PARAMETER variable
    Specifies the variable (email address or domain) to be added, removed, listed, or searched.

.EXAMPLE
    whitelist --list domain
    Lists all allowed sender domains in the hosted content filter policies.

.EXAMPLE
    whitelist --add trusted@example.com
    Adds the email address trusted@example.com to the allowed senders list.

.EXAMPLE
    whitelist --remove trusted@example.com
    Removes the email address trusted@example.com from the allowed senders list.

.EXAMPLE
    whitelist --search example
    Searches for any allowed senders or domains that match the string "example".

.EXAMPLE
    whitelist --search "trusted.com" | whitelist --remove
    Searches for any allowed senders or domains that match the string "trusted.com" and removes them.

.EXAMPLE
    whitelist --help
    Displays the help message.

.NOTES
    This function requires the appropriate permissions to manage hosted content filter policies.
#>

function whitelist {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$action,

        [Parameter(Position=1, ValueFromPipeline=$true)]
        [string]$variable
    )

    begin {
        $itemsToRemove = @()
        $helpMessage = @"
Usage: whitelist [--list | --add | --remove | --search | --help] [variable]

Actions:
  --list domain|email          Lists all allowed sender domains or email addresses.
  --add <variable>             Adds an email address or domain to the allowed list.
  --remove <variable>          Removes an email address or domain from the allowed list.
  --search <variable>          Searches for email addresses or domains in the allowed list.
  --help                       Displays this help message.
"@
        $validActions = @("--list", "--add", "--remove", "--search", "--help")
    }

    process {
        if ($validActions -notcontains $action) {
            Write-Output "Invalid action. Use --help to see the list of available actions."
            Write-Output $helpMessage
            return
        }

        if ($action -eq "--remove" -and $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('variable')) {
            $itemsToRemove += $variable
        } elseif ($action -eq "--remove" -and !$PSCmdlet.MyInvocation.BoundParameters.ContainsKey('variable')) {
            $itemsToRemove += $_
        } else {
            switch ($action) {
                "--list" {
                    if ($variable -eq "domain") {
                        Get-HostedContentFilterPolicy | Select-Object -ExpandProperty AllowedSenderDomains
                    } elseif ($variable -eq "email") {
                        Get-HostedContentFilterPolicy | Select-Object -ExpandProperty AllowedSenders
                    } else {
                        Write-Output "Invalid request, please specify 'domain' or 'email'"
                    }
                }
                "--add" {
                    if ($variable -match '^[^@]+@[^@]+\.[^@]+$') {
                        Write-Verbose -Message "Adding $variable to Allowed Senders"
                        Set-HostedContentFilterPolicy -Identity Default -AllowedSenders @{Add=$variable}
                    } elseif ($variable -notmatch '@') {
                        Write-Verbose -Message "Adding $variable to Allowed Sender Domains"
                        Set-HostedContentFilterPolicy -Identity Default -AllowedSenderDomains @{Add=$variable}
                    } else {
                        Write-Output "Invalid variable: contains '@' but is not a valid email"
                    }
                }
                "--search" {
                    $senders = Get-HostedContentFilterPolicy | Select-Object -ExpandProperty AllowedSenders
                    $domains = Get-HostedContentFilterPolicy | Select-Object -ExpandProperty AllowedSenderDomains
                    $allItems = $senders + $domains

                    $matches = $allItems | Where-Object { $_ -like "*$variable*" }
                    if ($matches) {
                        $matches | ForEach-Object { Write-Output "$_" }
                    } else {
                        Write-Output "No matches found for $variable"
                    }
                }
                "--help" {
                    Write-Output $helpMessage
                }
            }
        }
    }

    end {
        if ($action -eq "--remove") {
            foreach ($item in $itemsToRemove) {
                if ($item -match '^[^@]+@[^@]+\.[^@]+$') {
                    Write-Verbose -Message "Removing $item from Allowed Senders"
                    Set-HostedContentFilterPolicy -Identity Default -AllowedSenders @{Remove=$item}
                } elseif ($item -notmatch '@') {
                    Write-Verbose -Message "Removing $item from Allowed Sender Domains"
                    Set-HostedContentFilterPolicy -Identity Default -AllowedSenderDomains @{Remove=$item}
                } else {
                    Write-Output "Invalid item: contains '@' but is not a valid email"
                }
            }
        }
    }
}
