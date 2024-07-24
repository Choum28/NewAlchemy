<# 
.SYNOPSIS
    This script is a test to recreate the Creative Alchemy application in powershell with some new options and possibilities.

.DESCRIPTION
    What different from creative alchemy :
        Registry path are check in both X86 and X86-64 path.
        Add support for Debug settings 
        Add DisableNativeAL Option to Disable ALchemy to ouput sounds to X-fi Audigy OpenAl drivers (CT_oal.dll)
        In that case output is done by Creative Software 3D Library like Creative card that rely on Host Openal Drivers.
            X-fi card should set this settings to False by default and yes in case of problem with specific game.
            For other Creative sound Card (AE5/7/9), this settings make no difference.

.EXAMPLE
    .\NewALchemy.ps1
        Launch the script

 -------------------------- EXEMPLE 2 --------------------------
 .\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\Program Files (x86)\Creative\ALchemy\Alchemy.ps1"
        Launch the script and hide console

.OUTPUTS
    This script will generate an ini file NewAlchemy.ini to store gamelist audio options and change.
    
.NOTES
    NOM:       NewALchemy.ps1
    AUTEUR:    Choum

    HISTORIQUE VERSION:
	1.05	23.07.2024	  WPF forms are now rezisable.
    1.04    28.01.2024    No need anymore to install the scripts inside alchemy folder (Creative alchemy installed is still required), add default (reset) button.
    1.03    24.01.2024    Script_Internationalization with psd1 file for easier translation, fix non critcal error, improve error message, add messagebox Icon.
    1.02    20.01.2024    Few Bugfix, add Debug settings, Remove NativeAl value question on first launch
    1.01    06.10.2021    Fix edit new add game bug, add Nativeal value question on first launch
    1.0     15.11.2020    First version
.LINK
 #>
 
function LocateAlchemy { # Locate Alchemy installation and check for necessary files, return Creative alchemy path.
    if ([Environment]::Is64BitOperatingSystem -eq $true){
        $key = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{12321490-F573-4815-B6CC-7ABEF18C9AC4}"
    } else {
        $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{12321490-F573-4815-B6CC-7ABEF18C9AC4}"
    }
    $regkey = "InstallLocation"
    if (test-path $key){
        try { 
        $d = Get-ItemPropertyvalue -Path $key -name $regkey 
        }
        catch { 
            [System.Windows.MessageBox]::Show($txt.Badlocation,"",0,16)
            exit
        }
        if (Test-Path -path "$d\alchemy.ini"){
            if (Test-Path -path "$d\dsound.dll"){
                return $d
                } else {
                    [System.Windows.MessageBox]::Show("$($txt.missfile) $d\dsound.dll","",0,	16)
                }
            } else {
                [System.Windows.MessageBox]::Show("$($txt.missfile) $d\alchemy.ini","",0,	16)
            }
    } else {
        [System.Windows.MessageBox]::Show($txt.Badlocation,"",0,16)
    }  
	exit
}

function add-Game { # Convert value into hash table.
    param([string]$Name,[string]$RegPath,[string]$Gamepath,[int]$Buffers,[int]$Duration,[string]$DisableDirectMusic,[int]$MaxVoiceCount,[string]$SubDir,[string]$RootDirInstallOption,[String]$DisableNativeAL,[bool]$Found,[bool]$Transmut,[string]$LogDirectSound,[string]$LogDirectSound2D,[string]$LogDirectSound2DStreaming,[string]$LogDirectSound3D,[string]$LogDirectSoundListener,[string]$LogDirectSoundEAX,[string]$LogDirectSoundTimingInfo,[string]$LogStarvation)
    $d=@{
        Name=$Name
        RegPath=$RegPath
        Gamepath=$Gamepath
        Buffers=$Buffers
        Duration=$Duration
        DisableDirectMusic=$DisableDirectMusic
        MaxVoiceCount=$MaxVoiceCount
        SubDir=$SubDir
        RootDirInstallOption=$RootDirInstallOption
        DisableNativeAL=$DisableNativeAL
        Found=$Found
        Transmut=$Transmut
        LogDirectSound=$LogDirectSound
        LogDirectSound2D=$LogDirectSound2D
        LogDirectSound2DStreaming=$LogDirectSound2DStreaming
        LogDirectSound3D=$LogDirectSound3D
        LogDirectSoundListener=$LogDirectSoundListener
        LogDirectSoundEAX=$LogDirectSoundEAX
        LogDirectSoundTimingInfo=$LogDirectSoundTimingInfo
        LogStarvation=$LogStarvation
    }
    return $d
}

function read-file{ #read Newalchemy ini file and convert game to hash table with add-game function, default value are define here if not present in alchemy.ini.
    param([string]$file)
    $list = Get-content $file
    $liste = @()
    $test = 0
    $Number = 0
    $Buffers=4
    $Duration=25
    $DisableDirectMusic="False"
    $MaxVoiceCount=128
    $RootDirInstallOption="False"
    $DisableNativeAL="False"
    $Found=$false
    $Transmut=$false
    $LogDirectSound="False"
    $LogDirectSound2D="False"
    $LogDirectSound2DStreaming="False"
    $LogDirectSound3D="False"
    $LogDirectSoundListener="False"
    $LogDirectSoundEAX="False"
    $LogDirectSoundTimingInfo="False"
    $LogStarvation="False"

    foreach ($line in $list) {
        $Number = $Number + 1
        if($line -notlike ';*') {

            if($line -like '`[*') {
            if ($test -gt 0) {
                    $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Found $Found -Transmut $Transmut -LogDirectSound $LogDirectSound -LogDirectSound2D $LogDirectSound2D -LogDirectSound2DStreaming $LogDirectSound2DStreaming -LogDirectSound3D $LogDirectSound3D -LogDirectSoundListener $LogDirectSoundListener -LogDirectSoundEAX $LogDirectSoundEAX -LogDirectSoundTimingInfo $LogDirectSoundTimingInfo -LogStarvation $LogStarvation
                    $RegPath=""
                    $Gamepath=""
                    $Buffers=4
                    $Duration=25
                    $DisableDirectMusic="False"
                    $MaxVoiceCount=128
                    $SubDir=""
                    $RootDirInstallOption="False"
                    $DisableNativeAL="False"
                    $Found=$false
                    $Transmut=$false
                    $LogDirectSound="False"
                    $LogDirectSound2D="False"
                    $LogDirectSound2DStreaming="False"
                    $LogDirectSound3D="False"
                    $LogDirectSoundListener="False"
                    $LogDirectSoundEAX="False"
                    $LogDirectSoundTimingInfo="False"
                    $LogStarvation="False"
                }
                $test = $test+1
                $Name = $line -replace '[][]'
            }
            if($line -like "RegPath=*") {
                $RegPath = $line.replace("RegPath=","")
            }
            if($line -like "GamePath=*") {
                $Gamepath = $line.replace("GamePath=","")
            }
            if($line -like "Buffers=*") {
                $Buffers = $line.replace("Buffers=","")
            }
            if($line -like "Duration=*") {
                $Duration = $line.replace("Duration=","")
            }
            if($line -like "DisableDirectMusic=*") {
                $DisableDirectMusic = $line.replace("DisableDirectMusic=","")
            }
            if($line -like "MaxVoiceCount=*") {
                $MaxVoiceCount = $line.replace("MaxVoiceCount=","")
            }
            if($line -like "SubDir=*") {
                $SubDir = $line.replace("SubDir=","")
            }
            if($line -like "RootDirInstallOption=*") {
                $RootDirInstallOption = $line.replace("RootDirInstallOption=","")
            }
            if($line -like "DisableNativeAL=*") {
                $DisableNativeAL = $line.replace("DisableNativeAL=","")
            }
            if($line -like "LogDirectSound=*") {
                $LogDirectSound = $line.replace("LogDirectSound=","")
            }
            if($line -like "LogDirectSound2D=*") {
                $LogDirectSound2D = $line.replace("LogDirectSound2D=","")
            }
            if($line -like "LogDirectSound2DStreaming=*") {
                $LogDirectSound2DStreaming = $line.replace("LogDirectSound2DStreaming=","")
            }
            if($line -like "LogDirectSound3D=*") {
                $LogDirectSound3D = $line.replace("LogDirectSound3D=","")
            }
            if($line -like "LogDirectSoundListener=*") {
                $LogDirectSoundListener = $line.replace("LogDirectSoundListener=","")
            }
            if($line -like "LogDirectSoundEAX=*") {
                $LogDirectSoundEAX = $line.replace("LogDirectSoundEAX=","")
            }
            if($line -like "LogDirectSoundTimingInfo=*") {
                $LogDirectSoundTimingInfo = $line.replace("LogDirectSoundTimingInfo=","")
            }
            if($line -like "LogStarvation=*") {
                $LogStarvation = $line.replace("LogStarvation=","")
            }
        }
    }
    if ($Number -ne $test){
        $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Transmut $Transmut -LogDirectSound $LogDirectSound -LogDirectSound2D $LogDirectSound2D -LogDirectSound2DStreaming $LogDirectSound2DStreaming -LogDirectSound3D $LogDirectSound3D -LogDirectSoundListener $LogDirectSoundListener -LogDirectSoundEAX $LogDirectSoundEAX -LogDirectSoundTimingInfo $LogDirectSoundTimingInfo -LogStarvation $LogStarvation
    }
    return $liste
}

