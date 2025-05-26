#!/usr/bin/python3
import psycopg2

import login
import cgi

form = cgi.FieldStorage()

lati = form.getvalue('gpslat')
longi = form.getvalue('gpslong')
locality = form.getvalue('locality')

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Lab 09</title>')
print('</head>')
print('<body>')

print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="substation.cgi"> Back to Substations</a></h2>')

# The string has the {}, the variables inside format() will replace the {}
print('<h3>Change supervisor for substation {},{} in {}</h3>'.format(lati,longi,locality))

try:
	# Creating connection
	connection = psycopg2.connect(login.credentials)
	cursor = connection.cursor()

	sql = 'SELECT name, address FROM supervisor;'
	cursor.execute(sql)
	result = cursor.fetchall()
	print('<form action="updatesupervisor.cgi" method="post">')
	print('<p><input type="hidden" name="gpslat" value="{}"/></p>'.format(lati))
	print('<p><input type="hidden" name="gpslong" value="{}"/></p>'.format(longi))
	print('<p>Supervisor Name and Address :<select name="super"/>')
	for row in result:
		print('<option value ="{},{}">{},{}</option>'.format(row[0],row[1],row[0],row[1]))
	print('</select></p>')
	print('<p><input type = "submit" name="Submit"/></p>')
	print('</form>')
	# Closing connection
	cursor.close()
except Exception as e:
	# Print errors on the webpage if they occur
	print('<h1>An error occurred.</h1>')
	#print('<p>{}</p>'.format(e))
finally:
	if connection is not None:
		connection.close()


print('</body>')
print('</html>')