#Singleinstance, Force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Stashpricer_files\Scripts\JSON.ahk

;==========================================================================
;= 							globals:
;==========================================================================
global words_of_warning 	:= 1
global version				:= "dev.03.11"
global settings 			:= {}

;SplitPath, InputVar , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

global Mainfolder			:= A_WorkingDir 
SplitPath, Mainfolder, ,Mainfolder

global Stashdata			:= Mainfolder "\Stashdata"
global settingsfile 		:= Mainfolder "\settings.txt"
global chardata_file 		:= Mainfolder "\chardata.txt"
global accountname_file 	:= Mainfolder "\accountname.txt"
global batfile 				:= "downloadutils.bat"
global vbsfile 				:= "downloadutils.vbs"

global download     		:= ""	;makes "download" global for use
global update 				:= "" 	;makes "update" global for use
global get  				:= ""	;makes "get" global for use
global select 				:= ""	;makes "select" global for use

global temp_tab				:= ""

global OL_active 			:= false

global leaguearray			:= "" 	;stores league data for use at runtime
global leagueindex			:= ""	;stores selected active league at runtime
global tabarray 			:= ""	;stores tab data for use at runtime
global tabindex				:= ""	;stores index of the tab to display an overly for

;==========================================================================
;=               			Startup
;==========================================================================
initialize_main()

check_for_is_recent_update()

makesettings()
;--------------------------------------------------------------------------
;if they don't exist yet:
; 	request.poesessid()
;	download.characters() ;- based on ID
;	get.character() ;- get a random (first) character name based on character data
; 	get.accountname() ;- get accountname by character name
;	get.leagues() ;- get leagues used by character based on character data
; 	select.default_league() ;- select a league from the active leagues.
;	download.stashmetadata()
;if they do exist:
;	update.settings()
;--------------------------------------------------------------------------


;==========================================================================
;= What to do if this version was just installed from an old one
;==========================================================================
check_for_is_recent_update(){
	if FileExist(Mainfolder "\updated.ahk"){
		FileDelete, % Mainfolder "\updated.ahk"
	}
}

;==========================================================================
;= 						Automative Actions:
;==========================================================================
#Persistent
Settimer,Update, % settings["Update Delay"]

Update(){
	
	
	;get the current data for the tab and store it in old_contens or something
	;download the new data
	;get the new_content
	;compare item/item based on position and name
	;if the item is outdated, replace it. Then,
	;if the item is rare and unpriced, always price it
	;if the item isn't rare, just skip
	;if the item is rare and priced and forced reprice is disabled, skip


}
;==========================================================================
;= 					Hotkeys:
;==========================================================================



