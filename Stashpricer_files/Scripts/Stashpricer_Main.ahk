#Singleinstance, Force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Stashpricer_files\Scripts\JSON.ahk

;==========================================================================
;= 							globals:
;==========================================================================
global words_of_warning 	:= 1
global version				:= "dev.04.05"
global settings 			:= {}

;SplitPath, InputVar , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

global Mainfolder			:= A_WorkingDir 
SplitPath, Mainfolder, ,Mainfolder

global Stashdata			:= Mainfolder "\Stashdata"
global Images 				:= Mainfolder "\Images"
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
global tabindex				:= ""	;stores index of the tab to display an overlay for
global frameTypearray 		:= ["","Rare"] ;defintion of frameTypes
global itemarray			:= ""	;stores item information at runtime

;==========================================================================
;=               			Startup
;==========================================================================
initialize_main()
MsgBox, Press ctrl+i for information on hotkeys. 
check_for_is_recent_update()
makesettings()


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
;= 							Hotkeys:
;==========================================================================

^i::
{
	Messagetext := "Hotkeys are:"
	Messagetext .= "`nClose the tool completely: ctrl+x"
	Messagetext .= "`nToggle current overlay: ctrl+t"
	MsgBox, % Messagetext
}
return

^WheelDown::
{
	;cycles through overlays
	;Msgbox, scrolled
} return

~^+c::
{       
	;makes the tab containing the item copied the default tab
} return

^!0::
{
	;show menu	
} return

^!6::
{
	select.default_stashtab(6)
	update.settings_file()
	download.itemdata(6)
	get.itemdata(6)
} return

^!7::
{
	select.default_stashtab(7)
	update.settings_file()
	download.itemdata(7)
	get.itemdata(7)
} return

^!8::
{
	select.default_stashtab(8)
	update.settings_file()
	download.itemdata(8)
	get.itemdata(8)
} return

^!9::
{
	select.default_stashtab(9)
	update.settings_file()
	download.itemdata(9)
	get.itemdata(9)
} return

^t::
{
	;Msgbox, % "Test" settings["ScreenHeight"] " // " settings["ScreenWidth"]	
	draw_gui()
} return

^x::
{
	ExitApp
} return

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
		settings["ScreenWidth"]		:= A_ScreenWidth
		settings["ScreenHeight"]	:= A_ScreenHeight
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
		if !(settings["default league"]){
			select.default_league()
			update.settings_file()
		}
		download.stashmetadata()
		get.tabs()
		download.itemdata()
		get.itemdata()
		get.logfile()
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
		if !(settings["default league"]){
			select.default_league()
			update.settings_file()
		}
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

draw_gui(tab = 0){
	OL_active := !(OL_active)
	if (OL_active){
		swidth 	:= settings["ScreenWidth"]
		sheight := settings["ScreenHeight"] 
		Pic1 = %Images%\border.png
		Gui, +AlwaysOnTop +ToolWindow -Caption +LastFound
		Gui, Color, 000000
		Gui, Margin, 0, 0
		Gui, Add, Picture, w-1 h%sheight%, %Pic1%
		winset, transcolor, 000000 200 
		Gui, Show, x0 y0, WinTitle
	} else {
		Gui, Hide
	}
}


select_from_ddl(options,Titel = "Default"){
	global
	selection_to_return := ""
	Gui, +AlwaysOnTop
	; DropDownList:
	Gui, Add, DDL, gDDL_Selection vselection_to_return w450, % options
	; ListBox:
	; Gui, Add, ListBox, gDDL_Selection vselection_to_return w450, % options
	Gui, Show, , % Titel
	Loop{
		Sleep 100
	} Until (selection_to_return)
	return selection_to_return
}

