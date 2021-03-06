Import-Module UniversalDashboard

$FormLogin = New-UDAuthenticationMethod -Endpoint {
    param([PSCredential]$Credentials)

    if ($Credentials.UserName -eq "Adam" -and $Credentials.GetNetworkCredential().Password -eq "SuperSecretPassword") {
        New-UDAuthenticationResult -Success -UserName "Adam"
    }

    New-UDAuthenticationResult -ErrorMessage $Credentials.GetNetworkCredential().Password
}

$MicrosoftLogin = New-UDAuthenticationMethod -AppId "xyz" -AppSecret "123" -Provider Microsoft 

$LoginPage = New-UDLoginPage -AuthenticationMethod @($FormLogin, $MicrosoftLogin)

$MyDashboardPage = New-UDPage -Url "/myDashboard" -Endpoint {
    New-UDCard -Title "Welcome, $User" -Text "This is your custom dashboard."
}

$Dashboard = New-UDDashboard -LoginPage $LoginPage -Page @(
    $MyDashboardPage
)

Start-UDDashboard -Dashboard $Dashboard -Port 10000
