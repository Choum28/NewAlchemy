<# 
.SYNOPSIS
    This script is a test to recreate the Creative Alchemy application in powershell with some new options and possibilities.
    edit line 245 if alchemy is not installed in a default folder "C:\Program Files (x86)\Creative\ALchemy"

.DESCRIPTION
    What different from creative alchemy :
        Registry path are check in both X86 and X86-64 path.
        Add support for DisableNativeAL Option to Disable ALchemy to ouput to OpenAl drivers (CT_oal.dll only)
            Post X-fi card will need to rename sens_oal.dll to Ct_oal.dll to make use of it.
            X-fi card should set this settings to False by default and yes in case of problem with specific game.
            Post X-fi card must do the opposite, the scripts is set this option to true by default

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
    1.0     15.11.2020
            First version
.LINK
 #>

function add-Game { # Convert value into hash table.
    param([string]$Name,[string]$RegPath,[string]$Gamepath,[int]$Buffers,[int]$Duration,[string]$DisableDirectMusic,[int]$MaxVoiceCount,[string]$SubDir,[string]$RootDirInstallOption,[String]$DisableNativeAL,[bool]$Found,[bool]$Transmut)
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
    }
    return $d
}

function read-file{ #read alchemy ini file and convert game to hash table with add-game function, default value are define here if not present in alchemy.ini.
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
    $DisableNativeAL="True"
    $Found=$false
    $Transmut=$false

    foreach ($line in $list) {
        $Number = $Number + 1
        if($line -notlike ';*') {

            if($line -like '`[*') {
            if ($test -gt 0) {
                    $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Found $Found -Transmut $Transmut
                    $RegPath=""
                    $Gamepath=""
                    $Buffers=4
                    $Duration=25
                    $DisableDirectMusic="False"
                    $MaxVoiceCount=128
                    $SubDir=""
                    $RootDirInstallOption="False"
                    $DisableNativeAL="True"
                    $Found=$false
                    $Transmut=$false
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
        }
    }
    if ($Number -ne $test){
        $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Transmut $Transmut
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
;  DisableNativeAL <-- Bypass Native OpenAL drivers (Ct_oal.dll only) to use Alchemy internal libray (default is True, set to False for old X-fi Card)

"@ | Out-File -Append NewAlchemy.ini -encoding ascii
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
        "[$a]" | Out-File -Append NewAlchemy.ini -encoding ascii
        "RegPath=$b" | Out-File -Append NewAlchemy.ini -encoding ascii
        "GamePath=$c" | Out-File -Append NewAlchemy.ini -encoding ascii
        "Buffers=$d" | Out-File -Append NewAlchemy.ini -encoding ascii
        "Duration=$e" | Out-File -Append NewAlchemy.ini -encoding ascii
        "DisableDirectMusic=$f" | Out-File -Append NewAlchemy.ini -encoding ascii
        "MaxVoiceCount=$g" | Out-File -Append NewAlchemy.ini -encoding ascii
        "SubDir=$h" | Out-File -Append NewAlchemy.ini -encoding ascii
        "RootDirInstallOption=$i" | Out-File -Append NewAlchemy.ini -encoding ascii
        "DisableNativeAL=$j`r`n" | Out-File -Append NewAlchemy.ini -encoding ascii
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
        #récupérer clef registre
        $regkey = $b|split-path -leaf
        #"supprimer clef du lien registre"
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
function checkinstall{ # Check if game list is installed with check present function.
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

# add automatic detection ? check if newalchemy.ini is present or generate one
Set-Location "C:\Program Files (x86)\Creative\ALchemy"
if (!(Test-Path -path ".\newalchemy.ini")) {
    GenerateNewAlchemy ".\Alchemy.ini"
}

$liste = read-file ".\NewAlchemy.ini"
checkinstall $liste | Out-Null
$global:jeutrouve = $liste | where-object Found -eq $true
#$jeutrouve | Out-GridView
checktransmut $global:jeutrouve | Out-Null
$jeutransmut = $global:jeutrouve | where-object Transmut -eq $true
$jeunontransmut = $global:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}

[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
# Main windows
$inputXML =@"
<Window x:Class="alchemy.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:alchemy"
        mc:Ignorable="d"
        Title="New Alchemy" Height="417.814" Width="810.127">
    <Grid>
        <ListView x:Name="MenuGauche" HorizontalAlignment="Left" Height="280" Margin="20,75,0,0" VerticalAlignment="Top" Width="310">
            <ListView.View>
                <GridView>
                    <GridViewColumn Width="300"/>
                </GridView>
            </ListView.View>
        </ListView>
        <ListView x:Name="MenuDroite" HorizontalAlignment="Left" Height="280" Margin="472,75,0,0" VerticalAlignment="Top" Width="310">
            <ListView.View>
                <GridView>
                    <GridViewColumn Width="300"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button x:Name="BoutonTransmut" Content="&gt;&gt;" HorizontalAlignment="Left" Height="45" Margin="350,100,0,0" VerticalAlignment="Top" Width="100"/>
        <Button x:Name="BoutonUnTransmut" Content="&lt;&lt;" HorizontalAlignment="Left" Height="45  " Margin="350,163,0,0" VerticalAlignment="Top" Width="100"/>
        <Button x:Name="BoutonEdition" Content="&lt;&lt; Edition" HorizontalAlignment="Left" Height="25" Margin="350,256,0,0" VerticalAlignment="Top" Width="100"/>
        <Button x:Name="BoutonAjouter" Content="Ajouter" HorizontalAlignment="Left" Height="25" Margin="350,293,0,0" VerticalAlignment="Top" Width="100"/>
        <TextBlock x:Name="Text_main" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,10,0,0" Width="762" Height="34"><Run Text="NewAlchemy restitue un son accéléré par composant matériel de sorte que vous puissez profiter des effets EAX"/><Run Text=" et du son Audio 3D lorsque vous utilisez des jeux  DirectSound3D dans windows version Vista et supérieures."/></TextBlock>
        <TextBlock x:Name="Text_jeuinstall" HorizontalAlignment="Left" TextWrapping="Wrap" Text="Jeux installés" VerticalAlignment="Top" Margin="20,54,0,0" Width="238"/>
        <TextBlock HorizontalAlignment="Left" TextWrapping="Wrap" Text="Jeux activés par NewAlchemy" VerticalAlignment="Top" Margin="472,54,0,0" Width="173"/>
        <TextBlock HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Center" Margin="735,360,0,40" Width="47" Height="17" FontSize="8" Text="Version 1.0"/>
        <TextBlock x:Name="T_URL" HorizontalAlignment="Left" TextWrapping="Wrap" Text="https://github.com/Choum28/NewAlchemy" VerticalAlignment="Top" Margin="20,361,0,0" FontSize="8"/>
        <TextBlock x:Name="T_version" HorizontalAlignment="Left" TextWrapping="Wrap" Text="Version 1.0" VerticalAlignment="Top" Margin="733,359,0,0" FontSize="8"/>
    </Grid>
</Window>

"@
# function to remove unneeded XAML options for powershell
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window =[Windows.Markup.XamlReader]::Load( $reader )
$xaml.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

# populate each listview
$MenuGauche.Items.Clear()
foreach ($jeu in $jeunontransmut){
    $MenuGauche.Items.Add($jeu.name)
}

$MenuDroite.Items.Clear()
foreach ($jeu in $jeutransmut){
    $MenuDroite.Items.Add($jeu.name)
}

#Transmut Button Copy needed file to gamepath and refresh listview (sort by name)
$BoutonTransmut.add_Click({
    $x = $Menugauche.SelectedItem
        foreach($game in $global:jeutrouve){
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
                $text =   @"
Buffers=$Buffers
Duration=$Duration
MaxVoiceCount=$MaxVoiceCount
DisableDirectMusic=$DisableDirectMusic
DisableNativeAL=$DisableNativeAL
"@ 
                if ([string]::IsNullOrEmpty($Subdir)){
                    if (test-path ("$gamepath\dsound.ini")){
                        Remove-Item -Path $gamepath\dsound.ini -force
                    }
                    New-Item -Path $gamepath -Name "dsound.ini" -force
                    $text | Out-File $gamepath\dsound.ini -encoding ascii
                    Copy-Item -Path ".\dsound.dll" -Destination $gamepath
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
                    Copy-Item -Path ".\dsound.dll" -Destination $gamepath
                    Copy-Item -Path ".\dsound.dll" -Destination $gamepath\$Subdir

                } elseif (test-path ("$gamepath\$SubDir\dsound.ini")){
                    Remove-Item -Path "$gamepath\$SubDir\dsound.ini" -force
                    New-Item -Path "$gamepath\$SubDir" -Name "dsound.ini" -force
                    $text | Out-File $gamepath\$SubDir\dsound.ini -encoding ascii
                    Copy-Item -Path ".\dsound.dll" -Destination $gamepath\$Subdir

                } else { 
                    New-Item -Path "$gamepath\$Subdir" -Name "dsound.ini" -force
                    $text | Out-File $gamepath\$SubDir\dsound.ini -encoding ascii
                    Copy-Item -Path ".\dsound.dll" -Destination $gamepath\$Subdir
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
    foreach ($game in $global:jeutrouve){
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
        $InputXML =@"
<Window x:Name="Parametre_jeu" x:Class="Edit.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Edit"
        mc:Ignorable="d"
        Title="Parametres du jeu" Height="560.102" Width="552.512" VerticalAlignment="Bottom">
    <Grid>
        <TextBox x:Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
        <RadioButton x:Name="C_registre" Content="Utiliser le chemin d'accès au registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
        <RadioButton x:Name="C_Gamepath" Content="Utiliser le chemin d'accès au jeu" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
        <TextBox x:Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <TextBox x:Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
        <TextBox x:Name="T_buffers" HorizontalAlignment="Left" Height="22" Margin="188,331,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
        <TextBox x:Name="T_Duration" HorizontalAlignment="Left" Height="22" Margin="188,359,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
        <TextBox x:Name="T_voice" HorizontalAlignment="Left" Height="22" Margin="188,387,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293" AutomationProperties.HelpText="de 0 à 128"/>
        <CheckBox x:Name="C_SubDir" Content="Installer dans un sous-dossier" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
        <TextBox x:Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <CheckBox x:Name="C_DisableDirectMusic" Content="Désactiver la musique directe" HorizontalAlignment="Left" Margin="188,424,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="C_DisableNativeAl" Content="Désactiver le pilote OpenAL natif" HorizontalAlignment="Left" Margin="188,444,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="C_Rootdir" Content="Installer dans le dossier racine et un sous-dossier" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
        <Label Content="Titre du jeu" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
        <Label Content="Tampons" HorizontalAlignment="Left" Margin="45,327,0,0" VerticalAlignment="Top" Width="79" Height="26"/>
        <Label Content="Durée" HorizontalAlignment="Left" Margin="45,358,0,0" VerticalAlignment="Top" Height="23" Width="79"/>
        <Label Content="Nombre maximal de voix" HorizontalAlignment="Left" Height="25" Margin="45,384,0,0" VerticalAlignment="Top" Width="143"/>
        <Label Content="Paramètres" HorizontalAlignment="Left" Margin="28,297,0,0" VerticalAlignment="Top" Width="143"/>
        <Button x:Name="B_Cancel" Content="Annuler" HorizontalAlignment="Left" Height="25" Margin="439,491,0,0" VerticalAlignment="Top" Width="90"/>
        <Button x:Name="B_ok" Content="Ok" HorizontalAlignment="Left" Height="25" Margin="331,491,0,0" VerticalAlignment="Top" Width="90"/>
        <Button x:Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
        <Button x:Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
    </Grid>
</Window>
"@
        $inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
        [xml]$XAML = $inputXML
        $reader=(New-Object System.Xml.XmlNodeReader $XAML)
        $Window_edit =[Windows.Markup.XamlReader]::Load( $reader )
        $xaml.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_edit.FindName($_.Name)}

        $T_Titrejeu.IsReadOnly=$true
        $T_Titrejeu.Background = '#e5e5e5'
    
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
        foreach ($game in $global:jeutrouve){
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
            } else {
                if ($found -ne 1){
                    $count = $count +1
                }
            }
        }

    ## CLICK ON ICON GAMEPATH (EDIT FORM)
        $B_GamePath.add_Click({
            $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
            $foldername.Description = "Sélectionnez un dossier"
            $foldername.rootfolder = "MyComputer"
            if ($C_Gamepath.IsChecked) {
                $foldername.SelectedPath = $T_Gamepath.text
            }
            if($foldername.ShowDialog() -eq "OK")
            {
                $T_Gamepath.text = $foldername.SelectedPath
            }
        })

    ## CLICK ON ICON SUBDIR (EDIT FORM)
        $B_SubDir.add_Click({
            if ($C_registre.IsChecked) {
                $b = $T_Registre.Text
                if ($b -like "HKEY_LOCAL_MACHINE*") {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if($b -like "HKEY_CURRENT_USER*") {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    }        
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
                        [System.Windows.Forms.MessageBox]::Show("Valeur registre incorrect")
                    }
                    if (!(test-path $Gamepath)){
                        [System.Windows.Forms.MessageBox]::Show("La clef registre ne renvoie pas un chemin")
                    }
                }
            } else { 
                $Gamepath = $T_Gamepath.text
            }
            if (!(test-path $Gamepath)){
                [System.Windows.Forms.MessageBox]::Show("Le chemin est invalide")
            }        
            $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
            $foldername.Description = "Sélectionnez un sous-dossier"
            $foldername.SelectedPath = $Gamepath
            if($foldername.ShowDialog() -eq "OK"){
                $Subdir = $foldername.SelectedPath
                $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                $Subdir = $Subdir.Trimstart("\")
                if (test-path $Gamepath\$Subdir){
                    $T_Subdir.text = $Subdir
                } else { 
                    [System.Windows.Forms.MessageBox]::Show("le chemin n'existe pas ou n'est pas un sous-dossier.")
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
            $b = $T_Registre.Text
            if ($C_registre.IsChecked) {
                if ($b -like "HKEY_LOCAL_MACHINE*") {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if($b -like "HKEY_CURRENT_USER*") {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    }        
                #récupérer clef registre
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
                        [System.Windows.Forms.MessageBox]::Show("Valeur registre incorrect")
                    }
                    if (!(test-path $Gamepath)){
                        [System.Windows.Forms.MessageBox]::Show("La clef registre ne pointe pas sur un chemin")
                        $fail = $true
                    }
                    $regprio = $true
                    $Registre = $T_Registre.Text
                }
            } else {
                $Gamepath = $T_Gamepath.text
            }
            $Gamepath = $Gamepath.TrimEnd("\")
            if (![string]::IsNullOrEmpty($Gamepath)){
                if (!(test-path $Gamepath)){
                    $fail = $true
                    [System.Windows.Forms.MessageBox]::Show("Le chemin est invalide")
                } 
            }
            if ($C_SubDir.IsChecked){
                $Subdir = $T_Subdir.text
                if (!(test-path $Gamepath\$Subdir)){
                    $fail = $true
                    [System.Windows.Forms.MessageBox]::Show("Le sous-dossier est introuvable")
                } 
            }
            if (!($T_buffers.text -In 2..10)){
                $fail = $true
                [System.Windows.Forms.MessageBox]::Show("La valeur du tampon doit être de 2 à 10 !")
            }
            if (!($T_Duration.Text -In 2..50)){
                    $fail = $true
                    [System.Windows.Forms.MessageBox]::Show("La durée doit être de 5 à 50. !")
            }
            if (!($T_voice.text -In 32..128)){
                    $fail = $true
                    [System.Windows.Forms.MessageBox]::Show("Le nombre maximal de voix doit être de 32 à 128 !")
            }
            # Test if no error
            if ($fail -eq $False){

                # Prepare Game value to write
                $name = $T_titrejeu.text
                $buffers = $T_buffers.text
                $voice = $T_voice.text
                $duration = $T_Duration.text
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
                # Update list game to reflect change    
                $global:jeutrouve[$count].RegPath=$Registre
                $global:jeutrouve[$count].Gamepath=$Gamepath
                $global:jeutrouve[$count].Buffers=$buffers
                $global:jeutrouve[$count].Duration=$duration
                $global:jeutrouve[$count].DisableDirectMusic=$DisableDirectMusic
                $global:jeutrouve[$count].MaxVoiceCount=$voice
                $global:jeutrouve[$count].SubDir=$Subdir
                $global:jeutrouve[$count].RootDirInstallOption=$RootDirInstallOption
                $global:jeutrouve[$count].DisableNativeAL=$DisableNativeAL
                # Write change in file
                $file = Get-content ".\Newalchemy.ini"
                $LineNumber = Select-String -pattern ([regex]::Escape("[$Name]")) NewAlchemy.ini| Select-Object -ExpandProperty LineNumber
                if ($regprio -eq $true) {
                    $file[$LineNumber] = "RegPath=$Registre"
                    $file[$LineNumber +1]="GamePath="
                }else{
                    $file[$LineNumber] = "RegPath="
                    $file[$LineNumber +1]="GamePath=$Gamepath" 
                }
                $file[$LineNumber +2] = "Buffers=$buffers" 
                $file[$LineNumber +3] = "Duration=$duration" 
                $file[$LineNumber +4] = "DisableDirectMusic=$DisableDirectMusic" 
                $file[$LineNumber +5] = "MaxVoiceCount=$voice" 
                $file[$LineNumber +6] = "SubDir=$Subdir" 
                $file[$LineNumber +7] = "RootDirInstallOption=$RootDirInstallOption"
                $file[$LineNumber +8] = "DisableNativeAL=$DisableNativeAL" 
                $file | Set-Content NewAlchemy.ini -encoding ascii
                
                $Window_edit.Close()
                }
        })
        $Window_edit.ShowDialog() | out-null
    }
})

### ADD BUTTON (MAIN FORM)
$BoutonAjouter.add_Click({
    $InputXML =@"
<Window x:Name="Parametre_jeu" x:Class="Edit.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Edit"
        mc:Ignorable="d"
        Title="Parametres du jeu" Height="560.102" Width="552.512" VerticalAlignment="Bottom">
    <Grid>
        <TextBox x:Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
        <RadioButton x:Name="C_registre" Content="Utiliser le chemin d'accès au registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
        <RadioButton x:Name="C_Gamepath" Content="Utiliser le chemin d'accès au jeu" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
        <TextBox x:Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <TextBox x:Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
        <TextBox x:Name="T_buffers" HorizontalAlignment="Left" Height="22" Margin="188,331,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
        <TextBox x:Name="T_Duration" HorizontalAlignment="Left" Height="22" Margin="188,359,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293"/>
        <TextBox x:Name="T_voice" HorizontalAlignment="Left" Height="22" Margin="188,387,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="293" />
        <CheckBox x:Name="C_SubDir" Content="Installer dans un sous-dossier" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
        <TextBox x:Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <CheckBox x:Name="C_DisableDirectMusic" Content="Désactiver la musique directe" HorizontalAlignment="Left" Margin="188,424,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="C_DisableNativeAl" Content="Désactiver le pilote OpenAL natif" HorizontalAlignment="Left" Margin="188,444,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="C_Rootdir" Content="Installer dans le dossier racine et un sous-dossier" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
        <Label Content="Titre du jeu" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
        <Label Content="Tampons" HorizontalAlignment="Left" Margin="45,327,0,0" VerticalAlignment="Top" Width="79" Height="26"/>
        <Label Content="Durée" HorizontalAlignment="Left" Margin="45,358,0,0" VerticalAlignment="Top" Height="23" Width="79"/>
        <Label Content="Nombre maximal de voix" HorizontalAlignment="Left" Height="25" Margin="45,384,0,0" VerticalAlignment="Top" Width="143"/>
        <Label Content="Paramètres" HorizontalAlignment="Left" Margin="28,297,0,0" VerticalAlignment="Top" Width="143"/>
        <Button x:Name="B_Cancel" Content="Annuler" HorizontalAlignment="Left" Height="25" Margin="439,491,0,0" VerticalAlignment="Top" Width="90"/>
        <Button x:Name="B_ok" Content="Ok" HorizontalAlignment="Left" Height="25" Margin="331,491,0,0" VerticalAlignment="Top" Width="90"/>
        <Button x:Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
        <Button x:Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
    </Grid>
</Window>

"@
    $inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
    [xml]$XAML = $inputXML
    $reader=(New-Object System.Xml.XmlNodeReader $XAML)
    $Window_add =[Windows.Markup.XamlReader]::Load( $reader )
    $xaml.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_add.FindName($_.Name)}

    $T_buffers.text = 4
    $T_Duration.text = 25
    $T_voice.text = 128
    $C_DisableNativeAl.IsChecked=$True
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
        $foldername.Description = "Sélectionnez un dossier"
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
        if ($C_registre.IsChecked) {
            $b = $T_Registre.Text
            if ($b -like "HKEY_LOCAL_MACHINE*") {
                $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
            } else {
                    if($b -like "HKEY_CURRENT_USER*") {
                        $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                    }
                }        
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
                    [System.Windows.Forms.MessageBox]::Show("Valeur registre incorrect")
                }
                if (!(test-path $Gamepath)){
                    [System.Windows.Forms.MessageBox]::Show("La clef registre ne pointe pas sur un chemin")
                }
            }
        } else {
            $Gamepath = $T_Gamepath.text
        }
            if (!(test-path $Gamepath)){
                [System.Windows.Forms.MessageBox]::Show("Le chemin est invalide")
            }        
        $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
        $foldername.Description = "Sélectionnez un sous-dossier"
        $foldername.SelectedPath = $Gamepath
        if($foldername.ShowDialog() -eq "OK"){
            $Subdir = $foldername.SelectedPath
            $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
            $Subdir = $Subdir.Trimstart("\")
            if (test-path $Gamepath\$Subdir){
                $T_Subdir.text = $Subdir
            } else { 
                [System.Windows.Forms.MessageBox]::Show("le chemin n'existe pas ou n'est pas un sous-dossier.")
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

        foreach ($game in $liste){
            if ($x -eq $game.name){
                $fail = $true
                [System.Windows.Forms.MessageBox]::Show("Titre de jeu déja existant")
            }
        }
        if ([string]::IsNullOrEmpty($x)){
            $fail = $true
            [System.Windows.Forms.MessageBox]::Show("Titre de jeu obligatoire")
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
                        [System.Windows.Forms.MessageBox]::Show("Valeur registre incorrect")
                    }
                    if (!(test-path $Gamepath)){
                        [System.Windows.Forms.MessageBox]::Show("La clef registre ne pointe pas sur un chemin")
                        $fail = $true
                    }
                    $regprio = $true
                } else {
                    [System.Windows.Forms.MessageBox]::Show("La clef registre est invalide")
                    $fail = $true
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("La clef registre est vide")
                $fail = $true
             }
        } else {
            $Gamepath = $T_Gamepath.text
        }
        if (![string]::IsNullOrEmpty($Gamepath)){
            if (!(test-path $Gamepath)){
                $fail = $true
                [System.Windows.Forms.MessageBox]::Show("Le chemin est invalide")
            } 
        }
        if ($B_SubDir.IsEnabled){
            $Subdir = $T_Subdir.text
            if (!(test-path $Gamepath\$Subdir)){
                $fail = $true
                [System.Windows.Forms.MessageBox]::Show("Le sous-dossier est introuvable")
            } 
        }
        if (!($T_buffers.text -In 2..10)){
            $fail = $true
            [System.Windows.Forms.MessageBox]::Show("La valeur du tampon doit être de 2 à 10 !")
        }
        if (!($T_Duration.Text -In 2..50)){
                $fail = $true
                [System.Windows.Forms.MessageBox]::Show("La durée doit être de 5 à 50. !")
        }
        if (!($T_voice.text -In 32..128)){
                $fail = $true
                [System.Windows.Forms.MessageBox]::Show("Le nombre maximal de voix doit être de 32 à 128 !")
        }
        # test if no error
        if ($fail -eq $False){

            # Value to write
            $name = $T_titrejeu.text
            $buffers = $T_buffers.text
            $voice = $T_voice.text
            $duration = $T_Duration.text
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

            # Write change in file, Registry first, Gamepath second choice
            "[$name]" | Out-File -Append NewAlchemy.ini -encoding ascii
            if ($regprio -eq $true) {
                $Registre = $T_Registre.Text
                "RegPath=$Registre" | Out-File -Append NewAlchemy.ini -encoding ascii
                "GamePath="| Out-File -Append NewAlchemy.ini -encoding ascii
            }else{
                $Gamepath=$T_Gamepath.text
                "RegPath=" | Out-File -Append NewAlchemy.ini -encoding ascii
                "GamePath=$Gamepath"| Out-File -Append NewAlchemy.ini -encoding ascii
            }
            "Buffers=$buffers" | Out-File -Append NewAlchemy.ini -encoding ascii
            "Duration=$duration"| Out-File -Append NewAlchemy.ini -encoding ascii
            "DisableDirectMusic=$DisableDirectMusic"| Out-File -Append NewAlchemy.ini -encoding ascii
            "MaxVoiceCount=$voice"| Out-File -Append NewAlchemy.ini -encoding ascii
            "SubDir=$SubDir"| Out-File -Append NewAlchemy.ini -encoding ascii
            "RootDirInstallOption=$RootDirInstallOption"| Out-File -Append NewAlchemy.ini -encoding ascii
            "DisableNativeAL=$DisableNativeAL`r`n"| Out-File -Append NewAlchemy.ini -encoding ascii

            # Update list game to reflect change, Order listview by name
            $MenuGauche.Items.Add($name)
            Sortlistview $Menugauche
            $global:jeutrouve += add-Game -Name $name -RegPath $Registre -Gamepath $Gamepath -Buffers $buffers -Duration $duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $Voice -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Found $True -Transmut $False      
            $Window_add.Close()
        }
    })
    $Window_add.ShowDialog() | out-null
})
$Window.ShowDialog() | out-null
