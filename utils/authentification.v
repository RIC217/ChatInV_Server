module utils

import db.sqlite
import crypto.sha256

pub fn (mut app App) ask_credentials(mut user &User) (string, string) {
	for {
		mut credentials := []u8{len: 1024}
		length := user.read(mut credentials) or {
			eprintln(err)
			return "Cannot read credentials", ""
		}
		credentials = credentials[0..length]
		pseudo_length := credentials[0..2].bytestr().int()
		credentials = credentials[2..]
		username := credentials[0..pseudo_length].bytestr()
		println("Pseudo : $username len: $pseudo_length")
		credentials = credentials[pseudo_length..]
		password_length := credentials[0..2].bytestr().int()
		println("Password len : $password_length")
		credentials = credentials[2..]
		password := credentials[..password_length].bytestr()

		account := app.get_account_by_pseudo(username)

		if sha256.hexhash(account.salt+password) == account.password {
			if app.is_pseudo_connected(username) {
				user.write_string("1Already connected !") or {
					return "Error while sending already connected !\n", ""
				}
				return "Already connected\n", ""
			}

			user.write_string("0Welcome $username") or {
				return "Error while sending welcome\n", ""
			}
			return "", username
		}

		println("[LOG] ${user.peer_ip() or {"IPERROR"}} => 'Wrong password !'")
		user.write_string("1Wrong password !\n") or {
			return "Error while sending 'Wrong password' to ${user.peer_ip() or {"IPERROR"}}", ""
		}
	}
	return "This should never append !", ""
}

fn (mut app App) is_pseudo_connected(pseudo string) bool {
	for user in app.users {
		if user.pseudo == pseudo {
			return true
		}
	}
	return false
}