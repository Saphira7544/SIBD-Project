#!/usr/bin/python3
import psycopg2

import login

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Busbar</title>')
print('</head>')
print('<body>')

print('<h1><a href="../index.html"> Back to Index</a></h1>')

print('<h2>Busbars</h2>')

connection = None
try:
	# Creating connection
	connection = psycopg2.connect(login.credentials)
	cursor = connection.cursor()
	# Making query

	print('<h3>Add Busbars</h3>')
	print('<form action = "insertbusbar.cgi" method="post">')
	print('<p>ID :<input type = "text" maxlength = 10 name="id" required/></p>')
	print('<p>Voltage :<input type = "number" min = 0  step = 0.0001 max = 999.9999 name="voltage" required/></p>')
	print('<p><input type = "submit" name="Submit"/></p>')
	print('</form>')


	print('<h3>List Busbars</h3>')
	print('<h4> ID | Voltage</h4>')
	sql = 'SELECT * FROM busbar;'
	cursor.execute(sql)
	result = cursor.fetchall()
	num = len(result)

	# Displaying results
	print('<table border="0" cellspacing="5">')
	for row in result:
		print('<tr>')
		for value in row:
		# The string has the {}, the variables inside format() will replace the {}
			print('<td>{}</td>'.format(value))
		print('<td><a href="removebusbar.cgi?bbid={}">Delete</a></td>'.format(row[0]))
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
