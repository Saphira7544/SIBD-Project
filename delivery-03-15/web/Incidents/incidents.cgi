#!/usr/bin/python3
import psycopg2

import login

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Incident</title>')
print('</head>')
print('<body>')
print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2>Non-Line Incidents</h2>')

connection = None
try:
	# Creating connection
	connection = psycopg2.connect(login.credentials)
	cursor = connection.cursor()

	# Making query
	sql = """
		SELECT id FROM transformer
		UNION
		SELECT id FROM busbar;
		"""

	cursor.execute(sql)
	result = cursor.fetchall()
	print('<h3>Add Incident</h3>')
	print('<form action = "insert_incidents.cgi" method="post">')
	print('<p>Instant:<input type = "datetime-local" name="instant" required/></p>')
	print('<p>Severity:<input type = "text" maxlength = "30" name="severity"/></p>')
	print('<p>Description:<input type = "text" maxlength = "250" name="description"/></p>')
	print('<p>ID:<select name="id"/>')
	for row in result:
		print('<option value ={}>{}</option>'.format(row[0],row[0]))
	print('</select></p>')
	print('<p><input type = "submit" name="Submit"/></p>')
	print('</form>')

	print('<h3>Instant | ID | Description | Severity</h3>')
	# Making query
	sql = """
		SELECT * FROM incident
		WHERE id NOT IN(
			SELECT id FROM lineincident
		);
		"""
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
		print('<td><a href="change_description.cgi?instant={}&id={}">Change descrition</a></td>'.format(row[0],row[1]))
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