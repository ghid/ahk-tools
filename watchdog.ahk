; ahk: console
#NoEnv
#Persistent

#Include <app>
#Include <lib2>

class Watchdog {

	static handleOfCurrentConsoleWindow := WinExist("A")
	static comSpec := ""
	static directoriesToObserve := {}
	static commandToExecute := ""
	static interval := 1000
	static timer := Watchdog.checkIfSomethingWasChanged.bind(Watchdog)

	requires() {
		return [Ansi]
	}

	run(cmdLineArguments) {
		Watchdog.comSpec := System.envGet("comspec")
		Watchdog.directoriesToObserve := WatchDog.findDirectories()
		Ansi.writeLine("Watching %i director%s"
				.printf(Watchdog.directoriesToObserve.count()
				, Watchdog.directoriesToObserve.count() == 1 ? "y" : "ies" ))
		Watchdog.commandToExecute := Arrays.toString(cmdLineArguments)
		Ansi.writeLine("Running %s".printf(Watchdog.commandToExecute))
		Watchdog.startTimer()
		_handleOfCurrentConsoleWindow := Watchdog.handleOfCurrentConsoleWindow
		HotKey, IfWinActive, ahk_id %_handleOfCurrentConsoleWindow%
		Hotkey q, quitWatchdog
		Hotkey r, executeWatchdogCommand
		Hotkey Space, toggleWatchdog
		Hotkey h, printHelp
	}

	findDirectories() {
		dirs := {}
		FileGetTime workingDirFileTime, %A_WorkingDir%
		dirs[A_WorkingDir] := workingDirFileTime
		loop Files, *.*, DR
		{
			if (!RegExMatch(A_LoopFileFullPath
					, "(^|\\)\.git|\.svn|\node_modules(\\|$)")) {
				dirs[A_LoopFileFullPath] := A_LoopFileTimeModified
			}
		}
		return dirs
	}

	startTimer() {
		timer := Watchdog.timer
		SetTimer % timer, % Watchdog.interval
	}

	stopTimer() {
		timer := Watchdog.timer
		SetTimer % timer, Off
	}

	checkIfSomethingWasChanged() {
		dirs := Watchdog.findDirectories()
		for filePath, fileTime in dirs {
			if (Watchdog.directoriesToObserve[filePath] != fileTime) {
				Ansi.writeLine(filePath " was changed")
				Watchdog.executeCommand()
				Watchdog.directoriesToObserve := dirs
				return
			}
		}
	}

	executeCommand() {
		static magenta := Ansi.setGraphic(Ansi.FOREGROUND_MAGENTA)
		static blue := Ansi.setGraphic(Ansi.FOREGROUND_BLUE)
		static cyan := Ansi.setGraphic(Ansi.FOREGROUND_CYAN)
		Watchdog.stopTimer()
		sysComSpec := Watchdog.comSpec
		commandToExecute := Watchdog.commandToExecute
		RunWait %sysComSpec% /c "%commandToExecute%",, Hide
		Ansi.writeLine(magenta "> " blue "Stopped at "
				. cyan A_Hour ":" A_Min ":" A_Sec "." A_MSec
				. Ansi.reset())
		Watchdog.startTimer()
	}
}

quitWatchdog() {
	Watchdog.stopTimer()
	Ansi.flush()
	Ansi.stdIn.write(0)
	exitapp
}

executeWatchdogCommand() {
	Watchdog.executeCommand()
}

toggleWatchdog() {
	static red := Ansi.setGraphic(Ansi.FOREGROUND_RED)
	static paused := false
	if (paused) {
		WatchDog.directoriesToObserve := Watchdog.findDirectories()
		Ansi.write(Ansi.cursorHorizontalAbs(1) Ansi.eraseLine())
		Watchdog.startTimer()
	} else {
		Ansi.write(Ansi.cursorHorizontalAbs(1) Ansi.eraseLine())
		Ansi.write(red "-- Watchdog paused --" Ansi.reset())
		Watchdog.stopTimer()
	}
	paused := !paused
}

printHelp() {
	Ansi.writeLine("Space: Toggle Watchdog   r: Run Watchdog Command   q: Quit Watchdog") ; ahklint-ignore: W002
}

Main:
	App.checkRequiredClasses(Watchdog)
	Ansi.NO_BUFFER := true
    Watchdog.run(A_Args)
return
