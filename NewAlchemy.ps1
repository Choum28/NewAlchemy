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
 .\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\apps\NewAlchemy-main\Alchemy.ps1"
        Launch the script and hide console

.OUTPUTS
    This script will generate an ini file NewAlchemy.ini to store gamelist audio options and change.
    
.NOTES
    NOM:       NewALchemy.ps1
    AUTEUR:    Choum

    HISTORIQUE VERSION:
    1.09    17.08.2024    Hash check for transmuted game to exclude game with dsoal dsound.dll to appears as transmuted per newalchemy, fix bug related to missing dsound.ini log info when you transmut a newly created game.
    1.08    15.08.2024    Add doubleclick support to transmut/Untransmut, possibility to edit from both Listview.
    1.07    04.08.2024    Test subdir path (if filled) before adding game to the detected list on startup.
    1.06    25.07.2024    Significant improved loading time.
    1.05    23.07.2024    WPF forms are now rezisable.
    1.04    28.01.2024    No need anymore to install the scripts inside alchemy folder (Creative alchemy installed is still required), add default (reset) button.
    1.03    24.01.2024    Script_Internationalization with psd1 file for easier translation, fix non critical error, improve error message, add messagebox Icon.
    1.02    20.01.2024    Few Bugfix, add Debug settings, Remove NativeAl value question on first launch
    1.01    06.10.2021    Fix edit new add game bug, add Nativeal value question on first launch
    1.0     15.11.2020    First version
.LINK
 #>

