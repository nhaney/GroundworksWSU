import json

def parseReports(jsonReport):
	'''
	This function takes the entire report and outputs
	a list of report objects.
	This list will be used to create the table in the 
	operator view.
	>>> parseReports('{"Items": [{"test1":1}, {"test2":2}]}')
	[{'test1': 1}, {'test2': 2}]
	'''
	d = {}
	returnList = []
	print

	d = json.loads(jsonReport)
	
	for report in d['Items']:
		returnList.append(report)

	return returnList

if __name__ == '__main__':
	import doctest
	doctest.testmod()