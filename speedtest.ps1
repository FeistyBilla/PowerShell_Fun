[datetime]$datetime = (Get-Date).DateTime
[string]$date = $datetime.ToString("ddMMMyyyy")
[string]$time = $datetime.ToString("HH:mm")

#################################################################
### MODIFY THE PATHS TO SPEEDTEST.EXE AND OUTPUT FILE HERE!!! ###
#################################################################
[string]$output_path = 'D:\OneDrive\Scripts\Speedtest\Output\speedtest.csv'
$results = & D:\OneDrive\Scripts\Speedtest\Ookla\speedtest.exe -f csv -v
#################################################################

$array = $results.Split('"') | Where-Object {$_ -ne ','}
$output = [PSCustomObject]@{
    Date = $date
    Time = $time
    Server_Name = $array[1]
    Server_ID = $array[2]
    Latency = $array[3]
    Jitter = $array[4]
    Packet_Loss = $array[5]
    Download = ($array[6] / 131072)
    Upload = ($array[7] / 131072)
    Download_Bytes = $array[8]
    Upload_Bytes = $array[9]
    Share_URL = $array[10]
}
If (Test-Path $output_path) {
    $output | Export-Csv -Path $output_path -Append -Encoding UTF8 -NoTypeInformation
} else {
    $output | Export-Csv -Path $output_path -Encoding UTF8 -NoTypeInformation
}