# Locate Alchemy installation and check for necessary files, return Creative alchemy path.
function LocateAlchemy { 
    if ( [Environment]::Is64BitOperatingSystem -eq $true ) {
        $key = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{12321490-F573-4815-B6CC-7ABEF18C9AC4}"
    } else { $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{12321490-F573-4815-B6CC-7ABEF18C9AC4}" }
    $regkey = "InstallLocation"
    if ( test-path $key ) {
        try { $path = Get-ItemPropertyvalue -Path $key -name $regkey }
        catch { 
            [System.Windows.MessageBox]::Show($txt.Badlocation,"",0,16)
            exit
        }
        if ( Test-Path -path "$path\alchemy.ini" ) {
            if ( Test-Path -path "$path\dsound.dll" ) {
                return $path
            } else { [System.Windows.MessageBox]::Show("$($txt.missfile) $path\dsound.dll","",0,16) }
        } else { [System.Windows.MessageBox]::Show("$($txt.missfile) $path\alchemy.ini","",0,16) }
    } else { [System.Windows.MessageBox]::Show($txt.Badlocation,"",0,16) }  
    exit
}

# Convert value into hash table.
function add-Game { 
    param(
        [string]$Name,
        [string]$RegPath,
        [string]$Gamepath,
        [int]$Buffers,
        [int]$Duration,
        [string]$DisableDirectMusic,
        [int]$MaxVoiceCount,
        [string]$SubDir,
        [string]$RootDirInstallOption,
        [String]$DisableNativeAL,
        [bool]$Found,
        [bool]$Transmut,
        [string]$LogDirectSound,
        [string]$LogDirectSound2D,
        [string]$LogDirectSound2DStreaming,
        [string]$LogDirectSound3D,
        [string]$LogDirectSoundListener,
        [string]$LogDirectSoundEAX,
        [string]$LogDirectSoundTimingInfo,
        [string]$LogStarvation
    )
    
    $d = @{
        Name = $Name
        RegPath = $RegPath
        Gamepath = $Gamepath
        Buffers = $Buffers
        Duration = $Duration
        DisableDirectMusic = $DisableDirectMusic
        MaxVoiceCount = $MaxVoiceCount
        SubDir = $SubDir
        RootDirInstallOption = $RootDirInstallOption
        DisableNativeAL = $DisableNativeAL
        Found = $Found
        Transmut = $Transmut
        LogDirectSound = $LogDirectSound
        LogDirectSound2D = $LogDirectSound2D
        LogDirectSound2DStreaming = $LogDirectSound2DStreaming
        LogDirectSound3D = $LogDirectSound3D
        LogDirectSoundListener = $LogDirectSoundListener
        LogDirectSoundEAX = $LogDirectSoundEAX
        LogDirectSoundTimingInfo = $LogDirectSoundTimingInfo
        LogStarvation = $LogStarvation
    }
    return $d
}

#read Newalchemy ini file and convert game to hash table with add-game function, default value are defined here if not present in alchemy.ini.
function read-file { 
    param(
        [string]$file
    )
    
    $list = Get-content $file
    $liste = @()
    $count = 0
    $Number = 0
    $Buffers=4
    $Duration=25
    $DisableDirectMusic = "False"
    $MaxVoiceCount = 128
    $RootDirInstallOption = "False"
    $DisableNativeAL = "False"
    $Found = $false
    $Transmut = $false
    $LogDirectSound = "False"
    $LogDirectSound2D = "False"
    $LogDirectSound2DStreaming = "False"
    $LogDirectSound3D = "False"
    $LogDirectSoundListener = "False"
    $LogDirectSoundEAX = "False"
    $LogDirectSoundTimingInfo = "False"
    $LogStarvation = "False"

    foreach ( $line in $list ) {
        $Number = $Number + 1
        if ( $line -notlike ';*' ) {
            Switch -wildcard ($line) {
                '`[*' {
                        if ( $count -gt 0 ) {
                                $liste += Add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Found $Found -Transmut $Transmut -LogDirectSound $LogDirectSound -LogDirectSound2D $LogDirectSound2D -LogDirectSound2DStreaming $LogDirectSound2DStreaming -LogDirectSound3D $LogDirectSound3D -LogDirectSoundListener $LogDirectSoundListener -LogDirectSoundEAX $LogDirectSoundEAX -LogDirectSoundTimingInfo $LogDirectSoundTimingInfo -LogStarvation $LogStarvation
                                $RegPath = ""
                                $Gamepath = ""
                                $Buffers = 4
                                $Duration = 25
                                $DisableDirectMusic = "False"
                                $MaxVoiceCount = 128
                                $SubDir = ""
                                $RootDirInstallOption = "False"
                                $DisableNativeAL = "False"
                                $Found = $false
                                $Transmut = $false
                                $LogDirectSound = "False"
                                $LogDirectSound2D = "False"
                                $LogDirectSound2DStreaming = "False"
                                $LogDirectSound3D = "False"
                                $LogDirectSoundListener = "False"
                                $LogDirectSoundEAX = "False"
                                $LogDirectSoundTimingInfo = "False"
                                $LogStarvation = "False"
                        }
                        $count = $count+1
                        $Name = $line -replace '[][]' 
                    }
                "RegPath=*" { $RegPath = $line.replace("RegPath=","") }
                "GamePath=*" { $Gamepath = $line.replace("GamePath=","") }
                "Buffers=*" { $Buffers = $line.replace("Buffers=","") }
                "Duration=*" { $Duration = $line.replace("Duration=","") }
                "DisableDirectMusic=*" { $DisableDirectMusic = $line.replace("DisableDirectMusic=","") }
                "MaxVoiceCount=*" { $MaxVoiceCount = $line.replace("MaxVoiceCount=","") }
                "SubDir=*" { $SubDir = $line.replace("SubDir=","") }
                "RootDirInstallOption=*" { $RootDirInstallOption = $line.replace("RootDirInstallOption=","") }
                "DisableNativeAL=*" { $DisableNativeAL = $line.replace("DisableNativeAL=","") }
                "LogDirectSound=*" { $LogDirectSound = $line.replace("LogDirectSound=","") }
                "LogDirectSound2D=*" { $LogDirectSound2D = $line.replace("LogDirectSound2D=","") }
                "LogDirectSound2DStreaming=*" { $LogDirectSound2DStreaming = $line.replace("LogDirectSound2DStreaming=","") }
                "LogDirectSound3D=*" { $LogDirectSound3D = $line.replace("LogDirectSound3D=","") }
                "LogDirectSoundListener=*" { $LogDirectSoundListener = $line.replace("LogDirectSoundListener=","") }
                "LogDirectSoundEAX=*" { $LogDirectSoundEAX = $line.replace("LogDirectSoundEAX=","") }
                "LogDirectSoundTimingInfo=*" { $LogDirectSoundTimingInfo = $line.replace("LogDirectSoundTimingInfo=","") }
                "LogStarvation=*" { $LogStarvation = $line.replace("LogStarvation=","") }
            }
        }
    }
    if ( $Number -ne $count ) {
        $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Transmut $Transmut -LogDirectSound $LogDirectSound -LogDirectSound2D $LogDirectSound2D -LogDirectSound2DStreaming $LogDirectSound2DStreaming -LogDirectSound3D $LogDirectSound3D -LogDirectSoundListener $LogDirectSoundListener -LogDirectSoundEAX $LogDirectSoundEAX -LogDirectSoundTimingInfo $LogDirectSoundTimingInfo -LogStarvation $LogStarvation
    }
    return $liste
}

#Create New NewALchemy.ini file with new options, that will be used by the script
function GenerateNewAlchemy{ 
    param( [string]$file ) 
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
    foreach ( $line in $liste ) {
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
        "[$a]`r`nRegPath=$b`r`nGamePath=$c`r`nBuffers=$d`r`nDuration=$e`r`nDisableDirectMusic=$f`r`nMaxVoiceCount=$g`r`nSubDir=$h`r`nRootDirInstallOption=$i`r`nDisableNativeAL=$j`r`nLogDirectSound=$k`r`nLogDirectSound2D=$l`r`nLogDirectSound2DStreaming=$m`r`nLogDirectSound3D=$n`r`nLogDirectSoundListener=$o`r`nLogDirectSoundEAX=$p`r`nLogDirectSoundTimingInfo=$q`r`nLogStarvation=$r`r`n" | Out-File -Append $PSScriptRoot\NewAlchemy.ini -encoding ascii
    }
}

# Check if game is present (registry in priority then gamepath), test gamepath with/out subdir if present.
function checkpresent{ 
    param($game)
    $RegPath = $game.RegPath
    if ( ![string]::IsNullOrEmpty($RegPath) ) {
        # recover key and value
        $RegKey = $RegPath|split-path -leaf
        $KeyPath = $RegPath.replace("\$regkey","")
        Switch -wildcard ($RegPath) {
            "HKEY_LOCAL_MACHINE*" {
                $KeyPath = $KeyPath.replace("HKEY_LOCAL_MACHINE\","")
                $RegTest = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($KeyPath)
                if ( $Null -eq $RegTest ) {
                    $KeyPath = $Keypath.replace("SOFTWARE","SOFTWARE\WOW6432Node")
                    $RegTest = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($KeyPath)
                }
                if ( $Null -ne $RegTest ) {
                    $game.GamePath = $Regtest.GetValue($RegKey)
                }
            }
            "HKEY_CURRENT_USER*"{
                $KeyPath = $KeyPath.replace("HKEY_CURRENT_USER\","")
                $RegTest = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($KeyPath)
                if ( $Null -eq $RegTest ) {
                    $KeyPath = $Keypath.replace("SOFTWARE","SOFTWARE\WOW6432Node")
                    $RegTest = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($KeyPath)
                }
                if ( $Null -ne $RegTest ) {
                    $game.GamePath = $Regtest.GetValue($RegKey)
                }
            }
        }
    }
    if ( ![string]::IsNullOrEmpty($game.gamePath) ) {
        if ( [System.IO.Directory]::Exists($game.GamePath) ) {
            if ( ![string]::IsNullOrEmpty($game.SubDir) ) {
                if ( [System.IO.Directory]::Exists("$($game.GamePath)\$($game.SubDir)") ) {
                    $game.Found = $true
                } else { $game.Found = $false }
            } else { $game.Found = $true }
        } else { $game.Found = $false }
    } else { $game.Found = $false }
    return $game
}

# Check if the game list is installed with checkpresent function.
function checkinstall{ 
    param($liste)
    $count = 0
    foreach ( $game in $liste ) { 
        $liste[$count] = checkpresent $game
        $count = $count +1
    }
    return $liste
}

# Check if game is transmuted (dsound.dll present)
function checkTransmut{ 
    param($liste)
    $count = 0
    foreach ( $game in $liste ) {
        $gamepath = $game.Gamepath
        $Subdir = $game.SubDir
        $RootDirInstallOption = $game.RootDirInstallOption
        if ( [string]::IsNullOrEmpty($Subdir) ) {
            if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                $game.Transmut = CheckHash "$gamepath\dsound.dll"
            }
            else { $game.Transmut = $false }
        } elseif ( $RootDirInstallOption -eq $False ) {
            if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                $game.Transmut = CheckHash "$gamepath\$Subdir\dsound.dll"
            }
            else { $game.Transmut = $false}
        } else { 
                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                    if ( CheckHash "$gamepath\dsound.dll" ) {
                        if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                            $game.Transmut = CheckHash "$gamepath\$Subdir\dsound.dll"
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
                } else { $game.Transmut = $false }
          }
        $liste[$count] = $game
        $count = $count +1 
    }
    return $liste
}

function Sortlistview{
    param($listview)
    $items = $listview.items | Sort-Object
    $listview.Items.Clear()
    foreach ( $item in $items ) {
        $listview.Items.Add($item)
    }
    return $listview
}

function Transmut{
    param ($jeu)
    
    foreach( $game in $script:jeutrouve ) {
        if ( $jeu -eq $game.Name ) {
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
            $text = "Buffers=$Buffers`r`nDuration=$Duration`r`nMaxVoiceCount=$MaxVoiceCount`r`nDisableDirectMusic=$DisableDirectMusic`r`nDisableNativeAL=$DisableNativeAL`r`nLogDirectSound=$LogDirectSound`r`nLogDirectSound2D=$LogDirectSound2D`r`nLogDirectSound2DStreaming=$LogDirectSound2DStreaming`r`nLogDirectSound3D=$LogDirectSound3D`r`nLogDirectSoundListener=$LogDirectSoundListener`r`nLogDirectSoundEAX=$LogDirectSoundEAX`r`nLogDirectSoundTimingInfo=$LogDirectSoundTimingInfo`r`nLogStarvation=$LogStarvation`r`n"

            if ( [string]::IsNullOrEmpty($Subdir) ) {
                # no subdir
                if ( [System.IO.File]::Exists("$gamepath\dsound.ini") ) {
                    Remove-Item -Path $gamepath\dsound.ini -force
                }
                New-Item -Path $gamepath -Name "dsound.ini" -force
                $text | Out-File $gamepath\dsound.ini -encoding ascii
                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                    $destHash = (Get-FileHash -Path "$gamepath\dsound.dll" -Algorithm SHA256).Hash
                    if ( $script:dsoundHash -ne $destHash ) {
                        Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath
                    }
                } else { Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath }
            } elseif ( $RootDirInstallOption -eq "True" ) {
                # Subdir + root install
                if ( [System.IO.File]::Exists("$gamepath\dsound.ini") ) {
                    Remove-Item -Path "$gamepath\dsound.ini" -force
                }
                if ( [System.IO.File]::Exists("$gamepath\$SubDir\dsound.ini") ) {
                    Remove-Item -Path "$gamepath\$SubDir\dsound.ini" -force
                }
                New-Item -Path "$gamepath\$Subdir" -Name "dsound.ini" -force
                New-Item -Path "$gamepath\" -Name "dsound.ini" -force
                $text | Out-File $gamepath\dsound.ini -encoding ascii
                $text | Out-File $gamepath\$Subdir\dsound.ini -encoding ascii
                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                    $destHash = (Get-FileHash -Path "$gamepath\dsound.dll" -Algorithm SHA256).Hash
                    if ( $script:dsoundHash -ne $destHash ) {
                        Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath
                    }
                } else { Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath}
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                    $destHash = (Get-FileHash -Path "$gamepath\$Subdir\dsound.dll" -Algorithm SHA256).Hash
                    if ( $script:dsoundHash -ne $destHash ) {
                        Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir
                    }
                } else { Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir }
            } else {
                # Subdir only
                if ( [System.IO.File]::Exists("$gamepath\dsound.ini") ) {
                    Remove-Item -Path "$gamepath\dsound.ini" -force
                }
                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                    Remove-Item -Path "$gamepath\dsound.dll" -force
                }
                if ( [System.IO.File]::Exists("$gamepath\$SubDir\dsound.ini") ) {
                    Remove-Item -Path "$gamepath\$SubDir\dsound.ini" -force
                }
                New-Item -Path "$gamepath\$SubDir" -Name "dsound.ini" -force
                $text | Out-File $gamepath\$SubDir\dsound.ini -encoding ascii
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                    $destHash = (Get-FileHash -Path "$gamepath\$Subdir\dsound.dll" -Algorithm SHA256).Hash
                    if ( $script:dsoundHash -ne $destHash ) {
                        Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir
                    }
                } else { Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir }
            }
            $MenuGauche.Items.Remove($jeu)
            $MenuDroite.Items.Add($jeu)
            Sortlistview $MenuDroite
        }
    }
}

