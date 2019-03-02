from __future__ import absolute_import
from flask import Flask, render_template, request
#import requests
from parseReports import parseReports
import json
import urllib

app = Flask(__name__)

# all reports will be in Pullman, WA
# when appending this to the end of a 
# query string, the result will be in
# the right area
generalRegion = "Pullman WA"

# Decoraters display different pages
@app.route('/')
def index():
	return render_template("index.html")

#this is for each individual report
@app.route('/reports/<int:rid>')
def show_report(rid):
	'''This function displays a page
	for a given rid. The argument to this
	function signifies the reportID number
	'''
	data = get_data("https://******api.us-west-2.amazonaws.com/beta/getreports?rid=" + str(rid))
	if("does not exist" in data):
		return data
	ridJson = json.loads(data)
	# Get url to search for in the map
	mapurl = createMapURL(ridJson['location'])
	print(mapurl)
	return render_template("rid.html", json=ridJson, mapURL=mapurl)

@app.route('/table')
def table():
	'''
	This function generates the table used
	in the operator view and places the
	html on the server
	'''
	text = request.args.get('jsdata')
	print(text)
	jsonList = []
	if text:
		data = get_data(" https://******api.us-west-2.amazonaws.com/beta/getreports")
		jsonList = parseReports(data)

	return render_template('table.html', reportList=jsonList)


if __name__ == '__main__':
	app.run(debug=True)


def get_data(url):
	'''
	Helper function to convert get
	request into JSON from specified url
	'''
	return requests.get(url).json()

def createMapURL(location):
	'''
	This function will create a url used
	for an embed google map
	Usage:
	>>> createMapURL("700 Stadium Way")
	''https://www.google.com/maps/embed/v1/place?key=*******&q=700+Stadium+Way+Pullman+WA'
	'''
	url = 'https://www.google.com/maps/embed/v1/place?key=*******&'
	# we append the general region to make sure result is in pullman
	# if this app was running in a different area/school, generalRegion would need to be changed
	query = {'q' : location+generalRegion }
	url = url+urllib.parse.urlencode(query)

	return url


if __name__ == '__main__':
	import doctest
	doctest.testmod()