;=========================================================================
;= 							Settings:
;=========================================================================
requestpoesessid(){
	;---------------------------------------------------------------------
	if (words_of_warning){
	Messagetext := "This is a free tool made by a hobbyist. Said hobbyist "
	Messagetext .= "uses it himself, and obviously hopes to have ensured "
	Messagetext .= "that it functions without doing anything it shouldn't.`n`n"
	Messagetext .= "In spite of this, there are probably plenty of bugs "
	Messagetext .= "I overlooked so far, or simply considered too minor "
	Messagetext .= "to fix yet. I am not / refuse to be held responsible  "
	Messagetext .= "for any unintended behavior. While I will try to fix "
	Messagetext .= "the problem if you contact me, you ARE using this at your own"
	Messagetext .= " risk.`n`nAgain, I use this myself, so I've tried to make it "
	Messagetext .= " so that this doesn't end up erasing all files on my computer. "
	Messagetext .= " Still, that's about the only assurance I can give you."
	Messagetext .= "`n`n Do you agree to these conditions?"
	MsgBox, 4, , %Messagetext%, %Title%
	IfMsgBox, No
		ExitApp
	words_of_warning = 0
	}
	;---------------------------------------------------------------------
	Title 		:= 	"Hello! Thank you for trying out Stashpricer!`n"
	Messagetext	:=  "It would seem that this is your first time running"
	Messagetext	.=  " this script." " To function, it will need your"
	Messagetext	.=	" poesessid. Please enter it in the field below. "
	Messagetext .= 	"(Guides on how to obain it are available online.)"
	Messagetext	.=  "`n`n!! It acts as a password, so do not share it !!"
	settings["poesessid"]	:= InputBox(Messagetext,,"HIDE",Title)
	StrReplace(settings["poesessid"], " " , "", spaces)
	if (spaces)||(settings["poesessid"] == ""){
		invalid_poesessid()
	}
}
makesettings(force = ""){
	;=====================================================================
	;If the settings DON'T already exist:
	;=====================================================================
	if !(FileExist(settingsfile))||force{
		;-----------------------------------------------------------------
		;Initialize everthing:
		;-----------------------------------------------------------------
		settings["accountname"]		:= ""
		settings["active leagues"]	:= ""
		settings["default league"] 	:= ""
		settings["leagues"]			:= ""
		settings["Menu Hotkey"] 	:= ""
		settings["Overlay Hotkey"]	:= ""
		settings["poesessid"] 		:= ""
		settings["PoE_logfile"]		:= ""
		settings["Update Delay"]	:= "10000"
		settings["UI_Tab0"]			:= ""
		settings["UI_Tab6"]			:= ""
		settings["UI_Tab7"]			:= ""
		settings["UI_Tab8"]			:= ""
		settings["UI_Tab9"]			:= ""
		settings["version"]			:= version
		;-----------------------------------------------------------------
		requestpoesessid()
		;-----------------------------------------------------------------
		Messagetext := "Now going to attempt to download relevant data. This" 
		Messagetext .= " may take a few short moments. If you close this tool"
		Messagetext .= " before its settings are fully configured, you may "
		Messagetext .= " have to reinstall it, as this is likely to break something."
		MsgBox, % Messagetext
		download.chardata()
		;-----------------------------------------------------------------
		Messagetext := "Please also note that Stashpricer will only attempt to look for the first 15 tabs of any given stash."
		Messagetext .= "`n`nIt is furthermore only intended to function with ""regular"" (any 12x12) and Quad tabs, and will"
		Messagetext .= " only attempt to price RARE items (not uniques, divination cards...), in a single tab at a time.`n`n"
		Messagetext .= "Most of these restrictions could be removed easily, but the strain this would presumably put on poeprice"
		Messagetext .= ".info's servers simply isn't likely to be in relation to their utility. Depending feedback concerning "
		Messagetext .= "ressource availability from their side, this may change in the future. Alternatively, I may look into"
		Messagetext .= " integrating price information provided by other sites such as poe.ninja, but doing so would take time."
		MsgBox, % Messagetext
		;-----------------------------------------------------------------
		get.accountname()		
		;-----------------------------------------------------------------
		update.settings_file()
		;-----------------------------------------------------------------
		get.leagues()
		;-----------------------------------------------------------------
		while (settings["leagues"] == ""){
			invalid_poesessid()
			download.chardata()
			get.accountname()
			get.leagues()
		}
		;-----------------------------------------------------------------
		get.logfile()
		select.default_league()
		update.settings_file()
		download.stashmetadata()
		get.tabs()
		download.itemdata()
		get.itemdata()
		;retrives raw stashdata for the default tab

		;-----------------------------------------------------------------
		;Update the settings file with the new values:
		;-----------------------------------------------------------------

		update.settings_file()

		;-----------------------------------------------------------------
	} else {

	;=====================================================================
	;If the settings DO already exist:
	;=====================================================================

		;-----------------------------------------------------------------
		;Update the array-stored settings based on the file data:
		;-----------------------------------------------------------------

		
		;Temporary:
		update.settings()
		select.default_league()
		update.settings_file()
		download.stashmetadata()
		get.tabs()
		download.itemdata()
		get.itemdata()

		;-----------------------------------------------------------------
	}

	;=====================================================================
	;In either case:
	;=====================================================================

	update.settings()

}

;=========================================================================
;= 			GUI, Overlay, and other visual stuff.
;=========================================================================

select_from_ddl(options,Titel = "Default"){
	global
	selection_to_return := ""
	Gui, +AlwaysOnTop
	; DropDownList:
	Gui, Add, DDL, gDDL_Selection vselection_to_return w350, % options
	; ListBox:
	; Gui, Add, ListBox, gDDL_Selection vselection_to_return w350, % options
	Gui, Show, , % Titel
	Loop{
		Sleep 100
	} Until (selection_to_return)
	return selection_to_return
}

