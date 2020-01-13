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
#include <calendar\calendar>
#include <ansi>
#include <optparser\optparser>
#include <system>
#include <string>
#include *i %A_ScriptDir%\datesheet.versioninfo

class Opt {
	static help := false
	static version := false
	static wiki := false
}

Main:
	_main := new Logger("app.datesheet." A_ThisFunc)
	
	global G_VERSION_INFO

	global RC_OK := 1
		 , RC_TOO_MUCH_ARGS := 2


	op := new OptParser("[options] [month] [year]")
	op.add(new OptParser.Group("Options"))
	op.add(new OptParser.Boolean("h", "help", Opt, "help", "Print usage", OptParser.OPT_HIDDEN))
	op.add(new OptParser.Boolean("v", "version", Opt, "version", "Print version info"))
	op.add(new OptParser.Boolean("w", "wiki", Opt, "wiki", "Generate wiki markup output"))

	rc := RC_OK
	date := new Calendar().setAsDay(1)

	try {
		args := op.parse(System.vArgs)
		if (args.maxIndex() > 0) {
			date.setAsMonth(Arrays.shift(args))
			if (args.maxIndex() > 0) {
				date.setAsYear(Arrays.shift(args))
				if (args.maxIndex() > 0)
					throw Exception("error: Too much arguments",, RC_TOO_MUCH_ARGS)
			}
		}
		if (_main.Logs(Logger.Finest)) {
			_main.Finest("date.Month()", date.Month())
			_main.Finest("date.Year()", date.Year())
		}
		if (Opt.help) {
			Ansi.writeLine(op.usage())
		} else if (Opt.version) {
			Ansi.writeLine(G_VERSION_INFO.NAME
					. "/"  G_VERSION_INFO.ARCH
					. "-b" G_VERSION_INFO.BUILD)
		} else {
			output(date)
		}
	} catch _ex	{
		Ansi.writeLine(_ex.message)	
		Ansi.writeLine(op.usage())
		rc := _ex.extra
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
	Ansi.writeLine(format_header(date))
	
	start := date
	recent_sunday := date.findWeekDay(Calendar.SUNDAY, Calendar.FIND_RECENT)
	distance := recent_sunday.compare(date, Calendar.Units.DAYS)
	if (_log.Logs(Logger.Finest)) {
		_log.Finest("recent_sunday", recent_sunday)
		_log.Finest("distance", distance)
	}
	; Ansi.Write(date.Week() "`t")
	Ansi.write(format_week(date))
	loop % distance - 1
		Ansi.write(format_distance())
	loop % date.daysInMonth() {
		Ansi.write(format_day(date))	
		if (date.dayOfWeek() = Calendar.SUNDAY) {
			Ansi.writeLine()
			if (date.asDay() < date.daysInMonth()) {
				date := date.adjust(0, 0, 1)
				; Ansi.Write(date.Week() "`t")
				Ansi.write(format_week(date))
			}
		} else
			date := date.adjust(0, 0, 1)
	}
	Ansi.writeLine()


	return _log.Exit()
}

format_header(date) {
	if (Opt.wiki)
		return "|| *" date.asMonth() " / " date.asYear() "* ||`n"
			 . "||KW||Mo||Di||Mi||Do||Fr||Sa||So||"
	else
		return "`n" date.asMonth() " / " date.asYear() "`n"
			 . "KW`tMo`tDi`tMi`tDo`tFr`tSa`tSo"
}

format_week(date) {
	if (Opt.wiki)
		return "|*" date.week() "*|"
	else
		return date.week() "`t"
}

format_day(date) {
	d := date.formatTime("d").pad(String.PAD_LEFT, 2)
	if (Opt.wiki) {
		wd := date.dayOfWeek()
		if (wd = Calendar.SATURDAY || wd = Calendar.SUNDAY)
			return "{color:" (wd = Calendar.SATURDAY ? "grey}" : "red}") d "{color}|"
		else
			return d "|"
	} else
		return d "`t"
}

format_distance() {
	if (Opt.wiki)
		return " |"
	else
		return "`t"
}
