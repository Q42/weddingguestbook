from google.appengine.api import users
from google.appengine.ext import ndb
from google.appengine.ext import blobstore
from google.appengine.api import images
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.api import urlfetch

import os, jinja2, logging, webapp2, datetime, urllib, locale, random

VIEW_USERS = [] # TODO add the wedding couple
ADMIN_USERS = [] # TODO add the administrators

PRINTER_CODE = "" # TODO add printer code here

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

class Greeting(ndb.Model):
	img_url = ndb.StringProperty(indexed=False)
	added_date = ndb.DateTimeProperty(indexed=False)
	display_date = ndb.DateTimeProperty()
	sent = ndb.BooleanProperty()

# homepage: show all messages
class MainHandler(webapp2.RequestHandler):
	def get(self):
		user = users.get_current_user()

		if not user:
			self.redirect(users.create_login_url(self.request.uri))
		elif not user.email() in ADMIN_USERS + VIEW_USERS:
			logging.error('invalid user %s requested %s', user.nickname(), self.request.uri)
			self.response.write('<h2>For Jaap & Nadia\'s eyes only!</h2><p>Je bent nu ingelogd als ' + user.email() + '<br /><a href=\'' + users.create_logout_url(self.request.uri) + '\'>Log in als Jaap of Nadia...</a>')
		else:
			logging.info('%s requested %s', user.nickname(), self.request.uri)
			greetings = Greeting.query().order(-Greeting.display_date).fetch()
			future = [g for g in greetings if not g.sent]
			template_values = {
				'sent': [g for g in greetings if g.sent],
				'future': reversed(future) if user.email() in ADMIN_USERS else [],
				'futureCount': len(future),
				'isAdmin': user.email() in ADMIN_USERS,
				'email': user.email(),
				'uploadurl': blobstore.create_upload_url('/api/upload'),
				'logouturl': users.create_logout_url(self.request.uri)
			}

			template = JINJA_ENVIRONMENT.get_template('index.html')
			self.response.write(template.render(template_values))

	def post(self):
		user = users.get_current_user()

		if not user:
			self.redirect(users.create_login_url(self.request.uri))
		elif not user.email() in ADMIN_USERS:
			logging.error('invalid user %s requested %s', user.nickname(), self.request.uri)
			self.response.write('<h2>For Jaap & Nadia\'s admins only!</h2><p>Je bent nu ingelogd als ' + user.email() + '<br /><a href=\'' + users.create_logout_url(self.request.uri) + '\'>Log in als Jaap of Nadia...</a>')
		else:
			greetingid = self.request.get("id")
			sent = self.request.get("sent") == "True"
			date = self.request.get("display_date")
			logging.info('saving %d: %s %s', greetingid, sent, date)

			greeting = Greeting.get_by_id(int(greetingid))
			if (greeting):
				greeting.sent = bool(sent)
				greeting.display_date = datetime.datetime.strptime(date, '%Y-%m-%d %H:%M')
				greeting.put()
				self.response.write('<h2>Updated</h2>Updated sent to ' + str(greeting.sent) + ' and date to ' + str(greeting.display_date))
			else:
				self.response.write('<h2>Not found</h2>nothing updated')

# api call: post a message
class UploadUrlHandler(webapp2.RequestHandler):
	def get(self):
		self.response.write(blobstore.create_upload_url('/api/upload'));

class UploadHandler(blobstore_handlers.BlobstoreUploadHandler):
	def post(self):
		upload_files = self.get_uploads('file')
		blob_info = upload_files[0]
		url = images.get_serving_url(blob_info.key())
		logging.info('uploaded %s', url)

		display_date = datetime.datetime.fromtimestamp(
			int(blob_info.filename.split('.',1)[0])
		) + datetime.timedelta(minutes = random.randint( 60*8, 60*22 ))

		greeting = Greeting(
			display_date = display_date,
			added_date = datetime.datetime.now(),
			img_url = url,
			sent = False
			)
		greeting.put()
		self.response.write('Bedankt, namens Jaap & Nadia!<br /><br /><a href="/">Bekijk alle entries</a>')

# halfhourly call to see if a message should be sent
class SendOneHandler(webapp2.RequestHandler):
	def get(self):
		greetings = Greeting.query(Greeting.sent==False).order(Greeting.display_date).fetch(10)

		if len(greetings) == 0:
			self.response.write('Everything has been sent!');
			return

		for greeting in greetings:
			if (greeting.display_date < datetime.datetime.now()):
				html = '<html><head><meta charset="utf-8"></head><body><img class="dither" src="%s=w384" /></body></html>' % greeting.img_url
				url = 'http://remote.bergcloud.com/playground/direct_print/' + PRINTER_CODE
				form_fields = {
					"html": html,
				}
				form_data = urllib.urlencode(form_fields)

				result = urlfetch.fetch(url=url,
					payload=form_data,
					method=urlfetch.POST,
					headers={'Content-Type': 'application/x-www-form-urlencoded'}
					)

				if result.status_code == 200:
					greeting.sent = True
					greeting.put()

					logging.info('Sent: ' + greeting.img_url)
					self.response.write("sent: " + greeting.img_url);
					return

				logging.error('Error sending to %s: %d', url, result.status_code)



		self.response.write("Nothing sent. Next will be at: %s" % greetings[0].display_date);


app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/api/uploadurl', UploadUrlHandler),
    ('/api/upload', UploadHandler),
    ('/cron/sendone', SendOneHandler)
], debug=True)
