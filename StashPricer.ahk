#Singleinstance, Force
#NoEnv  									; Recommended for compatibility with future AutoHotkey releases.
; #Warn  									; Enable warnings to assist with detecting common errors.
SendMode Input  							; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  				; Ensures a consistent starting directory.

;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Global Variables:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------

global local_version 						:= "dev.00.00"
global local_version_info					:= ""

global online_version						:= ""
global online_version_info					:= ""

global Mainfolder							:= "\Stashpricer_files"

global Scriptfolder							:= Mainfolder "\Scripts"
global Infofolder							:= "\Update"

global VersionInfoFile						:= Infofolder "\Version_Info.txt"
global Changelogfile 						:= Infofolder "\changelog.txt"

global Mainscript							:= "\Stashpricer_Main.ahk"

global githublink 							:= "https://raw.githubusercontent.com/Neomachina/Stashpricer/master"

global GUIenabled							:= false
global RecentlyUpdated						:= false

global FolderUpdates						:= []
global FileUpdates							:= []

global debug_priority						:= 6

global Query 								:= ""
FormatTime, Query, ,ddMMyyyyHHmmss			; Query String becomes equal to current time in the described format

;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Core Sequence:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------

Load_GUI()									; Loads the Graphical User Interface, if it's been enabled.
check_if_script_location_is_vaild()			; if not (there's spaces in the folderpath), close the script
check_if_main_folder_already_exists()		; if not (it's missing or has since been renamed), create it
try_to_retrieve_local_version()				; if a version_info.txt exists, use its version instead of the launcher's
look_for_latest_online_version()			; if th online version is newer than the launcher's, offer to download it
update_folder_structure()					; - based on the changelog from the online version. Skipped if no update.
update_files()								; - based on the changelog from the online version. Skipped if no update.
finalize()									; catchall for "stuff that must be done before launching the main script"
launch_main()								; starts the main script and closes the launcher

;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Core Functions:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------
Load_GUI()									; Loads the Graphical User Interface, if it's been enabled.
;-----------------------------------------------------------------------------------------------------------------------
{
	if (GUIenabled)
	{
		dbm(A_LineNumber, "GUI is currently enabled.")
	}
	else
	{
		dbm(A_LineNumber, "GUI is currently disabled.")
	}
}
;-----------------------------------------------------------------------------------------------------------------------
check_if_script_location_is_vaild()			; if not (there's spaces in the folderpath), close the script
;-----------------------------------------------------------------------------------------------------------------------
{
	if location_is_valid()
	{
		dbm(A_LineNumber, "Location was valid.")
	}
	else
	{
		Title		:= "Invalid Location:"
		Messagetext := message.Invalid_Location()
		MsgBox, , %Title%, %Messagetext%
		ExitApp								; Terminate the Script
	}
}
;-----------------------------------------------------------------------------------------------------------------------
check_if_main_folder_already_exists()		; if not (it's missing or has since been renamed), create it
;-----------------------------------------------------------------------------------------------------------------------
{
	if mainfolder_already_exists()
	{
		dbm(A_LineNumber, "Mainfolder already exist.")
	}
	else
	{
		dbm(A_LineNumber, "Mainfolder doesn't exist yet.")
		MakeFolderEdit( ,"+")
	}
}
;-----------------------------------------------------------------------------------------------------------------------
try_to_retrieve_local_version()				; if a version_info.txt exists, use its version instead of the launcher's
;-----------------------------------------------------------------------------------------------------------------------
{
	if local_version_info_exists()
	{
		dbm(A_LineNumber, "Was able to find the Version_Info.txt")
		local_version := retrieve_local_version()
	}
	else
	{
		dbm(A_LineNumber, "Couldn't find the Version_Info.txt")
	}
}
;-----------------------------------------------------------------------------------------------------------------------
look_for_latest_online_version()			; if the online version is newer than the launcher's, offer to download it
;-----------------------------------------------------------------------------------------------------------------------
{
	dbm(A_LineNumber, "About to try to retrieve online version.")
	online_version := retrieve_online_version()

	dbm(A_LineNumber, "local version is:    |" local_version "| `n" "online version is: |" online_version "|")

	if (local_version < online_version)
	{
		dbm(A_LineNumber, "About to offer to download the online version.")
		offer_to_download(online_version)
	}
}
;-----------------------------------------------------------------------------------------------------------------------
update_folder_structure()					; - based on the changelog from the online version. Skipped if no update.
;-----------------------------------------------------------------------------------------------------------------------
{
	if (FolderUpdates.Length())
	{
		dbm(A_LineNumber, "About to perform Folderupdates",3)
		For index, value in FolderUpdates
		{
			dbm(A_LineNumber, "|" value "|" ,4)
			Folder 	:= "\" SubStr(value, StrLen("__Folder__")) 
			mode 	:= SubStr(value,1 ,1 )
			MakeFolderEdit(Folder, mode)
		}
		dbm(A_LineNumber, "Done with Folderupdates.",3)
	}
	else 
	{
		dbm(A_LineNumber, "Looks like there are no FolderUpdates to be performed.",3)
	}
}
;-----------------------------------------------------------------------------------------------------------------------
update_files()								; - based on the changelog from the online version. Skipped if no update.
;-----------------------------------------------------------------------------------------------------------------------
{
	if (FileUpdates.Length())
	{
		dbm(A_LineNumber, "About to perform Fileupdates",3)
		For index, value in FileUpdates
		{
			dbm(A_LineNumber, "|" value "|",4)
			File 	:= "\" SubStr(value,StrLen("__File__"))
			mode 	:= SubStr(value, 1 ,1 )
			MakeFileEdit(File, mode)
		}
		dbm(A_LineNumber, "Done with Fileupdates.",3)
	}
	else 
	{
		dbm(A_LineNumber, "Looks like there are no Fileupdates to be performed.",3)
	}
}
;-----------------------------------------------------------------------------------------------------------------------
finalize()									; catchall for "stuff that must be done before launching the main script"
;-----------------------------------------------------------------------------------------------------------------------
{
	dbm(A_LineNumber, "Finalizing...",3)
	if (RecentlyUpdated)
	{
		MakeFolderEdit(Infofolder,"~")
		MakeFileEdit(VersionInfoFile,"+")
		MakeFileEdit(Changelogfile,"+")
	}
}
;-----------------------------------------------------------------------------------------------------------------------
launch_main()								; starts the main script and closes the launcher
;-----------------------------------------------------------------------------------------------------------------------
{
	dbm(A_LineNumber, "Starting Main Script...",3)
	launch()
	ExitApp
}

;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Auxilliary Functions:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------
location_is_valid()							; returns true if its true, and false if it isnt. 
;-----------------------------------------------------------------------------------------------------------------------
{
	return !(InStr(A_WorkingDir," "))
}

;-----------------------------------------------------------------------------------------------------------------------
mainfolder_already_exists()					; returns true if its true, and false if it isnt. 
;-----------------------------------------------------------------------------------------------------------------------
{
	return (InStr(FileExist(A_WorkingDir Mainfolder), "D"))
}

;-----------------------------------------------------------------------------------------------------------------------
MakeFolderEdit(Folder := "", mode := "")	; creates(+) / deletes(-) / recreates(~) the specified folder
;-----------------------------------------------------------------------------------------------------------------------
{
	if (mode == "+")
	{
		dbm(A_LineNumber, "Now creating:`n`n" A_WorkingDir Mainfolder Folder,4)
		if (FileExist(A_WorkingDir Mainfolder Folder))
		{
			dbm(A_LineNumber, "Looks like the Folder exists already for some reason.`nDeleting the old version...",2)
			FileRemoveDir, % A_WorkingDir Mainfolder Folder, 1
			While (FileExist(A_WorkingDir Mainfolder Folder))
			{
				Sleep 1000
			}
		}
		FileCreateDir, % A_WorkingDir Mainfolder Folder
		While !(FileExist(A_WorkingDir Mainfolder Folder))
		{
			Sleep 1000
		}
	}

	else if (mode == "-")
	{
		dbm(A_LineNumber, "Now deleting:`n`n" A_WorkingDir Mainfolder Folder,4)
		Filedelete, % A_WorkingDir Folder
	}

	else if (mode == "~")
	{	
		dbm(A_LineNumber, "Now recreating:`n`n" A_WorkingDir Mainfolder Folder,4)
		MakeFolderEdit(Folder, "-")
		MakeFolderEdit(Folder, "+")
	}

	else if (mode == "=")
	{

	}

	else
	{
		dbm(A_LineNumber, "Folderedit received unknown mode: |" mode "|",1)
	}
}

;-----------------------------------------------------------------------------------------------------------------------
local_version_info_exists()					; returns true if its the case, else false. 
;-----------------------------------------------------------------------------------------------------------------------
{
	return % FileExist(A_WorkingDir Mainfolder VersionInfoFile)
}

;-----------------------------------------------------------------------------------------------------------------------
retrieve_local_version()					; returns current version number (only!) from Version_Info.txt
;-----------------------------------------------------------------------------------------------------------------------
{
	FileRead, local_version_info, % A_WorkingDir Mainfolder VersionInfoFile
	dbm(A_LineNumber, "Current version info seems to be:`n`n" local_version_info)
	return % Info_to_Version_Number(local_version_info)
}

;-----------------------------------------------------------------------------------------------------------------------
retrieve_online_version()					; returns online version number (only!). If it cant, returns current version.
;-----------------------------------------------------------------------------------------------------------------------
{
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", githublink StrReplace(Mainfolder VersionInfoFile,"\","/") "?" Query, true)
	whr.Send()
	whr.WaitForResponse()

	online_version_info := whr.ResponseText
	dbm(A_LineNumber, "Online version info seems to be:`n`n" online_version_info)

	if ( InStr(online_version_info,"Version: ") )
	{
		return % Info_to_Version_Number(online_version_info)
	}
	else
	{
		return % local_version
	}
}

;-----------------------------------------------------------------------------------------------------------------------
Info_to_Version_Number(info)				; input is full info, output is "number" only.
;-----------------------------------------------------------------------------------------------------------------------
{
	number := SubStr(info,StrLen("Version: "))
	number := SubStr(number,2,InStr(number,"`n")-2)
	dbm(A_LineNumber, "Was asked for version number.`nAbout to return:`n`n|" number "|")
	return % number
}

;-----------------------------------------------------------------------------------------------------------------------
offer_to_download(online_version)			; makes a messagebox appear, offering to download the new version, if any.
;-----------------------------------------------------------------------------------------------------------------------
{
	Title 			:= "A new version of Stashpricer is available."
	Messagetext		:= message.New_Version_Available(online_version)
	MsgBox, 4, %Title%, %Messagetext%
	IfMsgBox, Yes
	{
		dbm(A_LineNumber, "Pressed Yes. Now trying to update.")
		retrieve_and_apply_changelog()
		RecentlyUpdated := true
	}
	IfMsgBox, No
	{
		dbm(A_LineNumber, "Pressed No. Proceeding with current version.")
	}
}

;-----------------------------------------------------------------------------------------------------------------------
retrieve_and_apply_changelog()				; retrieves a list of changes to be performed to update and queues them. 
;-----------------------------------------------------------------------------------------------------------------------
{
	global

	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET",  githublink StrReplace(Mainfolder Changelogfile,"\","/") "?" Query, true)
	whr.Send()
	whr.WaitForResponse()

	changelog := whr.ResponseText

	if !(InStr(changelog,"changelog:"))
	{
		dbm(A_LineNumber, "changelog doesn't seem to be valid. Update canceled.")
	}
	else
	{
		changelog 		:= SubStr(changelog,StrLen("changelog:  "))
		changelog 		:= SubStr(changelog,InStr(changelog, local_version))
		changelog 		:= SubStr(changelog,InStr(changelog, "Version")) 
		dbm(A_LineNumber, "Full changelog from " local_version " onward seems to be:`n`n" changelog)

		array1 	:= StrSplit(changelog, "`n") 
		array2  := array1

		index 	:= 1

		while ( index <= array1.MaxIndex())
		{
			array2 := summarize_changes(array1,array2,index)
			index += 1
		}

		array1 := []

		compiled_changelog := ""
    	For index, value in array2
		{
			Origin_Typekey := SubStr(value , 1, InStr(value," ")-1)
			if Key_is_candidate(Origin_Typekey) 
	    	{
	    		array1.Push(value)
				compiled_changelog .= value "`n"
			}
		}
		dbm(A_LineNumber, "compiled changelog from " local_version " onward is:`n`n" compiled_changelog ,6)

		compiled_changelog := array1

		FolderUpdates 	:= full_to_partial_changelog(compiled_changelog,"Folder")
		FileUpdates 	:= full_to_partial_changelog(compiled_changelog,"File")
	}
}

;-----------------------------------------------------------------------------------------------------------------------
summarize_changes(array1,array2,index)		; part of retrive_and_apply_changelog()
;-----------------------------------------------------------------------------------------------------------------------
{
	dbm(A_LineNumber, "About to summarize for index " index, 7)

	value := array1[index]
	previndex := index

	dbm(A_LineNumber, "origin value given is " value, 8)

	Origin_Typekey := SubStr(value , 1, InStr(value," ")-1)
	if Key_is_candidate(Origin_Typekey) 
	{
		index += 1
		while (index <= array2.Length())
		{
			dbm(A_LineNumber, "target value given is " array2[index], 8)

			Target_Typekey := SubStr(array2[index] , 1, InStr(array2[index]," ")-1)
			if Key_is_candidate(Target_Typekey) 
			{
				dbm(A_LineNumber, value "`nto`n" array2[index],8)
				if (SubStr(value,2) == SubStr(array2[index],2))
				{
					dbm(A_LineNumber, "Found match:`n" value "`nto`n" array2[index],7)
					value := Keymath(Origin_Typekey,Target_Typekey) SubStr(array2[index],2)

					Origin_Typekey := SubStr(value , 1, InStr(value," ")-1)

					array2[previndex] := ""
					previndex := index

					array2[index] := value
					dbm(A_LineNumber, "Targetarray Field[" index "] is now " array2[index],7)
				}
				else
				{
					dbm(A_LineNumber, "No match",8)
				}
			}
			else
			{
				dbm(A_LineNumber, "Skipped due to invalid key",8)
			}
			index += 1
		}
	}
	else
	{
		dbm(A_LineNumber, "Skipped due to invalid key",8)
	}
	return % array2
}

;-----------------------------------------------------------------------------------------------------------------------
Key_is_candidate(Key)						; Determines if the passed string is a valid "Key" (+ / - / = / ~ ).
;-----------------------------------------------------------------------------------------------------------------------
{
	return % (Key == "-")||(Key == "+")||(Key == "~")||(Key == "=")
}

;-----------------------------------------------------------------------------------------------------------------------
Keymath(Key1,Key2)							; Determines what the overall change is, given a sequence.
;-----------------------------------------------------------------------------------------------------------------------
{
	if (Key1 == "+") && (Key2 == "-")
	{
		return "="
	}
	else if (Key1 == "=") && (Key2 == "+")
	{
		return "+"
	}
	else if (Key1 == "-") && (Key2 == "+")
	{
		return "~"
	}
	else if (Key1 == "~") && (Key2 == "-")
	{
		return "-"
	}
	else if (Key1 == "+") && (Key2 == "~")
	{
		return "+"
	}
	else
	{
		dbm(A_LineNumber, "Keymath went wrong: |" Key1 "| |" Key2 "|",6)
	}
}

;-----------------------------------------------------------------------------------------------------------------------
full_to_partial_changelog(changelog,string)	; returns an array containing only those changes which include the string.
;-----------------------------------------------------------------------------------------------------------------------
{
	dbm(A_LineNumber, "About to try to retrive specific changes with Keyword [" string "]")
	index := 1

	partial_log := []

	while (index <= changelog.Length())
	{
		dbm(A_LineNumber, "Looking at:`n|" changelog[index] "|`n(Searching for " """" string """)",8)
		if (InStr(changelog[index],string))
		{
			dbm(A_LineNumber, "Found match:`n|" changelog[index] "|`n(Searching for " """" string """)", 7)
			partial_log.Push(changelog[index])
		}
		index += 1
	}

	changelist := ""
	For index, value in partial_log
	{
		changelist .= value "`n"
	}
	dbm(A_LineNumber, "Returning changes with Keyword [" string "] - they are: `n`n" changelist ,6)

	return partial_log
}

;-----------------------------------------------------------------------------------------------------------------------
MakeFileEdit(File := "", mode := "")		; downloads(+) / deletes(-) / recreates(~) the specified file
;-----------------------------------------------------------------------------------------------------------------------
{
	if (mode == "+")
	{
		dbm(A_LineNumber, "Now creating:`n`n" A_WorkingDir Mainfolder File,4)
		if (FileExist(A_WorkingDir Mainfolder File))
		{
			dbm(A_LineNumber, "Looks like the Folder exists already for some reason.`nDeleting the old version...",2)
			Filedelete, % A_WorkingDir Mainfolder File
			While (FileExist(A_WorkingDir Mainfolder Folder))
			{
				Sleep 1000
			}
		}
		target_to_file(File)
		While !(FileExist(A_WorkingDir Mainfolder File))
		{
			Sleep 1000
		}
	}

	else if (mode == "-")
	{
		dbm(A_LineNumber, "Now deleting:`n`n" A_WorkingDir Mainfolder File,4)
		Filedelete, % A_WorkingDir File
	}

	else if (mode == "~")
	{	
		dbm(A_LineNumber, "Now recreating:`n`n" A_WorkingDir Mainfolder File,4)
		MakeFileEdit(File, "-")
		MakeFileEdit(File, "+")
	}

	else if (mode == "=")
	{

	}

	else
	{
		dbm(A_LineNumber, "FileEdit received unknown mode: |" mode "|",1)
	}
}

;-----------------------------------------------------------------------------------------------------------------------
target_to_file(target,path = "")			; dowloads the specified file from github, to the specified path.
;-----------------------------------------------------------------------------------------------------------------------
{
	if (path == "")
	{
		path := Mainfolder
	}
	link_path 	:= githublink StrReplace(path target,"\","/")
	dbmtext 	:= message.debug_URLtoFILE_download(link_path,path,target)
	dbm(A_LineNumber, dbmtext ,4)
	UrlDownloadToFile, % link_path "?" Query, % A_WorkingDir path target
}

;-----------------------------------------------------------------------------------------------------------------------
Launch(target := "", location := "")
;-----------------------------------------------------------------------------------------------------------------------
{
	if !(target)
	{
		target := Mainscript
	}
	if !(location)
	{
		location := A_WorkingDir Scriptfolder
	}
	dbm(A_LineNumber,"About to try to run:`n`n" location target,3)
	Run, % location target
}

;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											User Interface:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------



;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Hotkeys:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------



;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Labels:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------



;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Debugging:
;=====================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------
dbm(Line, Content := "", Priority := 9, Context := "", Code := 0)
;-----------------------------------------------------------------------------------------------------------------------
{
	if (debug_priority >= Priority){
		if (code == 0) 
		{
			Title := "Debugging info for line " Line " - Priority: " Priority
		}
		else 
		{
			Title := Title := "Error occured at line " Line " - Code: " Code " Priority: " Priority
		}
		Text := message.debug_default(Content, Context, Priority)
		show(Text, Title)
	}
}

;-----------------------------------------------------------------------------------------------------------------------
;=======================================================================================================================
;											Messages:
;=======================================================================================================================
;-----------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------
show(content, title := "", options := "")	; a slightly modified messagebox command
;-----------------------------------------------------------------------------------------------------------------------
{
	if !(content == " ")
	{
		if (options == "")
		{
			MsgBox , , %title% , %content%
		} 	
		else
		{
			MsgBox , %options% , %title% , %content%
		}
	}
}

;-----------------------------------------------------------------------------------------------------------------------
class message 								; Text content of (longer) messages used by the script
;-----------------------------------------------------------------------------------------------------------------------
{
	;-------------------------------------------------------------------------------------------------------------------
	debug_default(Content, Context, Priority)
	;-------------------------------------------------------------------------------------------------------------------
	{
		Text 	:= ""
		if (Content)
		{
			Text 	.= Content  
			Text	.= "`n`n==============================================`n`n"
		}
		if (Context)
		{
			Text	.= Context
			Text	.= "`n`n==============================================`n`n"
		}
		Text .= "(Showing Debug Messages with priority up to " debug_priority ")"
		return % Text
	}

	debug_URLtoFILE_download(link_path,path,target)
	{
		dbmtext 	:= "Trying do download`n`n" link_path 
		dbmtext		.= "`n`nwith target`n`n" A_WorkingDir path target 
		dbmtext		.= "`n`n(Query is " Query ")"
		return % dbmtext
	}

	Invalid_Location()
	{
		Text := "It would seem you have place this script if a folder "
		Text .= "which's path contains spaces ("" "").`n`n" "Due to "
		Text .= "limitations I am trying to deal with, the tool will "
		Text .= "not function if placed in such a folder. The tool will "
		Text .= "now exit - please place it in a valid location afterwards."
		Text .= "`n`nFixing this has low priority, so do not expect this."
		Text .= " to be dealt with in the current main version (" 
		Text .= SubStr(version,1,(StrLen(version)-3)) ")."
		return % Text
	}

	New_Version_Available(online_version)
	{
		Text 	:= "A new version of Stashpricer is available.`n`n"
		Text 	.= "Your local version is: 	|" local_version "|`n"
		Text 	.= "The online version is: 	|" online_version "|`n`n"
		Text 	.= "Would you like to download it now? (This may take a few moments.)"
		return % Text
	}

	;-------------------------------------------------------------------------------------------------------------------
	test_1(content := "")					; used for testing purposes
	;-------------------------------------------------------------------------------------------------------------------
	{
		Text 	:= "Hello "
		Text 	.= "World."
		Text 	.= "`n`n"
		Text 	.= content
		return 	% Text
	}
}