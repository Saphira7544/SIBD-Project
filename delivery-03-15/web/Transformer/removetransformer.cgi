#!/usr/bin/python3
import psycopg2, cgi
import login

#print('Location: ./busbar.cgi')
#print()
form = cgi.FieldStorage()
#getvalue uses the names from the form in previous page
id = form.getvalue('id')
print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Project</title>')
print('</head>')
print('<body>')
print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="transformers.cgi"> Back to Transformers</a></h2>')
connection = None
try:
    # Creating connection
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()
    # Making delete
    sql = 'DELETE FROM transformer WHERE id = %s;' 
    
    # Feed the data to the SQL query as follows to avoid SQL injection
    cursor.execute(sql , [id])
    #Making delete
    sql = 'DELETE FROM element WHERE id = %s;' 

    # Feed the data to the SQL query as follows to avoid SQL injection
    cursor.execute(sql , [id])
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