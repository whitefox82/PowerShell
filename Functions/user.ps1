function user {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("--list", "--add", "--remove", "--search", "--logon", "--help")]
        [string]$Action,
        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [string]$Variable
    )

    begin {
        $script:ItemsToRemove = @()
        $helpMessage = @"
Usage: user [--list | --add | --remove | --search | --logon | --help] [variable]
Actions:
--list    List users
--add     Add a new user
--remove  Remove a user
--search  Search for a user
--logon   Log in to Microsoft Graph
--help    Displays this help message
"@
        $wordList = @("Sunrise", "Ocean", "Thunder", "Firefly", "Rainbow", "Thunderbolt", "Rancher", "Planter", "Spaced", "Ladder", "WireFrame", "Skateboard", "Troublesome")
        $minNumber = 100
        $maxNumber = 9999
    }

    process {
        switch ($Action) {
            "--list" {
                # List users code
                Write-Verbose "Listing users..."
            }
            "--add" {
                Add-NewUser
            }
            "--remove" {
                # Remove user code
                Write-Verbose "Removing user..."
            }
            "--search" {
                Search-User -SearchTerm $Variable
            }
            "--logon" {
                Connect-ToMicrosoftGraph
            }
            "--help" {
                Write-Output $helpMessage
            }
        }
    }

    end {
        # Any cleanup code if needed
    }
}

function Add-NewUser {
    $displayName = Read-Host "Enter Display Name"
    $mailNickname = Read-Host "Enter Mail Nickname (Alias)"
    $userPrincipalName = Read-Host "Enter User Principal Name (UPN, e.g., user@domain.com)"

    try {
        $password = Get-RandomPassword
        $newUserParams = @{
            AccountEnabled    = $true
            DisplayName       = $displayName
            MailNickname      = $mailNickname
            UserPrincipalName = $userPrincipalName
            PasswordProfile   = @{
                ForceChangePasswordNextSignIn = $true
                Password                      = $password
            }
        }

        New-MgUser -BodyParameter $newUserParams
        Write-Output "User created successfully."
        Write-Output "Username: $userPrincipalName"
        Write-Output "Password: $password"
    }
    catch {
        Write-Error "An error occurred while creating the user. Error details: $($_.Exception.Message)"
    }
}

function Get-RandomPassword {
    $randomWord = $wordList | Get-Random
    $randomNumber = Get-Random -Minimum $minNumber -Maximum $maxNumber
    return "${randomWord}-${randomNumber}"
}

function Connect-ToMicrosoftGraph {
    try {
        Connect-MgGraph -Scopes "User.ReadWrite.All"
        Write-Output "Logged in to Microsoft Graph successfully."
    }
    catch {
        Write-Error "An error occurred while logging in to Microsoft Graph. Error details: $($_.Exception.Message)"
    }
}

function Search-User {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm
    )

    try {
        # Create a custom HTTP header with ConsistencyLevel: eventual
        $header = @{
            "ConsistencyLevel" = "eventual"
        }

        # Perform a search using the -Search parameter with the custom header
        $uri = "https://graph.microsoft.com/v1.0/users?\$search=""displayName:$SearchTerm""&\$top=999"
        $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ContentType "application/json"

        if ($response.value.Count -gt 0) {
            $response.value | ForEach-Object {
                Write-Output "Display Name: $($_.displayName)"
                Write-Output "UPN: $($_.userPrincipalName)"
                Write-Output "Email: $($_.mail)"
                Write-Output "---"
            }
        } else {
            Write-Output "No users found matching the search term: $SearchTerm"
        }
    }
    catch {
        Write-Error "An error occurred while searching for users. Error details: $($_.Exception.Message)"
    }
}
