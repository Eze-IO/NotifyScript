$fullpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $fullpath
cd $dir

# Set notification title, message and balloonicon.
$Title = "Hello World!"
$Message = "Default message"

#Type: None, Info, Warning or Error.
$BalloonIcon = "Info"

# Path to icon to display in taskbar.
$NotifyIconTray = "welcome.ico"

# Display time of the notification in milliseconds.
# Be between 10 and 30 seconds.
$Timeout = 15000

$temp = $ENV:TEMP
$global:mill = 001
$global:msg = $Message

function GetXML()
{

	#Read XML Document file
    $filePath = $temp + "\set-message.xml"
	if([System.IO.File]::Exists($temp + "\set-message-alt.xml")){
		$filePath = $temp + "\set-message-alt.xml"
	}

    Try
    {

        if([System.IO.File]::Exists($filePath)){

            # file with path $path doesn't exist
            [System.Xml.XmlDocument] $XMlDoc = New-Object System.Xml.XmlDocument
            $XMlDoc.Load($filePath)

            [System.Xml.XmlNode]$xmlnode = $xmldoc.GetElementsByTagName("Settings")[0]
			
			$msg = $xmlnode.ChildNodes[0].InnerText
			$mill = $xmlnode.ChildNodes[1].InnerText
			
			if($msg.length -lt 32){
            	$global:msg = $xmlnode.ChildNodes[0].InnerText
			}
			else
			{
				#[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
				#[System.Windows.Forms.MessageBox]::Show("Couldn't read xml file!", "" , 0, "warn")
			}
			
			if($mill.length -lt 4){
				if($mill -is [int]){
            		$global:mill = $xmlnode.ChildNodes[1].InnerText
				} else {
				
					#[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
					#[System.Windows.Forms.MessageBox]::Show("Reseted xml file!", "" , 0, "warn")
				}
			}
			else
			{
				#[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
				#[System.Windows.Forms.MessageBox]::Show("Couldn't read xml file!", "" , 0, "error")
			}
        }
        else
        {
            return
        }

    }
    Catch [System.Exception]
    {
       $ErrorMessage = $_.Exception.Message
       [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
       [System.Windows.Forms.MessageBox]::Show("Error: " + $ErrorMessage , "" , 0, "warn")
       ClearStat

    }

    
 }

GetXML

Start-Sleep -s $mill

$Message = $Message -replace $Message, $msg

function CreateXML($sec, $newmsg)
{

     # Set the File Name
    $filePath = $temp + "\set-message.xml"
	if([System.IO.File]::Exists($temp + "\set-message-alt.xml")){
		$filePath = $temp + "\set-message-alt.xml"
	}	

    Try
    {
        # Create The XML Document
        $XmlWriter = New-Object System.XMl.XmlTextWriter($filePath,$Null)
 
        # Set The Formatting
        $xmlWriter.Formatting = "Indented"
        $xmlWriter.Indentation = "4"
 
        # Write the XML Decleration
        $xmlWriter.WriteStartDocument()
 
        $XSLPropText = "type='text/xsl' href='style.xsl'"
        $xmlWriter.WriteProcessingInstruction("xml-stylesheet", $XSLPropText)
 
        # Write Root Element
        $xmlWriter.WriteStartElement("WelcomeMessage")
 
        # Write the Document
        $xmlWriter.WriteStartElement("Settings")
        $xmlWriter.WriteElementString("Name",$newmsg)
        $xmlWriter.WriteElementString("Delay",$sec)
        $xmlWriter.WriteEndElement # <-- Closing Servers

        $mill = $sec
        $msg = $newmsg
 
        # Write Close Tag for Root Element
        $xmlWriter.WriteEndElement # <-- Closing RootElement
 
        # End the XML Document
        $xmlWriter.WriteEndDocument()
 
        # Finish The Document
        $xmlWriter.Finalize
        $xmlWriter.Flush
        $xmlWriter.Close()

        $Status.Text = "Succesfully Saved!"
        $Status.ForeColor = "LimeGreen"
        ClearStat
    }
    catch [System.Exception]
    {
        $ErrorMessage = $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show("Error: " + $ErrorMessage, "" , 0, "error")

        $Status.Text = "Failed to save! :("
        $Status.ForeColor = "DarkRed"
		if(![System.IO.File]::Exists($temp + "\set-message-alt.xml")){
			[System.IO.File]::Create($temp + "\set-message-alt.xml")
		}
        ClearStat
    }
}

Function ClearStat()
{
    Try
    {
        Start-Sleep -s 3
        $Status.Text = ""
    }
    catch
    {
        return
    }
}

Try 
{

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $NotifyIcon = New-Object System.Windows.Forms.NotifyIcon 
    $Icon = New-Object system.drawing.icon ($NotifyIconTray)
    $Color = New-Object System.Drawing.Color
    $Image = [system.drawing.image]::FromFile("scroll.png")
    $Mark = [system.drawing.image]::FromFile("close.ico")

    $NotifyIcon.Icon = $Icon
    $NotifyIcon.BalloonTipTitle = $Title
    $NotifyIcon.BalloonTipText  = $Message
    $NotifyIcon.BalloonTipIcon  = $BalloonIcon

    $NotifyIcon.Visible = $True 
    $NotifyIcon.ShowBalloonTip($Timeout)
    $NotifyIcon.Visible = $False

    $form = New-Object System.Windows.Forms.form
    $form.BackgroundImage = $Image
    $form.BackgroundImageLayout = "None"
    $form.ShowInTaskbar = $False
    $form.text = "Welcome Settings"
    $form.WindowState = "normal"
    $form.MinimizeBox = $False
    $form.MaximizeBox = $False
    $form.SizeGripStyle = "Hide"
    $form.AutoScroll = $False
    $form.AutoSize = $False
    $form.StartPosition = "CenterScreen"
    $form.AutoSizeMode = "GrowAndShrink"
    $form.Width = 335
    $form.Height = 200
    $form.Width = $Image.Width + 30
    $form.Height = $Image.Height + 30
    $form.FormBorderStyle = "none"
    $form.TransparencyKey = "Turquoise"
    $form.BackColor = "Turquoise"
    $form.Opacity = 1.0
    $form.Icon = $Icon
    
    $Font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Bold)
    $form.Font = $Font

    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = "Choose your personal message:"

    $Label.AutoSize = $True
    $Label.BackColor = "Transparent"
    $Label.Location = New-Object System.Drawing.Point(25, 52)
    $form.Controls.Add($Label)

    $Text = New-Object System.Windows.Forms.TextBox
    $Text.Text = $msg
    $Text.Height = 18
    $Text.Width = 75
    $Text.MaxLength = 31
    $Text.Location = New-Object System.Drawing.Point(35, 80)
    $form.Controls.Add($Text)

    $Style = New-Object System.Drawing.Font("Times New Roman",11,[System.Drawing.FontStyle]::Bold)
    $Save = New-Object System.Windows.Forms.Button
	$Save.Padding = 1
    $Save.Text = "Save"
    $Save.Font = $Style
    $Save.ForeColor = "White"
    $Save.BackColor = "Black"
    $Save.FlatStyle = "Flat"
    $Save.Location = New-Object System.Drawing.Point(95, 180)
    $Save.Add_Click({
        CreateXML $Tim.Text $Text.Text
    })
    $form.Controls.Add($Save)

    $Close = New-Object System.Windows.Forms.PictureBox
    $Close.BackColor = "Transparent"
    $Close.Image = $Mark
    $Close.Height = 33
    $Close.Width = 33
    $Close.Location = New-Object System.Drawing.Point(195, 20)
    $Close.Add_Click({ 
        $form.close()
    })
    $form.Controls.Add($Close)

    $Pause = New-Object System.Windows.Forms.Label
    $Pause.Text = "Delay notification in seconds:"
    $Pause.AutoSize = $True
    $Pause.BackColor = "Transparent"
    $Pause.Location = New-Object System.Drawing.Point(25, 120)
    $form.Controls.Add($Pause)

    $Stat = New-Object System.Drawing.Font("Times New Roman",8,[System.Drawing.FontStyle]::Bold)
    $Status = New-Object System.Windows.Forms.Label
    $Status.Text = ""
    $Status.Font = $Stat
    $Status.AutoSize = $True
    $Status.BackColor = "Transparent"
    $Status.Location = New-Object System.Drawing.Point(80, 20)
    $form.Controls.Add($Status)

    $Tim = New-Object System.Windows.Forms.TextBox
    $Tim.Text = $mill
    $Tim.MaxLength = 3
    $Tim.Height = 18
    $Tim.Width = 75
    $Tim.Location = New-Object System.Drawing.Point(35, 145)
    $Tim.Add_KeyDown({KeyDown})
    $Tim.Add_TextChanged({
        if($Tim.Text -match '\D'){
            $Tim.Text = $Tim.Text -replace '\D'
            if($Tim.Text.Length -gt 0){
                $Tim.Focus()
                $Tim.SelectionStart = $Tim.Text.Length
            }
        }
    })
    $form.Controls.Add($Tim)

    Function KeyDown()
    {
        if ($FromDateText.Focused -eq $true -or $ToDateText.Focused -eq $true)
        {
            if ($_.KeyCode -gt 47 -And $_.KeyCode -lt 58 -or $_.KeyCode -gt 95 -and
                $_.KeyCode -lt 106 -or $_.KeyCode -eq 8)
            {
                $_.SuppressKeyPress = $false 
            }
            else
            {
                $_.SuppressKeyPress = $true  
            }
        }
    }

    Unregister-Event -SourceIdentifier click_event -ErrorAction SilentlyContinue 
    Register-ObjectEvent $NotifyIcon BalloonTipClicked -sourceIdentifier click_event -Action {
	        $form.ShowDialog()
			$form.BringToFront()
			GetXML
    }
 
    Wait-Event -timeout 15 -sourceIdentifier click_event > $null 
    Remove-Event click_event -ea SilentlyContinue 
    Unregister-Event -SourceIdentifier click_event -ErrorAction SilentlyContinue 
    $NotifyIcon.Dispose() 

}
Catch [System.Exception]
{
   $ErrorMessage = $_.Exception.Message
    
   Try
   {
       [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
       [System.Windows.Forms.MessageBox]::Show("Error: " + $ErrorMessage , "" , 0, "warn")
   }
   Catch
   {
        Exit
   }
    
}
Catch 
{
    Exit
}