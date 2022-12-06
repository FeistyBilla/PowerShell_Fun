Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
function ShowAbout {
    [void] [System.Windows.MessageBox]::Show( "My simple PowerShell GUI script with dialog elements and menus v1.0", "About script", "OK", "Information" )
}
function OpenFile {
    [void] [System.Windows.MessageBox]::Show( "This part doesn't work yet... sorry.", "It's Fucked", "YesNo", "Warning" )
}
function SaveFile {
    [void] [System.Windows.MessageBox]::Show( "This part doesn't work yet... sorry.", "It's Fucked", "YesNo", "Warning" )
}
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='GUI Thang'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Local Users"
$Label.Location  = New-Object System.Drawing.Point(10,50)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)
$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 200
$Users = Get-LocalUser
Foreach ($User in $Users) {
    if ($User.PasswordLastSet -gt 0) {
        $ComboBox.Items.Add($User.Name) | Out-Null
    }
}
$ComboBox.Location  = New-Object System.Drawing.Point(150,50)
$main_form.Controls.Add($ComboBox)
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Last Password Set:"
$Label2.Location  = New-Object System.Drawing.Point(10,80)
$Label2.AutoSize = $true
$main_form.Controls.Add($Label2)
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = ""
$Label3.Location  = New-Object System.Drawing.Point(150,80)
$Label3.AutoSize = $true
$main_form.Controls.Add($Label3)
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(400,50)
$Button.Size = New-Object System.Drawing.Size(120,23)
$Button.Text = "Check"
$main_form.Controls.Add($Button)
$Button.Add_Click({
    if ($ComboBox.selectedItem) {
        $Label3.Text = ((Get-LocalUser -Name $ComboBox.selectedItem).PasswordLastSet).ToString('g')
    }
})
$menuMain         = New-Object System.Windows.Forms.MenuStrip
$menuFile         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOpen         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSave         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout        = New-Object System.Windows.Forms.ToolStripMenuItem
$main_form.MainMenuStrip = $menuMain
$main_form.Controls.Add($menuMain)
[void]$main_Form.Controls.Add($menuMain)
$menuFile.Text = "File"
[void]$menuMain.Items.Add($menuFile)
$menuOpen.Text         = "Open"
$menuOpen.Add_Click({OpenFile})
[void]$menuFile.DropDownItems.Add($menuOpen)
$menuSave.Text         = "Save"
$menuSave.Add_Click({SaveFile})
[void]$menuFile.DropDownItems.Add($menuSave)
$menuExit.Text         = "Exit"
$menuExit.Add_Click({$main_Form.Close()})
[void]$menuFile.DropDownItems.Add($menuExit)
$menuHelp.Text      = "Help"
[void]$menuMain.Items.Add($menuHelp)
$menuAbout.Text      = "About"
$menuAbout.Add_Click({ShowAbout})
[void]$menuHelp.DropDownItems.Add($menuAbout)
$main_form.ShowDialog() | Out-Null