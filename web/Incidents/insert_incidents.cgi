#!/usr/bin/python3
import psycopg2, cgi
import login
import string

form = cgi.FieldStorage()
#getvalue uses the names from the form in previous page
incident_id = form.getvalue('id')
incident_instant = form.getvalue('instant')
incident_description = form.getvalue('description')
incident_severity = form.getvalue('severity')

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Project</title>')
print('</head>')
print('<body>')

print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="incidents.cgi"> Back to Incidents</a></h2>')

connection = None
try:
    # Creating connection
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()
    # Making the insert
    sql = 'INSERT INTO incident VALUES(%s,%s,%s,%s);' #(instant,id,description,severity)
    data = (incident_instant,incident_id,incident_description,incident_severity)
    # Feed the data to the SQL query as follows to avoid SQL injection
    cursor.execute(sql, data)
    # Commit the update (without this step the database will not change)
    print('<h3> SUCCESS</h3>')
    connection.commit()
    # Closing connection
    cursor.close()
except Exception as e:
    # Print errors on the webpage if they occur
    print('<h3>An error occurred.</h3>')
    #print('<p>{}</p>'.format(e))
finally:
    if connection is not None:
        connection.close()
print('</body')
print('</html>')