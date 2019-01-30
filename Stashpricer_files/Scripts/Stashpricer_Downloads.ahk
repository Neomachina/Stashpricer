
;=========================================================================
;= Download
;=========================================================================
class downloads_ {
	;---------------------------------------------------------------------
	;download character data
	;---------------------------------------------------------------------
	chardata(){
		file 	:= Mainfolder "\chardata.txt"
		if FileExist(file){
			FileDelete, %file%
		}
		link 	:= """"
		link 	.= "https://www.pathofexile.com/character-window/get-characters"
		link 	.= """"
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
		Run, % vbsfile " " batfile " " link " " settings["poesessid"] " " file 
		if !(FileExist(file)){
			Loop{
				Sleep, 1000
			} Until (FileExist(file))
			Sleep, 1000
		}
	}
}
