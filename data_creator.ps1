#Import Customer Data
$customer = Import-Csv -Path 'cust.csv'
$customer_n = ($customer).count
#Import Wine Options
$wine = Import-Csv -Path 'wines.csv'
$wine_n = ($wine).count
#Fake Record Generation
(146752..200999) | ForEach-Object {
    #Create Fake Date
    $month = Get-Random -Minimum 1 -Maximum 12
    if ($month -lt 6) {
        $year = Get-Random -Minimum 2023 -Maximum 2026
    } else {
        $year = Get-Random -Minimum 2022 -Maximum 2026
    }
    if ($month -eq 2 ) {
        $day = Get-Random -Minimum 1 -Maximum 28
    } elseif ($month -eq ('4|6|9|11')){
        $day = Get-Random -Minimum 1 -Maximum 30
    } else {
        $day = Get-Random -Minimum 1 -Maximum 31
    }
    $pickup = Get-Date -Month $month -Day $day -Year $year -Format 'MM/dd/yyyy'
    #Create Object, Add Properties & Randomized Set of Values
    $rand_cust = Get-Random -Minimum 0 -Maximum ($customer_n - 1)
    $rand_wine = Get-Random -Minimum 0 -Maximum ($wine_n - 1)
    $output_row = [PSCustomObject]@{
        Record = $_
        Name = $customer[$rand_cust].Name
        Address = $customer[$rand_cust].Address
        City = $customer[$rand_cust].City
        State = $customer[$rand_cust].State
        Zip = $customer[$rand_cust].Zip
        Contact = $customer[$rand_cust].Contact
        Email = $customer[$rand_cust].Email
        Phone = $customer[$rand_cust].Phone
        Wine = $wine[$rand_wine].Wine
        Bottle = $wine[$rand_wine].Bottle
        UM = 'CS'
        Qty = (Get-Random -Minimum 1 -Maximum 10)*10
        Pickup = $pickup
    }
    #Output Row Data to CSV
    $output_row | Export-Csv -Path 'D:\fake_records.csv' -NoTypeInformation -Append
}
