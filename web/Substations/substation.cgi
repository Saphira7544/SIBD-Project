#!/usr/bin/python3
import psycopg2

import login

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Substation</title>')
print('</head>')
print('<body>')
print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2>Substations</h2>')


connection = None
try:
	# Creating connection
	connection = psycopg2.connect(login.credentials)
	cursor = connection.cursor()

	sql = 'SELECT name, address FROM supervisor;'
	cursor.execute(sql)
	result = cursor.fetchall()
	print('<h3>Add Substation</h3>')
	print('<form action = "insertsubstation.cgi" method="post">')
	print('<p>Locality :<input type = "text" maxlength = 80 name="locality"/></p>')
	print('<p>Latitude :<input type = "number" max = 180 min =-180 step = 0.000001 name="gpslat" required/></p>')
	print('<p>Longitude :<input type = "number" max = 90 min =-90 step = 0.000001 name="gpslong" required/></p>')
	print('<p>Supervisor Name and Address :<select name="super"/>')
	for row in result:
		print('<option value ="{},{}">{},{}</option>'.format(row[0],row[1],row[0],row[1]))
	print('</select></p>')
	print('<p><input type = "submit" name="Submit"/></p>')
	print('</form>')
	

	print('<h3>List Substation</h3>')
	print('<h4>Latitude | Longitude | Locality | Supervisor Name | Supervisor Address</h4>')
	sql = 'SELECT * FROM substation;'
	cursor.execute(sql)
	result = cursor.fetchall()
	num = len(result)

	# Displaying results
	# print('<p>{}</p>'.format(cursor.description(name)))
	print('<table border="0" cellspacing="5">')
	for row in result:
		print('<tr>')
		for value in row:
		# The string has the {}, the variables inside format() will replace the {}
			print('<td>{}</td>'.format(value))
		print('<td><a href="removesubstation.cgi?gpslat={}&gpslong={}">Delete</a></td>'.format(row[0],row[1]))
		print('<td><a href="changesupper.cgi?gpslat={}&gpslong={}&locality={}&sname={}&saddress={}">Change Supervisor</a></td>'.format(row[0],row[1],row[2],row[3],row[4]))
		print('</tr>')
	print('</table>')

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
