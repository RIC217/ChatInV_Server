module utils

import net
import db.sqlite

pub fn ask_credentials(mut socket &net.TcpConn, db sqlite.DB) (string, string, string) {
	mut data := []u8{len: 1024}
	mut error := ""
	socket.write_string("Pseudo : ") or {
		error = "Error while asking pseudo : $err"
		eprintln(error)
		return error, "", ""
	}
	lenght := socket.read(mut data) or {
		error = "Error while reading pseudo : $err"
		eprintln(error)
		return error, "", ""
	}
	mut pseudo := data[0..lenght].bytestr()
	socket.write_string("Password : ") or {
		error = "Error while asking password : $err"
		eprintln(error)
		return error, "", ""
	}
	data = []u8{len: 1024}
	socket.read(mut data) or {
 		error = "Error while reading password : $err"
		eprintln(error)
		return error, "", ""
	}
	mut password := data[0..lenght].bytestr()
	if pseudo.len < 8 || password.len < 8 {
		return "Pseudo or password too short !\n", "", ""
	}

	account := get_account_by_pseudo(db, pseudo)
	if password == account.password {
		return "", pseudo, password
	}

	return "Wrong password !\n", pseudo, password
}
