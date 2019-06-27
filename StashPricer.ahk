#Singleinstance, Force
#NoEnv  										; Recommended for compatibility with future AutoHotkey releases.
; #Warn  										; Enable warnings to assist with detecting common errors.
SendMode Input  								; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  					; Ensures a consistent starting directory.

;===========================================================================================================================
;												Global Variables:
;===========================================================================================================================
{
	global online_version						:= ""
	global online_version_info					:= ""
	global local_version						:= "dev.current"
	global local_version_info					:= ""
	global Mainfolder 							:= "\StashPricer_files"
	global ForceUpdate 							:= false
	global githublink 							:= "https://raw.githubusercontent.com/Neomachina/Stashpricer/master"
	global Query 								:= ""
	FormatTime, Query, ,ddMMyyyyHHmmss			; Query String becomes equal to current time in the described format
}
;===========================================================================================================================
;												Core Sequence:
;===========================================================================================================================
{
	check_location()							; if not (there's spaces in the folderpath), close the script
	create_mainfolder()							; if not (it's missing or has since been renamed), create it
	retrieve_local_version()					; if a version_info.txt exists, use its version instead of the launcher's
	retrieve_online_version()					; if the online version differs from the launcher's, offer to download it
	launch() 									; launch - always StashPricer_Main.ahk
	ExitApp  									; Exit
}
;===========================================================================================================================
;												Core Functions:
;===========================================================================================================================
{
	;-----------------------------------------------------------------------------------------------------------------------
	check_location()							; if not (there's spaces in the folderpath), close the script
	{
		if (InStr(A_WorkingDir," "))
		{
			Title		:= "Invalid Location:"
			Messagetext := message.Invalid_Location()
			MsgBox, , %Title%, %Messagetext%
			ExitApp								; Terminate the Script
		}
	}
	;-----------------------------------------------------------------------------------------------------------------------
	create_mainfolder()							; if not (it's missing or has since been renamed), create it
	{
		if !(InStr(FileExist(A_WorkingDir Mainfolder), "D"))
		{
			FileCreateDir, % A_WorkingDir Mainfolder
			ForceUpdate := true
		}
	}
	;-----------------------------------------------------------------------------------------------------------------------
	retrieve_local_version()					; if a version_info.txt exists, use its version instead of the launcher's
	{
		if (FileExist(A_WorkingDir Mainfolder "\README.md"))
		{
			Loop, Read, % A_WorkingDir Mainfolder "\README.md"
			{
				if (InStr(A_LoopReadLine,"Version: "))
				{
					local_version := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, "Version: ") + StrLen("Version: "))
				}
			}
		}
		else
		{
			local_version := "N/A: missing files"
			ForceUpdate := true
		}
	}
	;-----------------------------------------------------------------------------------------------------------------------
	retrieve_online_version()					; if the online version is newer than the launcher's, offer to download it
	{
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		Try
		{
			whr.Open("GET", githublink "/README.md" "?" Query, true)
			whr.Send()
			whr.WaitForResponse()
			online_version_info := whr.ResponseText
		}
		if (InStr(online_version_info,"Version: "))
		{
			Loop, Parse, online_version_info, "`n"
			{
				if (InStr(A_LoopField,"Version: "))
				{
					online_version := SubStr(A_LoopField, InStr(A_LoopField, "Version: ") + StrLen("Version: "))
				}
			}
		}
		if (local_version != online_version)||(online_version == "dev.current")
		{
			offer_to_download(online_version)
		}
	}
	;-----------------------------------------------------------------------------------------------------------------------
	launch()									; 
	{
		Run, % A_WorkingDir Mainfolder "\" local_version "\Scripts\StashPricer_Main.ahk"
	}
}
;===========================================================================================================================
;												Auxilliary Functions:
;===========================================================================================================================
{
	;-----------------------------------------------------------------------------------------------------------------------
	offer_to_download(online_version)			; makes a messagebox appear, offering to download the new version, if any.
	{
		Title 			:= "Local Version seems outdated."
		Messagetext		:= message.New_Version_Available(online_version)
		MsgBox, 4, %Title%, %Messagetext%
		IfMsgBox, Yes
		{
			download()
		}
		else
		{
			if (ForceUpdate)
			{
				ExitApp
			}
		}
	}
	;-----------------------------------------------------------------------------------------------------------------------
	download()
	{
		target_to_file("/" online_version ".zip")
		FileRemoveDir, % A_WorkingDir Mainfolder "\" local_version, 1
		Unz(A_WorkingDir Mainfolder "\" online_version ".zip", A_WorkingDir Mainfolder "\" online_version)
		i = 0
		While(FileExist(A_WorkingDir Mainfolder "\README.md"))
		{
			Filedelete, % A_WorkingDir Mainfolder "\README.md"
			Sleep 100
			i += 1
			if (i > 50)
			{
				MsgBox % "It's seem the README.md is currently open in another application. Please close it."
			}
		}
		target_to_file("/README.md")
		i = 0
		While (FileExist(A_WorkingDir Mainfolder "\" online_version ".zip"))
		{
			Filedelete, % A_WorkingDir Mainfolder "\" online_version ".zip"
			Sleep 100
			i += 1
			if (i > 50)
			{
				MsgBox % "It's seem the " online_version ".zip is currently open in another application. Please close it."
			}
		}	
		local_version := online_version
	}
	;-----------------------------------------------------------------------------------------------------------------------
	target_to_file(target,path = "")			; dowloads the specified file from github, to the specified path.
	{
		if (path == "")
		{
			path := Mainfolder
		}
		link_path 	:= githublink StrReplace(target,"\","/")
		UrlDownloadToFile, % link_path "?" Query, % A_WorkingDir path target
	}
	;-----------------------------------------------------------------------------------------------------------------------
	Unz(sZip, sUnz)
	{
	    fso := ComObjCreate("Scripting.FileSystemObject")
	    If Not fso.FolderExists(sUnz)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
	    {
	       fso.CreateFolder(sUnz)
	    }
	    psh  := ComObjCreate("Shell.Application")
	    zippedItems := psh.Namespace( sZip ).items().count
	    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
	    Loop 
	    {
	        sleep 100
	        unzippedItems := psh.Namespace( sUnz ).items().count
	        If (zippedItems <= unzippedItems) && (prevun == unzippedItems)
	        {
	            break
	        }
	        prevun := unzippedItems
	    }
	}
}
;===========================================================================================================================
class UI 										; User Interface:
;===========================================================================================================================
{
	
}
;===========================================================================================================================
;												Labels:
;===========================================================================================================================
{
	
}
;===========================================================================================================================
;												Hotkeys:
;===========================================================================================================================
{
	^r::Reload
	^x::ExitApp
}
;===========================================================================================================================
class message   								; Messages:
;===========================================================================================================================
{
	;-----------------------------------------------------------------------------------------------------------------------
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
	;-----------------------------------------------------------------------------------------------------------------------
	New_Version_Available(online_version)
	{
		Text 	:= "A new version of Stashpricer is available.`n`n"
		Text 	.= "Your local version is:	" local_version "`n"
		Text 	.= "The online version is:	" online_version "`n`n"
		Text 	.= "Would you like to download it now?`n(This may take a few moments.)`n"
		return % Text
	}
}