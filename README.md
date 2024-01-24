# NewAlchemy
Recreate in powershell the creative alchemy application with more settings and options.
French and English version avalaible.

   What is different from creative alchemy ?
   
       *  Registry path are checked in both X86 and X86-64 path.
       *  Add support for DisableNativeAL Option to Disable ALchemy to ouput to OpenAl drivers (CT_oal.dll only) and rely on Creative Software 3D Library.
                   This permit X-fi / Audigy Card to use Creative Software 3D Library instead of native Open Al drivers in case of problem with specific game.
                   Post X-fi card (Recon/AE/X) can rename their sens_oal.dll drivers to Ct_oal.dll to make use of it, 
                   from my experience I do not recommend to rely on native openAl drivers (sens_oal.dll rename as Ct_oal.dll) for Post X-fi card as some game
                   do not work fine with this trick like Call of Duty 1 (Missing eax effect).
       *  Add support of Debug log option in the GUI.
                   Post X-fi card will need to rename sens_oal.dll to Ct_oal.dll to make use of it, as log required native openAl drivers.
            
    
## Install
Copy the script and your language (culture) folder in your Creative alchemy folder (ex: C:\Program Files (x86)\Creative\ALchemy). 
   
The script will use for text translation in priority the culture folder of your language, or will load the en-us one if it's not present (ex: de-DE).   
if you do not copy at least the en-US culture folder, you will have no text.   

## launch application
Launch the script and hide console
.\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\Program Files (x86)\Creative\ALchemy\NewAlchemy.ps1"

The scripts will create and use a new NewAlchemy.ini in the alchemy folder to store games and options.

You can also use the EXE version that has been compiled with PS2EXE.

When launched, NewALchemy application will search the system for supported DirectSound3D enabled games. All the games found will be listed in the left pane (titled "Installed Games"). The right pane (titled "NewALchemy-enabled Games”) will show any games which have already been converted to use ALchemy. To enable ALchemy support for a particular game, select it from the left panel, and press the “>>” button. To undo ALchemy support, select the game from the right panel and press the “<<” button. You can select multiple games at once and then use the directional arrow buttons to update them all.

<img src="https://i.imgur.com/MIhlNTC.png">
<img src="https://i.imgur.com/kvZsC3t.png">
<img src="https://i.imgur.com/HeqoCVO.png">
<img src="https://i.imgur.com/5VL3oKI.png">

## Options

*When launched, the Creative ALchemy application will search the system for supported
DirectSound3D enabled games. All the games found will be listed in the left pane (titled
"Installed Games"). The right pane (titled "ALchemy-enabled Games”) will show any
games which have already been converted to use ALchemy.
To enable ALchemy support for a particular game, select it from the left panel, and press
the “>>” button. To undo ALchemy support, select the game from the right panel and
press the “<<” button. You can select multiple games at once and then use the directional
arrow buttons to update them all. 

* Buffers' is used to set the number of audio buffers used internally. The default value of 4
should be fine for most applications.

* Duration' is used to set the length in milliseconds of each of the audio buffers. The
default value is 25ms.
The total duration of the audio queue used internally is equal to Buffers * Duration (i.e.
100ms by default). Experimenting with Duration values may be necessary in order to
find the best performance vs. quality trade-off for each game. In addition, some games
require smaller values than the default of 25ms because they use very small DirectSound
Buffers for streaming, or they require faster playback position updates. Reducing the
‘Duration’ value can prevent audio glitches, pops and clicks. However, lower values
mean that there is more chance of the audio breaking up during CPU intensive moments
(e.g. lots of disc access during level loading). The recommended approach is to try the
default settings, and if audio artifacts are regularly heard then try lowering Duration by
5ms and trying again. If the problem still occurs try dropping the value by another 5ms
and so on (minimum allowed value is 5ms).

* Maximum Voice Count' is used to set the maximum number of hardware voices that
will be used by ALchemy. The number of voices used will be the lesser of, the hardware
voice count limit and this setting. The default is 128 which is the highest number of
voices available on SB X-Fi cards. By lowering this value, hardware voices can be
reserved for another application to use, or, to improve performance by streaming less
audio channels.

* Disable Direct Music' is used to disable DirectMusic support. The default is false
(unchecked), meaning DirectMusic support is enabled. At this time no known problems
have been caused by combining ALchemy with games, such as TRON 2.0, that use
DirectMusic. 

* Disable native AL' is used to force Alchemy wrapper to ignore the OpenAl drivers (Ct_Oal.dll only)
and force the wrapper to use his own libray (Creative Software 3D Library).
This setting is by Default set to False for all X-FI / Audigy Card.
Post X-fi card do not have the CT_oal.dll drivers, so by default this setting make no difference.

All log option required the CT_oal.dll drivers to work, Log do not work with the Creative Software 3D Library.
Post X-fi card can rename their Sens_oal.dll drivers to Ct_oal.dll to have logs.
Enabling logs can have impact on sound performance.

* LogDirectSound : log DirectSound (default is False) into dsound.txt
* LogDirectSound2D : log DirectSound 2D into dsound.txt (default is False).
* LogDirectSound2DStreaming : log DirectSound 2D streaming into dsound.txt (default is False).
* LogDirectSound3D : log DirectSound 3D into dsound.txt (default is False).
* LogDirectSoundListener : Log DirectSound Listener into dsound.txt(default is False).
* LogDirectSoundEAX : log EAX into dsound.txt (default is False).
* LogDirectSoundTimingInfo : Log DirectSound timing into dsound.txt(default is False).
* LogStarvation : Log starvation into dsound.txt (default is False).


