#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , H ;if unstable, comment or remove this line
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

#include <logging>
#include <calendar>
#include <ansi>
#include <optparser>
#include <system>
#include <string>
#include *i %A_ScriptDir%\datesheet.versioninfo

Main:
	_main := new Logger("app.datesheet." A_ThisFunc)
	
	global G_wiki
		 , G_help
		 , G_version

	global G_VERSION_INFO

	global RC_OK := 1
		 , RC_TOO_MUCH_ARGS := 2


	op := new OptParser(["adjust [options] [--] [timestamp]", "compare [options] [--] timestamp [timestamp]"])
	op.Add(new OptParser.Group("adjust:  Calculate a new timestamp"))
	op.Add(new OptParser.Group("compare: Calcuate the distance between two timestamps"))
	op.Add(new OptParser.Group("Options"))
	op.Add(new OptParser.Boolean("h", "help", G_help, "Print usage", OptParser.OPT_HIDDEN))
	op.Add(new OptParser.Boolean("v", "version", G_version, "Print version info"))
	op.Add(new OptParser.Boolean("w", "wiki", G_wiki, "Generate wiki markup output"))

	rc := RC_OK
	date := new Calendar().Day(1)

	try {
		args := op.Parse(System.vArgs)
		if (args.MaxIndex() > 0) {
			date.Month(Arrays.Shift(args))
			if (args.MaxIndex() > 0) {
				date.Year(Arrays.Shift(args))
				if (args.MaxIndex() > 0)
					throw Exception("error: Too much arguments",, RC_TOO_MUCH_ARGS)
			}
		}
		if (_main.Logs(Logger.Finest)) {
			_main.Finest("date.Month()", date.Month())
			_main.Finest("date.Year()", date.Year())
		}
		if (G_help) {
			Ansi.WriteLine(op.Usage())
		} else if (G_version) {
			Ansi.WriteLine(G_VERSION_INFO.NAME
					. "/"  G_VERSION_INFO.ARCH
					. "-b" G_VERSION_INFO.BUILD)
		} else {
			output(date)
		}
	} catch _ex	{
		Ansi.WriteLine(_ex.Message)	
		Ansi.WriteLine(op.Usage())
		rc := _ex.Extra
	}
	
exitapp _main.Exit(rc)

output(date) {
	_log := new Logger("app.datesheet." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("date", date)
		if (_log.Logs(Logger.All)) {
			_log.All("date:`n" LoggingHelper.Dump(date))
		}
	}

	; Ansi.WriteLine("`n" date.Month() " / " date.Year() "`n")
	; Ansi.WriteLine("KW`tMo`tDi`tMi`tDo`tFr`tSa`tSo")
	Ansi.WriteLine(format_header(date))
	
	start := date
	recent_sunday := date.FindWeekDay(Calendar.SUNDAY, Calendar.FIND_RECENT)
	distance := recent_sunday.Compare(date, Calendar.Units.DAYS)
	if (_log.Logs(Logger.Finest)) {
		_log.Finest("recent_sunday", recent_sunday)
		_log.Finest("distance", distance)
	}
	; Ansi.Write(date.Week() "`t")
	Ansi.Write(format_week(date))
	loop % distance - 1
		Ansi.Write(format_distance())
	loop % date.DaysInMonth() {
		Ansi.Write(format_day(date))	
		if (date.DayOfWeek() = Calendar.SUNDAY) {
			Ansi.WriteLine()
			if (date.Day() < date.DaysInMonth()) {
				date := date.Adjust(0, 0, 1)
				; Ansi.Write(date.Week() "`t")
				Ansi.Write(format_week(date))
			}
		} else
			date := date.Adjust(0, 0, 1)
	}
	Ansi.WriteLine()


	return _log.Exit()
}

format_header(date) {
	if (G_wiki)
		return "|| *" date.Month() " / " date.Year() "* ||`n"
			 . "||KW||Mo||Di||Mi||Do||Fr||Sa||So||"
	else
		return "`n" date.Month() " / " date.Year() "`n"
			 . "KW`tMo`tDi`tMi`tDo`tFr`tSa`tSo"
}

format_week(date) {
	if (G_wiki)
		return "|*" date.Week() "*|"
	else
		return date.Week() "`t"
}

format_day(date) {
	d := date.FormatTime("d").Pad(String.PAD_LEFT, 2)
	if (G_wiki) {
		wd := date.DayOfWeek()
		if (wd = Calendar.SATURDAY || wd = Calendar.SUNDAY)
			return "{color:" (wd = Calendar.SATURDAY ? "grey}" : "red}") d "{color}|"
		else
			return d "|"
	} else
		return d "`t"
}

format_distance() {
	if (G_wiki)
		return " |"
	else
		return "`t"
}
