@echo off
set test_expansion_delay=pass
if !test_expansion_delay! NEQ pass (set test_expansion_delay=& start /B /WAIT cmd.exe /V:ON /C "%0" %* & goto:eof)
set test_expansion_delay=

for /L %%a in (0,1,1) do (
	for /L %%b in (30,1,37) do (
		set line=
		for /L %%c in (40,1,47) do (
			set line=!line! [%%a;%%c;%%bm%%a;%%c;%%b[0m 
		)
		echo !line!
	)
)
echo.
