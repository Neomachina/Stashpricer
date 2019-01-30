#Singleinstance, Force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Stashpricer_files\Scripts\JSON.ahk
#Include Stashpricer_files\Scripts\Stashpricer_Download.ahk

;==========================================================================
;= 							globals:
;==========================================================================

MsgBox, Test 1 2