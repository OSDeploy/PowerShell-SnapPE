<#
.NOTES
SnapPS is created by David Segura @SeguraOSD and hosted on OSDeploy.com
Version 18.11.5.0
WinPE Requires ADK WinPE-NetFx.cab and WinPE-PowerShell.cab

.SYNOPSIS
SnapPE captures screenshots in WinPE

.DESCRIPTION
SnapPE captures screenshots in Windows or WinPE as PNG files.  Cursor is not visible.
In WinPE, the SystemDrive is X:\, the Path is set to X:\SnapPE
In Windows, the Path is set to $env:UserProfile\Pictures\SnapPE
In Windows, under the System account, the Path is set to $env:SystemDrive\SnapPE

.PARAMETER Path
Changes the default save Path for PNG files

.EXAMPLE
.\SnapPE.ps1 -Path 'C:\Temp\SnapPE'
Saves PNG files to C:\Temp\SnapPE
#>

[CmdletBinding()]
Param (
    [string]$Path
)

if ($Path) {$global:SnapPath = $Path}
elseif ($env:SystemDrive -eq 'X:') {$global:SnapPath = 'X:\SnapPE'}
elseif ($env:UserName -eq 'system') {$global:SnapPath = "$env:SystemDrive\SnapPE"}
else {$global:SnapPath = "$env:UserProfile\Pictures\SnapPE"}

Function SnapPEForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $FormSnapPE = New-Object System.Windows.Forms.Form
    $FormSnapPE.Text = "SnapPE"
    $FormSnapPE.Size = New-Object System.Drawing.Size(223,90)
    $FormSnapPE.StartPosition = "CenterScreen"
    $FormSnapPE.Topmost = $True

    $ButtonSnap = New-Object System.Windows.Forms.Button
    $ButtonSnap.Location = New-Object System.Drawing.Size(10,10)
    $ButtonSnap.Size = New-Object System.Drawing.Size(145,30)
    $ButtonSnap.Text = "Snap"
    $FormSnapPE.Controls.Add($ButtonSnap)
    $ButtonSnap.Add_Click({Snap})

    $ButtonConfig = New-Object System.Windows.Forms.Button
    $ButtonConfig.Location = New-Object System.Drawing.Size(165,10)
    $ButtonConfig.Size = New-Object System.Drawing.Size(30,30)
    $ButtonConfig.Text = "@"
    $FormSnapPE.Controls.Add($ButtonConfig)
    $ButtonConfig.Add_Click({AboutForm})

    $FormSnapPE.ShowDialog()| Out-Null
}
Function AboutForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $FormAbout = New-Object System.Windows.Forms.Form
    $FormAbout.Text = 'About'
    $FormAbout.Size = New-Object System.Drawing.Size(300,150)
    $FormAbout.StartPosition = 'CenterScreen'

    $LabelAbout = New-Object System.Windows.Forms.Label
    $LabelAbout.Location = New-Object System.Drawing.Point(60,10)
    $LabelAbout.Size = New-Object System.Drawing.Size(280,20)
    $LabelAbout.Text = 'OSDeploy.com SnapPE 18.11.5.0'
    $FormAbout.Controls.Add($LabelAbout)

    $TextBoxSavePath = New-Object System.Windows.Forms.TextBox
    $TextBoxSavePath.Location = New-Object System.Drawing.Point(10,35)
    $TextBoxSavePath.Size = New-Object System.Drawing.Size(260,20)
    $TextBoxSavePath.Text = $SnapPath
    $FormAbout.Controls.Add($TextBoxSavePath)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(112,68)
    $OKButton.Size = New-Object System.Drawing.Size(75,30)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $FormAbout.AcceptButton = $OKButton
    $FormAbout.Controls.Add($OKButton)
    
    $FormAbout.Topmost = $true
    
    $FormAbout.Add_Shown({$TextBoxSavePath.Select()})
    $result = $FormAbout.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $global:SnapPath = $TextBoxSavePath.Text
    }
}

Function Snap {
    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing

    $FormSnapPE.Hide()
    Start-Sleep 1
 
    $VirtualScreen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $ScreenBitmap = New-Object System.Drawing.Bitmap $VirtualScreen.Width, $VirtualScreen.Height

    $GraphicObject = [System.Drawing.Graphics]::FromImage($ScreenBitmap)
    $GraphicObject.CopyFromScreen($VirtualScreen.Left, $VirtualScreen.Top, 0, 0, $ScreenBitmap.Size)

    if (!(Test-Path "$SnapPath")) {New-Item -Path "$SnapPath" -ItemType Directory -Force | Out-Null}
    $ScreenBitmap.Save("$SnapPath\$((Get-Date).ToString('yyyyMMdd_HHmmss')).png")

    $FormSnapPE.Show()
}

SnapPEForm