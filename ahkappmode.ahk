;@Ahk2Exe-ConsoleApp

class AhkAppMode {

    requires() {
        return [App, Ansi, OptParser]
    }

    static options := { help: false
            , version: false
            , check: false }
    
    run(cmdLineArguments) {
        returnCode := ""
        try {
            op := AhkAppMode.cli()
            remainingArguments := op.parse(cmdLineArguments)
            if (remainingArguments.count() == 0 || AhkAppMode.options.help) {
                Ansi.writeLine(op.usage())
			} else if (AhkAppMode.options.version) {
				Ansi.writeLine(AhkAppMode.versionInfo())
            } else if (AhkAppMode.options.check) {
                returnCode := AhkAppMode.checkModes(remainingArguments)
			} else {
				returnCode := AhkAppMode.changeModes(remainingArguments)
			}
		} catch gotException {
			Ansi.writeLine(gotException.message)
			returnCode := 1
		}
		return returnCode
    }

    cli() {
        op := new OptParser(["ahkappmode [options] <executable> [[executable]...]"
                , "ahkappmode -c <executable> [[executable]...]"])
        op.add(new OptParser.Group("Options:"))
        op.add(new OptParser.Boolean("c", "check"
                , AhkAppMode.options, "check"
                , "Check and print actual mode of the executable"))
        op.add(new OptParser.Boolean("h", "help"
                , AhkAppMode.options, "help"
				, "This help", OptParser.OPT_HIDDEN))
        return op
    }

    versionInfo() {
        return ""
    }

    checkModes(executableNames) {
        for _, executableName in executableNames {
            Ansi.writeLine((executableNames.count() > 1
                    ? executableName " " : "")
                    . AhkAppMode.checkMode(executableName))
        }
        return 0
    }

    checkMode(executableName) {
        if (!FileExist(executableName) 
                || InStr(FileExist(executableName), "D")) {
            AhkAppMode.throwError(executableName ": File does not exist")

        }
        try {
            if (!(file := FileOpen(executableName, "rw", "cp0"))) {
                AhkAppMode.throwError(executableName ": File can not be opened for writing!")
            }

            file.seek(0x3c, 0)
            offset := file.readUInt()+4
            file.seek(offset-4, 0)
            if (file.read(2) != "PE" || file.readUShort() != 0) {
                AhkAppMode.throwError(executableName ": File is not an application!")
            }
            
            file.seek(offset+16, 0)
            if (!(optHdrSize := file.readUShort())) {
                AhkAppMode .throwError(executableName ": File does not contain an optional header!")
            }
            
            file.seek(offset+20, 0)
            type := file.readUShort()
            if (type != 0x10b && type != 0x20b) 	{
                AhkAppMode.throwError(executableName ": File may not be compiled for x86 or x64 systems!")
            }

            file.seek(offset+88, 0)
            currentSubsystem := file.readUShort()
            if (currentSubsystem < 2 || currentSubsystem > 3) {
                AhkAppMode.throwError(executableName ": Mode is neither GUI nor CUI")
            }

            return (currentSubsystem == 2 ? "GUI" : "CUI")
        } catch gotException {
            throw gotException
        } finally {
            file.close()
        }
    }

    changeModes(executableNames) {
        for _, executableName in executableNames {
            Ansi.writeLine((executableNames.count() > 1
                    ? executableName " " : "")
                    . AhkAppMode.changeMode(executableName))
        }
        return 0
    }

    changeMode(executableName) {
        try {
            targetMode := (AhkAppMode
                    .checkMode(executableName) = "CUI" ? "GUI" : "CUI")
            file := FileOpen(executableName, "rw", "cp0")
            file.seek(0x3c, 0)
            offset := file.readUInt()+4
            file.seek(offset+88, 0)
            file.writeUShort((targetMode = "GUI") ? 2 : 3)	
        } catch gotException {
            throw gotException
        } finally {
            file.close()
        }
        return "Changed mode to " targetMode
    }

    throwError(message) {
        throw { Message: message, Extra: "Error" }
    }
}

#NoEnv
#NoTrayIcon
#SingleInstance Off
ListLines Off
SetBatchLines -1

#Include <app>
#Include <cui-libs>

main:
exitapp App.checkRequiredClasses(AhkAppMode).run(A_Args)
