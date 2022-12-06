try {
    $connect_teams = Connect-MicrosoftTeams
    do {
        Start-Sleep -Milliseconds 500    
    } until (($connect_teams).Tenant.Domain -eq 'YOUR_DOMAIN') ### TENANT DOMAIN GOES HERE ###
} catch {
    Write-Host 'Not able to connect to MS Teams. Exiting...' -ForegroundColor Red
    exit
}
$output = @()
$teams = Get-Team
foreach ($team in $teams) {
    $users = Get-TeamUser -GroupId ($team).GroupId
    $owners = ($users | Where-Object {($_).Role -eq 'owner'}).count
    $members = ($users | Where-Object {($_).Role -eq 'member'}).count
    $guests = ($users | Where-Object {($_).Role -eq 'guest'}).count
    if ($owners -eq 0) {
        $output_row = [PSCustomObject]@{
            GroupId     = ($team).GroupId
            DisplayName = ($team).DisplayName
            Owners      = $owners
            Members     = $members
            Guests      = $guests
        }
    $output += $output_row
    }
}
if (($output).count -gt 0) {
    $output | Out-GridView -Title "Ownerless/Orphaned MS Teams"
} else {
    Write-Host "`nNo Ownerless/Orphaned MS Teams Found!`n" -ForegroundColor Green
}
Start-Job -ScriptBlock {Disconnect-MicrosoftTeams} -Name 'Disconnect_Teams' | Out-Null
do {
    Start-Sleep -Milliseconds 200
} until ((Get-Job -Name 'Disconnect_Teams').State -eq 'Completed')