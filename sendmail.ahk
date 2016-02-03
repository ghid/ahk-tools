#NoEnv
#include <logging>
#include <ansi>
#include <optparser>
#include <system>
#include <string>
#include <arrays>
#include *i %A_ScriptDir%\sendmail.versioninfo

Main:
_main := new Logger("app.sendmail.Main")

	EnvGet username, USERNAME
	EnvGet dnsdomain, USERDNSDOMAIN

	global AUTH_ANONYMOUS := 0
		 , AUTH_BASIC     := 1
		 , AUTH_NTLM      := 2

		 , SENDUSING_PICKUP := 1
		 , SENDUSING_PORT   := 2

	global G_opts := { subject: ""
					 , body: ""
					 , from: username "@" dnsdomain
					 , to: ""
					 , cc: ""
					 , bcc: ""
					 , reply_to: ""
					 , attachments: ""
					 , timeout: 60
					 , sendusing: SENDUSING_PORT
					 , auth: AUTH_ANONYMOUS
					 , user: ""
					 , ssl: false
					 , html: false
					 , smtp_server: ""
					 , smtp_port: 25 }

	global RC_OK := 0

	rc := RC_OK

	op := new OptParser("sendmail [options] [[-a <path>] ...] <address> [address...]",, "SENDMAIL_OPTIONS")
	op.Add(new OptParser.String("a", "attach-file", _attachments, "path", "A path to a file to attach to the mail", OptParser.OPT_ARG | OptParser.OPT_MULTIPLE))
	op.Add(new OptParser.String("s", "subject", _subject, "subject", "The subject for the mail"))
	op.Add(new OptParser.String("f", "from", _from, "sender", "Name of the sender of the mail", OptParser.OPT_ARG, G_opts["from"], G_opts["from"]))
	op.Add(new OptParser.String("t", "to", _to, "recipient", "Recipient of the mail", OptParser.OPT_ARG | OptParser.OPT_MULTIPLE))
	op.Add(new OptParser.String("c", "cc", _cc, "recipient", "Carbon copy recipient of the mail", OptParser.OPT_ARG | OptParser.OPT_MULTIPLE))
	op.Add(new OptParser.String("b", "bcc", _bcc, "recipient", "Blind carbon copy recipient of the mail", OptParser.OPT_ARG | OptParser.OPT_MULTIPLE))
	op.Add(new OptParser.String("r", "reply-to", _reply_to, "address", "Set a reply-to address", OptParser.OPT_ARG))
	op.Add(new OptParser.String("S", "smtp-server", _smpt_server, "hostname", "SMTP server name"))
	op.Add(new OptParser.String("P", "smtp-port", _smpt_port, "port", "SMTP server port (default: %i)".Subst(G_opts["smtp_port"]),OptParser.OPT_ARG, G_opts["smtp_port"], G_opts["smtp_port"]))
	op.Add(new OptParser.String("T", "timeout", _timeout, "secs", "SMTP connection time out (default: %i secs)".Subst(G_opts["timeout"]), OptParser.OPT_ARG, G_opts["timeout"], G_opts["timeout"]))
	op.add(new OptParser.String(0, "sendusing", _sendusing, "method", "Specifiy the method used to send the message (default: %s)".Subst(G_opts["sendusing"]), OptParser.OPT_ARG, G_opts["sendusing"], G_opts["sendusing"]))
	op.add(new OptParser.String(0, "authenticate", _auth, "method", "How to authenticate (Default: %s)".Subst(G_opts["auth"]), OptParser.OPT_ARG, G_opts["auth"], G_opts["auth"]))
	op.add(new OptParser.String(0, "user-name", _user, "user-id", "The username for authentication"))
	op.add(new OptParser.String(0, "password", _password, "password", "The password for authentication"))
	op.Add(new OptParser.Boolean(0, "ssl", _ssl, "Use SSL", OptParser.OPT_NEG))
	op.Add(new OptParser.Boolean(0, "html", _html, "Accept HTML markup for the message body", OptParser.OPT_NEG))
	op.Add(new OptParser.Boolean(0, "env", env_dummy, "Ignore environment variable SENDMAIL_OPTIONS", OptParser.OPT_NEG | OptParser.OPT_NEG_USAGE))
	op.Add(new OptParser.Boolean(0, "version", _version, "Print version info"))
	op.Add(new OptParser.Boolean(0, "help", _help, "This help", OptParser.OPT_HIDDEN))

	try {
		addr := op.Parse(System.vArgs)

		op.TrimArg(_from)
		op.TrimArg(_to)
		op.TrimArg(_cc)
		op.TrimArg(_bcc)
		op.TrimArg(_reply_to)
		op.TrimArg(_subject)
		op.TrimArg(_sendusing)
		op.TrimArg(_smpt_server)
		op.TrimArg(_smpt_port)
		op.TrimArg(_attachments)
		op.TrimArg(_timeout)
		op.TrimArg(_auth)
		op.TrimArg(_user)
		op.TrimArg(_password)

		G_opts["from"] := _from
		G_opts["to"] := (addr.MaxIndex() <> "" ? Arrays.ToString(addr, ", ") ", " : "") _to.Replace("`n", ", ")
		G_opts["cc"] := _cc.Replace("`n", ", ")
		G_opts["bcc"] := _bcc.Replace("`n", ", ")
		G_opts["reply_to"] := _reply_to
		G_opts["subject"] := _subject
		G_opts["attachments"] := _attachments.Replace("`n", "|")
		G_opts["sendusing"] := _sendusing
		G_opts["smtp_server"] := _smpt_server
		G_opts["smtp_port"] := _smpt_port
		G_opts["timeout"] := _timeout
		G_opts["auth"] := _auth
		G_opts["user"] := _user
		G_opts["password"] := _password
		G_opts["ssl"] := _ssl
		G_opts["html"] := _html
		G_opts["help"] := _help
		G_opts["version"] := _version

		_in := Ansi.StdIn
		_body := ""
		while (!_in.AtEOF()) {
			RegExMatch(_in.ReadLine(), "^.*$", line)
			if (_main.Logs(Logger.Finest)) {
				_main.Finest("line", line)
			}
			_body .= line "`n"
		}
		G_opts["body"] := _body
		_in.Close()
		if (_main.Logs(Logger.Finest)) {
			_main.Finest("G_opts:`n" LoggingHelper.Dump(G_opts))
			_main.Finest("addr:`n" LoggingHelper.Dump(addr))
			if (_main.Logs(Logger.All)) {
				_main.Finest("StrLen(_body)", StrLen(_body))
				_main.All("_body:`n" LoggingHelper.HexDump(&_body, 0, StrLen(_body) * (A_IsUnicode ? 2 : 1)))
			}
		}

		if (G_opts["help"]) {
			Ansi.WriteLine(op.Usage())
			exitapp _main.Exit(RC_OK)
		} else if (G_opts["version"]) {
			Ansi.WriteLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
			exitapp _main.Exit(RC_OK)
		}

		if (G_opts["to"] = "")
			throw Exception("error: No recipient",, -1)

		rc := send_mail()
	} catch _ex {
		if (_main.Logs(Logger.Info)) {
			_main.Info("_ex", _ex)
		}
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
		rc := _ex.Extra
	}