DDL_Selection(default){
	global
	Gui, Submit ; or
	;Gui, Submit, NoHide   ; if you don't want to hide the gui-window after an action
	Gui, Destroy
}

;=========================================================================
;= 					Utility(Functions):
;=========================================================================

;-------------------------------------------------------------------------
;Ensures that things are done in the proper order:
;-------------------------------------------------------------------------
initialize_main(){
	download 	:= new downloads_
	get 		:= new gets_
	update 		:= new update_
	select 		:= new select_
}

;-------------------------------------------------------------------------
;Inputbox (function)
;-------------------------------------------------------------------------
Inputbox(Prompt = "", Default = "", HIDE = "", Title = ""){
	InputBox, OutputVar , %Title%, %Prompt%, %HIDE%, %Default%
	return OutputVar
}

;-------------------------------------------------------------------------
;Writes (array)contents file
;-------------------------------------------------------------------------
fileupdate(file,array){
	if FileExist(file){
		FileDelete, %file%
	}
	contents := ""
	For key, value in array{
		contents .=  key ": " value "`n"
	}
	FileAppend , %contents% , %file%	
}

;-------------------------------------------------------------------------
;Writes (file)contents to the array
;-------------------------------------------------------------------------
arrayupdate(array,file){
	Loop, Read, %file%
	{
		row := StrSplit(A_LoopReadLine, ": ")
		key := row[1]
		row.RemoveAt(1)
		if !(row[2]){
			array[key] := row[1]
		} else {
			array[key] := row
		}
	}
}

;-------------------------------------------------------------------------
;Remove excessive trailing zeroes
;-------------------------------------------------------------------------
Float( n, p:=6 ) { ; By SKAN on D1BM @ goo.gl/Q7zQG9
Return SubStr(n:=Format("{:0." p "f}",n),1,-1-p) . ((n:=RTrim(SubStr(n,1-p),0) ) ? "." . n : "") 
}

invalid_poesessid(){
	Messagetext := "You appear to have entered an invalid poesessid."
	Messagetext .= " Please try again.`n`nIf this message"
	Messagetext .= " keeps appearing even though you are certain to"
	Messagetext .= " have entered the correct value, please contact"
	Messagetext .= " me via reddit (neomachina), discord, ([ ]#3548)"
	Messagetext .= " or over the forums (EmperorIzaro). Try again?"
	MsgBox, 4, , %Messagetext%
	IfMsgBox, No
		ExitApp
	requestpoesessid()
}

;=========================================================================
;= 						Utility (Classes):
;=========================================================================

