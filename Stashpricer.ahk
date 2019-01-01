#Singleinstance, Force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;==========================================================================
global version 			:= "dev.04.01"
global githublink 		:= "https://raw.githubusercontent.com/Neomachina/Stashpricer/master/"
global Mainfolder		:= A_WorkingDir "\Stashpricer_files"
global Stashdata		:= Mainfolder "\Stashdata"
global Scripts			:= Mainfolder "\Scripts"
;==========================================================================

;==========================================================================
;= 			Create a Query string that should be unique enough. 
;==========================================================================
global Query
FormatTime, Query, ,ddMMyyyyHHmmss

;==========================================================================
;= 				Check if the folder path contains spaces. 
;==========================================================================
if InStr(Mainfolder," "){
	Messagetext := "It would seem you have place this script if a folder "
	Messagetext .= "which's path contains spaces ("" "").`n`n" "Due to "
	Messagetext .= "limitations I am trying to deal with, the tool will "
	Messagetext .= "not function if placed in such a folder. The tool will "
	Messagetext .= "now exit - please place it in a valid location afterwards."
	Messagetext .= "`n`n Fixing this has low priority, so do not expect this."
	Messagetext .= " to be dealt with in the current main version (dev.04)."
	MsgBox, % Messagetext
	ExitApp
} else {
	makefolders()
	check_for_new_version()
}
;==========================================================================
;= 				Check if a version update is available:
;==========================================================================
check_for_new_version(){
	online_version 		:= get_online_version()
	if !(version == SubStr(online_version, 1 , RegExMatch(online_version, "`n")-1)) {
		Title 			:= "A new version of Stashpricer is available!"
		Messagetext 	:= "A new version of Stashpricer is available.`n`n"
		Messagetext 	.= "Your current version is: " version "`n`n"
		Messagetext 	.= "The online version is: " online_version "`n"
		Messagetext 	.= "Would you like to download it now?`n`n"
		MsgBox, 4, , %Messagetext%, %Title%
		IfMsgBox, Yes 
		  {	
			Download()
			While !(FileExist(Mainfolder "\updated.txt")){
				Sleep 1000
				if (A_Index > 30) {
					Meseagetext	:= "Something seems to have gone wrong while trying "
					Messagetext .= "to install the update. The program will now exit."
					MsgBox, %  Messagetext
					ExitApp
				}
			}
			Run, Stashpricer.ahk
			ExitApp
		} else {
			MsgBox, About to run
			Run()
		}
	}
	if FileExist(Mainfolder "\updated.txt"){
		Download()
		FileDelete, % Mainfolder "\updated.txt"
	}
	Run()
}
;==========================================================================
;=			Retrieve the online version (and the text )
;==========================================================================
get_online_version(){
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET",  githublink "version.txt" "?" Query, true)
	whr.Send()
	whr.WaitForResponse()
	online_version := SubStr(whr.ResponseText,StrLen("Version:  "))
	return online_version
}

;==========================================================================
;=			Creates the main Folders if they don't exist yet
;==========================================================================
makefolders(){
	if !(InStr(FileExist(Mainfolder),"D")){
		FileCreateDir, %Mainfolder%
	}
	if !(InStr(FileExist(Stashdata),"D")){
		FileCreateDir, %Stashdata%
	}
	if !(InStr(FileExist(Scripts),"D")){
		FileCreateDir, %Scripts%
	}
}

;==========================================================================
;=		Downloads the recquired files (of the newest version)
;==========================================================================
Download(){
	target_to_file("README.md")
	target_to_file("Stashpricer.ahk")
	target_to_file("updated.txt",Mainfolder)
	target_to_file("JSON.ahk",Scripts)
	target_to_file("Stashpricer_Main.ahk",Scripts)
	target_to_file("downloadutils.bat",Scripts)
	target_to_file("downloadutils.vbs",Scripts)
	target_to_file("curl.exe",Scripts)
}
target_to_file(url,dir = ""){
	if !(dir) {
		dir := A_WorkingDir
	}
	UrlDownloadToFile, % githublink url "?" Query, % dir "\" url 
} 

;==========================================================================
;=					Starts Stashpricer
;==========================================================================
Run(target := "Stashpricer_Main.ahk"){
	Run, %   Scripts "\" target
}
