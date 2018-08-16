/*
:encoding=UTF-8:
:mode=AutoHotkey:
:folding=explicit:
*/

#Include <logging>
#Include <string>
#Include <system>

Main:
	Exit_Code := 0

	if (System.vArgs.MaxIndex() = 2) {
		FileAppend, % "Change " System.vArgs[1] " to mode " System.vArgs[2].Upper() "...`n", *
		try {
			file := Check_File(System.vArgs[1], System.vArgs[2])
			if (Change_File(file, System.vArgs[2]) = 2)
				FileAppend, % "Mode changed successfully!`n`n", *
			else
				FileAppend, % "Error changing mode!`n`n", *
		} catch Ex {
			Message := Ex.Message "`n`n"
			FileAppend, %Message%, *
			Exit_Code := 1
		}
	} else
		goto AppModeChangerGui

exitapp Exit_Code

;{{{ AppModeChangerGui
AppModeChangerGui:
	Gui, add, text, x10 y10 w400, Application Path (executable)
	Gui, add, edit, xp y+10 wp vExecutable, % A_ScriptDir
	Gui, add, button, x+5 yp w80 hp gBrowse, Browse...
	Gui, add, text, x10 y+20 w400, Application Mode
	Gui, add, radio, xp y+10 wp +checked vGUI, GUI-Application (GUI)
	Gui, add, radio, xp y+5 wp vCUI, Console-Application (CUI)
	Gui, add, button, xp y+20 w150 gChange, Change Mode
	Gui, margin, 10, 10
	Gui, -MaximizeBox -MinimizeBox
	Gui, show,, AppMode changer v1.0
return
;}}}

;{{{ GuiClose
GuiClose:
exitapp
;}}}

;{{{ Browse
Browse:
	GuiControlGet, Executable
	FileSelectFile, file, 1, % Executable, % "Select an executable...", % "Application (*.exe)"
	if (file)
		 GuiControl,, Executable, % file
return
;}}}

;{{{ Change
Change:
	GuiControlGet, Executable
	GuiControlGet, GUI
	mode := (GUI) ? "GUI" : "CUI"
	try {
		file := Check_File(Executable, mode)
		if (Change_File(file, mode) = 2)
			MsgBox, 64, Info, % "Mode changed successfully!"
		else
			MsgBox, 16, Error, % "Error changing mode!"
	} catch Ex {
		Extra := Ex.Extra
		Message := Ex.Message
		
		if (Extra = "Error")
			Icon_Code := 16
		else if (Extra = "Warning")
			Icon_Code := 48
		else
			Icon_Code := 0
		
		MsgBox, % Icon_Code, % Extra, % Message
		Exit_Code := 1
	}
	
	if (file)
		file.close()
return
;}}}

;{{{ Check_File
Check_File(Executable, mode) {
	if (!FileExist(Executable) || InStr(FileExist(Executable), "D")) {
		throw { Message: "The selected file does not exist!", Extra: "Error" }
	}
	
	if (!(file := FileOpen(Executable, "rw", "cp0"))) {
		throw { Message: "The selected file can not be opened for writing!", Extra: "Error" }
	}
	
	file.seek(0x3c, 0)
	peOffset := file.readUInt()+4
	file.seek(peOffset-4, 0)
	if (file.read(2) <> "PE" || file.readUShort() <> 0) {
		throw { Message: "The selected file is not an application!", Extra: "Error"}
	}
	
	file.seek(peOffset+16, 0)
	if (!(optHdrSize := file.readUShort())) {
		throw { Message: "The selected file does not contain an optianal header!", Extra: "Error" }
	}
	
	file.seek(peOffset+20, 0)
	type := file.readUShort()
	if (type <> 0x10b && type <> 0x20b) 	{
		throw { Message: "The selecte file may not be compiled for x86 or x64 systems!", Extra: "Error" }
	}
	file.seek(peOffset+88, 0)
	currentSubsystem := file.readUShort()
	if ((currentSubsystem = 2 && mode="GUI") || (currentSubsystem = 3 && mode = "CUI")) {
		throw { Message: "The selected file has already the mode (" mode ") you have selected!", Extra: "Warning" }
	}
	
	if (currentSubsystem <> 2 && currentSubsystem <> 3) {
		throw { Message: "The mode of the executable must be Windows GUI or CUI to change it!", Extra: "Error" }
	}

	return file	
}
;}}}

;{{{ Change_File
Change_File(file, mode) {
	file.seek(0x3c, 0)
	peOffset := file.readUInt()+4
	file.seek(peOffset+88, 0)
	
	return file.writeUShort((mode = "GUI") ? 2 : 3)	
}
;}}}