;=========================================================================
;= Download
;=========================================================================
class downloads_ {
	;---------------------------------------------------------------------
	;download character data
	;---------------------------------------------------------------------
	chardata(){
		;MsgBox, Trying to obtain chardata.
		file 	:= Mainfolder "\chardata.txt"
		if FileExist(file){
			FileDelete, %file%
		}
		link 	:= """"
		link 	.= "https://www.pathofexile.com/character-window/get-characters"
		link 	.= """"
		Run, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		if !(FileExist(file)){
			Loop{
				Sleep, 1000
			} Until (FileExist(file))
			Sleep, 1000
		}
	}
	;---------------------------------------------------------------------
	;download accountname
	;---------------------------------------------------------------------
	accountname(){
		;MsgBox, Trying to obtain accountname.
		file 	:= Mainfolder "\accountname.txt"
		file 	:= StrReplace(file," ","_")
		if FileExist(file){
			FileDelete, %file%
		}
		link 	:= """"
		link 	.= "https://www.pathofexile.com/character-window/get-account-name-by-character"
		link 	.= "?character=" get.character()
		link	.= """"
		Run, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		if !(FileExist(file)){
			Loop{
				Sleep, 1000
			} Until (FileExist(file))
			Sleep, 1000
		}
	}
	;---------------------------------------------------------------------
	;download stashmetadata
	;---------------------------------------------------------------------
	stashmetadata(){
		;MsgBox, % "Trying to obtain stashmetadata for " settings["default league"] 
		file 	:= Stashdata "\" settings["default league"] "\-stashmetadata.txt"
		file 	:= StrReplace(file," ","_")
		if FileExist(file){
			FileDelete, %file%
		}
		link 	:= """"""
		link 	.= "https://www.pathofexile.com/character-window/get-stash-items"
		link 	.= "?league=" settings["default league"]
		link 	.= "&accountName=" settings["accountname"]
		link 	.= "&tabs=1"
		link	.= """"""
		link 	:= StrReplace(link," ", "%20")
		;MsgBox, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		Run, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		if !(FileExist(file)){
			Loop{
				Sleep, 1000
			} Until (FileExist(file))
			Sleep, 1000
		}
	}
	;---------------------------------------------------------------------
	;download stash item data
	;---------------------------------------------------------------------
	itemdata(tab := "0"){
		tab 	:= settings["UI_Tab" tab]
		;MsgBox, % "Trying to obtain tab contents for tab"  tab " in " settings["default league"]
		file 	:= Stashdata "\"  settings["default league"] "\" "tab_" tab ".txt"
		file 	:= StrReplace(file," ","_")
		if FileExist(file){
			FileDelete, %file%
		}
		ink 	:= """"""
		link 	.= "https://www.pathofexile.com/character-window/get-stash-items"
		link 	.= "?league=" settings["default league"]
		link 	.= "&tabs=1"
		link 	.= "&tabIndex=" tab
		link 	.= "&accountName=" settings["accountname"]
		link	.= """"""
		link 	:= StrReplace(link," ", "%20")
		;MsgBox, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		Run, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		if !(FileExist(file)){
			Loop{
				Sleep, 1000
			} Until (FileExist(file))
			Sleep, 1000
		}
	}
}

;=========================================================================
;= "Get"
;=========================================================================
class gets_ {
	;---------------------------------------------------------------------
	logfile(){
	;---------------------------------------------------------------------
		Loop, Files, C:\*Grinding Gear Games , DFR
		 {	GGG := A_LoopFileFullPath 
		 	Loop, Files, %GGG%\Path of Exile\logs, DFR
		 	 {	logs := A_LoopFileFullPath
		 	 	;MsgBox, % "logs are in: " logs
		 	 	logfile := (FileExist(logs "\client.txt"))		 	 	
		 	} Until (logfile)
		} Until (GGG)&&(logfile)
		logfile := logs "\client.txt"
		;MsgBox, % "logfile is: " logs "\client.txt"
		if !(GGG)||!(logfile){
			Messagetext := "Could not find the Poe log (client.txt) file."
			Messagetext .= " You will have to enter its full path manually"
			Messagetext .= "  in the settings. The tool will now close."
			MsgBox, % Messagetext 
			ExitApp
		} else {
			settings["PoE_logfile"] := GGG "\client.txt"
			;MsgBox, % "logfile now is " settings["PoE_logfile"]
		}
	}
	;---------------------------------------------------------------------
	character(){
	;---------------------------------------------------------------------
		File 	:= chardata_file
		FileRead, contents, % File
		if InStr(contents,"<!DOCTYPE html>"){
			invalid_poesessid()
			makesettings(1)
		}
		chardata := JSON.Load(contents)
		return chardata[1]["name"]	
	}
	;---------------------------------------------------------------------
	accountname(){
	;---------------------------------------------------------------------
		download.accountname()		
		File 	:= accountname_file
		FileRead, contents, % File
		accdata := JSON.Load(contents)	
		FileDelete, % File
		settings["accountname"] := accdata["accountName"]
		update.settings_file()
		;MsgBox, % "Accountname is " settings["accountname"] 
	}
	;---------------------------------------------------------------------
	leagues(){
	;---------------------------------------------------------------------
		;MsgBox, % "Trying to obtain active leagues."	
		File 	:= chardata_file
		FileRead, contents, % File
		chardata := JSON.Load(contents)
		For key, value in chardata 
		  {	found := value["league"]
			if !(InStr(settings["leagues"],found)){
				settings["leagues"] .= "|" found
				Messagetext := "You appear to have characters in:	<"
				Messagetext .= found ">"
				Messagetext .= "`n`nWould you like to enable this league for use by"
				Messagetext .= " Stashpricer? If you chose not to, you can easily "
				Messagetext .= "add it later. Impact on performance should be minimal."
				if InStr(found,"SSF") {
					Messagetext .= "`n`n!! This is a SSF league. !!`n`nIf you chose to enable"
					Messagetext .= " it anyway, pricing will be based on its parent league."
				}
				MsgBox, 4, , %Messagetext%
				IfMsgBox, Yes 
				  {	settings["active leagues"] .= "|" found
					Folder 	:= Stashdata "\" found
					if !(InStr(FileExist(Folder),"D")){
						Folder 	:= StrReplace(Folder," ","_")
						FileCreateDir, %Folder%
					}
				}
			}
		}
		if (SubStr(settings["leagues"],1,1) == "|"){
			settings["leagues"] := SubStr(settings["leagues"],2)
		}
		if (SubStr(settings["active leagues"],1,1) == "|"){
			settings["active leagues"] := SubStr(settings["active leagues"],2)
		}
	}
	;---------------------------------------------------------------------
	tabs(){
	;---------------------------------------------------------------------
		File 	:= Stashdata "\" settings["default league"] "\-stashmetadata.txt" 
		file 	:= StrReplace(file," ","_")
		FileRead, contents, % File
		tabdata := JSON.Load(contents)	
		tabdata := tabdata["tabs"]
		;select which tab to use from tabdata. Read in the first 15 (!) entries	
		tabarray := tabdata 
		select.default_stashtab()
	}
	;---------------------------------------------------------------------
	itemdata(tab := "0"){
	;---------------------------------------------------------------------
		;Tab 	:= settings["UI_Tab" UITab]
		
		tab 	:= settings["UI_Tab" tab]

		;MsgBox, % "Tab about to be priced is " tab 

		File 	:= Stashdata "\" settings["default league"] "\tab_" tab ".txt" 
		file 	:= StrReplace(file," ","_")
		FileRead, contents, % File
		itemdata := JSON.Load(contents)	
		itemdata := itemdata["items"]
		;retrive itemdata, price if necessary.
		For key, value in itemdata
		 {  Messagetext := "Item Nr. is " key "`n"
		 	Messagetext .= "Dimesions are width: " value["w"] " height: " value["h"] "`n"
		 	Messagetext .= "Position is: x" value["x"] " y" value["y"] "`n`n"
		 	Messagetext .= value["name"] "`n"
		 	Messagetext .= value["typeLine"] "`n"
		 	If (0) {
			 	For key, val in value
			 	 {	Messagetext .= 	
			 	} 
		 	}
		 	MsgBox, % Messagetext
		}
		MsgBox, Program believes to have looked through all items.
	}
}