function UnTransmut{
    param ($Jeu)
    
    $Jeu = $Menudroite.SelectedItem
    foreach ( $game in $script:jeutrouve ) {
        if ( $Jeu -eq $game.Name ) {
            $gamepath = $game.Gamepath
            $SubDir = $game.SubDir
            $RootDirInstallOption = $game.RootDirInstallOption
            if ( [string]::IsNullOrEmpty($Subdir) ) {
                Remove-Item $gamepath\dsound.ini
                Remove-Item $gamepath\dsound.dll
            } elseif ( $RootDirInstallOption -eq "True" ) {
                Remove-Item "$gamepath\dsound.ini"
                Remove-Item "$gamepath\dsound.dll"
                Remove-Item "$gamepath\$Subdir\dsound.ini"
                Remove-Item "$gamepath\$Subdir\dsound.dll"
            } else {
                Remove-Item "$gamepath\$Subdir\dsound.ini"
                Remove-Item "$gamepath\$Subdir\dsound.dll"
            }
            $MenuDroite.Items.Remove($Jeu)
            $MenuGauche.Items.Add($Jeu)
            Sortlistview $MenuGauche
        }
    }
}

#Check if file in parameter is an alchemy dsound.dll or not.
function CheckHash{
    param($filepath)
    
    $destHash = (Get-FileHash -Path $filepath -Algorithm SHA256).Hash
    if ( $script:dsoundHash -ne $destHash ) { $Correcthash = $False } else { $Correcthash = $True }
    return $Correcthash
}    
    
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#load translation if exist, if not found will load en-US one.
Import-LocalizedData -BindingVariable txt

# Locate alchemy folder and test if newalchemy.ini is present or generate a new one
$PathALchemy = LocateAlchemy
if ( !(Test-Path -path "$PSScriptRoot\newalchemy.ini") ) { GenerateNewAlchemy "$PathALchemy\Alchemy.ini" }
$script:dsoundHash = (Get-FileHash -Path "$PathAlchemy\dsound.dll" -Algorithm SHA256).Hash
$script:listejeux = read-file "$PSScriptRoot\NewAlchemy.ini"
checkinstall $script:listejeux | Out-Null
$script:jeutrouve = $script:listejeux | where-object Found -eq $true
#$jeutrouve | Out-GridView
checktransmut $script:jeutrouve | Out-Null
$jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
$jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}

# Main windows
[xml]$inputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="New Alchemy" Height="417" Width="818" MinHeight="417" MinWidth="818" ResizeMode="CanResizeWithGrip" Icon="$PSScriptRoot\NewAlchemy.ico">
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
            <TextBlock Name="T_version" HorizontalAlignment="Right" TextWrapping="Wrap" Text="Version 1.09" VerticalAlignment="Top" Margin="0,359,20,0" FontSize="8"/>
        </Grid>
    </Viewbox>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $inputXML)
$Window = [Windows.Markup.XamlReader]::Load( $reader )
$inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

$Window.WindowStartupLocation = "CenterScreen"
$BoutonEdition.Content = $txt.BoutonEditionContent
$BoutonAjouter.Content = $txt.BoutonAjouterContent
$BoutonParDefaut.Content = $txt.BoutonDefaultContent
$Text_main.Text = $txt.Text_main
$Text_jeuInstall.Text = $txt.Text_jeuInstall
$Text_JeuTransmut.Text = $txt.Text_JeuTransmut
$BoutonEdition.IsEnabled = $False
$BoutonTransmut.IsEnabled = $False
$BoutonUnTransmut.IsEnabled = $False

# populate each listview, disable counter output in terminal
$MenuGauche.Items.Clear()
foreach ( $jeu in $jeunontransmut ) {
    $MenuGauche.Items.Add($jeu.name) | Out-Null
}
Sortlistview $MenuGauche | Out-Null

$MenuDroite.Items.Clear()
foreach ( $jeu in $jeutransmut ) {
    $MenuDroite.Items.Add($jeu.name) | Out-Null
}
Sortlistview $MenuDroite | Out-Null
 
$BoutonTransmut.add_Click({
    Transmut $MenuGauche.SelectedItem
    if ( $Null -eq $MenuGauche.SelectedItem) { $BoutonTransmut.IsEnabled = $False }
 })

$BoutonUnTransmut.add_Click({
    UnTransmut $MenuDroite.SelectedItem
    if ( $Null -eq $MenuDroite.SelectedItem) { $BoutonUnTransmut.IsEnabled = $False }
})

$MenuGauche.Add_MouseDoubleClick({
    if ( $Null -ne $MenuGauche.SelectedItem ) {
        Transmut $MenuGauche.SelectedItem
        $BoutonTransmut.IsEnabled = $False
    }
})

$MenuDroite.Add_MouseDoubleClick({
    if ( $Null -ne $MenuDroite.SelectedItem ) {
        UnTransmut $MenuDroite.SelectedItem
        $BoutonUnTransmut.IsEnabled = $False
    }
})

