target = chr(34) & WScript.Arguments.Item(0) & chr(34)
link = chr(34) & chr(34) & WScript.Arguments.Item(1) & chr(34) & chr(34)
poesessid = chr(34) & WScript.Arguments.Item(2) & chr(34)
file = chr(34) & WScript.Arguments.Item(3) & chr(34)
command = target & " " & link & " " & poesessid & " " & file
command = Replace(command,"=","""=""")
command = Replace(command,"&","""&""")
Set WshShell = CreateObject("Wscript.Shell")
WshShell.Run command,0,True