function GenerateNewAlchemy{ #Create New NewALchemy.ini file with new options, that will be used by the script
    param([string]$file) 
    @"
;Creative ALchemy titles
;Format/Options:
;  [TITLE]
;  RegPath <-- registry path containing string to executable or executable's directory (use this when available; alternative is GamePath)
;  GamePath <-- Directory to look for app (if RegPath can't be used) 
;  Buffers <--  is used to set the number of audio buffers used internally. The default value of 4 should be fine for most applications. (Values 2 to 10).
;  Duration <-- used to set the length in milliseconds of each of the audio buffers. default value is 25ms. (values : 5 to 50)
;  DisableDirectMusic <--  is used to disable DirectMusic support. The default is false (0 or 1 in dsound.ini).
;  MaxVoiceCount <--  is used to set the maximum number of hardware voices that will be used by ALchemy (default is 128), values : 32 to 128
;  SubDir <-- subdirectory offset off of path pointed to by RegPath for library support (default is empty string)
;  RootDirInstallOption <-- option to install translator support in both RegPath and SubDir directories (default is False)
;  DisableNativeAL <-- Bypass Native OpenAL drivers (Ct_oal.dll only) to use Alchemy internal library, only for old X-fi/Audigy Card)
;  LogDirectSound <-- log DirectSound (default is False) into dsound.txt
;  LogDirectSound2D <-- log DirectSound 2D into dsound.txt (default is False).
;  LogDirectSound2DStreaming <-- log DirectSound 2D streaming into dsound.txt (default is False).
;  LogDirectSound3D <-- log DirectSound 3D into dsound.txt (default is False).
;  LogDirectSoundListener <-- Log DirectSound Listener into dsound.txt(default is False).
;  LogDirectSoundEAX <-- log EAX into dsound.txt (default is False).
;  LogDirectSoundTimingInfo <-- Log DirectSound timing into dsound.txt(default is False).
;  LogStarvation <-- Log starvation into dsound.txt (default is False).

"@ | Out-File -Append $PSScriptRoot\NewAlchemy.ini -encoding ascii
    $liste = read-file $file
    foreach ($line in $liste){
        $a = $line.Name
        $b = $line.RegPath
        $c = $line.Gamepath
        $d = $line.Buffers
        $e = $line.Duration
        $f = $line.DisableDirectMusic
        $g = $line.MaxVoiceCount
        $h = $line.SubDir
        $i = $line.RootDirInstallOption
        $j = $line.DisableNativeAL
        $k = $line.LogDirectSound
        $l = $line.LogDirectSound2D
        $m = $line.LogDirectSound2DStreaming
        $n = $line.LogDirectSound3D
        $o = $line.LogDirectSoundListener
        $p = $line.LogDirectSoundEAX
        $q = $line.LogDirectSoundTimingInfo
        $r = $line.LogStarvation
        "[$a]`rRegPath=$b`rGamePath=$c`rBuffers=$d`rDuration=$e`rDisableDirectMusic=$f`rMaxVoiceCount=$g`rSubDir=$h`rRootDirInstallOption=$i`rDisableNativeAL=$j`rLogDirectSound=$k`rLogDirectSound2D=$l`rLogDirectSound2DStreaming=$m`rLogDirectSound3D=$n`rLogDirectSoundListener=$o`rLogDirectSoundEAX=$p`rLogDirectSoundTimingInfo=$q`rLogStarvation=$r`r`n" | Out-File -Append $PSScriptRoot\NewAlchemy.ini -encoding ascii
    }
}

function checkpresent{ # Check if game is present (registry in priority then gamepath)
    param($a)
    $b = $a.RegPath
    if (![string]::IsNullOrEmpty($b)) {
        if ($b -like "HKEY_LOCAL_MACHINE*") {
            $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
        } else {
                if($b -like "HKEY_CURRENT_USER*") {
                    $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                }
            }        
        # recover registry key
        $regkey = $b|split-path -leaf
        # delete key from registry link
        $b = $b.replace("\$regkey","")
        if (!(test-path $b)){
            $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
            $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
        }
        if (test-path $b){
            try { $a.GamePath = Get-ItemPropertyvalue -Path $b -name $regkey
            }
            catch {}
        }
    }
    if (![string]::IsNullOrEmpty($a.gamePath)){
        if (test-path $a.GamePath){
            $a.Found = $true
        }
        else {$a.Found = $false}
    }
    return $a
}

function checkinstall{ # Check if the game list is installed with check present function.
    param($liste)
    $test = 0
    foreach ($game in $liste){ 
        $liste[$test] = checkpresent $game
        $test = $test +1
    }
    return $liste
}

function checkTransmut{ # Check if game is transmuted (dsound.dll present)
    param($liste)
    $test = 0
    foreach ($game in $liste){
        $gamepath=$game.Gamepath
        $Subdir=$game.SubDir
        if ([string]::IsNullOrEmpty($Subdir)){
            if (test-path ("$gamepath\dsound.dll")){
                $game.Transmut = $true
            }
            else {
                $game.Transmut = $false
            }
        } else {
            if (test-path ("$gamepath\$Subdir\dsound.dll")){
                $game.Transmut = $true
            }
            else {
                $game.Transmut = $false
            }
        }
        $liste[$test] = $game
        $test = $test +1 
    }
    return $liste
}

function Sortlistview{
    param($listview)
    $items = $listview.items | Sort-Object
    $listview.Items.Clear()
    foreach ($item in $items){
        $listview.Items.Add($item)
    }
    return $listview
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#load translation if exist, if not found will load en-US one.
Import-LocalizedData -BindingVariable txt

# check if inside alchemy folder and if newalchemy.ini is present or generate a new one
$PathALchemy=LocateAlchemy
if (!(Test-Path -path "$PSScriptRoot\newalchemy.ini")) {
    GenerateNewAlchemy "$PathALchemy\Alchemy.ini"
}

$script:listejeux = read-file "$PSScriptRoot\NewAlchemy.ini"
checkinstall $script:listejeux | Out-Null
$script:jeutrouve = $script:listejeux | where-object Found -eq $true
#$jeutrouve | Out-GridView
checktransmut $script:jeutrouve | Out-Null
$jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
$jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}