DDL_Selection(default){
	global
	;Gui, Submit ; or
	Gui, Submit, NoHide   ; if you don't want to hide the gui-window after an action
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

;--------------------------------------------------------------------------
;Encoder, Plagiarized from trademacro (POE-ItemInfo.ahk), hope that's okay, I needed it
;--------------------------------------------------------------------------

;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
	StrPutVar(Str, ByRef Var, Enc = "") {
		Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
		VarSetCapacity(Var, Len, 0)
		Return, StrPut(Str, &Var, Enc)
	}
	UriEncode(Uri, Enc = "UTF-8")	{
		StrPutVar(Uri, Var, Enc)
		f := A_FormatInteger
		SetFormat, IntegerFast, H
		Loop
		{
			Code := NumGet(Var, A_Index - 1, "UChar")
			If (!Code)
				Break
			If (Code >= 0x30 && Code <= 0x39 ; 0-9
				|| Code >= 0x41 && Code <= 0x5A ; A-Z
				|| Code >= 0x61 && Code <= 0x7A) ; a-z
				Res .= Chr(Code)
			Else
				Res .= "%" . SubStr(Code + 0x100, -1)
		}
		SetFormat, IntegerFast, %f%
		Return, Res
	}
	ReadConsoleOutputFromFile(command, fileName, ByRef error = "") {
		file := "temp\" fileName
		RunWait %comspec% /c "chcp 1251 /f >nul 2>&1 & %command% > %file%", , Hide
		FileRead, io, %file%
		
		If (FileExist(file) and not StrLen(io)) {
			error := "Output file is empty."
		}
		Else If (not FileExist(file)) {
			error := "Output file does not exist."
		}
		
		Return io
	}
	b64Encode(string, ByRef error = "") {	
		VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1 
		If !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size)) {
			;throw Exception("CryptBinaryToString failed", -1)
			error := "Exception (1) while encoding string to base64."
		}	
		VarSetCapacity(buf, size << 1, 0)
		If !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size)) {
			;throw Exception("CryptBinaryToString failed", -1)
			error := "Exception (2) while encoding string to base64."
		}	
		If (not StrLen(Error)) {
			Return StrGet(&buf)
		} Else {
			Return ""
		}
	}
	StringToBase64UriEncoded(stringIn, noUriEncode = false, ByRef errorMessage = "") {
		FileDelete, %A_ScriptDir%\temp\itemText.txt
		FileDelete, %A_ScriptDir%\temp\base64Itemtext.txt
		FileDelete, %A_ScriptDir%\temp\encodeToBase64.txt	
		encodeError1 := ""
		encodeError2 := ""
		stringBase64 := b64Encode(stringIn, encodeError1)	
		If (not StrLen(stringBase64)) {
			FileAppend, %stringIn%, %A_ScriptDir%\temp\itemText.txt, utf-8
			command		:= "certutil -encode -f ""%cd%\temp\itemText.txt"" ""%cd%\temp\base64ItemText.txt"" & type ""%cd%\temp\base64ItemText.txt"""
			stringBase64	:= ReadConsoleOutputFromFile(command, "encodeToBase64.txt", encodeError2)
			stringBase64	:= Trim(RegExReplace(stringBase64, "i)-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----|77u/", ""))
		}
		If (not StrLen(stringBase64)) {
			errorMessage := ""
			If (StrLen(encodeError1)) {
				errorMessage .= encodeError1 " "
			}
			If (StrLen(encodeError2)) {
				errorMessage .= "Encoding via certutil returned: " encodeError2
			}
		}	
		If (not noUriEncode) {
			stringBase64	:= UriEncode(stringBase64)
			stringBase64	:= RegExReplace(stringBase64, "i)^(%0D)?(%0A)?|((%0D)?(%0A)?)+$", "")
		} Else {
			stringBase64 := RegExReplace(stringBase64, "i)\r|\n", "")
		}	
		Return stringBase64
	}
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------

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
		MsgBox, % "Trying to obtain tab contents for tab"  tab " in " settings["default league"]
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
		if !(settings["accountname"]){
			Title 		:= "Please enter your accountname below."
			Messagetext	:= "Failed to automatically retrieve your accountname."
			Messagetext .= " A likely cause for this is (one of) your characters"
			Messagetext .= " being set to private. You will have to manually "
			Messagetext .= " enter your accountname in the field below."
			settings["accountname"]	:= InputBox(Messagetext,,,Title)
		}
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
		if !(settings["UI_Tab0"]){
			select.default_stashtab()
		}
	}
	;---------------------------------------------------------------------
	price(itemtext){
	;---------------------------------------------------------------------
		;MsgBox, % "About to try to get pricetag"
		encodedtext 	:= StringToBase64UriEncoded(itemtext, true, encodingError)
		link := "https://www.poeprices.info/api"
		link .= "?l=" settings["default league"]
		link .= "&i=" encodedtext 
		link .= "&s=" "Stashpricer"
		;MsgBox, % "Link is: " link
		Try
		 {	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			whr.Open("GET", link, true)
			whr.Send()
			whr.WaitForResponse()
			returned := whr.ResponseText
			;MsgBox, % "About to return" returned 
			Sleep, 1000
		}
		return returned
	}
	;---------------------------------------------------------------------
	itemdata(tab := "0"){
	;---------------------------------------------------------------------	
		;Msgbox, % "Getting itemdata for tab " tab
		;================================================================
		; which tab is to be priced?
		;================================================================
		tab 	:= settings["UI_Tab" tab]
		File 	:= Stashdata "\" settings["default league"] "\tab_" tab ".txt" 
		File 	:= StrReplace(file," ","_")
		;================================================================
		; get the item info
		;================================================================
		FileRead, contents, % File
		tabdata := JSON.Load(contents)	
		itemdata := tabdata["items"]
		;================================================================
		; get the pricetag info
		;================================================================


		priceddata := [[{}]]
		Try {
			PriceFile 	:= Stashdata "\" settings["default league"] "\tab_" tab "_priceddata.txt"
			PriceFile 	:= StrReplace(PriceFile," ","_")
			FileRead, contents, % PriceFile
			priceddata := JSON.Load(contents)
		} 
		;================================================================
		; process the items, one by one
		For INr, item in itemdata
		 {  Itemtext := ""
		 	;Rarity, name, typeline:
		 	;-------------------------------------------------------------
		 	if (frameTypearray[item["frameType"]]){
		 		Itemtext .= "Rarity: " frameTypearray[item["frameType"]] "`n"
		 	}
		 	if (item["name"]){
		 		Itemtext .= item["name"] "`n"
		 	}
		 	if (item["typeline"]){
		 		Itemtext .= item["typeLine"] "`n"
		 	}
		 	;-------------------------------------------------------------
		 	;Properties:
		 	;-------------------------------------------------------------
		 	if (item["properties"]) {
		 		Itemtext 	.= "--------`n"
		 		For property, description in item["properties"]
		 		 {	Itemtext .= description["name"] ": " 
		 		 	For Nr, value in description["values"]
		 		 	 {	Itemtext .= value[1]	
		 		 	}
		 		 	Itemtext .= "`n"
		 		}
		 	}
		 	;-------------------------------------------------------------
		 	;Requirements:
		 	;-------------------------------------------------------------
		 	if (item["requirements"]) {
		 		Itemtext 	.= "--------`n"
		 		Itemtext 	.= "Requirements:`n"
		 		For requirement, description in item["requirements"]
		 		 {	Itemtext .= description["name"] ": " 
		 		 	For Nr, value in description["values"]
		 		 	 {	Itemtext .= value[1] 
		 		 	}
		 		 	Itemtext .= "`n"
		 		}
		 	}
		 	;-------------------------------------------------------------
		 	;Sockets:
		 	;-------------------------------------------------------------
		 	if (item["sockets"]){
		 		Itemtext 	.= "--------`n"
		 		Itemtext 	.= "Sockets: "
		 		currentgroup 	:= "0"
		 		firstsocket 	:= true
		 		For socket, values in item["sockets"]
		 		 {	if !(firstsocket){
		 		 		if !(currentgroup == values["group"]){
							Itemtext .= " "
							currentgroup .= values["group"]
						} else {
							Itemtext .= "-"
						}
		 		 	} else {
		 		 		firstsocket := false
		 		 	}
		 		 	Itemtext .= values["sColour"]	
		 		}
		 		Itemtext 	.= "`n"
		 	}
		 	;-------------------------------------------------------------
		 	;Item Level:
		 	;-------------------------------------------------------------
		 	if (item["ilvl"]){
		 		Itemtext .= "--------`n"
		 		Itemtext .= "Item Level: " item["ilvl"] "`n"
		 	}
		 	;-------------------------------------------------------------
		 	;Implicit mods:
		 	;-------------------------------------------------------------
		 	if (item["implicitMods"]){
		 		Itemtext .= "--------`n"
		 		For mod, description in item["implicitMods"]
		 		 {	Itemtext .= description "`n"
		 		}
		 	}
		 	;-------------------------------------------------------------
		 	;Unidentified:
		 	;-------------------------------------------------------------
		 	if !(item["identified"]){
		 		Itemtext .= "--------`n"
		 		Itemtext .= "Unidentified`n"
		 	}
		 	;-------------------------------------------------------------
			;Properly use the "-------" sepparator between mod types
			;-------------------------------------------------------------
			if (item["explicitMods"])||(item["craftedMods"]){
				Itemtext .= "--------`n"
			}
		 	;-------------------------------------------------------------
		 	;Explicit mods:
		 	;-------------------------------------------------------------
		 	if (item["explicitMods"]){
		 		For mod, description in item["explicitMods"]
		 		 {	Itemtext .= description "`n"
		 		}
		 	}
		 	;-------------------------------------------------------------
		 	;Crafted mods:
		 	;-------------------------------------------------------------
		 	if (item["craftedMods"]){
		 		For mod, description in item["craftedMods"]
		 		 {	Itemtext .= description "`n"
		 		}
		 	}
		 	;-------------------------------------------------------------
		 	;Description:
		 	;-------------------------------------------------------------
		 	if (item["descrText"]){
		 		Itemtext .= "--------`n"
		 		Itemtext .= item["descrText"] "`n"
		 	}
		 	;-------------------------------------------------------------
		 	;Corrupted:
		 	;-------------------------------------------------------------
		 	if (item["corrupted"]){
		 		Itemtext .= "--------`n"
		 		Itemtext .= "Corrupted`n"
		 	}
		 	;-------------------------------------------------------------
		 	;Shaper/Elder:
		 	;-------------------------------------------------------------
		 	if (item["shaper"]){
		 		Itemtext .= "--------`n"
		 		Itemtext .= "Shaper Item"
		 	}
		 	if (item["elder"]){
		 		Itemtext .= "--------`n"
		 		Itemtext .= "Elder Item"
		 	}
		 	;-------------------------------------------------------------
		 	;-------------------------------------------------------------
			timestamp := A_DD * 100 + A_Hour // 5

			item["x"] += 1
		 	item["y"] += 1

			;MsgBox, % "Timestamp is: " timestamp "Position are: " item["x"] ", " item["y"]
			;-------------------------------------------------------------
		 	;itemarray holds the compiled, OLD information, by the end of this it should be updated
		 	;"item" is from the NEW raw data
		 	;priceddata is from the OLD priced information, by the end of this it should be updated
	
		 	;-------------------------------------------------------------
		 	if (item["identified"])&&(item["frameType"]==2){
		 		;MsgBox, % "Item is rare and identified."
		 		;MsgBox, % "Itemtext is:`n`n" Itemtext
		 		if (priceddata[item["x"], item["y"], "item"] == item){
		 			;---------------------------------------------------------
		 			;Msgbox, new item has an exact match in old items
		 			;---------------------------------------------------------
		 			if !(priceddata[item["x"], item["y"], "timestamp"] == timestamp){
		 				;---------------------------------------------------------
		 				;Msgbox, the timestamp of the exact match is outdated => reprice
		 				;---------------------------------------------------------
		 				priceddata[item["x"], item["y"], "priceinfo"] := get.price(Itemtext)
		 				;Msgbox, % "new priceinfo is`n`n" priceddata[item["x"], item["y"], "priceinfo"]
		 				priceddata[item["x"], item["y"], "timestamp"] := timestamp
		 			} else {
		 				;---------------------------------------------------------
		 				;Msgbox, timestamp is up2date, do nothing
		 				;---------------------------------------------------------
		 			}
		 		} else {
		 			;---------------------------------------------------------
		 			;Msgbox, new item has no exact match in old items
		 			;---------------------------------------------------------
		 			For x , y in pricedata
	 				 { if (pricedata[x, y, "item"] == item){
	 				 		;---------------------------------------------------------
	 				 		;Msgbox, there was a match with different x/y values
	 				 		;---------------------------------------------------------
	 				 		priceddata[item["x"], item["y"], "item"] := item 				 		
	 				 		priceddata[item["x"], item["y"], "timestamp"]:= priceddata[x, y, "timestamp"]
	 				 	}
	 				 	;Msgbox, looped 
	 				}
	 				if !(priceddata[item["x"], item["y"], "timestamp"] == timestamp){
		 				;---------------------------------------------------------
		 				;Msgbox, the timestamp of the found match is outdated => reprice
		 				;---------------------------------------------------------
		 				priceddata[item["x"], item["y"], "priceinfo"] := get.price(Itemtext)
		 				priceddata[item["x"], item["y"], "timestamp"] := timestamp
		 				priceddata[item["x"], item["y"], "item"] := item
		 			} else {
		 				;---------------------------------------------------------
		 				;Msgbox, timestamp is up2date, do nothing
		 				priceddata[item["x"], item["y"], "item"] := item
		 				;---------------------------------------------------------
		 			}
		 		}
		 		Messagetext := Itemtext 
		 		Messagetext .= "`n---------------------------------------------------------`n"
		 		Messagetext .= "At position: " item["x"] "/" item["y"]
		 		Messagetext .= "`n---------------------------------------------------------`n"
		 		Messagetext .= priceddata[item["x"], item["y"], "priceinfo"]
		 		;Msgbox, % Messagetext
		 	}
		}
		FileDelete, % PriceFile
		Try{
			contents := JSON.Dump(priceddata)
		}
		itemarray := priceddata
		;Msgbox, % itemarray[12, 1, "timestamp"]
		FileAppend, %contents%, %PriceFile%
		MsgBox, Program believes to have looked through all items.
	}
}

