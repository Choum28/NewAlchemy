# NewAlchemy
Recreate in powershell the creative alchemy application with more settings and options.

   What is different from creative alchemy ?
   
       *  Registry path are checked in both X86 and X86-64 path.
       *  Add support for DisableNativeAL Option to Disable ALchemy to ouput to OpenAl drivers (CT_oal.dll only)
            Post X-fi card will need to rename sens_oal.dll to Ct_oal.dll to make use of it.
            X-fi card should set this settings to False by default and yes in case of problem with specific game.
            Post X-fi card must do the opposite, the scripts is set this option to true by default (edit line 48 and 68 to change that)
    
## Install
Copy the script in your Creative alchemy folder.

## launch application
Launch the script and hide console
.\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\Program Files (x86)\Creative\ALchemy\Alchemy_XXX.ps1"

The scripts will create and use a new NewAlchemy.ini in the alchemy folder to store games and options.

You can also use the EXE version that has been compiled with PS2EXE.

When launched, NewALchemy application will search the system for supported DirectSound3D enabled games. All the games found will be listed in the left pane (titled "Installed Games"). The right pane (titled "NewALchemy-enabled Games”) will show any games which have already been converted to use ALchemy. To enable ALchemy support for a particular game, select it from the left panel, and press the “>>” button. To undo ALchemy support, select the game from the right panel and press the “<<” button. You can select multiple games at once and then use the directional arrow buttons to update them all.

<img src="https://i.imgur.com/l92WUJl.png">
<img src="https://i.imgur.com/qKifGXa.png">
<img src="https://i.imgur.com/8VYRtMS.png">

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
and force the wrapper to use his own libray.
This is the default mode for all post-x-fi card.
This allow all post x-fi card to rename their sens_oal.dll Host openAL drivers to Ct_oal.dll and be able
to disable the option when needed.