# Main windows
[xml]$inputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="New Alchemy" Height="417" Width="818" MinHeight="417" MinWidth="818" ResizeMode="CanResizeWithGrip">
	<Viewbox Stretch="Uniform" StretchDirection="UpOnly">
		<Grid>
			<ListView Name="MenuGauche" HorizontalAlignment="Left" Height="280" Margin="20,75,0,0" VerticalAlignment="Top" Width="310">
				<ListView.View>
					<GridView>
						<GridViewColumn Width="300"/>
					</GridView>
				</ListView.View>
			</ListView>
			<ListView Name="MenuDroite" HorizontalAlignment="Left" Height="280" Margin="472,75,20,0" VerticalAlignment="Top" Width="310">
				<ListView.View>
					<GridView>
						<GridViewColumn Width="300"/>
					</GridView>
				</ListView.View>
			</ListView>
			<Button Name="BoutonTransmut" Content="&gt;&gt;" HorizontalAlignment="Left" Height="45" Margin="350,100,0,0" VerticalAlignment="Top" Width="100"/>
			<Button Name="BoutonUnTransmut" Content="&lt;&lt;" HorizontalAlignment="Left" Height="45  " Margin="350,163,0,0" VerticalAlignment="Top" Width="100"/>
			<Button Name="BoutonEdition" HorizontalAlignment="Left" Height="25" Margin="350,256,0,0" VerticalAlignment="Top" Width="100"/>
			<Button Name="BoutonAjouter" HorizontalAlignment="Left" Height="25" Margin="350,293,0,0" VerticalAlignment="Top" Width="100"/>
			<Button Name="BoutonParDefaut" HorizontalAlignment="Left" Height="25" Margin="350,330,0,0" VerticalAlignment="Top" Width="100"/>
			<TextBlock Name="Text_main" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,10,0,0" Width="762" Height="34"/>
			<TextBlock Name="Text_jeuInstall" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,54,0,0" Width="238"/>
			<TextBlock Name="Text_JeuTransmut" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="472,54,0,0" Width="173"/>
			<TextBlock Name="T_URL" HorizontalAlignment="Left" TextWrapping="Wrap" Text="https://github.com/Choum28/NewAlchemy" VerticalAlignment="Top" Margin="20,361,0,0" FontSize="8"/>
			<TextBlock Name="T_version" HorizontalAlignment="Right" TextWrapping="Wrap" Text="Version 1.05" VerticalAlignment="Top" Margin="0,359,20,0" FontSize="8"/>
		</Grid>
	</Viewbox>
</Window>

"@
$reader=(New-Object System.Xml.XmlNodeReader $inputXML)
$Window =[Windows.Markup.XamlReader]::Load( $reader )
$inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

$BoutonEdition.Content="<< $($txt.BoutonEditionContent)"
$BoutonAjouter.Content=$txt.BoutonAjouterContent
$BoutonParDefaut.Content=$txt.BoutonDefaultContent
$Text_main.Text=$txt.Text_main
$Text_jeuInstall.Text=$txt.Text_jeuInstall
$Text_JeuTransmut.Text=$txt.Text_JeuTransmut

# populate each listview, disable counter output in terminal
$MenuGauche.Items.Clear()
foreach ($jeu in $jeunontransmut){
    $MenuGauche.Items.Add($jeu.name) | Out-Null
}

$MenuDroite.Items.Clear()
foreach ($jeu in $jeutransmut){
    $MenuDroite.Items.Add($jeu.name) | Out-Null
}
 
#Transmut Button Copy needed file to gamepath and refresh listview (sort by name)
$BoutonTransmut.add_Click({
    $x = $Menugauche.SelectedItem
        foreach($game in $script:jeutrouve){
            if ($x -eq $game.Name){
                $gamepath = $game.Gamepath
                $SubDir = $game.SubDir
                $Buffers= $game.Buffers
                $Duration = $game.Duration
                $MaxVoiceCount = $game.MaxVoiceCount
                $DisableDirectMusic = $game.DisableDirectMusic
                $DisableNativeAL = $game.DisableNativeAL
                $RootDirInstallOption = $game.RootDirInstallOption
                $DisableDirectMusic = $DisableDirectMusic -ireplace("False","0")
                $DisableDirectMusic = $DisableDirectMusic -ireplace("True","1")
                $LogDirectSound = $game.LogDirectSound
                $LogDirectSound2D = $game.LogDirectSound2D
                $LogDirectSound2DStreaming = $game.LogDirectSound2DStreaming
                $LogDirectSound3D = $game.LogDirectSound3D
                $LogDirectSoundListener = $game.LogDirectSoundListener
                $LogDirectSoundEAX = $game.LogDirectSoundEAX
                $LogDirectSoundTimingInfo = $game.LogDirectSoundTimingInfo
                $LogStarvation = $game.LogStarvation
                $text = "Buffers=$Buffers`rDuration=$Duration`rMaxVoiceCount=$MaxVoiceCount`rDisableDirectMusic=$DisableDirectMusic`rDisableNativeAL=$DisableNativeAL`rLogDirectSound=$LogDirectSound`rLogDirectSound2D=$LogDirectSound2D`rLogDirectSound2DStreaming=$LogDirectSound2DStreaming`rLogDirectSound3D=$LogDirectSound3D`rLogDirectSoundListener=$LogDirectSoundListener`rLogDirectSoundEAX=$LogDirectSoundEAX`rLogDirectSoundTimingInfo=$LogDirectSoundTimingInfo`rLogStarvation=$LogStarvation`r"
 
                if ([string]::IsNullOrEmpty($Subdir)){
                    if (test-path ("$gamepath\dsound.ini")){
                        Remove-Item -Path $gamepath\dsound.ini -force
                    }
                    New-Item -Path $gamepath -Name "dsound.ini" -force
                    $text | Out-File $gamepath\dsound.ini -encoding ascii
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath
                } elseif ($RootDirInstallOption -eq "True"){
                    if (test-path ("$gamepath\dsound.ini")){
                        Remove-Item -Path "$gamepath\dsound.ini" -force
                    }
                    if (test-path ("$gamepath\$SubDir\dsound.ini")){
                        Remove-Item -Path "$gamepath\$SubDir\dsound.ini" -force
                    }
                    New-Item -Path "$gamepath\$Subdir" -Name "dsound.ini" -force
                    New-Item -Path "$gamepath\" -Name "dsound.ini" -force
                    $text | Out-File $gamepath\dsound.ini -encoding ascii
                    $text | Out-File $gamepath\$Subdir\dsound.ini -encoding ascii
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir

                } elseif (test-path ("$gamepath\$SubDir\dsound.ini")){
                    Remove-Item -Path "$gamepath\$SubDir\dsound.ini" -force
                    New-Item -Path "$gamepath\$SubDir" -Name "dsound.ini" -force
                    $text | Out-File $gamepath\$SubDir\dsound.ini -encoding ascii
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir

                } else { 
                    New-Item -Path "$gamepath\$Subdir" -Name "dsound.ini" -force
                    $text | Out-File $gamepath\$SubDir\dsound.ini -encoding ascii
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir
                }
                $MenuGauche.Items.Remove($x)
                $MenuDroite.Items.Add($x)
                Sortlistview $MenuDroite
            }
    }
 })

#Button Untransmut, remove Dsound files and refresh each listview (sort by name)
$BoutonUnTransmut.add_Click({
    $x = $Menudroite.SelectedItem
    foreach ($game in $script:jeutrouve){
        if ($x -eq $game.Name){
            $gamepath = $game.Gamepath
            $SubDir = $game.SubDir
            $RootDirInstallOption = $game.RootDirInstallOption
            if ([string]::IsNullOrEmpty($Subdir)){
                Remove-Item $gamepath\dsound.ini
                Remove-Item $gamepath\dsound.dll
            } elseif ($RootDirInstallOption -eq "True"){
                Remove-Item "$gamepath\dsound.ini"
                Remove-Item "$gamepath\dsound.dll"
                Remove-Item "$gamepath\$Subdir\dsound.ini"
                Remove-Item "$gamepath\$Subdir\dsound.dll"
            } else {
                Remove-Item "$gamepath\$Subdir\dsound.ini"
                Remove-Item "$gamepath\$Subdir\dsound.dll"
            }
            $MenuDroite.Items.Remove($x)
            $MenuGauche.Items.Add($x)
            Sortlistview $MenuGauche
        }
    }
})

