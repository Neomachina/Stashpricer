
MsgBox, Test 1-2 1-2: Hello World!

{
	global Mainfolder							:= "\Stashpricer_files"

	global Scriptfolder							:= "\Scripts"
	global Infofolder							:= "\Update"

	global VersionInfoFile						:= Infofolder "\Version_Info.txt"
	global Changelogfile 						:= Infofolder "\changelog.txt"

	global Mainscript							:= "\Stashpricer_Main.ahk"

	global githublink 							:= "https://raw.githubusercontent.com/Neomachina/Stashpricer/master"

	global RecentlyUpdated						:= false

	global GUIenabled							:= true

	Fontsize									:= 12

	global LaunchProgress 						:= "" 
	global Statustext 							:= ""
	global Logtext 								:= ""
	global Questtext 							:= ""
	global Button1_text 						:= ""
	global Button2_text 						:= ""	

	global BaseX 								:= "Center"
	global BaseY 								:= "Center"
	global BaseW 								:= 500
	global BaseH 								:= 30

	global X 									:= 0
	global Y 									:= 0
	global W 									:= 0
	global H 									:= 0

	global debug_priority						:= 6						; smaller number means less messages
	global debug_priority_if_GUI_is_active		:= 1						

	global Query 								:= ""
	FormatTime, Query, ,ddMMyyyyHHmmss			; Query String becomes equal to current time in the described format
}
