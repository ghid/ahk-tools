;@Ahk2Exe-ConsoleApp

/*
set AHK_LIB=%userprofile%\Documents\AutoHotkey\lib

if not exist .\modules\ (
    echo Plaese run from lib's base dir...
    goto:eof
)

if exist %1 (
    for /D %%s in (%1) do (
        set module_name=%%~ns
        goto:synch
    )
)
if exist %1.ahk (
    set module_name=%1
    goto:synch
)

:synch
set exclude=
if exist .\modules\%module_name%\xcopy.ignore (
    set exclude=/EXCLUDE:.\modules\%module_name%\xcopy.ignore
    xecho -n "$E[1mThe following file(s) will be ignored (xcopy.ignore):"
    xecho -n "$E[96m.\modules\%module_name%\xcopy.ignore:"
    type .\modules\%module_name%\xcopy.ignore
    echo.
)
if exist "%AHK_LIB%\%module_name%.ahk" (
    attrib -R "%AHK_LIB%\%module_name%.ahk"
)
copy .\%module_name%.ahk "%AHK_LIB%\%module_name%.ahk"
if exist .\modules\%module_name%\*.ahk (
    if not exist "%AHK_LIB%\modules\%module_name%\" (
        mkdir "%AHK_LIB%\modules\%module_name%\"
    )
    attrib -R "%AHK_LIB%\modules\%module_name%\*.*" /S
    xcopy .\modules\%module_name%\*.ahk "%AHK_LIB%\modules\%module_name%\" /D /E %exclude%
)
attrib +R "%AHK_LIB%\*.*" /S
goto:eof
*/

class AhkDist {

    static options := AhkDist.setDefaults()

    setDefaults() {
        EnvGet profile, USERPROFILE
        return { verbose: false
                , whatif: false
                , AHK_LIB: AhkDist.getUserProfileDir()
                . "\Documents\AutoHotkey\lib" }
    }

    getUserProfileDir() {
        EnvGet userProfile, USERPROFILE
        if (!userProfile) {
            throw Exception("USERPROFILE not set")
        }
        return userProfile
    }

    run(args) {
        try {
            rc := 1
            files := []
            prevArg := ""
            termArgs := false
            for each, arg in args {
                if (arg = "-h" || arg = "--help") {
                    AhkDist.usage()
                    exitapp
                }
                if (arg == "--") {
                    termArgs := true
                } else if (RegExMatch(prevArg, "(-L|--lib)")) {
                    AhkDist.options.AHK_LIB := arg
                } else if (RegExMatch(arg, "(-v|--verbose)")) {
                    AhkDist.options.verbose := true
                } else if (RegExMatch(arg, "--whatif")) {
                    AhkDist.options.whatif := true
                } else if (RegExMatch(arg, "--synch")) {
                    loop Files, *.ahk
                    {
                        files.push(A_LoopFileName)
                    }
                    break
                } else if (SubStr(arg, 1, 1) != "-" || termArgs) {
                    files.push(arg)
                } else {
                    if (!RegExMatch(arg, "(-L|--lib)")) {
                        throw Exception("error: Illegal argument ")
                    }
                }
                prevArg := arg
            }
            if (FileExist(".\modules") != "D") {
                throw Exception("error: Run from 'ahk-lib's base dir")
            } else {
                AhkDist.dist(files)
            }
        } catch e {
            AhkDist.print(e.message)
            AhkDist.print(AhkDist.usage())
            rc := 0
        }

        return rc
    }

    usage() {
        AhkDist.print("usage: ahkdist [-L <path-to-lib>] [--] ahkfile [ahkfile...]") ; ahklint-ignore: W002
        AhkDist.print("       ahkdist [-L <path-to-lib>] --synch")
        AhkDist.print()
        AhkDist.print(" -L, --lib      Set path to AutoHotkey/lib direcotry")
        AhkDist.print(" --synch        Synchronise files and modules")
        AhkDist.print(" --whatif       Simulate execution")
        AhkDist.print(" -v, --verbose  Verbose output")
    }

    dist(files) {
        static GREEN := "[32m"
        static NORMAL := "[0m"
        moduleNames := AhkDist.checkFilesAndDirectories(files)
        targetDir := AhkDist.options.AHK_LIB
        if (!AhkDist.isDirectory(targetDir)) {
            AhkDist.verbose("Creating AutoHotkey lib direcotry "
                    . GREEN targetDir)
            if (!AhkDist.options.whatif) {
                FileCreateDir %targetDir%
            }
        }
        for each, module in moduleNames {
            filePath := targetDir "\" module ".ahk"
            if (FileExist(filePath)) {
                AhkDist.verbose("Remove readonly flag from " GREEN filePath)
                if (!AhkDist.options.whatif) {
                    FileSetAttrib -R, %filePath%
                }
            }
            AhkDist.print(Format("Copy {:s} to {:s}"
                    , GREEN module ".ahk" NORMAL, GREEN filePath))
            if (!AhkDist.options.whatif) {
                FileCopy %module%.ahk, %filePath%, true
            }
            if (AhkDist.isDirectory(".\modules\" module)) {
                if (!AhkDist.isDirectory(targetDir "\modules\" module)) {
                    AhkDist.verbose("Creating module directory for "
                            . GREEN module)
                    if (!AhkDist.options.whatif) {
                        FileCreateDir %targetDir%\modules\%module%
                    }
                }
                if (FileExist(targetDir "\modules\" module "\*.ahk")) {
                    AhkDist.verbose("Remove readonly from "
                            . GREEN targetDir "\modules\" module "\*.ahk")
                    if (!AhkDist.options.whatif) {
                        FileSetAttrib -R, %targetDir%\modules\%module%\*.ahk
                                ,, true
                    }
                }
                AhkDist.print(Format("Copy all module files for {:s} to {:s}"
                        , GREEN module NORMAL
                        , GREEN targetDir "\modules\" module))
                if (!AhkDist.options.whatif) {
                    FileCopy .\modules\%module%\*.ahk
                            , %targetDir%\modules\%module%, true
                }
            }
            AhkDist.verbose("")
        }
        AhkDist.verbose("Apply readonly attribute to all files in "
                . GREEN targetDir)
        if (!AhkDist.options.whatif) {
            FileSetAttrib +R, %targetDir%,, true
        }
    }

    isDirectory(name) {
        return InStr(FileExist(name), "D")
    }

    checkFilesAndDirectories(args) {
        if (!AhkDist.isDirectory(AhkDist.options.AHK_LIB)) {
            throw Exception(Format("error: Directory '{:s}' doesn't exist"
                    , AhkDist.options.AHK_LIB))
        }
        moduleNames := []
        for each, fileName in args {
            SplitPath fileName,,, fileExtension, fileNameNoExtension
            fileName := fileNameNoExtension
                    . "." (fileExtension == "" ? "ahk" : fileExtension)
            if (!InStr("RASHNOCT", FileExist(fileName))) {
                throw Exception(Format("error: File '{:s}' doesn't exist"
                        , fileName))
            }
            moduleNames.push(fileNameNoExtension)
        }
        return moduleNames
    }

    print(message="") {
        static stdOut := (stdOut == "" ? FileOpen("*", "w"):)
        stdOut.writeLine("[0m" (AhkDist.options.whatif && message != ""
                ? "what if: " : "") message "[0m")
    }

    verbose(message) {
        if (AhkDist.options.verbose) {
            AhkDist.print(message)
        }
    }
}

Main:
exitapp AhkDist.run(A_Args)