### EDIT BUTON, Check each mandatory info, add then to global var and edit newalchemy file entry.
$BoutonEdition.add_Click({
    $x = $MenuGauche.SelectedItem
    if (!($x -eq $null)) {
        [xml]$InputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Height="710" Width="558" MinHeight="710" MinWidth="558" VerticalAlignment="Bottom" ResizeMode="CanResizeWithGrip">
	<Viewbox Stretch="Uniform" StretchDirection="UpOnly">
		<Grid>
			<TextBox Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
			<RadioButton Name="C_registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
			<RadioButton Name="C_Gamepath" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
			<TextBox Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
			<TextBox Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
			<TextBox Name="T_buffers" HorizontalAlignment="Left" Height="22" Margin="188,331,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
			<TextBox Name="T_Duration" HorizontalAlignment="Left" Height="22" Margin="188,359,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
			<TextBox Name="T_voice" HorizontalAlignment="Left" Height="22" Margin="188,387,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
			<CheckBox Name="C_SubDir" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
			<TextBox Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
			<CheckBox Name="C_DisableDirectMusic" HorizontalAlignment="Left" Margin="188,424,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_Rootdir" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
			<Label Name ="L_GameTitle" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
			<Label Name ="L_Buffers" HorizontalAlignment="Left" Margin="45,327,0,0" VerticalAlignment="Top" Width="79" Height="26"/>
			<Label Name="L_Duration" HorizontalAlignment="Left" Margin="45,358,0,0" VerticalAlignment="Top" Height="23" Width="79"/>
			<Label Name="L_Voice" HorizontalAlignment="Left" Height="25" Margin="45,384,0,0" VerticalAlignment="Top" Width="143"/>
			<Label Name="L_Settings" HorizontalAlignment="Left" Margin="28,297,0,0" VerticalAlignment="Top" Width="143"/>
			<Button Name="B_Cancel" HorizontalAlignment="Left" Height="25" Margin="439,634,0,13" VerticalAlignment="Top" Width="90"/>
			<Button Name="B_ok" HorizontalAlignment="Left" Height="25" Margin="331,634,0,13" VerticalAlignment="Top" Width="90"/>
			<Button Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
			<Button Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
			<Label Name="L_Debug1" HorizontalAlignment="Left" Margin="0,464,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.484,0"/>
			<Label Name="L_Debug2" HorizontalAlignment="Left" Margin="20,484,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
			<CheckBox Name="C_LogDirectSound" HorizontalAlignment="Left" Margin="67,524,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSound2D" HorizontalAlignment="Left" Margin="300,524,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSound2DStreaming" HorizontalAlignment="Left" Margin="67,544,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSound3D" HorizontalAlignment="Left" Margin="300,544,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSoundListener" HorizontalAlignment="Left" Margin="67,564,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSoundEAX" HorizontalAlignment="Left" Margin="300,564,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSoundTimingInfo" HorizontalAlignment="Left" Margin="67,584,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogStarvation" HorizontalAlignment="Left" Margin="300,584,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_DisableNativeAl" HorizontalAlignment="Left" Margin="67,604,0,0" VerticalAlignment="Top"/>
		</Grid>
	</Viewbox>
</Window>
"@
        $reader=(New-Object System.Xml.XmlNodeReader $inputXML)
        $Window_edit =[Windows.Markup.XamlReader]::Load( $reader )
        $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_edit.FindName($_.Name)}

        $T_Titrejeu.IsReadOnly=$true
        $T_Titrejeu.Background = '#e5e5e5'

        $Window_edit.Title=$txt.MainTitle2    
        $C_Gamepath.Content = $txt.C_GamepathContent
        $C_registre.Content=$txt.C_registreContent
        $T_registre.ToolTip = $txt.T_registreToolTip
        $T_Gamepath.ToolTip= $txt.T_GamepathToolTip
        $T_voice.ToolTip = $txt.T_voiceToolTip
        $C_SubDir.Content = $txt.C_SubDirContent
        $T_Subdir.ToolTip = $txt.T_SubdirToolTip
        $C_DisableDirectMusic.Content=$txt.C_DisableDirectMusicContent
        $C_DisableDirectMusic.ToolTip=$txt.C_DisableDirectMusicToolTip
        $C_Rootdir.Content=$txt.C_RootdirContent
        $L_GameTitle.Content=$txt.L_GameTitleContent
        $T_buffers.ToolTip = $txt.T_buffersToolTip
        $L_Buffers.Content=$txt.T_BuffersContent
        $L_Buffers.toolTip=$txt.T_BuffersToolTip
        $T_duration.toolTip = $txt.T_DurationToolTip
        $L_Duration.Content=$txt.T_DurationContent
        $L_Duration.ToolTip=$txt.T_DurationToolTip
        $L_Voice.Content=$txt.T_VoiceContent
        $L_Settings.Content=$txt.L_Settings
        $B_Cancel.Content=$txt.B_CancelContent
        $B_ok.Content=$txt.B_OkContent
        $L_Debug1.Content=$txt.L_Debug1Content
        $L_Debug2.Content=$txt.L_Debug2Content
        $C_LogDirectSound.Content=$txt.C_LogDirectSoundContent
        $C_LogDirectSound2D.Content=$txt.C_LogDirectSound2DContent
        $C_LogDirectSound2DStreaming.Content=$txt.C_LogDirectSound2DStreamingContent
        $C_LogDirectSound3D.Content=$txt.C_LogDirectSound3DContent
        $C_LogDirectSoundListener.Content=$txt.C_LogDirectSoundListenerContent
        $C_LogDirectSoundEAX.Content=$txt.C_LogDirectSoundEAXContent
        $C_LogDirectSoundTimingInfo.Content=$txt.C_LogDirectSoundTimingInfoContent
        $C_LogStarvation.Content=$txt.C_LogStarvationContent
        $C_LogDirectSound.ToolTip=$txt.C_logtextTooltip
        $C_LogDirectSound2D.ToolTip=$txt.C_logtextTooltip
        $C_LogDirectSound2DStreaming.ToolTip=$txt.C_logtextTooltip
        $C_LogDirectSound3D.ToolTip=$txt.C_logtextTooltip
        $C_LogDirectSoundListener.ToolTip=$txt.C_logtextTooltip
        $C_LogDirectSoundEAX.ToolTip=$txt.C_logtextTooltip
        $C_LogDirectSoundTimingInfo.ToolTip=$txt.C_logtextTooltip
        $C_LogStarvation.ToolTip=$txt.C_logtextTooltip
        $C_DisableNativeAl.Content=$txt.C_DisableNativeAlContent
        $C_DisableNativeAl.ToolTip=$txt.C_DisableNativeAlToolTip

        $C_Registre.Add_Checked({
            $T_Registre.IsReadOnly=$False
            $T_Registre.Background = '#ffffff'
            $B_GamePath.IsEnabled=$False
            $T_Gamepath.IsReadOnly=$true
            $T_Gamepath.Background = '#e5e5e5'
        })
        $C_Gamepath.Add_Checked({
            $T_Registre.IsReadOnly=$true
            $T_Registre.Background = '#e5e5e5'
            $T_Gamepath.IsReadOnly=$False
            $T_Gamepath.Background = '#ffffff'
            $B_GamePath.IsEnabled=$True
        })
        $C_SubDir.Add_Checked({
            $T_SubDir.IsReadOnly=$False
            $T_SubDir.Background = '#ffffff'
            $C_Rootdir.Background = '#ffffff'
            $C_Rootdir.IsEnabled=$true
            $B_SubDir.IsEnabled=$True
        })
        $C_SubDir.Add_UnChecked({
            $T_SubDir.IsReadOnly=$True
            $T_SubDir.Background = '#e5e5e5'
            $C_Rootdir.Background = '#e5e5e5'
            $C_Rootdir.IsChecked=$False
            $B_SubDir.IsEnabled=$False
            $C_Rootdir.IsEnabled=$False
        })

    ## RETREIVE EDIT FORM VALUES
        $count = 0
        $found = 0
        foreach ($game in $script:jeutrouve){
            if ($x -eq $game.Name){
                $found = 1
                $T_titrejeu.text = $game.Name
                $T_buffers.text = $game.Buffers
                $T_Duration.text = $game.Duration
                $T_voice.text = $game.MaxVoiceCount
                $T_Subdir.text = $game.Subdir
                $RootDirInstallOption = $game.RootDirInstallOption
                $DisableNativeAL = $game.DisableNativeAL
                $DisableDirectMusic = $game.DisableDirectMusic
                $LogDirectSound = $game.LogDirectSound
                $LogDirectSound2D = $game.LogDirectSound2D
                $LogDirectSound2DStreaming = $game.LogDirectSound2DStreaming
                $LogDirectSound3D = $game.LogDirectSound3D
                $LogDirectSoundListener = $game.LogDirectSoundListener
                $LogDirectSoundEAX = $game.LogDirectSoundEAX
                $LogDirectSoundTimingInfo = $game.LogDirectSoundTimingInfo
                $LogStarvation = $game.LogStarvation

                if ([string]::IsNullOrEmpty($game.RegPath)){
                    $T_Gamepath.text = $game.Gamepath
                    $T_Registre.IsReadOnly=$true
                    $T_Registre.Background = '#e5e5e5'
                    $C_GamePath.IsChecked=$true
                } else{
                    $T_registre.text = $game.RegPath
                    $T_Gamepath.IsReadOnly=$true
                    $T_Gamepath.Background = '#e5e5e5'
                    $B_GamePath.IsEnabled=$False
                    $C_Registre.IsChecked=$True
                }
                if ($DisableDirectMusic -eq "True"){
                    $C_DisableDirectMusic.IsChecked = $True
                }else {
                    $C_DisableDirectMusic.IsChecked = $False
                }
                if ($DisableNativeAL -eq "True"){
                    $C_DisableNativeAl.IsChecked=$True
                }else {
                    $C_DisableNativeAl.IsChecked=$False
                }
                if ([string]::IsNullOrEmpty($T_Subdir.text)){
                    $T_SubDir.IsReadOnly=$True
                    $T_SubDir.Background = '#e5e5e5'
                    $C_Rootdir.IsEnabled=$False
                    $C_Rootdir.Background = '#e5e5e5'
                    $B_SubDir.IsEnabled=$False
                    $C_SubDir.IsChecked=$False
                    $C_Rootdir.IsChecked=$False
                }else{
                    $C_SubDir.Ischecked= $true
                    $C_Rootdir.IsEnabled=$true
                    if ($RootDirInstallOption -eq "True"){
                        $C_Rootdir.IsChecked=$True
                    } else {
                        $C_Rootdir.IsChecked=$False
                    }
                }
                if ($LogDirectSound -eq "True"){
                    $C_LogDirectSound.IsChecked=$True
                }else {
                    $C_LogDirectSound.IsChecked=$False
                }

                if ($LogDirectSound2D -eq "True"){
                    $C_LogDirectSound2D.IsChecked=$True
                }else {
                    $C_LogDirectSound2D.IsChecked=$False
                }
                if ($LogDirectSound2DStreaming -eq "True"){
                    $C_LogDirectSound2DStreaming.IsChecked=$True
                }else {
                    $C_LogDirectSound2DStreaming.IsChecked=$False
                }
                if ($LogDirectSound3D -eq "True"){
                    $C_LogDirectSound3D.IsChecked=$True
                }else {
                    $C_LogDirectSound3D.IsChecked=$False
                }
                if ($LogDirectSoundListener -eq "True"){
                    $C_LogDirectSoundListener.IsChecked=$True
                }else {
                    $C_LogDirectSoundListener.IsChecked=$False
                }
                if ($LogDirectSoundEAX -eq "True"){
                    $C_LogDirectSoundEAX.IsChecked=$True
                }else {
                    $C_LogDirectSoundEAX.IsChecked=$False
                }
                if ($LogDirectSoundTimingInfo -eq "True"){
                    $C_LogDirectSoundTimingInfo.IsChecked=$True
                }else {
                    $C_LogDirectSoundTimingInfo.IsChecked=$False
                }
                if ($LogStarvation -eq "True"){
                    $C_LogStarvation.IsChecked=$True
                }else {
                    $C_LogStarvation.IsChecked=$False
                }
            } else {
                if ($found -ne 1){
                    $count = $count +1
                }
            }
        }

    ## CLICK ON ICON GAMEPATH (EDIT FORM)
        $B_GamePath.add_Click({
            $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
            $foldername.Description = $txt.FolderChoice
            $foldername.rootfolder = "MyComputer"
            if ($C_Gamepath.IsChecked) {
                $foldername.SelectedPath = $T_Gamepath.text
            }
            if($foldername.ShowDialog() -eq "OK")
            {
                $T_Gamepath.text = $foldername.SelectedPath
            }
        })

    ## CLICK ON SUBDIR BUTTON (EDIT FORM)
        $B_SubDir.add_Click({
            $fail=$False
            if ($C_registre.IsChecked) {
                    $b = $T_Registre.Text
                    if (![string]::IsNullOrEmpty($b)){
                        if ($b -like "HKEY_LOCAL_MACHINE*") {
                            $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                        } else {
                            if($b -like "HKEY_CURRENT_USER*") {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                            } else {
                                $fail = $True
                                [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                            }
                        }
                    } else { 
                            $fail = $True
                            [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                    }
                    if ($fail -eq $False){            
                        #retreive registry key
                        $regkey = $b|split-path -leaf
                        #remove registry key from registry link"
                        $b = $b.replace("\$regkey","")
                        if (!(test-path $b)){
                            $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                            $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                        }
                        if (test-path $b){
                            try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                            }
                            catch {
                                [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                                $fail = $true
                            }
                            if ($fail -eq $False) {
                                if (!(test-path $Gamepath)){
                                    [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                                    $fail = $true
                                }
                            }
                        } else {
                                    $fail = $true
                                    [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                        }
                    }
            } else {
                    $Gamepath = $T_Gamepath.text
                    if ([string]::IsNullOrEmpty($Gamepath)){
                        $fail = $True
                        [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ($fail -eq $False) {
                if (!(test-path $Gamepath)){
                    [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    $fail = $true
                }
                if ($fail -eq $False) {
                    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                    $foldername.Description = $txt.SubFolderChoice
                    $foldername.SelectedPath = $Gamepath
                    if($foldername.ShowDialog() -eq "OK"){
                        $Subdir = $foldername.SelectedPath
                        $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                        $Subdir = $Subdir.Trimstart("\")
                        if (test-path $Gamepath\$Subdir){
                            $T_Subdir.text = $Subdir
                        } else { 
                            [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48)
                        }
                    }
                }
            }
        })
        # Cancel Button (EDIT FORM)
        $B_Cancel.add_Click({
            $Window_edit.Close()
        })

    
    ### OK BUTTON (EDIT FORM), Check if everything is ok, then EDIT GAME FILE and Hash table
        $B_Ok.add_Click({
            $fail = $false
            $regprio = $false
            if ($C_registre.IsChecked) {
                $b = $T_Registre.Text
                if (![string]::IsNullOrEmpty($b)) {    
                    if ($b -like "HKEY_LOCAL_MACHINE*") {
                        $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                    } else {
                            if($b -like "HKEY_CURRENT_USER*") {
                                $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                            }
                        }        
                    #Recover Reg Key
                    $regkey = $b|split-path -leaf
                    #"supprimer clef du lien registre"
                    $b = $b.replace("\$regkey","")
                    if (!(test-path $b)){
                    $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                    }
                    if (test-path $b){
                        try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                        }
                        catch {
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                        }
                        if ($fail -eq $False) {
                            if (!(test-path $Gamepath)){
                                [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                                $fail = $true
                            } else {
                                $regprio = $true
                                $RegPath = $T_Registre.Text
                            }
                        }
                    } else {
                     $fail = $true
                     [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                    }
                } else { 
                         $fail = $true
                         [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                }
            } else {
                $Gamepath = $T_Gamepath.text
                if ([string]::IsNullOrEmpty($Gamepath)){ 
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ($fail -eq $False) {
                $Gamepath = $Gamepath.TrimEnd("\")
                if (![string]::IsNullOrEmpty($Gamepath)){
                    if (!(test-path $Gamepath)){
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    } 
                }
            }
            if ($C_SubDir.IsChecked -and $fail -eq $false){
                $Subdir = $T_Subdir.text
                if (!(test-path $Gamepath\$Subdir)){
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
                } 
            }
            if (!($T_buffers.text -In 2..10)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.BuffersErr,"",0,48)
            }
            if (!($T_Duration.Text -In 2..50)){
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.DurationErr,"",0,48)
            }
            if (!($T_voice.text -In 32..128)){
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.VoiceErr,"",0,48)
            }
            # Test if no error
            if ($fail -eq $False){

                # Prepare Game value to write
                $Name = $T_titrejeu.text
                $Buffers = $T_buffers.text
                $Voice = $T_voice.text
                $Duration = $T_Duration.text
                if ($C_DisableDirectMusic.IsChecked) {
                    $DisableDirectMusic="True"
                } else {
                    $DisableDirectMusic="False"
                }
                if ($C_Rootdir.IsChecked){
                    $RootDirInstallOption="True"
                } else {
                    $RootDirInstallOption="False"
                }
                if ($C_DisableNativeAl.IsChecked){
                    $DisableNativeAL="True"
                } else { 
                    $DisableNativeAL ="False"
                }
                if ($C_SubDir.IsUnChecked){
                    $SubDir=""
                    $RootDirInstallOption="False"
                }
                if ($C_LogDirectSound.IsChecked){
                    $LogDirectSound="True"
                } else { 
                    $LogDirectSound ="False"
                }
                if ($C_LogDirectSound2D.IsChecked){
                    $LogDirectSound2D="True"
                } else { 
                    $LogDirectSound2D ="False"
                }
                 if ($C_LogDirectSound2DStreaming.IsChecked){
                    $LogDirectSound2DStreaming="True"
                } else { 
                    $LogDirectSound2DStreaming ="False"
                }
                 if ($C_LogDirectSound3D.IsChecked){
                    $LogDirectSound3D="True"
                } else { 
                    $LogDirectSound3D ="False"
                }
                 if ($C_LogDirectSoundListener.IsChecked){
                    $LogDirectSoundListener="True"
                } else { 
                    $LogDirectSoundListener ="False"
                }
                 if ($C_LogDirectSoundEAX.IsChecked){
                    $LogDirectSoundEAX="True"
                } else { 
                    $LogDirectSoundEAX ="False"
                }
                 if ($C_LogDirectSoundTimingInfo.IsChecked){
                    $LogDirectSoundTimingInfo="True"
                } else { 
                    $LogDirectSoundTimingInfo ="False"
                }
                 if ($C_LogStarvation.IsChecked){
                    $LogStarvation="True"
                } else { 
                    $LogStarvation ="False"
                }
                
                # Update list game to reflect change    
                $script:jeutrouve[$count].RegPath=$RegPath
                $script:jeutrouve[$count].Gamepath=$Gamepath
                $script:jeutrouve[$count].Buffers=$Buffers
                $script:jeutrouve[$count].Duration=$Duration
                $script:jeutrouve[$count].DisableDirectMusic=$DisableDirectMusic
                $script:jeutrouve[$count].MaxVoiceCount=$Voice
                $script:jeutrouve[$count].SubDir=$Subdir
                $script:jeutrouve[$count].RootDirInstallOption=$RootDirInstallOption
                $script:jeutrouve[$count].DisableNativeAL=$DisableNativeAL
                $script:jeutrouve[$count].LogDirectSound=$LogDirectSound
                $script:jeutrouve[$count].LogDirectSound2D=$LogDirectSound2D
                $script:jeutrouve[$count].LogDirectSound2DStreaming=$LogDirectSound2DStreaming
                $script:jeutrouve[$count].LogDirectSound3D=$LogDirectSound3D
                $script:jeutrouve[$count].LogDirectSoundListener=$LogDirectSoundListener
                $script:jeutrouve[$count].LogDirectSoundEAX=$LogDirectSoundEAX
                $script:jeutrouve[$count].LogDirectSoundTimingInfo=$LogDirectSoundTimingInfo
                $script:jeutrouve[$count].LogStarvation=$LogStarvation
                
                # Write change in file
                $file = Get-content "$PSScriptRoot\Newalchemy.ini"
                $LineNumber = Select-String -pattern ([regex]::Escape("[$Name]")) $PSScriptRoot\NewAlchemy.ini| Select-Object -ExpandProperty LineNumber
                if ($regprio -eq $true) {
                    $file[$LineNumber] = "RegPath=$RegPath"
                    $file[$LineNumber +1]="GamePath="
                }else{
                    $file[$LineNumber] = "RegPath="
                    $file[$LineNumber +1]="GamePath=$Gamepath" 
                }
                $file[$LineNumber +2] = "Buffers=$Buffers" 
                $file[$LineNumber +3] = "Duration=$Duration" 
                $file[$LineNumber +4] = "DisableDirectMusic=$DisableDirectMusic" 
                $file[$LineNumber +5] = "MaxVoiceCount=$Voice" 
                $file[$LineNumber +6] = "SubDir=$Subdir" 
                $file[$LineNumber +7] = "RootDirInstallOption=$RootDirInstallOption"
                $file[$LineNumber +8] = "DisableNativeAL=$DisableNativeAL"
                $file[$LineNumber +9] = "LogDirectSound=$LogDirectSound"
                $file[$LineNumber +10] = "LogDirectSound2D=$LogDirectSound2D"
                $file[$LineNumber +11] = "LogDirectSound2DStreaming=$LogDirectSound2DStreaming"
                $file[$LineNumber +12] = "LogDirectSound3D=$LogDirectSound3D"
                $file[$LineNumber +13] = "LogDirectSoundListener=$LogDirectSoundListener"
                $file[$LineNumber +14] = "LogDirectSoundEAX=$LogDirectSoundEAX"
                $file[$LineNumber +15] = "LogDirectSoundTimingInfo=$LogDirectSoundTimingInfo"
                $file[$LineNumber +16] = "LogStarvation=$LogStarvation"
                $file | Set-Content $PSScriptRoot\NewAlchemy.ini -encoding ascii
                
                $Window_edit.Close()
                }
        })
        $Window_edit.ShowDialog() | out-null
    }
})

### ADD BUTTON (MAIN FORM)
$BoutonAjouter.add_Click({
    [xml]$InputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Height="710" Width="558" MinHeight="710" MinWidth="558" VerticalAlignment="Bottom" ResizeMode="CanResizeWithGrip">
		<Viewbox Stretch="Uniform" StretchDirection="UpOnly">
			<Grid>
			<TextBox Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
			<RadioButton Name="C_registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
			<RadioButton Name="C_Gamepath" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
			<TextBox Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
			<TextBox Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
			<TextBox Name="T_buffers" HorizontalAlignment="Left" Height="22" Margin="188,331,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
			<TextBox Name="T_Duration" HorizontalAlignment="Left" Height="22" Margin="188,359,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
			<TextBox Name="T_voice" HorizontalAlignment="Left" Height="22" Margin="188,387,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
			<CheckBox Name="C_SubDir" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
			<TextBox Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
			<CheckBox Name="C_DisableDirectMusic" HorizontalAlignment="Left" Margin="188,424,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_Rootdir" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
			<Label Name ="L_GameTitle" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
			<Label Name ="L_Buffers" HorizontalAlignment="Left" Margin="45,327,0,0" VerticalAlignment="Top" Width="79" Height="26"/>
			<Label Name="L_Duration" HorizontalAlignment="Left" Margin="45,358,0,0" VerticalAlignment="Top" Height="23" Width="79"/>
			<Label Name="L_Voice" HorizontalAlignment="Left" Height="25" Margin="45,384,0,0" VerticalAlignment="Top" Width="143"/>
			<Label Name="L_Settings" HorizontalAlignment="Left" Margin="28,297,0,0" VerticalAlignment="Top" Width="143"/>
			<Button Name="B_Cancel" HorizontalAlignment="Left" Height="25" Margin="439,634,0,13" VerticalAlignment="Top" Width="90"/>
			<Button Name="B_ok" HorizontalAlignment="Left" Height="25" Margin="331,634,0,13" VerticalAlignment="Top" Width="90"/>
			<Button Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
			<Button Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
			<Label Name="L_Debug1" HorizontalAlignment="Left" Margin="0,464,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.484,0"/>
			<Label Name="L_Debug2" HorizontalAlignment="Left" Margin="20,484,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
			<CheckBox Name="C_LogDirectSound" HorizontalAlignment="Left" Margin="67,524,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSound2D" HorizontalAlignment="Left" Margin="300,524,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSound2DStreaming" HorizontalAlignment="Left" Margin="67,544,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSound3D" HorizontalAlignment="Left" Margin="300,544,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSoundListener" HorizontalAlignment="Left" Margin="67,564,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSoundEAX" HorizontalAlignment="Left" Margin="300,564,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogDirectSoundTimingInfo" HorizontalAlignment="Left" Margin="67,584,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_LogStarvation" HorizontalAlignment="Left" Margin="300,584,0,0" VerticalAlignment="Top"/>
			<CheckBox Name="C_DisableNativeAl" HorizontalAlignment="Left" Margin="67,604,0,0" VerticalAlignment="Top"/>
		</Grid>
	</Viewbox>
</Window>
"@
    $reader=(New-Object System.Xml.XmlNodeReader $inputXML)
    $Window_add =[Windows.Markup.XamlReader]::Load( $reader )
    $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_add.FindName($_.Name)}
    
    # WPF Content, tooltip values
    $Window_add.Title=$txt.MainTitle2    
    $C_Gamepath.Content = $txt.C_GamepathContent
    $C_registre.Content=$txt.C_registreContent
    $T_registre.ToolTip = $txt.T_registreToolTip
    $T_Gamepath.ToolTip= $txt.T_GamepathToolTip
    $T_voice.ToolTip = $txt.T_voiceToolTip
    $C_SubDir.Content = $txt.C_SubDirContent
    $T_Subdir.ToolTip = $txt.T_SubdirToolTip
    $C_DisableDirectMusic.Content=$txt.C_DisableDirectMusicContent
    $C_DisableDirectMusic.ToolTip=$txt.C_DisableDirectMusicToolTip
    $C_Rootdir.Content=$txt.C_RootdirContent
    $L_GameTitle.Content=$txt.L_GameTitleContent
    $T_buffers.ToolTip = $txt.T_buffersToolTip
    $L_Buffers.Content=$txt.T_BuffersContent
    $L_Buffers.toolTip=$txt.T_BuffersToolTip
    $T_duration.toolTip = $txt.T_DurationToolTip
    $L_Duration.Content=$txt.T_DurationContent
    $L_Duration.ToolTip=$txt.T_DurationToolTip
    $L_Voice.Content=$txt.T_VoiceContent
    $L_Settings.Content=$txt.L_Settings
    $B_Cancel.Content=$txt.B_CancelContent
    $B_ok.Content=$txt.B_OkContent
    $L_Debug1.Content=$txt.L_Debug1Content
    $L_Debug2.Content=$txt.L_Debug2Content
    $C_LogDirectSound.Content=$txt.C_LogDirectSoundContent
    $C_LogDirectSound2D.Content=$txt.C_LogDirectSound2DContent
    $C_LogDirectSound2DStreaming.Content=$txt.C_LogDirectSound2DStreamingContent
    $C_LogDirectSound3D.Content=$txt.C_LogDirectSound3DContent
    $C_LogDirectSoundListener.Content=$txt.C_LogDirectSoundListenerContent
    $C_LogDirectSoundEAX.Content=$txt.C_LogDirectSoundEAXContent
    $C_LogDirectSoundTimingInfo.Content=$txt.C_LogDirectSoundTimingInfoContent
    $C_LogStarvation.Content=$txt.C_LogStarvationContent
    $C_LogDirectSound.ToolTip=$txt.C_logtextTooltip
    $C_LogDirectSound2D.ToolTip=$txt.C_logtextTooltip
    $C_LogDirectSound2DStreaming.ToolTip=$txt.C_logtextTooltip
    $C_LogDirectSound3D.ToolTip=$txt.C_logtextTooltip
    $C_LogDirectSoundListener.ToolTip=$txt.C_logtextTooltip
    $C_LogDirectSoundEAX.ToolTip=$txt.C_logtextTooltip
    $C_LogDirectSoundTimingInfo.ToolTip=$txt.C_logtextTooltip
    $C_LogStarvation.ToolTip=$txt.C_logtextTooltip
    $C_DisableNativeAl.Content=$txt.C_DisableNativeAlContent
    $C_DisableNativeAl.ToolTip=$txt.C_DisableNativeAlToolTip

    # Default value
    $T_buffers.text = 4
    $T_Duration.text = 25
    $T_voice.text = 128
    $C_DisableDirectMusic.IsChecked = $False
    $T_Gamepath.MaxLines=1
    $T_registre.MaxLines=1
    $C_registre.IsChecked=$true
    $C_SubDir.IsChecked=$False
    $T_SubDir.IsReadOnly=$True
    $T_SubDir.Background='#e5e5e5'
    $C_Rootdir.IsChecked=$false
    $C_Rootdir.IsEnabled=$False
    $C_Rootdir.Background = '#e5e5e5'
    $B_SubDir.IsEnabled=$False
    $T_Registre.IsReadOnly=$False
    $T_Registre.Background = '#ffffff'
    $B_GamePath.IsEnabled=$False
    $T_Gamepath.IsReadOnly=$true
    $T_Gamepath.Background = '#e5e5e5'
    $C_DisableNativeAl.IsChecked=$False
    $C_LogDirectSound.IsChecked=$False
    $C_LogDirectSound2D.IsChecked=$False
    $C_LogDirectSound2DStreaming.IsChecked=$False
    $C_LogDirectSound3D.IsChecked=$False
    $C_LogDirectSoundListener.IsChecked=$False
    $C_LogDirectSoundEAX.IsChecked=$False
    $C_LogDirectSoundTimingInfo.IsChecked=$False
    $C_LogStarvation.IsChecked=$False
 
    $C_Registre.Add_Checked({
        $T_Registre.IsReadOnly=$False
        $T_Registre.Background = '#ffffff'
        $B_GamePath.IsEnabled=$False
        $T_Gamepath.IsReadOnly=$true
        $T_Gamepath.Background = '#e5e5e5'
    })

    $C_Gamepath.Add_Checked({
        $T_Registre.IsReadOnly=$true
        $T_Registre.Background = '#e5e5e5'
        $T_Gamepath.IsReadOnly=$False
        $T_Gamepath.Background = '#ffffff'
        $B_GamePath.IsEnabled=$True
    })

    $C_SubDir.Add_Checked({
        $T_SubDir.IsReadOnly=$False
        $T_SubDir.Background = '#ffffff'
        $C_Rootdir.IsEnabled=$True
        $C_Rootdir.Background = '#ffffff'
        $B_SubDir.IsEnabled=$True
        $C_Rootdir.IsEnabled=$true
    })

    $C_SubDir.Add_UnChecked({
        $T_SubDir.IsReadOnly=$True
        $T_SubDir.Background = '#e5e5e5'
        $C_Rootdir.IsEnabled=$False
        $C_Rootdir.Background = '#e5e5e5'
        $B_SubDir.IsEnabled=$False
        $C_Rootdir.IsEnabled=$False
        $C_Rootdir.IsChecked=$False
    })

## CLICK ON GAMEPATH BUTTON (ADD FORM)
    $B_GamePath.add_Click({
        $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
        $foldername.Description = $txt.FolderChoice
        $foldername.rootfolder = "MyComputer"
        #$initialDirectory
        if ($C_Gamepath.IsChecked) {
            $foldername.SelectedPath = $T_Gamepath.text
        }
        if($foldername.ShowDialog() -eq "OK")
        {
            $T_Gamepath.text = $foldername.SelectedPath
        }
    })

## CLICK ON SUBDIR BUTTON (ADD FORM), chek registry path first or gamepath is not present, then test subdir+gamepath path
    $B_SubDir.add_Click({
        $fail = $false
        if ($C_registre.IsChecked) {
            $b = $T_Registre.Text
            if (![string]::IsNullOrEmpty($b)){
                if ($b -like "HKEY_LOCAL_MACHINE*") {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if($b -like "HKEY_CURRENT_USER*") {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        } else {
                            $fail = $True
                            [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                        }    
                    }
            } else {
                $fail = $True
                [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)        
            }
            if ($fail -eq $False) {                
                #retreive registry key
                $regkey = $b|split-path -leaf
                #remove registry key from registry path
                $b = $b.replace("\$regkey","")
                if (!(test-path $b)){
                $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if (test-path $b){
                    try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ($fail -eq $False) {
                        if (!(test-path $Gamepath)){
                            [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                            $fail = $True
                        }
                    }
                } else {
                        $fail = $True
                        [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                }
            }
        } else {
            $Gamepath = $T_Gamepath.text
            if ([string]::IsNullOrEmpty($Gamepath)){ 
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
        }
        if ($fail -eq $False) {
            if (!(test-path $Gamepath)){
                [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
            } else {        
                $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                $foldername.Description = $txt.SubFolderChoice
                $foldername.SelectedPath = $Gamepath
                if($foldername.ShowDialog() -eq "OK"){
                    $Subdir = $foldername.SelectedPath
                    $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                    $Subdir = $Subdir.Trimstart("\")
                    if (test-path $Gamepath\$Subdir){
                        $T_Subdir.text = $Subdir
                    } else { 
                        [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48)
                    }
                }
            }
        }
    })
    $B_Cancel.add_Click({
        $Window_add.Close()
    })
   
### OK BUTTON (ADD FORM), test if every value are correct, then add game to ini file and inside hashtable
    $B_Ok.add_Click({
        $fail = $false
        $regprio = $false
        $b = $T_Registre.Text
        $x = $T_titrejeu.Text

        foreach ($game in $script:listejeux){
            if ($x -eq $game.name){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.TitleExist,"",0,64)
            }
        }
        if ([string]::IsNullOrEmpty($x)){
            $fail = $true
            [System.Windows.MessageBox]::Show($txt.TitleMiss,"",0,64)
        }
        if ($C_registre.IsChecked) {
            if (![string]::IsNullOrEmpty($b)) {
                if ($b -like "HKEY_LOCAL_MACHINE*") {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if($b -like "HKEY_CURRENT_USER*") {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    } 
                $regkey = $b|split-path -leaf
                $b = $b.replace("\$regkey","")
                if (!(test-path $b)){
                    $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if (test-path $b){
                    try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ($fail -eq $false){
                        if (!(test-path $Gamepath)){
                            [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                            $fail = $true
                        }
                        $regprio = $true
                        $Gamepath = $Gamepath.TrimEnd("\")
                    }
                } else {
                    [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                    $fail = $true
                }
            } else {
                [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                $fail = $true
             }
        } else {
            $Gamepath = $T_Gamepath.text
        }    
        if ($fail -eq $False) {
            if ([string]::IsNullOrEmpty($Gamepath)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
            else {
                if (!(test-path $Gamepath)){
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                }
            }
        }
        if ($B_SubDir.IsEnabled -and $fail -eq $false){
            $Subdir = $T_Subdir.text
            if (!(test-path $Gamepath\$Subdir)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
            } 
        }
        if (!($T_buffers.text -In 2..10)){
            $fail = $true
            [System.Windows.MessageBox]::Show($txt.BuffersErr,"",0,48)
        }
        if (!($T_Duration.Text -In 2..50)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.DurationErr,"",0,48)
        }
        if (!($T_voice.text -In 32..128)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.VoiceErr,"",0,48)
        }
        # test if no error
        if ($fail -eq $False){
            # Value to write
            $Name = $T_titrejeu.text
            $Buffers = $T_buffers.text
            $Voice = $T_voice.text
            $Duration = $T_Duration.text
            if ($C_DisableDirectMusic.IsChecked) {
                $DisableDirectMusic=1
            } else {
                $DisableDirectMusic=0
            }
            if ($C_Rootdir.IsChecked){
                $RootDirInstallOption="True"
            } else {
                $RootDirInstallOption="False"
            }
            if ($C_DisableNativeAl.IsChecked){
                $DisableNativeAL="True"
            } else { 
                $DisableNativeAL ="False"
            }
            if ($C_SubDir.IsUnchecked){
                $SubDir=""
                $RootDirInstallOption="False"
            }
             if ($C_LogDirectSound.IsChecked){
                $LogDirectSound="True"
            } else { 
                $LogDirectSound ="False"
            }
             if ($C_LogDirectSound2D.IsChecked){
                $LogDirectSound2D="True"
            } else { 
                $LogDirectSound2D ="False"
            }
             if ($C_LogDirectSound2DStreaming.IsChecked){
                $LogDirectSound2DStreaming="True"
            } else { 
                $LogDirectSound2DStreaming ="False"
            }
             if ($C_LogDirectSound3D.IsChecked){
                $LogDirectSound3D="True"
            } else { 
                $LogDirectSound3D ="False"
            }
             if ($C_LogDirectSoundListener.IsChecked){
                $LogDirectSoundListener="True"
            } else { 
                $LogDirectSoundListener ="False"
            }
             if ($C_LogDirectSoundEAX.IsChecked){
                $LogDirectSoundEAX="True"
            } else { 
                $LogDirectSoundEAX ="False"
            }
             if ($C_LogDirectSoundTimingInfo.IsChecked){
                $LogDirectSoundTimingInfo="True"
            } else { 
                $LogDirectSoundTimingInfo ="False"
            }
             if ($C_LogStarvation.IsChecked){
                $LogStarvation="True"
            } else { 
                $LogStarvation ="False"
            }
            # Write change in file, Registry first, Gamepath second choice
            if ($regprio -eq $true) {
                $RegPath = $T_Registre.Text
                $Gamepath=""
            }else{
                $RegPath=""
                $Gamepath=$T_Gamepath.text
            }
            "[$Name]`rRegPath=$RegPath`rGamePath=$Gamepath`rBuffers=$Buffers`rDuration=$Duration`rDisableDirectMusic=$DisableDirectMusic`rMaxVoiceCount=$Voice`rSubDir=$SubDir`rRootDirInstallOption=$RootDirInstallOption`rDisableNativeAL=$DisableNativeAL`rLogDirectSound=$LogDirectSound`rLogDirectSound2D=$LogDirectSound2D`rLogDirectSound2DStreaming=$LogDirectSound2DStreaming`rLogDirectSound3D=$LogDirectSound3D`rLogDirectSoundListener=$LogDirectSoundListener`rLogDirectSoundEAX=$LogDirectSoundEAX`rLogDirectSoundTimingInfo=$LogDirectSoundTimingInfo`rLogStarvation=$LogStarvation`r`n"| Out-File -Append $PSScriptRoot\NewAlchemy.ini -encoding ascii

            # Update list game to reflect change, Order listview by name
            $script:listejeux += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $buffers -Duration $duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $Voice -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Found $True -Transmut $False      
            $script:jeutrouve = $script:listejeux | where-object Found -eq $True
            checktransmut $script:jeutrouve | Out-Null
            $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
            $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
            $MenuGauche.Items.Clear()
            foreach ($jeu in $jeunontransmut){
                $MenuGauche.Items.Add($jeu.name) | Out-Null
            }
            $MenuDroite.Items.Clear()
            foreach ($jeu in $jeutransmut){
                $MenuDroite.Items.Add($jeu.name) | Out-Null
            }
            Sortlistview $MenuGauche
            Sortlistview $MenuDroite
            $Window_add.Close()
        }
    })
    $Window_add.ShowDialog() | out-null
})

### Default Button (MAIN FORM)
$BoutonParDefaut.add_Click({
    $choice = [System.Windows.MessageBox]::Show("$($txt.Defaultmsgbox)`r$($txt.Defaultmsgbox2)`r$(Get-Location)\NewAlchemy.bak`r`r$($txt.Defaultmsgbox3)" , "NewAlchemy" , 4,64)
    if ($choice -eq 'Yes') {
        move-Item "$PSScriptRoot\NewAlchemy.ini" "$PSScriptRoot\NewAlchemy.Bak" -force
        GenerateNewAlchemy "$PathAlchemy\Alchemy.ini"	
        $script:listejeux = read-file "$PSScriptRoot\NewAlchemy.ini"
        checkinstall $script:listejeux | Out-Null
        $script:jeutrouve = $script:listejeux | where-object Found -eq $true
        checktransmut $script:jeutrouve | Out-Null
        $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
        $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
        $MenuGauche.Items.Clear()
        foreach ($jeu in $jeunontransmut){
            $MenuGauche.Items.Add($jeu.name) | Out-Null
        }
        $MenuDroite.Items.Clear()
        foreach ($jeu in $jeutransmut){
            $MenuDroite.Items.Add($jeu.name) | Out-Null
        }
    }
})

$Window.ShowDialog() | out-null
