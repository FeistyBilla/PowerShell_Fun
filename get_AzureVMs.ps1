$pool_group_sets = @()
$output_array = @()
$connect_AzureAccount = Connect-AzAccount -ErrorAction SilentlyContinue
do {
    Start-Sleep -Seconds 1
} until (($connect_AzureAccount).Context.Environment.Name -eq 'AzureCloud')
$connect_AzureAD = Connect-AzureAD -ErrorAction SilentlyContinue
do {
    Start-Sleep -Seconds 1
} until (($connect_AzureAD).TenantDomain -eq 'YOUR_DOMAIN') ### TENANT DOMAIN GOES HERE ###
$resource_groups = (Get-AZResourceGroup).ResourceGroupName
foreach ($resource_group in $resource_groups) {
    $host_pools = Get-AzWvdHostPool -ResourceGroupName $resource_group | Where-Object HostPoolType -eq 'Personal'
    foreach ($host_pool in $host_pools) {
        $wvd_info = @{
            Hst_Pl = ($host_pool).Name
            Res_Grp = $resource_group
        }
        $pool_group_sets += $wvd_info
    }
}
$results = $pool_group_sets | ForEach-Object {Get-AzWvdSessionHost -HostPoolName ($_).Hst_Pl -ResourceGroupName ($_).Res_Grp | Select-Object Name,Status,AssignedUser}
$results_n = ($results).count
$results_i = 0
$results | ForEach-Object {
    $results_i ++
    Write-Progress -Id 1 -Activity ('Collecting VMs & Assigned Users - VM Name: ' + ($_).Name) -Status ("Progress: " + [math]::Round((($results_i/$results_n)*100)) + "%") -PercentComplete (($results_i/$results_n)*100)
    $output = [PSCustomObject]@{
        VM_Name = ($_).Name
        VM_Status = ($_).Status
        User_Assigned = ($_).AssignedUser
        User_Status = ""
        User_LastSignIn = ""
    }
    if ($null -ne ($_).AssignedUser) {
        Write-Progress -Id 2 -ParentId 1 -Activity "   Gathering User Details..." -Status ($_).AssignedUser
        $user_status = (Get-AzureADUser -All $true -SearchString ($_).AssignedUser) | Select-Object AccountEnabled,LastDirSyncTime
        if (($user_status).AccountEnabled -eq $true) {
            ($output).User_Status = "Active"
        } else {
            ($output).User_Status = "Disabled"
        }
        try {
            Start-Sleep -Seconds 1
            $user_signin = (Get-AzureADAuditSignInLogs -Filter ("userPrincipalName eq '" + ($_).AssignedUser + "' and status/errorCode eq 0") -Top 1 -ErrorAction Stop).CreatedDateTime
        } catch {
            Start-Sleep -Seconds 10
            $user_signin = (Get-AzureADAuditSignInLogs -Filter ("userPrincipalName eq '" + ($_).AssignedUser + "' and status/errorCode eq 0") -Top 1).CreatedDateTime
        }
        ($output).User_LastSignIn = $user_signin
    }
    $output_array += $output
}
$output_array | Sort-Object User_Status -Descending | Out-GridView
Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
Disconnect-AzureAD -ErrorAction SilentlyContinue | Out-Null