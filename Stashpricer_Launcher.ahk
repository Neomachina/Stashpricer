;==========================================================================
#Singleinstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;==========================================================================

;This is the launcher/updater for Stashpricer

;==========================================================================
global version 			:= "dev.04.05"
global githublink 		:= "https://raw.githubusercontent.com/Neomachina/Stashpricer/master/"
global Mainfolder		:= A_WorkingDir "\Stashpricer_files"
global Scripts			:= Mainfolder "\Scripts"
global debug_priority	:= 0
;--------------------------------------------------------------------------
dbm(Content := "No information was given", Priority := 0, Context := "(No context was given)", error := true){
	if (debug_priority >= Priority){
		if (error) {
			Messagetext := "An error seems to have occured at line " A_LineNumber 
		} else {
			Messagetext := "This is regular debug message for line " A_LineNumber
		}
		Messagetext .= "`n`n" Content "`n`n" Context 
		MsgBox, % Messagetext
	}
}
;--------------------------------------------------------------------------
global Query 			:= ""
FormatTime, Query, ,ddMMyyyyHHmmss
;==========================================================================

dbm("This should be the fist Message you see",,,0)

if (location_is_valid()){
	target_to_file("README.md")
	if (version_outdated()){
		target_to_file("README.md")
		ExitApp
	} else {
		if (debugmsg) MsgBox, Location was valid
		run(Stashpricer_Main.ahk)
	}
}

location_is_valid(){
	;Check if folder location contains spaces, because those break things.
	if InStr(Mainfolder," "){
		Messagetext := "It would seem you have place this script if a folder "
		Messagetext .= "which's path contains spaces ("" "").`n`n" "Due to "
		Messagetext .= "limitations I am trying to deal with, the tool will "
		Messagetext .= "not function if placed in such a folder. The tool will "
		Messagetext .= "now exit - please place it in a valid location afterwards."
		Messagetext .= "`n`n Fixing this has low priority, so do not expect this."
		Messagetext .= " to be dealt with in the current main version (dev.05)."
		MsgBox, % Messagetext
		ExitApp
	} else {
		return true
	}
}

version_outdated(){
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET",  githublink "version.txt" "?" Query, true)
	whr.Send()
	whr.WaitForResponse()
	online_version := SubStr(whr.ResponseText,StrLen("Version:  "))
	if !(version == SubStr(online_version, 1 , RegExMatch(online_version, "`n")-1)) {
		Title 			:= "A new version of Stashpricer is available!"
		Messagetext 	:= "A new version of Stashpricer is available.`n`n"
		Messagetext 	.= "Your current version is: " version "`n`n"
		Messagetext 	.= "The online version is: " online_version "`n"
		Messagetext 	.= "Would you like to download it now? (This may take a few moments.)"
		MsgBox, 4, , %Messagetext%, %Title%
		IfMsgBox, Yes 
			return true
	} 
	return false
}

download_updater(){
	target_to_file("Run_Stashpricer.ahk")
	;target_to_file("updated.txt",Mainfolder)
	While !(FileExist(Mainfolder "\updated.txt")){
		Sleep 1000
		if (A_Index > 30) {
			Meseagetext	:= "Something seems to have gone wrong while trying "
			Messagetext .= "to install the update. The program will now exit."
			MsgBox, %  Messagetext
			ExitApp
		}
	}
}

target_to_file(target,dir = ""){
	if !(dir) {
		dir := A_WorkingDir
	}
	dbm("Trying to download " target " from " githublink)
	UrlDownloadToFile, % githublink target "?" Query, % dir "\" target
}

download_files(){
	target_to_file("JSON.ahk",Scripts)
}

Run(target := "Stashpricer_Main.ahk", location := ""){
	if !(location){
		location := Scripts
	}
	;Run, % location "\" target
}