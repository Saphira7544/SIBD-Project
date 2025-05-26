#!/usr/bin/python3
import psycopg2, cgi
import login


form = cgi.FieldStorage()
#getvalue uses the names from the form in previous page
id = form.getvalue('id')
voltage = form.getvalue('voltage')
print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Lab 09</title>')
print('</head>')
print('<body>')
print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="busbar.cgi"> Back to Busbars</a></h2>')
connection = None
try:
    # Creating connection
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()
    # Insert into elemnet
    ins_ele = 'INSERT INTO element VALUES(%s);'

    cursor.execute(ins_ele, [id])

    #Insert into busbar
    ins_bb = 'INSERT INTO busbar VALUES(%s , %s);'

    data = (id,voltage)
    
    # Feed the data to the SQL query as follows to avoid SQL injection
    cursor.execute(ins_bb, data)
    # Commit the update (without this step the database will not change)
    connection.commit()
    # Closing connection
    print('<h3> SUCCESS</h3>')
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