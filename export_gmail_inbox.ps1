$output = @()
$bad_domains = Get-Content -Path ""
$clientId = ""
$clientSecret = ""
$refreshToken = ""
$headers = @{ 
   "Content-Type" = "application/x-www-form-urlencoded" 
} 
$body = @{
   client_id     = $clientId
   client_secret = $clientSecret
   refresh_token = $refreshToken
   grant_type    = 'refresh_token'
}
$params = @{
   'Uri'         = 'https://accounts.google.com/o/oauth2/token'
   'ContentType' = 'application/x-www-form-urlencoded'
   'Method'      = 'POST'
   'Headers'     = $headers
   'Body'        = $body
   'Verbose'     = $false
}
$accessTokenResponse = Invoke-RestMethod @params
$accesstoken = $($accessTokenResponse.access_token)
$pageToken = 0
do {
    $headers = @{ 
    "Content-Type" = "application/json" 
    }
    if ($pageToken -eq 0) {
        $Uri = ("https://gmail.googleapis.com/gmail/v1/users/me/messages?q=in:inbox&maxResults=500&access_token=" + $accesstoken)
    } else {
        $Uri = ("https://gmail.googleapis.com/gmail/v1/users/me/messages?q=in:inbox&maxResults=500&pageToken=" + $pageToken + "&access_token=" + $accesstoken)
    }
    $params = @{
    'Uri'         = $Uri
    'ContentType' = 'application/json'
    'Method'      = 'GET'
    'Headers'     = $headers
    'Verbose'     = $false
    }
    $getMessagesResponse = Invoke-RestMethod @params
    $pageToken = $getMessagesResponse.nextPageToken
    $messages = $($getMessagesResponse.messages)
    $ids = ($messages).id
    foreach ($id in $ids) {
        $headers = @{ 
            "Content-Type" = "application/json" 
        }
        $params = @{
            'Uri'         = ("https://gmail.googleapis.com/gmail/v1/users/me/messages/" + $id + "?access_token=" + $accesstoken)
            'ContentType' = 'application/json'
            'Method'      = 'GET'
            'Headers'     = $headers
            'Verbose'     = $false
        }
        $getDetailsResponse = Invoke-RestMethod @params
        $from = ((($getDetailsResponse).payload).headers | Where-Object name -like '*from*').value
        $date = ((($getDetailsResponse).payload).headers | Where-Object name -like '*date*').value
        
        foreach ($bad_domain in $bad_domains) {
            if ($from -like $bad_domain) {
                $output_row = [PSCustomObject]@{
                    id = $id
                    From = $from
                    Date = $date
                }
            }
        }
        
        #$output += $output_row
        Write-Host $output_row
    }
} until ($null -eq $pageToken)
$output | Export-Csv -Path .\gmail_inbox2.csv -NoTypeInformation 
<#
ForEach-Object {
    $trash = $true
    if ($trash) {
        $headers = @{ 
            "Content-Type" = "application/json" 
        }
        $params = @{
            'Uri'         = ("https://gmail.googleapis.com/gmail/v1/users/me/messages/" + $id + "/trash?access_token=" + $accesstoken)
            'ContentType' = 'application/json'
            'Method'      = 'POST'
            'Headers'     = $headers
            'Verbose'     = $false
        }
        Invoke-RestMethod @params
        Write-Host ("Trashed " + ($_).id + " from " + ($_).From + " received " + ($_).Date + "!")
    }
}
#>