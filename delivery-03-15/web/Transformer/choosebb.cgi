#!/usr/bin/python3
import psycopg2

import cgi

import login

form = cgi.FieldStorage()
pv = form.getvalue('pv')
sv = form.getvalue('sv')
gps = form.getvalue('gpscoord')
id  = form.getvalue('id')

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Transformers</title>')
print('</head>')
print('<body>')


print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="transformers.cgi"> Back to Transformers</a></h2>')

connection = None
try:
    # Creating connection
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()

    print('<h3>Choose Busbars that connect to Transformer</h3>')
    print('<form action = "insertransformer.cgi" method="post">')
    print('<p><input type = "hidden" name="pv" value="{}"/></p>'.format(pv))
    print('<p><input type = "hidden" name="sv" value="{}"/></p>'.format(sv))
    print('<p><input type = "hidden" name="gpscoord" value="{}"/></p>'.format(gps))
    print('<p><input type = "hidden" maxlength = 10 name="id" value="{}"/></p>'.format(id))

    print('<p>Primary Busbar ID :<select name="bb1id"/>')
    sql = """
        select id
        from busbar
        where voltage = %s
        """
    cursor.execute(sql, [pv])
    result = cursor.fetchall()
    for row in result:
        print(
            '<option value ={}>{}</option>'.format(row[0],row[0]))
    print('</select></p>')

    print('<p>Secondary Busbar :<select name="bb2id"/>')
    sql = """
        select id
        from busbar
        where voltage = %s
        """
    cursor.execute(sql, [sv])
    result = cursor.fetchall()
    for row in result:
        print(
            '<option value ={}>{}</option>'.format(row[0],row[0]))
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
