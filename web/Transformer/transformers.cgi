#!/usr/bin/python3
import psycopg2

import login

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Transformers</title>')
print('</head>')
print('<body>')

print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2>Transformers</h2>')
connection = None
try:
    # Creating connection
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()

    print('<h3>Add Transformer</h3>')
    print('<form action = "choosebb.cgi" method="post">')
    print('<p>ID :<input type = "text" maxlength = 10 name="id" required/></p>')
    
    sql = """
        select distinct voltage
        from busbar
        """
    cursor.execute(sql)
    result = cursor.fetchall()
    
    print('<p>pv :<select name="pv"/></p>')
    for row in result:
        print(
            '<option value ="{}">{}</option>'.format(row[0],row[0]))
    print('</select></p>')
    
    print('<p>sv :<select name="sv"/></p>')
    for row in result:
        print(
            '<option value ="{}">{}</option>'.format(row[0],row[0]))
    print('</select></p>')

    print('<p>Latitude, Longitude :<select name="gpscoord"/>')
    sql = """
        select gpslat,gpslong
        from substation
        """
    cursor.execute(sql)
    result = cursor.fetchall()
    for row in result:
        print(
            '<option value ="{},{}">{},{}</option>'.format(row[0],row[1],row[0],row[1]))
    print('</select></p>')

    print('<p><input type = "submit" name="Submit"/></p>')
    print('</form>')
    # Making query
    print('<h3>List Transformer</h3>')
    print('<h4> ID | pv | sv | Latitude | Longitude | Busbar1 | Busbar2 </h4>')

    sql = 'SELECT * FROM transformer;'
    cursor.execute(sql)
    result = cursor.fetchall()
    num = len(result)
    
    print('<table border="0" cellspacing="5">')
    for row in result:
        print('<tr>')
        for value in row:
            # The string has the {}, the variables inside format() will replace the {}
            print('<td>{}</td>'.format(value))
        print(
            '<td><a href="removetransformer.cgi?id={}">Delete</a></td>'.format(row[0]))
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
