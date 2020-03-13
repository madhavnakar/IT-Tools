[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

Function RemoteRun($resultsTextBox, $ComputerName, $u, $a, $progressBar, $cred) {
try {
    $progressBar.Maximum = 8
    $s = New-PSSession -ComputerName $ComputerName -Credential $cred
    $resultsTextBox.Text = "Computer Name: " + $ComputerName + "`r`n"
    $serial = Invoke-Command -Session $s {Get-WmiObject win32_bios} | Select -expandproperty Serialnumber | out-string
    $resultsTextBox.Text += "Serial #: " +  $serial
    $bios =  Invoke-Command -Session $s {Get-WmiObject win32_bios} | Select -expandproperty BiosVersion | out-string
    $resultsTextBox.Text += "Bios Version: " + $bios
    $model = Invoke-Command -Session $s {Get-WmiObject Win32_ComputerSystem} | Select -ExpandProperty Model | out-string
    $resultsTextBox.Text += "Model: " + $model + "`r`n"

    $progressBar.Value += 1

    $drive = Invoke-Command -Session $s {Get-PSDrive C}
    $freeSpace = [math]::round($drive.free / 1gb, 3) | out-string
    $resultsTextBox.Text += "Free Space (GB): " + $freeSpace
    $usedSpace = [math]::round($drive.used / 1gb, 3) | out-string
    $resultsTextBox.Text += "Used Space (GB): " + $usedSpace
    $totalSpace = [math]::round(($drive.used + $drive.free) / 1gb, 3) | out-string
    $resultsTextBox.Text += "Total Space (GB): " + $totalSpace
    $driveType = Invoke-Command -Session $s {Get-Physicaldisk} | select -expandproperty mediatype | Out-String
    $resultsTextBox.Text += "Drive Type: " + $driveType + "`r`n"

    $progressBar.Value += 1

    $ram = [math]::round((Invoke-Command -Session $s {Get-WmiObject win32_computersystem} | select -expandproperty TotalPhysicalMemory) / 1gb, 3) | Out-String
    $resultsTextBox.Text += "RAM (GB): " + $ram + "`r`n"

    $progressBar.Value += 1

    $procesor = Invoke-Command -Session $s {Get-WmiObject win32_processor} | select -expandproperty name | Out-string
    $resultsTextBox.Text += "Processor: " + $procesor + "`r`n"

    $progressBar.Value += 1

    $graphics = ""
    foreach($gpu in Invoke-Command -Session $s {Get-WmiObject Win32_VideoController})
    {
      $graphics += $gpu.Description | Out-String
    }
    $resultsTextBox.Text += "Graphics Info: `r`n" + $graphics + "`r`n"

    $progressBar.Value += 1

    try {
        #Below 'if' checks if program was run as an admin
        $AdminMod = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $Admin = $AdminMod.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ($Admin) {
            $tpmpresent = Invoke-Command -Session $s {Get-Tpm} | select -ExpandProperty  tpmpresent | Out-String
            $tpmready = Invoke-Command -Session $s {Get-Tpm} | select -ExpandProperty  tpmready | Out-String
            $resultsTextBox.Text += "TPM Present: " + $tpmpresent
            $resultsTextBox.Text += "TPM Ready: " + $tpmready + "`r`n"
        }
        else {
            $resultsTextBox.Text += "TPM: Need to run this program as an administrator `r`n `r`n"
        }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        $resultsTextBox.Text += "TPM Present: False `r`n"
    }

    $progressBar.Value += 1

    if ($u) {
        $str = "ls C:\Users -name"
        $block = [scriptblock]::Create($str)
        $resultsTextBox.Text += Invoke-Command -Session $s -ScriptBlock $block | out-string
    }

    $progressBar.Value += 1
    if ($a) {

        $applications += Invoke-Command -Session $s {Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*} |
        select DisplayName | Out-String
        $resultsTextBox.Text += "`r`n" + $applications
    }
    $progressBar.Value += 1
}
catch [System.Management.Automation.CommandNotFoundException] {
    $resultsTextBox.Text += "`r`n" + "ONE OR MORE OF THE REQUIRED CMDLETS ARE MISSING"
}
Remove-PSSession -Session $s
}

Function LocalRun($resultsTextBox, $u, $a, $progressBar) {
try {
    $progressBar.Maximum = 8

    $compName = hostname | Out-String
    $resultsTextBox.Text = "Computer Name: " + $compName
    $serial =  Get-WmiObject win32_bios | Select -expandproperty Serialnumber | out-string
    $resultsTextBox.Text += "Serial #: " +  $serial
    $bios =  Get-WmiObject win32_bios | Select -expandproperty BiosVersion | out-string
    $resultsTextBox.Text += "Bios Version: " + $bios
    $model = Get-WmiObject Win32_ComputerSystem | Select -ExpandProperty Model | out-string
    $resultsTextBox.Text += "Model: " + $model + "`r`n"

    $progressBar.Value += 1

    $drive = Get-PSDrive C
    $freeSpace = [math]::round($drive.free / 1gb, 3) | out-string
    $resultsTextBox.Text += "Free Space (GB): " + $freeSpace
    $usedSpace = [math]::round($drive.used / 1gb, 3) | out-string
    $resultsTextBox.Text += "Used Space (GB): " + $usedSpace
    $totalSpace = [math]::round(($drive.used + $drive.free) / 1gb, 3) | out-string
    $resultsTextBox.Text += "Total Space (GB): " + $totalSpace
    $driveType =  Get-Physicaldisk | select -expandproperty mediatype | Out-String
    $resultsTextBox.Text += "Drive Type: " + $driveType + "`r`n"

    $progressBar.Value += 1

    $ram = [math]::round((Get-WmiObject win32_computersystem | select -expandproperty TotalPhysicalMemory) / 1gb, 3) | Out-String
    $resultsTextBox.Text += "RAM (GB): " + $ram + "`r`n"

    $progressBar.Value += 1

    $procesor = Get-WmiObject win32_processor | select -expandproperty name | Out-string
    $resultsTextBox.Text += "Processor: " + $procesor + "`r`n"

    $progressBar.Value += 1

    $graphics = ""
    foreach($gpu in Get-WmiObject Win32_VideoController)
    {
      $graphics += $gpu.Description | Out-String
    }
    $resultsTextBox.Text += "Graphics Info: `r`n" + $graphics + "`r`n"

    $progressBar.Value += 1

    try {
        #Below 'if' checks if program was run as an admin
        $AdminMod = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $Admin = $AdminMod.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ($Admin) {
            $tpmpresent = Get-Tpm | select -ExpandProperty  tpmpresent | Out-String
            $tpmready = Get-Tpm | select -ExpandProperty  tpmready | Out-String
            $resultsTextBox.Text += "TPM Present: " + $tpmpresent
            $resultsTextBox.Text += "TPM Ready: " + $tpmready + "`r`n"
        }
        else {
            $resultsTextBox.Text += "TPM: Need to run this program as an administrator `r`n `r`n"
        }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        $resultsTextBox.Text += "TPM Present: False `r`n"
    }

    $progressBar.Value += 1

    if ($u) {
        $resultsTextBox.Text += ls C:\Users -name | out-string
    }

    $progressBar.Value += 1
    if ($a) {

        $applications += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
        select DisplayName | Out-String
        $resultsTextBox.Text += "`r`n" + $applications
    }
    $progressBar.Value += 1
}
catch [System.Management.Automation.CommandNotFoundException] {
    $resultsTextBox.Text += "`r`n" + "ONE OR MORE OF THE REQUIRED CMDLETS ARE MISSING"
}
}

Function Generate-Form($progressBar) {

$folderForm = New-Object System.Windows.Forms.Form
    $folderForm.Text = 'Info about remote computer'
    $folderForm.size = New-Object System.Drawing.size(600,800)

$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = 'Run'
$runButton.Location = '23,32'
$folderForm.Controls.Add($runButton)

$users = New-Object System.Windows.Forms.CheckBox
$users.Location = New-Object System.Drawing.Point(53,60)
$users.Size = New-Object System.Drawing.Size(80,20)
$users.Text = 'List Users'
$folderForm.Controls.Add($users)

$applications = New-Object System.Windows.Forms.CheckBox
$applications.Location = New-Object System.Drawing.Point(53,80)
$applications.Size = New-Object System.Drawing.Size(150,20)
$applications.Text = 'List Applications'
$folderForm.Controls.Add($applications)

$remoteComp = New-Object System.Windows.Forms.CheckBox
$remoteComp.Location = New-Object System.Drawing.Point(53,100)
$remoteComp.Size = New-Object System.Drawing.Size(150,20)
$remoteComp.Text = 'Remote Computer'
$folderForm.Controls.Add($remoteComp)

$compName = New-Object System.Windows.Forms.TextBox
$compName.Location = New-Object System.Drawing.Point(70, 120)
$compName.Size = New-Object System.Drawing.Point(150, 20)
$compName.ReadOnly = $true
$folderForm.Controls.Add($compName)

$remoteComp.Add_CheckStateChanged({
    #Enable or Disable the TextBox controls
    $compName.ReadOnly = !$remoteComp.Checked
})

$resultsTextBox = New-Object System.Windows.Forms.TextBox
$resultsTextBox.Location = New-Object System.Drawing.Point(23,150)
$resultsTextBox.Size = New-Object System.Drawing.Size(554, 530)
$resultsTextBox.Multiline = $true
$resultsTextBox.ScrollBars = "Vertical"
$resultsTextBox.ReadOnly = $true
$folderForm.Controls.Add($resultsTextBox)

$saveAsTxt = New-Object System.Windows.Forms.Button
$saveAsTxt.Text = 'Save Output'
$saveAsTxt.Location = New-Object System.Drawing.Point(23, 700)
$saveAsTxt.Size = New-Object System.Drawing.Size(203, 32)
$folderForm.Controls.Add($saveAsTxt)

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

$runButton.Add_Click( {
    $progressBar.Value = 0
    $resultsTextBox.Text = ""
    if (!$remoteComp.Checked) {
        LocalRun $resultsTextBox $users.Checked $applications.Checked $progressBar
    }
    else {
        $ValidAccount = $false
        do {
            Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            $cred = Get-Credential -Message "Enter a 1 account domain credential" -UserName "umroot\$env:username"
            if(!$cred) {
                break
            }
            $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
            $UserDomain = "umroot"
            $UserName = $cred.UserName
            $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ContextType,$UserDomain
            $ValidAccount = $PrincipalContext.ValidateCredentials($UserName,$Cred.GetNetworkCredential().Password)
        } until ($ValidAccount)
        if (!$cred) {
            $resultsTextBox.Text += "Credentials Not Entered!"
        }
        else {
            RemoteRun $resultsTextBox $compName.Text $users.Checked $applications.Checked $progressBar $cred
        }
    }

})

$saveAsTxt.Add_Click( {
    $folderBrowser.ShowDialog()
    $logName = ""
    if ($remoteComp.Checked) {
        $logName = $compName.Text
    }
    else {
        $logName = $env:computername
    }
    $logName += ".txt"
    New-Item -Force -Path $folderBrowser.SelectedPath -Name $logName -ItemType "file" -Value $resultsTextBox.Text
    $folderForm.Close()
})

[void] $folderForm.showdialog()

}

Function Find-FolderSize{ 
    Param(
        [String]
        $Targetfolder,
        [System.Windows.Forms.ProgressBar]
        $progressBar
    )
    $progressBar.Maximum = (Get-ChildItem $Targetfolder -Directory -force).Count
    [System.Collections.Arraylist]$DataColl = @()
    Get-ChildItem $Targetfolder -Directory -ErrorAction SilentlyContinue -force | ForEach-Object {
        $Length = 0
        $progressBar.Value += 1
        Get-ChildItem $_.fullname -Recurse -force -ErrorAction SilentlyContinue | ForEach-Object { $Length += $_.length }
        [void]$DataColl.Add([PSCustomObject]@{
            FolderName = $_.fullname
            Foldersize= '{0:N2}' -f ($Length / 1Gb)
        })
    }
    $DataColl | Out-GridView -Title "Size of SubDirectories"
}

Function Main {

    $mainMenu = New-Object System.Windows.Forms.Form
    $mainMenu.startposition = 'CenterScreen'
    $mainMenu.Size = New-Object System.Drawing.Size(300, 300)
    $mainMenu.Text = 'Main Menu'

    $computerInfo = New-Object System.Windows.Forms.Button
    $computerInfo.Size = New-Object System.Drawing.Size(100, 50)
    $computerInfo.Location = New-Object System.Drawing.point(90, 60)
    $computerInfo.Text = "Computer Info"
    $mainMenu.Controls.Add($computerInfo)

    $folderSize = New-Object System.Windows.Forms.Button
    $folderSize.Size = New-Object System.Drawing.Size(100, 50)
    $folderSize.Location = New-Object System.Drawing.point(90, 120)
    $folderSize.Text = "Folder Size"
    $mainMenu.Controls.Add($folderSize)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Minimum = 0
    $progressBar.Location = new-object System.Drawing.point(35,200)
    $progressBar.size = new-object System.Drawing.Size(200,25)
    $mainMenu.Controls.Add($progressBar)

    $computerInfo.Add_Click( {
        Generate-Form $progressBar
        $progressBar.Value = 0
    })

    $folderSize.Add_Click( {
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $FolderBrowser.ShowDialog()
        Find-FolderSize $FolderBrowser.SelectedPath $progressBar
        $progressBar.Value = 0
    })

    [void] $mainMenu.ShowDialog()

}

Main