;=========================================================================
;= Update (Information)
;=========================================================================
class update_ {
	settings(){
		arrayupdate(settings,settingsfile)
		;Msgbox, Updated settings.
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
	default_stashtab(slot = 0){
		tabselection 	:= ""
		For key, value in tabarray
		 {	if (A_Index<16) {
		 		;MsgBox, % "Found Tab: " A_Index - 1 ": " tabarray[key]["n"]
		 		;MsgBox, % "Type is " tabarray[key]["type"]
		 		tabvalidity  := (tabarray[key]["type"] == "PremiumStash")
		 		tabvalidity  .= (tabarray[key]["type"] == "NormalStash")
		 		tabvalidity  .= (tabarray[key]["type"] == "QuadStash")
		 		;MsgBox, % "validity is " tabvalidity
		 		if (tabvalidity){
		 			tabselection .= "|" A_Index - 1 ": " tabarray[key]["n"] 
		 		}
		 	} 
		}
		if (SubStr(tabselection,1,1) == "|"){
			tabselection := SubStr(tabselection,2)
		}
		;MsgBox, % "Tabselection wound up being: " tabselection
		Title 	:= "Please select a stashtab to assign to slot " slot "."
		selected := select_from_ddl(tabselection , Title)
		selected := SubStr(selected,1,2)
		;MsgBox, % "returning " StrReplace(selected,":","")
		settings["UI_Tab"slot]	 := StrReplace(selected,":","")
	}
}
