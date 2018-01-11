#NoEnv
#Persistent
#SingleInstance force
#include <logging>
#include <crypto>
#include <ldap>

Main:
	success := false
	ld := new Ldap("lx150w05.viessmann.com")
	try {
		ld.Connect()
		loop {
			InputBox phrase, "Mozilla Auto Authorization", "Enter LDAP credentials for User %A_UserName%, HIDE
			try {
				ld.SimpleBind("cn=" A_Username ",ou=mitarbeiter,dc=viessmann,dc=net", phrase)
				success := true
			} catch {
				success := false
			}
		} until (success)
	} catch _ex {
		OutputDebug % _ex.Message
	} finally {
		if (ld)
			ld.Unbind()
	}
	global phrase := Crypto.Encrypt(phrase, A_Computername, Crypto.ALGORITHM_RC4)
	SetTimer CheckMozAuthWin, 500
exit

CheckMozAuthWin() {
	DetectHiddenWindows On
	DetectHiddenText On
	if (unid := WinExist("Authentifizierung erforderlich ahk_class MozillaDialogClass")) {
		SetTimer CheckMozAuthWin, Off
		WinActivate ahk_id %unid%
		Crypto.Decrypt(pw := phrase, A_Computername)
		VarSetCapacity(pw, -1)
		Send %A_UserName%{tab}%pw%{Enter}
		VarSetCapacity(pw, 0)
		SetTimer CheckMozAuthWin, 500
	}
}
