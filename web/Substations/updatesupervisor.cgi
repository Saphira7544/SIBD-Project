#!/usr/bin/python3
import psycopg2, cgi
import login

#print('Location: ./supervisorchange.cgi')
#print()

form = cgi.FieldStorage()
#getvalue uses the names from the form in previous page
lati = form.getvalue('gpslat')
longi = form.getvalue('gpslong')
super = form.getvalue('super')
words = super.split(',')
name = words[0]
address = words[1]

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Lab 09</title>')
print('</head>')
print('<body>')
print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="substation.cgi"> Back to Substations</a></h2>')
connection = None
try:
    # Creating connection
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()
    # Making update
    sql = 'UPDATE substation SET sname = %s, saddress = %s WHERE gpslat = %s AND gpslong = %s;'
    data = (name, address,lati,longi)
    
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