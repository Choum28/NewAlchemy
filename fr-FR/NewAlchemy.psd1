#culture="fr_FR"
ConvertFrom-StringData @'
	#main form
	BoutonAjouterContent=Ajouter
	BoutonEditionContent=Édition
	BoutonDefaultContent=Par défaut
	Defaultmsgbox=La liste de jeux et les paramètres par défaut vont être rétablis.
	Defaultmsgbox2=Ces informations vont être sauvegardée dans : 
	Defaultmsgbox3=Etes vous sur de vouloir continuer ?
	Text_main=NewAlchemy restitue un son accéléré par composant matériel de sorte que vous puissez profiter des effets EAX et du son Audio 3D lorsque vous utilisez des jeux DirectSound3D dans windows version Vista et supérieures.
	Text_jeuInstall=Jeux installés
	Text_JeuTransmut=Jeux activés par NewAlchemy
	#Edit / add Form
	MainTitle2=Paramètres du jeu
	C_registreContent=Utiliser le chemin d'accès au registre
	C_GamepathContent=Utiliser le chemin d'accès au jeu
	T_registreToolTip=Chemin du registre contenant la chaîne de l'exécutable ou le répertoire de l'exécutable (à privilégier, l'alternative est le chemin d'accès)
	T_GamepathToolTip=Chemin vers le dossier de l'application (si le chemin d'accès au registre ne peut être utilisé)
	T_BuffersContent=Tampons
	T_BuffersToolTip=Permet de définir le nombre de tampons audio utilisés en interne. La valeur par défaut de 4 devrait convenir à la plupart des applications. (Valeurs 2 à 10).
	T_DurationContent=Durée
	T_DurationToolTip=Utilisé pour définir la longueur en millisecondes de chacun des tampons audio. La valeur par défaut est de 25ms. (valeurs : 5 à 50)
	T_VoiceContent=Nombre maximal de voix
	T_voiceToolTip=Utilisé pour définir le nombre maximum de voix matérielles qui seront utilisées par Alchemy (par défaut 128), valeurs : 32 à 128
	L_Settings=Paramètres
	B_OkContent=Ok
	B_CancelContent=Annuler
	L_GameTitleContent=Titre du jeu
	T_SubdirToolTip=Permet de définir un sous-dossier par rapport au chemin remonté par le chemin d'accès
	C_DisableDirectMusicContent=Désactiver la musique directe
	C_DisableDirectMusicToolTip=Permet de désactiver la prise en charge de DirectMusic. (0 ou 1 dans dsound.ini).
	C_DisableNativeAlContent=Désactiver le pilote OpenAL natif
	C_DisableNativeAlToolTip=Pour carte son X-FI et Audigy uniquement, désactive l'utilisation pilote OpenAl matériel (Ct_oal.dll) par Alchemy, Creative Software 3D Library est alors utilisé à la place.
	C_SubDirContent=Installer dans un sous-dossier
	C_RootdirContent=Installer dans le dossier racine et un sous-dossier
	L_Debug1Content=---------------------------------------------------DEBUG---------------------------------------------------
	L_Debug2Content=L'activation des paramètres de log peut grandement impacter les performances.
	C_LogDirectSoundContent=Log Directsound
	C_LogDirectSound2DContent=Log Directsound 2D
	C_LogDirectSound2DStreamingContent=Log Directsound 2D streaming
	C_LogDirectSound3DContent=Log Directsound 3D
	C_LogDirectSoundListenerContent=Log DirectSound Listener
	C_LogDirectSoundEAXContent=Log EAX
	C_LogDirectSoundTimingInfoContent=Log Directsound timing info
	C_LogStarvationContent=Log starvation
	C_logtextTooltip=Les logs seront sauvegardés dans le fichier dsound.log du jeu, nécéssite le pilote OpenAl natif CT.oal.dll
	FolderChoice=Sélectionnez un dossier
	SubFolderChoice=Sélectionnez un sous-dossier
	# Error message
	Badlocation=NewAlchemy nécéssite l'installation de Creative Alchemy.
	MissFile=Fichier nécéssaire manquant dans le dossier Creative Alchemy
	RegKeyInc=Valeur de la clef registre incorrect
	RegKeyValInc=La clef registre ne renvoie pas un chemin
	RegKeyBad=La clef registre est invalide
	RegKeyEmpty=Le chemin d'accès au registre est vide
	PathEmpty=Le chemin d'accès au jeu est vide
	BadPath=Le chemin d'accès est invalide
	BadPathOrSub=Le chemin n'existe pas ou n'est pas un sous-dossier.
	SubNotFound=Le sous-dossier est introuvable
	BuffersErr=La valeur du tampon doit être de 2 à 10 !
	DurationErr=La durée doit être de 5 à 50 !
	VoiceErr=Le nombre maximal de voix doit être de 32 à 128 !
	TitleExist=Titre de jeu déja existant
	TitleMiss=Titre de jeu obligatoire
'@
