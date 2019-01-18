;==========================================================================
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;==========================================================================
global version 			:= "dev.04.05"
global githublink 		:= "https://raw.githubusercontent.com/Neomachina/Stashpricer/master/"
global Mainfolder		:= A_WorkingDir "\Stashpricer_files"
global Stashdata		:= Mainfolder "\Stashdata"
global Scripts			:= Mainfolder "\Scripts"
global Images 			:= Mainfolder "\Images"
;==========================================================================
global Query 			:= ""
FormatTime, Query, ,ddMMyyyyHHmmss
;==========================================================================
if (location_is_valid()){
	if (version_outdated())||!(FileExist(Mainfolder)){
		download_updater()
	} else {
		if (this_is_a_fresh_update()){
			perform_actions_required_if_fresh_update()
		}
	}
	run_main_script()
}
;==========================================================================
location_is_valid(){
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
;==========================================================================
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
;==========================================================================
download_updater(){
	create_missing_folders()
	target_to_file("Stashpricer.ahk")
	target_to_file("updated.txt",Mainfolder)
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
;==========================================================================
target_to_file(url,dir = ""){
	if !(dir) {
		dir := A_WorkingDir
	}
	UrlDownloadToFile, % githublink url "?" Query, % dir "\" url 
}
;==========================================================================
this_is_a_fresh_update(){
	if FileExist(Mainfolder "\updated.txt"){
		FileDelete, % Mainfolder "\updated.txt"
		return true
	} else {
		return false
	}
}
;==========================================================================
perform_actions_required_if_fresh_update(){
	create_missing_folders()
	download_files()
}
;==========================================================================
create_missing_folders(){
	if !(InStr(FileExist(Mainfolder),"D")){
		FileCreateDir, %Mainfolder%
	}
	if !(InStr(FileExist(Stashdata),"D")){
		FileCreateDir, %Stashdata%
	}
	if !(InStr(FileExist(Scripts),"D")){
		FileCreateDir, %Scripts%
	}
	if !(InStr(FileExist(Images),"D")){
		FileCreateDir, %Images%
	}
}
;==========================================================================
download_files(){
	target_to_file("C-orb.png",Images)
	target_to_file("JSON.ahk",Scripts)
	target_to_file("Stashpricer_Main.ahk",Scripts)
	target_to_file("downloadutils.bat",Scripts)
	target_to_file("downloadutils.vbs",Scripts)
	target_to_file("curl.exe",Scripts)
}
;==========================================================================
run_updater(){
	Run, Stashpricer.ahk
}
;==========================================================================
run_main_script(){
	Run()
}
;==========================================================================
Run(target := "Stashpricer_Main.ahk", location := ""){
	if !(location){
		location := Scripts
	}
	Run, % location "\" target
}