$MenuDroite.Add_SelectionChanged({
    if ( $MenuDroite.SelectedIndex -ne -1 ) { $MenuGauche.SelectedIndex = -1 }
    $BoutonEdition.IsEnabled = $True
    $BoutonTransmut.IsEnabled = $False
    $BoutonUnTransmut.IsEnabled = $True
    $script:lastSelectedListView = $MenuDroite
})

$MenuGauche.Add_SelectionChanged({
    if ( $MenuGauche.SelectedIndex -ne -1 ) { $MenuDroite.SelectedIndex = -1 }
    $BoutonEdition.IsEnabled = $True
    $BoutonTransmut.IsEnabled = $True
    $BoutonUnTransmut.IsEnabled = $False
    $script:lastSelectedListView = $MenuGauche
})

### EDIT BUTTON, Check each mandatory info, add then to global var and edit newalchemy file entry.
$BoutonEdition.add_Click({
    $gamename = $script:lastSelectedListView.SelectedItem
    if ( !($Null -eq $gamename) ) {
        [xml]$InputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Height="710" Width="558" MinHeight="710" MinWidth="558" VerticalAlignment="Bottom" ResizeMode="CanResizeWithGrip" Icon="$PSScriptRoot\NewAlchemy.ico">
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
        $reader = (New-Object System.Xml.XmlNodeReader $inputXML)
        $Window_edit = [Windows.Markup.XamlReader]::Load( $reader )
        $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_edit.FindName($_.Name)}

        $Window_edit.WindowStartupLocation = "CenterScreen"
        $T_Titrejeu.IsReadOnly = $true
        $T_Titrejeu.Background = '#e5e5e5'
        $Window_edit.Title = $txt.MainTitle2    
        $C_Gamepath.Content = $txt.C_GamepathContent
        $C_registre.Content = $txt.C_registreContent
        $T_registre.ToolTip = $txt.T_registreToolTip
        $T_Gamepath.ToolTip = $txt.T_GamepathToolTip
        $T_voice.ToolTip = $txt.T_voiceToolTip
        $C_SubDir.Content = $txt.C_SubDirContent
        $T_Subdir.ToolTip = $txt.T_SubdirToolTip
        $C_DisableDirectMusic.Content = $txt.C_DisableDirectMusicContent
        $C_DisableDirectMusic.ToolTip = $txt.C_DisableDirectMusicToolTip
        $C_Rootdir.Content = $txt.C_RootdirContent
        $L_GameTitle.Content = $txt.L_GameTitleContent
        $T_buffers.ToolTip = $txt.T_buffersToolTip
        $L_Buffers.Content = $txt.T_BuffersContent
        $L_Buffers.toolTip = $txt.T_BuffersToolTip
        $T_duration.toolTip = $txt.T_DurationToolTip
        $L_Duration.Content = $txt.T_DurationContent
        $L_Duration.ToolTip = $txt.T_DurationToolTip
        $L_Voice.Content = $txt.T_VoiceContent
        $L_Settings.Content = $txt.L_Settings
        $B_Cancel.Content = $txt.B_CancelContent
        $B_ok.Content = $txt.B_OkContent
        $L_Debug1.Content = $txt.L_Debug1Content
        $L_Debug2.Content = $txt.L_Debug2Content
        $C_LogDirectSound.Content = $txt.C_LogDirectSoundContent
        $C_LogDirectSound2D.Content = $txt.C_LogDirectSound2DContent
        $C_LogDirectSound2DStreaming.Content = $txt.C_LogDirectSound2DStreamingContent
        $C_LogDirectSound3D.Content = $txt.C_LogDirectSound3DContent
        $C_LogDirectSoundListener.Content = $txt.C_LogDirectSoundListenerContent
        $C_LogDirectSoundEAX.Content = $txt.C_LogDirectSoundEAXContent
        $C_LogDirectSoundTimingInfo.Content = $txt.C_LogDirectSoundTimingInfoContent
        $C_LogStarvation.Content = $txt.C_LogStarvationContent
        $C_LogDirectSound.ToolTip = $txt.C_logtextTooltip
        $C_LogDirectSound2D.ToolTip = $txt.C_logtextTooltip
        $C_LogDirectSound2DStreaming.ToolTip = $txt.C_logtextTooltip
        $C_LogDirectSound3D.ToolTip = $txt.C_logtextTooltip
        $C_LogDirectSoundListener.ToolTip = $txt.C_logtextTooltip
        $C_LogDirectSoundEAX.ToolTip = $txt.C_logtextTooltip
        $C_LogDirectSoundTimingInfo.ToolTip = $txt.C_logtextTooltip
        $C_LogStarvation.ToolTip = $txt.C_logtextTooltip
        $C_DisableNativeAl.Content = $txt.C_DisableNativeAlContent
        $C_DisableNativeAl.ToolTip = $txt.C_DisableNativeAlToolTip

        $C_Registre.Add_Checked({
            $T_Registre.IsReadOnly = $False
            $T_Registre.Background = '#ffffff'
            $B_GamePath.IsEnabled = $False
            $T_Gamepath.IsReadOnly = $true
            $T_Gamepath.Background = '#e5e5e5'
        })
        $C_Gamepath.Add_Checked({
            $T_Registre.IsReadOnly = $true
            $T_Registre.Background = '#e5e5e5'
            $T_Gamepath.IsReadOnly = $False
            $T_Gamepath.Background = '#ffffff'
            $B_GamePath.IsEnabled = $True
        })
        $C_SubDir.Add_Checked({
            $T_SubDir.IsReadOnly = $False
            $T_SubDir.Background = '#ffffff'
            $C_Rootdir.Background = '#ffffff'
            $C_Rootdir.IsEnabled = $true
            $B_SubDir.IsEnabled = $True
        })
        $C_SubDir.Add_UnChecked({
            $T_SubDir.IsReadOnly = $True
            $T_SubDir.Background = '#e5e5e5'
            $C_Rootdir.Background = '#e5e5e5'
            $C_Rootdir.IsChecked = $False
            $B_SubDir.IsEnabled = $False
            $C_Rootdir.IsEnabled = $False
        })

    ## RETREIVE EDIT FORM VALUES
        $count = 0
        $found = 0
        foreach ( $game in $script:jeutrouve ) {
            if ( $gamename -eq $game.Name ) {
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

                if ( [string]::IsNullOrEmpty($game.RegPath) ) {
                    $T_Gamepath.text = $game.Gamepath
                    $T_Registre.IsReadOnly = $true
                    $T_Registre.Background = '#e5e5e5'
                    $C_GamePath.IsChecked = $true
                } else {
                    $T_registre.text = $game.RegPath
                    $T_Gamepath.IsReadOnly = $true
                    $T_Gamepath.Background = '#e5e5e5'
                    $B_GamePath.IsEnabled = $False
                    $C_Registre.IsChecked = $True
                }
                if ( $DisableDirectMusic -eq "True" ) { $C_DisableDirectMusic.IsChecked = $True } else { $C_DisableDirectMusic.IsChecked = $False }
                if ( $DisableNativeAL -eq "True" ) { $C_DisableNativeAl.IsChecked = $True } else { $C_DisableNativeAl.IsChecked = $False }
                if ( [string]::IsNullOrEmpty($T_Subdir.text) ) {
                    $T_SubDir.IsReadOnly = $True
                    $T_SubDir.Background = '#e5e5e5'
                    $C_Rootdir.IsEnabled = $False
                    $C_Rootdir.Background = '#e5e5e5'
                    $B_SubDir.IsEnabled = $False
                    $C_SubDir.IsChecked = $False
                    $C_Rootdir.IsChecked = $False
                } else {
                    $C_SubDir.Ischecked = $true
                    $C_Rootdir.IsEnabled = $true
                    if ( $RootDirInstallOption -eq "True" ) { $C_Rootdir.IsChecked = $True } else { $C_Rootdir.IsChecked = $False }
                }
                if ( $LogDirectSound -eq "True" ) { $C_LogDirectSound.IsChecked = $True } else { $C_LogDirectSound.IsChecked = $False }
                if ( $LogDirectSound2D -eq "True" ) { $C_LogDirectSound2D.IsChecked = $True } else { $C_LogDirectSound2D.IsChecked = $False }
                if ( $LogDirectSound2DStreaming -eq "True" ) { $C_LogDirectSound2DStreaming.IsChecked = $True } else { $C_LogDirectSound2DStreaming.IsChecked = $False }
                if ( $LogDirectSound3D -eq "True" ) { $C_LogDirectSound3D.IsChecked = $True } else { $C_LogDirectSound3D.IsChecked = $False }
                if ( $LogDirectSoundListener -eq "True" ) { $C_LogDirectSoundListener.IsChecked = $True } else { $C_LogDirectSoundListener.IsChecked = $False }
                if ( $LogDirectSoundEAX -eq "True" ) { $C_LogDirectSoundEAX.IsChecked = $True } else { $C_LogDirectSoundEAX.IsChecked = $False }
                if ( $LogDirectSoundTimingInfo -eq "True" ) { $C_LogDirectSoundTimingInfo.IsChecked = $True } else { $C_LogDirectSoundTimingInfo.IsChecked = $False }
                if ( $LogStarvation -eq "True" ) { $C_LogStarvation.IsChecked = $True }else { $C_LogStarvation.IsChecked = $False }
            } else { if ( $found -ne 1 ) { $count = $count +1 } }
        }

    ## CLICK ON ICON GAMEPATH (EDIT FORM)
        $B_GamePath.add_Click({
            $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
            $foldername.Description = $txt.FolderChoice
            $foldername.rootfolder = "MyComputer"
            if ( $C_Gamepath.IsChecked ) { $foldername.SelectedPath = $T_Gamepath.text }
            if( $foldername.ShowDialog() -eq "OK" ) { $T_Gamepath.text = $foldername.SelectedPath }
        })

    ## CLICK ON SUBDIR BUTTON (EDIT FORM)
        $B_SubDir.add_Click({
            $fail = $False
            if ( $C_registre.IsChecked ) {
                    $registre = $T_Registre.Text
                    if ( ![string]::IsNullOrEmpty($registre) ) {
                        if ( $registre -like "HKEY_LOCAL_MACHINE*" ) {
                            $registre = $registre.replace("HKEY_LOCAL_MACHINE","HKLM:")
                        } else {
                            if ( $registre -like "HKEY_CURRENT_USER*" ) {
                            $registre = $registre.replace("HKEY_CURRENT_USER","HKCU:")
                            } else {
                                $fail = $True
                                [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                            }
                        }
                    } else { 
                            $fail = $True
                            [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                    }
                    if ( $fail -eq $False ) {
                        #retreive registry key
                        $regkey = $registre|split-path -leaf
                        #remove registry key from registry link"
                        $registre = $registre.replace("\$regkey","")
                        if ( !(test-path $registre) ) {
                            $registre = $registre.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                            $registre = $registre.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                        }
                        if (test-path $registre) {
                            try { $Gamepath = Get-ItemPropertyvalue -Path $registre -name $regkey }
                            catch {
                                [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                                $fail = $true
                            }
                            if ( $fail -eq $False ) {
                                if ( !(test-path $Gamepath) ) {
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
                    if ( [string]::IsNullOrEmpty($Gamepath) ) {
                        $fail = $True
                        [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ( $fail -eq $False ) {
                if ( !(test-path $Gamepath) ) {
                    [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    $fail = $true
                }
                if ( $fail -eq $False ) {
                    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                    $foldername.Description = $txt.SubFolderChoice
                    $foldername.SelectedPath = $Gamepath
                    if ( $foldername.ShowDialog() -eq "OK" ) {
                        $Subdir = $foldername.SelectedPath
                        $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                        $Subdir = $Subdir.Trimstart("\")
                        if ( test-path $Gamepath\$Subdir ) {
                            $T_Subdir.text = $Subdir
                        } else { [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48) }
                    }
                }
            }
        })
        # Cancel Button (EDIT FORM)
        $B_Cancel.add_Click({
            $MenuGauche.SelectedIndex = -1
            $MenuDroite.SelectedIndex = -1
            $BoutonEdition.IsEnabled = $False
            $BoutonTransmut.IsEnabled = $False
            $BoutonUnTransmut.IsEnabled = $False
            $Window_edit.Close()
        })

    
    ### OK BUTTON (EDIT FORM), Check if everything is ok, then EDIT GAME FILE and Hash table
        $B_Ok.add_Click({
            $fail = $false
            $regprio = $false
            if ( $C_registre.IsChecked ) {
                $registre = $T_Registre.Text
                if ( ![string]::IsNullOrEmpty($registre) ) {
                    if ( $registre -like "HKEY_LOCAL_MACHINE*" ) {
                        $registre = $registre.replace("HKEY_LOCAL_MACHINE","HKLM:")
                    } else {
                        if ( $registre -like "HKEY_CURRENT_USER*" ) {
                            $registre = $registre.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    }        
                    #Recover Reg Key
                    $regkey = $registre|split-path -leaf
                    #"supprimer clef du lien registre"
                    $registre = $registre.replace("\$regkey","")
                    if ( !(test-path $registre) ) {
                    $registre = $registre.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $registre = $registre.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                    }
                    if ( test-path $registre ) {
                        try { $Gamepath = Get-ItemPropertyvalue -Path $registre -name $regkey
                        }
                        catch {
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                        }
                        if ( $fail -eq $False ) {
                            if ( !(test-path $Gamepath) ) {
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
                if ( [string]::IsNullOrEmpty($Gamepath) ) { 
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ( $fail -eq $False ) {
                $Gamepath = $Gamepath.TrimEnd("\")
                if ( ![string]::IsNullOrEmpty($Gamepath) ) {
                    if ( !(test-path $Gamepath) ) {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    } 
                }
            }
            if ( $C_SubDir.IsChecked -and $fail -eq $false ) {
                $Subdir = $T_Subdir.text
                if ( !(test-path $Gamepath\$Subdir) ) {
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
                } 
            }
            if ( !($T_buffers.text -In 2..10) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.BuffersErr,"",0,48)
            }
            if ( !($T_Duration.Text -In 2..50) ) {
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.DurationErr,"",0,48)
            }
            if ( !($T_voice.text -In 32..128) ) {
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.VoiceErr,"",0,48)
            }
            # Test if no error
            if ( $fail -eq $False ) {
                # Prepare Game value to write
                $Name = $T_titrejeu.text
                $Buffers = $T_buffers.text
                $Voice = $T_voice.text
                $Duration = $T_Duration.text
                if ( $C_DisableDirectMusic.IsChecked ) { $DisableDirectMusic = "True" } else { $DisableDirectMusic = "False" }
                if ( $C_Rootdir.IsChecked ) { $RootDirInstallOption = "True" } else { $RootDirInstallOption = "False" }
                if ( $C_DisableNativeAl.IsChecked ) { $DisableNativeAL = "True" } else {  $DisableNativeAL = "False" }
                if ( $C_SubDir.IsUnChecked ) {
                    $SubDir = ""
                    $RootDirInstallOption = "False"
                }
                if ( $C_LogDirectSound.IsChecked) { $LogDirectSound = "True" } else { $LogDirectSound ="False" }
                if ( $C_LogDirectSound2D.IsChecked) { $LogDirectSound2D = "True" } else { $LogDirectSound2D ="False" }
                if ( $C_LogDirectSound2DStreaming.IsChecked ) { $LogDirectSound2DStreaming = "True" } else { $LogDirectSound2DStreaming = "False" }
                if ( $C_LogDirectSound3D.IsChecked ) { $LogDirectSound3D = "True" } else { $LogDirectSound3D = "False" }
                if ( $C_LogDirectSoundListener.IsChecked ) { $LogDirectSoundListener = "True" } else { $LogDirectSoundListener = "False" }
                if ( $C_LogDirectSoundEAX.IsChecked ) { $LogDirectSoundEAX = "True" } else { $LogDirectSoundEAX = "False" }
                if ( $C_LogDirectSoundTimingInfo.IsChecked ) { $LogDirectSoundTimingInfo = "True" } else { $LogDirectSoundTimingInfo = "False" }
                if ( $C_LogStarvation.IsChecked ) { $LogStarvation = "True" } else { $LogStarvation = "False" }
                
                # Update list game to reflect change    
                $script:jeutrouve[$count].RegPath = $RegPath
                $script:jeutrouve[$count].Gamepath = $Gamepath
                $script:jeutrouve[$count].Buffers = $Buffers
                $script:jeutrouve[$count].Duration = $Duration
                $script:jeutrouve[$count].DisableDirectMusic = $DisableDirectMusic
                $script:jeutrouve[$count].MaxVoiceCount = $Voice
                $script:jeutrouve[$count].SubDir = $Subdir
                $script:jeutrouve[$count].RootDirInstallOption = $RootDirInstallOption
                $script:jeutrouve[$count].DisableNativeAL = $DisableNativeAL
                $script:jeutrouve[$count].LogDirectSound = $LogDirectSound
                $script:jeutrouve[$count].LogDirectSound2D = $LogDirectSound2D
                $script:jeutrouve[$count].LogDirectSound2DStreaming = $LogDirectSound2DStreaming
                $script:jeutrouve[$count].LogDirectSound3D = $LogDirectSound3D
                $script:jeutrouve[$count].LogDirectSoundListener = $LogDirectSoundListener
                $script:jeutrouve[$count].LogDirectSoundEAX = $LogDirectSoundEAX
                $script:jeutrouve[$count].LogDirectSoundTimingInfo = $LogDirectSoundTimingInfo
                $script:jeutrouve[$count].LogStarvation = $LogStarvation
                
                # Write change in file
                $file = Get-content "$PSScriptRoot\Newalchemy.ini"
                $LineNumber = Select-String -pattern ([regex]::Escape("[$Name]")) $PSScriptRoot\NewAlchemy.ini| Select-Object -ExpandProperty LineNumber
                if ( $regprio -eq $true ) {
                    $file[$LineNumber] = "RegPath=$RegPath"
                    $file[$LineNumber +1] ="GamePath="
                }else{
                    $file[$LineNumber] = "RegPath="
                    $file[$LineNumber +1] ="GamePath=$Gamepath" 
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
                # Update file/conf if game is already transmuted (Re-transmut)
                if ( $script:lastSelectedListView -eq $MenuDroite ) {
                    $MenuDroite.Items.Remove($gamename)
                    Transmut $gamename
                }
                $Window_edit.Close()
            }
        })
        $closingHandler = {
            $MenuGauche.SelectedIndex = -1
            $MenuDroite.SelectedIndex = -1
            $BoutonEdition.IsEnabled = $False
            $BoutonTransmut.IsEnabled = $False
            $BoutonUnTransmut.IsEnabled = $False
        }
        $Window_edit.Add_Closing($closingHandler)
        $Window_edit.ShowDialog() | out-null
    }
})

### ADD BUTTON (MAIN FORM)
$BoutonAjouter.add_Click({
    [xml]$InputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Height="710" Width="558" MinHeight="710" MinWidth="558" VerticalAlignment="Bottom" ResizeMode="CanResizeWithGrip" Icon="$PSScriptRoot\NewAlchemy.ico">
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
    $reader = (New-Object System.Xml.XmlNodeReader $inputXML)
    $Window_add = [Windows.Markup.XamlReader]::Load( $reader )
    $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_add.FindName($_.Name)}
    
    $Window_add.WindowStartupLocation = "CenterScreen"
    # WPF Content, tooltip values
    $Window_add.Title = $txt.MainTitle2    
    $C_Gamepath.Content = $txt.C_GamepathContent
    $C_registre.Content = $txt.C_registreContent
    $T_registre.ToolTip = $txt.T_registreToolTip
    $T_Gamepath.ToolTip = $txt.T_GamepathToolTip
    $T_voice.ToolTip = $txt.T_voiceToolTip
    $C_SubDir.Content = $txt.C_SubDirContent
    $T_Subdir.ToolTip = $txt.T_SubdirToolTip
    $C_DisableDirectMusic.Content = $txt.C_DisableDirectMusicContent
    $C_DisableDirectMusic.ToolTip = $txt.C_DisableDirectMusicToolTip
    $C_Rootdir.Content = $txt.C_RootdirContent
    $L_GameTitle.Content = $txt.L_GameTitleContent
    $T_buffers.ToolTip = $txt.T_buffersToolTip
    $L_Buffers.Content = $txt.T_BuffersContent
    $L_Buffers.toolTip = $txt.T_BuffersToolTip
    $T_duration.toolTip = $txt.T_DurationToolTip
    $L_Duration.Content = $txt.T_DurationContent
    $L_Duration.ToolTip = $txt.T_DurationToolTip
    $L_Voice.Content = $txt.T_VoiceContent
    $L_Settings.Content = $txt.L_Settings
    $B_Cancel.Content = $txt.B_CancelContent
    $B_ok.Content = $txt.B_OkContent
    $L_Debug1.Content = $txt.L_Debug1Content
    $L_Debug2.Content = $txt.L_Debug2Content
    $C_LogDirectSound.Content = $txt.C_LogDirectSoundContent
    $C_LogDirectSound2D.Content = $txt.C_LogDirectSound2DContent
    $C_LogDirectSound2DStreaming.Content = $txt.C_LogDirectSound2DStreamingContent
    $C_LogDirectSound3D.Content = $txt.C_LogDirectSound3DContent
    $C_LogDirectSoundListener.Content = $txt.C_LogDirectSoundListenerContent
    $C_LogDirectSoundEAX.Content = $txt.C_LogDirectSoundEAXContent
    $C_LogDirectSoundTimingInfo.Content = $txt.C_LogDirectSoundTimingInfoContent
    $C_LogStarvation.Content = $txt.C_LogStarvationContent
    $C_LogDirectSound.ToolTip = $txt.C_logtextTooltip
    $C_LogDirectSound2D.ToolTip = $txt.C_logtextTooltip
    $C_LogDirectSound2DStreaming.ToolTip = $txt.C_logtextTooltip
    $C_LogDirectSound3D.ToolTip = $txt.C_logtextTooltip
    $C_LogDirectSoundListener.ToolTip = $txt.C_logtextTooltip
    $C_LogDirectSoundEAX.ToolTip = $txt.C_logtextTooltip
    $C_LogDirectSoundTimingInfo.ToolTip = $txt.C_logtextTooltip
    $C_LogStarvation.ToolTip = $txt.C_logtextTooltip
    $C_DisableNativeAl.Content = $txt.C_DisableNativeAlContent
    $C_DisableNativeAl.ToolTip = $txt.C_DisableNativeAlToolTip

    # Default value
    $T_buffers.text = 4
    $T_Duration.text = 25
    $T_voice.text = 128
    $C_DisableDirectMusic.IsChecked = $False
    $T_Gamepath.MaxLines = 1
    $T_registre.MaxLines = 1
    $C_registre.IsChecked = $true
    $C_SubDir.IsChecked = $False
    $T_SubDir.IsReadOnly = $True
    $T_SubDir.Background = '#e5e5e5'
    $C_Rootdir.IsChecked = $false
    $C_Rootdir.IsEnabled = $False
    $C_Rootdir.Background = '#e5e5e5'
    $B_SubDir.IsEnabled = $False
    $T_Registre.IsReadOnly = $False
    $T_Registre.Background = '#ffffff'
    $B_GamePath.IsEnabled = $False
    $T_Gamepath.IsReadOnly = $true
    $T_Gamepath.Background = '#e5e5e5'
    $C_DisableNativeAl.IsChecked = $False
    $C_LogDirectSound.IsChecked = $False
    $C_LogDirectSound2D.IsChecked = $False
    $C_LogDirectSound2DStreaming.IsChecked = $False
    $C_LogDirectSound3D.IsChecked = $False
    $C_LogDirectSoundListener.IsChecked = $False
    $C_LogDirectSoundEAX.IsChecked = $False
    $C_LogDirectSoundTimingInfo.IsChecked = $False
    $C_LogStarvation.IsChecked = $False
 
    $C_Registre.Add_Checked({
        $T_Registre.IsReadOnly = $False
        $T_Registre.Background = '#ffffff'
        $B_GamePath.IsEnabled = $False
        $T_Gamepath.IsReadOnly = $true
        $T_Gamepath.Background = '#e5e5e5'
    })

    $C_Gamepath.Add_Checked({
        $T_Registre.IsReadOnly = $true
        $T_Registre.Background = '#e5e5e5'
        $T_Gamepath.IsReadOnly = $False
        $T_Gamepath.Background = '#ffffff'
        $B_GamePath.IsEnabled = $True
    })

    $C_SubDir.Add_Checked({
        $T_SubDir.IsReadOnly = $False
        $T_SubDir.Background = '#ffffff'
        $C_Rootdir.IsEnabled = $True
        $C_Rootdir.Background = '#ffffff'
        $B_SubDir.IsEnabled = $True
        $C_Rootdir.IsEnabled = $true
    })

    $C_SubDir.Add_UnChecked({
        $T_SubDir.IsReadOnly = $True
        $T_SubDir.Background = '#e5e5e5'
        $C_Rootdir.IsEnabled = $False
        $C_Rootdir.Background = '#e5e5e5'
        $B_SubDir.IsEnabled = $False
        $C_Rootdir.IsEnabled = $False
        $C_Rootdir.IsChecked = $False
    })

## CLICK ON GAMEPATH BUTTON (ADD FORM)
    $B_GamePath.add_Click({
        $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
        $foldername.Description = $txt.FolderChoice
        $foldername.rootfolder = "MyComputer"
        #$initialDirectory
        if ( $C_Gamepath.IsChecked ) { $foldername.SelectedPath = $T_Gamepath.text }
        if ( $foldername.ShowDialog() -eq "OK" ) { $T_Gamepath.text = $foldername.SelectedPath }
    })

## CLICK ON SUBDIR BUTTON (ADD FORM), chek registry path first or gamepath is not present, then test subdir+gamepath path
    $B_SubDir.add_Click({
        $fail = $false
        if ( $C_registre.IsChecked ) {
            $registre = $T_Registre.Text
            if ( ![string]::IsNullOrEmpty($registre) ) {
                if ( $registre -like "HKEY_LOCAL_MACHINE*" ) {
                    $registre = $registre.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if ( $registre -like "HKEY_CURRENT_USER*" ) {
                            $registre = $registre.replace("HKEY_CURRENT_USER","HKCU:")
                        } else {
                            $fail = $True
                            [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                        }    
                    }
            } else {
                $fail = $True
                [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
            }
            if ( $fail -eq $False ) {
                #retreive registry key
                $regkey = $registre|split-path -leaf
                #remove registry key from registry path
                $registre = $registre.replace("\$regkey","")
                if ( !(test-path $registre) ) {
                    $registre = $registre.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $registre = $registre.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if ( test-path $registre ) {
                    try { $Gamepath = Get-ItemPropertyvalue -Path $registre -name $regkey }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ( $fail -eq $False ) {
                        if ( !(test-path $Gamepath) ) {
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
            if ( [string]::IsNullOrEmpty($Gamepath) ) { 
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
        }
        if ( $fail -eq $False ) {
            if ( !(test-path $Gamepath) ) {
                [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
            } else {        
                $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                $foldername.Description = $txt.SubFolderChoice
                $foldername.SelectedPath = $Gamepath
                if ( $foldername.ShowDialog() -eq "OK" ) {
                    $Subdir = $foldername.SelectedPath
                    $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                    $Subdir = $Subdir.Trimstart("\")
                    if ( test-path $Gamepath\$Subdir ) {
                        $T_Subdir.text = $Subdir
                    } else { [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48) }
                }
            }
        }
    })
    $B_Cancel.add_Click({
        $MenuGauche.SelectedIndex = -1
        $MenuDroite.SelectedIndex = -1
        $BoutonEdition.IsEnabled = $False
        $BoutonTransmut.IsEnabled = $False
        $BoutonUnTransmut.IsEnabled = $False
        $Window_add.Close()
    })
   
### OK BUTTON (ADD FORM), test if every value are correct, then add game to ini file and inside hashtable
    $B_Ok.add_Click({
        $fail = $false
        $regprio = $false
        $registre = $T_Registre.Text
        $gamename = $T_titrejeu.Text

        foreach ( $game in $script:listejeux ) {
            if ( $gamename -eq $game.name ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.TitleExist,"",0,64)
            }
        }
        if ( [string]::IsNullOrEmpty($gamename) ) {
            $fail = $true
            [System.Windows.MessageBox]::Show($txt.TitleMiss,"",0,64)
        }
        if ( $C_registre.IsChecked ) {
            if ( ![string]::IsNullOrEmpty($registre) ) {
                if ( $registre -like "HKEY_LOCAL_MACHINE*" ) {
                    $registre = $registre.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if ( $registre -like "HKEY_CURRENT_USER*" ) {
                            $registre = $registre.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    } 
                $regkey = $registre|split-path -leaf
                $registre = $registre.replace("\$regkey","")
                if ( !(test-path $registre) ) {
                    $registre = $registre.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $registre = $registre.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if ( test-path $registre ) {
                    try { $Gamepath = Get-ItemPropertyvalue -Path $registre -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ( $fail -eq $false ) {
                        if ( !(test-path $Gamepath) ) {
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
        if ( $fail -eq $False ) {
            if ( [string]::IsNullOrEmpty($Gamepath) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
            else {
                if ( !(test-path $Gamepath) ) {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                }
            }
        }
        if ( $B_SubDir.IsEnabled -and $fail -eq $false ) {
            $Subdir = $T_Subdir.text
            if ( !(test-path $Gamepath\$Subdir) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
            } 
        }
        if ( !($T_buffers.text -In 2..10) ) {
            $fail = $true
            [System.Windows.MessageBox]::Show($txt.BuffersErr,"",0,48)
        }
        if ( !($T_Duration.Text -In 2..50) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.DurationErr,"",0,48)
        }
        if ( !($T_voice.text -In 32..128) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.VoiceErr,"",0,48)
        }
        # test if no error
        if ( $fail -eq $False ) {
            # Value to write
            $Name = $T_titrejeu.text
            $Buffers = $T_buffers.text
            $Voice = $T_voice.text
            $Duration = $T_Duration.text
            if ( $C_DisableDirectMusic.IsChecked ) { $DisableDirectMusic = 1 } else { $DisableDirectMusic = 0 }
            if ( $C_Rootdir.IsChecked ) { $RootDirInstallOption = "True" } else { $RootDirInstallOption = "False" }
            if ( $C_DisableNativeAl.IsChecked ) { $DisableNativeAL = "True" } else { $DisableNativeAL = "False" }
            if ( $C_SubDir.IsUnchecked ) {
                $SubDir = ""
                $RootDirInstallOption = "False"
            }
            if ( $C_LogDirectSound.IsChecked ) { $LogDirectSound = "True" } else { $LogDirectSound = "False" }
            if ( $C_LogDirectSound2D.IsChecked ) { $LogDirectSound2D = "True" } else { $LogDirectSound2D = "False" }
            if ( $C_LogDirectSound2DStreaming.IsChecked ) { $LogDirectSound2DStreaming = "True" } else { $LogDirectSound2DStreaming = "False" }
            if ( $C_LogDirectSound3D.IsChecked ) { $LogDirectSound3D = "True" } else { $LogDirectSound3D = "False" }
            if ( $C_LogDirectSoundListener.IsChecked ) { $LogDirectSoundListener = "True" } else { $LogDirectSoundListener = "False" }
            if ( $C_LogDirectSoundEAX.IsChecked ) { $LogDirectSoundEAX = "True" } else { $LogDirectSoundEAX = "False" }
            if ( $C_LogDirectSoundTimingInfo.IsChecked ) { $LogDirectSoundTimingInfo = "True" } else { $LogDirectSoundTimingInfo = "False" }
            if ( $C_LogStarvation.IsChecked ) { $LogStarvation = "True" } else { $LogStarvation = "False" }
            # Write change in file, Registry first, Gamepath second choice
            if ( $regprio -eq $true ) {
                $RegPath = $T_Registre.Text
                $Gamepath = ""
            }else{
                $RegPath = ""
                $Gamepath = $T_Gamepath.text
            }
            "[$Name]`r`nRegPath=$RegPath`r`nGamePath=$Gamepath`r`nBuffers=$Buffers`r`nDuration=$Duration`r`nDisableDirectMusic=$DisableDirectMusic`r`nMaxVoiceCount=$Voice`r`nSubDir=$SubDir`r`nRootDirInstallOption=$RootDirInstallOption`r`nDisableNativeAL=$DisableNativeAL`r`nLogDirectSound=$LogDirectSound`r`nLogDirectSound2D=$LogDirectSound2D`r`nLogDirectSound2DStreaming=$LogDirectSound2DStreaming`r`nLogDirectSound3D=$LogDirectSound3D`r`nLogDirectSoundListener=$LogDirectSoundListener`r`nLogDirectSoundEAX=$LogDirectSoundEAX`r`nLogDirectSoundTimingInfo=$LogDirectSoundTimingInfo`r`nLogStarvation=$LogStarvation`r`n"| Out-File -Append $PSScriptRoot\NewAlchemy.ini -encoding ascii

            # Update list game to reflect change, Order listview by name
            $script:listejeux += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $buffers -Duration $duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $Voice -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Found $True -Transmut $False -LogDirectSound $LogDirectSound -LogDirectSound2D $LogDirectSound2D -LogDirectSound2DStreaming $LogDirectSound2DStreaming -LogDirectSound3D $LogDirectSound3D -LogDirectSoundListener $LogDirectSoundListener -LogDirectSoundEAX $LogDirectSoundEAX -LogDirectSoundTimingInfo $LogDirectSoundTimingInfo -LogStarvation $LogStarvation
            $script:jeutrouve = $script:listejeux | where-object Found -eq $True
            checktransmut $script:jeutrouve | Out-Null
            $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
            $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
            $MenuGauche.Items.Clear()
            foreach ( $jeu in $jeunontransmut ) {
                $MenuGauche.Items.Add($jeu.name) | Out-Null
            }
            $MenuDroite.Items.Clear()
            foreach ( $jeu in $jeutransmut ) {
                $MenuDroite.Items.Add($jeu.name) | Out-Null
            }
            Sortlistview $MenuGauche
            Sortlistview $MenuDroite
            $Window_add.Close()
        }
    })
    $closingHandler = {
        $MenuGauche.SelectedIndex = -1
        $MenuDroite.SelectedIndex = -1
        $BoutonEdition.IsEnabled = $False
        $BoutonTransmut.IsEnabled = $False
        $BoutonUnTransmut.IsEnabled = $False
    }
    $Window_add.Add_Closing($closingHandler)
    $Window_add.ShowDialog() | out-null
})

### Default Button (MAIN FORM)
$BoutonParDefaut.add_Click({
    $choice = [System.Windows.MessageBox]::Show("$($txt.Defaultmsgbox)`r`n$($txt.Defaultmsgbox2)`r`n$($PSScriptRoot)\NewAlchemy.bak`r`n`r`n$($txt.Defaultmsgbox3)" , "NewAlchemy" , 4,64)
    if ( $choice -eq 'Yes' ) {
        move-Item "$PSScriptRoot\NewAlchemy.ini" "$PSScriptRoot\NewAlchemy.Bak" -force
        GenerateNewAlchemy "$PathAlchemy\Alchemy.ini"
        $script:listejeux = read-file "$PSScriptRoot\NewAlchemy.ini"
        checkinstall $script:listejeux | Out-Null
        $script:jeutrouve = $script:listejeux | where-object Found -eq $true
        checktransmut $script:jeutrouve | Out-Null
        $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
        $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
        $MenuGauche.Items.Clear()
        foreach ( $jeu in $jeunontransmut ) {
            $MenuGauche.Items.Add($jeu.name) | Out-Null
        }
        Sortlistview $MenuGauche
        $MenuDroite.Items.Clear()
        foreach ( $jeu in $jeutransmut ) {
            $MenuDroite.Items.Add($jeu.name) | Out-Null
        }
        Sortlistview $MenuDroite
    }
})

$Window.ShowDialog() | out-null
