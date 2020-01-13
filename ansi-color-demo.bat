@echo off
set test_expansion_delay=pass
if !test_expansion_delay! NEQ pass (set test_expansion_delay=& start /B /WAIT cmd.exe /V:ON /C "%0" %* & goto:eof)
set test_expansion_delay=

call:printSwatches 30 40
call:printSwatches 90 40
call:printSwatches 30 100
call:printSwatches 90 100

goto:eof

:printSwatches
	set foregroundColorBase=%1
	set backgroundColorBase=%2
	if %backgroundColorBase% LSS 100 (set padWith= ) else set padWith=
	for /L %%f in (0,1,7) do (
		set line=
		set /A foregroundColor=%foregroundColorBase% + %%f
		for /L %%b in (0,1,7) do (
			set /A backgroundColor=%backgroundColorBase% + %%b
			set sequence=!foregroundColor!;!backgroundColor!m
			set line=!line! [!sequence! !padWith!!sequence! [0m 
		)
		echo !line!
	)
goto:eof
