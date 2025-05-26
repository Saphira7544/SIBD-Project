#!/usr/bin/python3
import cgi

form = cgi.FieldStorage()

incident_id = form.getvalue('id')
instant = form.getvalue('instant')

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>Incident</title>')
print('</head>')
print('<body>')
print('<h1><a href="../index.html"> Back to Index</a></h1>')
print('<h2><a href="incidents.cgi"> Back to Incidents</a></h2>')

# The string has the {}, the variables inside format() will replace the {}
print('<h3>Change Description for incident {}, {} </h3>'.format(instant, incident_id))

# The form will send the info needed for the SQL query
print('<form action="update_incidents.cgi" method="post">')
print('<p><input type="hidden" name="instant" value="{}"/></p>'.format(instant))
print('<p><input type="hidden" name="id" value="{}"/></p>'.format(incident_id))
print('<p>New Description: <input type="text" maxlength = 250 name="description"/></p>')
print('<p><input type="submit" value="Submit"/></p>')
print('</form>')

print('</body>')
print('</html>')