;=========================================================================
;= Update (Information)
;=========================================================================
class update_ {
	settings(){
		arrayupdate(settings,settingsfile)
	}
	settings_file(){
		fileupdate(settingsfile,settings)
	}
}

;=========================================================================
;= Select
;=========================================================================
class select_ {
	default_league(){
		Title 	:= "Please select your default League."
		settings["default league"]	:= select_from_ddl(settings["active leagues"] , Title)
	}
	default_stashtab(){
		tabselection 	:= ""
		For key, value in tabarray
		 {	if (A_Index<16) {
		 		MsgBox, % "Found Tab: " A_Index - 1 ": " tabarray[key]["n"]
		 		MsgBox, % "Type is " tabarray[key]["type"]
		 		tabvalidity  := (tabarray[key]["type"] == "PremiumStash")
		 		tabvalidity  .= (tabarray[key]["type"] == "NormalStash")
		 		tabvalidity  .= (tabarray[key]["type"] == "QuadStash")
		 		MsgBox, % "validity is " tabvalidity
		 		if (tabvalidity){
		 			tabselection .= "|" A_Index - 1 ": " tabarray[key]["n"] 
		 		}
		 	} 
		}
		if (SubStr(tabselection,1,1) == "|"){
			tabselection := SubStr(tabselection,2)
		}
		;MsgBox, % "Tabselection wound up being: " tabselection
		Title 	:= "Please select your default stashtab."
		selected := select_from_ddl(tabselection , Title)
		selected := SubStr(selected,1,2)
		;MsgBox, % "returning " StrReplace(selected,":","")
		settings["UI_Tab0"]	 := StrReplace(selected,":","")
	}
}
