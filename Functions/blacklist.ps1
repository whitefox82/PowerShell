function blacklist {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet("--list", "--add", "--remove", "--search", "--audit", "--help")]
        [string]$Action,

        [Parameter(Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Variable
    )

    begin {
        $helpMessage = @"
Usage: blacklist [--list | --add | --remove | --search | --audit | --help] [variable]

Actions:
  --list domain|email          Lists all blocked sender domains or email addresses.
  --add <variable>             Adds an email address or domain to the blocked list.
  --remove <variable>          Removes an email address or domain from the blocked list.
  --search <variable>          Searches for email addresses or domains in the blocked list.
  --audit                      Lists and removes emails that have domains in the blocked domain list.
  --help                       Displays this help message.
"@
        # Check if ExchangeOnlineManagement module is installed
        if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
            Write-Output "ExchangeOnlineManagement module is not installed. Installing..."
            Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
        }

        # Check if connected to Exchange Online
        if (-not (Get-Module -Name ExchangeOnlineManagement)) {
            Write-Output "Connecting to Exchange Online..."
            Connect-ExchangeOnline -UserPrincipalName user@example.com -ShowProgress $true
        }
    }

    process {
        switch ($Action) {
            "--list" { List-Blacklist $Variable }
            "--add" { Add-ToBlacklist $Variable }
            "--remove" { Remove-FromBlacklist $Variable }
            "--search" { Search-Blacklist $Variable }
            "--audit" { Audit-Blacklist }
            "--help" { Write-Output $helpMessage }
        }
    }
}

function List-Blacklist {
    param ([string]$Type)
    switch ($Type) {
        "domain" { Get-HostedContentFilterPolicy | Select-Object -ExpandProperty BlockedSenderDomains }
        "email" { Get-HostedContentFilterPolicy | Select-Object -ExpandProperty BlockedSenders }
        default { Write-Output "Invalid request, please specify 'domain' or 'email'" }
    }
}

function Add-ToBlacklist {
    param ([string]$Item)
    if ($Item -match '^[^@]+@[^@]+\.[^@]+$') {
        Set-HostedContentFilterPolicy -Identity Default -BlockedSenders @{Add=$Item}
        Write-Host "Added $Item to Blocked Senders"
    }
    elseif ($Item -notmatch '@') {
        Set-HostedContentFilterPolicy -Identity Default -BlockedSenderDomains @{Add=$Item}
        Write-Host "Added $Item to Blocked Sender Domains"
    }
    else {
        Write-Output "Invalid item: contains '@' but is not a valid email"
    }
}

function Remove-FromBlacklist {
    param (
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Item
    )

    process {
        if ($Item -match '^[^@]+@[^@]+\.[^@]+$') {
            Set-HostedContentFilterPolicy -Identity Default -BlockedSenders @{Remove=$Item}
            Write-Host "Removed $Item from Blocked Senders"
        }
        elseif ($Item -notmatch '@') {
            Set-HostedContentFilterPolicy -Identity Default -BlockedSenderDomains @{Remove=$Item}
            Write-Host "Removed $Item from Blocked Sender Domains"
        }
        else {
            Write-Output "Invalid item: contains '@' but is not a valid email"
        }
    }
}

function Search-Blacklist {
    param ([string]$SearchTerm)
    $allItems = (Get-HostedContentFilterPolicy | Select-Object -ExpandProperty BlockedSenders) + 
                (Get-HostedContentFilterPolicy | Select-Object -ExpandProperty BlockedSenderDomains)
    $matches = $allItems | Where-Object { $_ -like "*$SearchTerm*" }
    if ($matches) {
        $matches | ForEach-Object { Write-Output $_ }
    }
    else {
        Write-Output "No matches found for $SearchTerm"
    }
}

function Audit-Blacklist {
    $blockedDomains = Get-HostedContentFilterPolicy | Select-Object -ExpandProperty BlockedSenderDomains
    $blockedEmails = Get-HostedContentFilterPolicy | Select-Object -ExpandProperty BlockedSenders

    $domainInEmails = @()
    foreach ($domain in $blockedDomains) {
        foreach ($email in $blockedEmails) {
            if ($email -match "@$domain$") {
                $domainInEmails += $email
            }
        }
    }

    Write-Host "Attempting to Remove Emails"
    foreach ($email in $domainInEmails) {
        Set-HostedContentFilterPolicy -Identity Default -BlockedSenders @{Remove=$email.Sender.Address}
        Write-Host $email.Sender.Address
    }

    if ($domainInEmails) {
        Write-Output "The following emails had a domain that exists in the blocked domain list and were removed:"
        $domainInEmails | ForEach-Object { Write-Output $_ }
    }
    else {
        Write-Output "No emails had a domain that exists in the blocked domain list."
    }
}