exitapp _main.Exit(rc)

expand_filename(filename) {
	_log := new Logger("app.sendmail." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("filename", filename)
	}

	loop Files, %filename%
		return _log.Exit(A_LoopFileLongPath)
}

send_mail() {
	_log := new Logger("app.sendmail." A_ThisFunc)
	
	pmsg 						 := ComObjCreate("CDO.Message")
	pmsg.From 					 := G_opts["From"] ; """John Doe"" <John.Doe@gmail.com>"
	pmsg.To 					 := G_opts["To"]   ; "Jane.Doe@gmail.com, Joe.Schmo@gmx.com"
	pmsg.BCC 					 := G_opts["Bcc"]  ; ""   									; Blind Carbon Copy, Invisible for all, same syntax as CC
	pmsg.CC 					 := G_opts["cc"]   ; ""										; Somebody@somewhere.com, Other-somebody@somewhere.com
	pmsg.Subject 				 := G_opts["subject"] ; "See below"
	if (G_opts["reply_to"])
		pmsg.ReplyTo := G_opts["reply_to"]
	if (G_opts["html"])
		pmsg.HtmlBody            := G_opts["body"]
	else
		pmsg.TextBody            := G_opts["body"]
	sAttach                      := G_opts["attachments"]
	fields 						 := Object()
	fields.smtpserver   		 := G_opts["smtp_server"] ; "smtp.gmail.com" 						; specify your SMTP server
	fields.smtpserverport   	 := G_opts["smtp_port"] ; 465 										; 25
	fields.smtpusessl      		 := G_opts["ssl"] ; True 									; False
	fields.sendusing     		 := G_opts["sendusing"] ; 2   										; cdoSendUsingPort
	fields.smtpauthenticate 	 := G_opts["auth"] ; 1   										; cdoBasic
	fields.sendusername 		 := G_opts["user"] ; "John.Doe@gmail.com"
	fields.sendpassword 		 := G_opts["password"] ; "yourpw"
	fields.smtpconnectiontimeout := G_opts["timeout"] ; 60
	schema 						 := "http://schemas.microsoft.com/cdo/configuration/"
	pfld 						 :=  pmsg.Configuration.Fields
	For field,value in fields
		pfld.Item(schema field)  := value
	pfld.Update()
	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
	{
		fname := expand_filename(A_LoopField)
		if (_log.Logs(Logger.Info)) {
			_log.Info("Attach " fname)
		}
		pmsg.AddAttachment(fname)
	}

	if (_log.Logs(Logger.Finest)) {
		_log.Finest("pmsg.From", pmsg.From)
		_log.Finest("pmsg.To", pmsg.To)
		_log.Finest("pmsg.CC", pmsg.CC)
		_log.Finest("pmsg.BCC", pmsg.BCC)
		_log.Finest("pmsg.ReplyTo", pmsg.ReplyTo)
		_log.Finest("pmsg.Subject", pmsg.Subject)
		_log.Finest("pmsg.TextBody", pmsg.TextBody)
		_log.Finest("pmsg.HtmlBody", pmsg.HtmlBody)
		_log.Finest("fields.smtpserver", fields.smtpserver)
		_log.Finest("fields.smtpserverport", fields.smtpserverport)
		_log.Finest("fields.smtpauthenticate", fields.smtpauthenticate)
		_log.Finest("fields.smtpusessl", fields.smtpusessl)
		_log.Finest("fields.sendusing", fields.sendusing)
		_log.Finest("fields.sendusername", fields.sendusername)
		_log.Finest("fields.sendpassword", fields.sendpassword)
		_log.Finest("fields.smptconnectiontimeout", fields.smtpconnectiontimeout)
		_log.Finest("schema", schema)
	}

	return _log.Exit(pmsg.Send())
}
