#!/usr/bin/env bash
# CGI script
# Does not work with FastCGI (fcgi) because it requires additional communication, see https://unix.stackexchange.com/a/241694
set -e
set -f
#set -u # BAH01215: ./bashlib: line 82: value: unbound variable

# https://stackoverflow.com/questions/3919755/how-to-parse-query-string-from-a-bash-cgi-script

# source bashlib https://github.com/mikhailnov/bashlib
. ./bashlib 2>/dev/null || . bashlib || ( echo "Failed to source bashlib!" ; exit 1 )

# get file with promo codes
for file in './promo_codes_1.txt' '/var/www/domain.tld/promo_codes_1.txt'
do
	[ -f "$file" ] && file_codes="$file" && break
done

do_redirect_back(){
code_error_type="${code_error_type:-неверный}"
echo -n "
<head><meta charset=\"utf-8\"></head>
<body><center>
Ошибка: вы ввели ${code_error_type} промо-код!
<br>
<form><input type=\"button\" value=\"Вернуться назад\" onclick=\"history.back()\"></form>
</center></body>"
}

do_redirect_forward(){
redir_URL='https://domain.tld/page2'
echo -n "
<head>
<meta charset=\"utf-8\">
<meta http-equiv=\"refresh\" content=\"0;${redir_URL}\">
</head>
<body>
Вы будете перенаправлены на страницу записи. Если она не открылась, перейдите по <a href=\"${redir_URL}\">ссылке</a>.
</body>"
}

write_used_code(){
	# used codes will be converted to empty lines
	# TODO: check if this file is writable and redirect back in case of error
	sed -e "s/${code}//g" -i "$file_codes"
}

code="$(param code)"
if grep -q "$code" "$file_codes"
	then write_used_code && do_redirect_forward # don't redirect if failed to write_used_code
	else do_redirect_back
fi
