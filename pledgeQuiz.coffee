# Description:
#   Pledge quizes for the Pledge Meetings
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   quiz start - start the quiz with weighted odds
#	quiz correct - gives the selected pledges a correct response for the current 	
		question and moves on to the next question
#	quiz incorrect - gives the slected pledges an incorrect response for the current 
		question and moves on to the next question
#
# Author:
#   Cameron Piel



class pledgeQuiz
	
	constructor: (@robot) ->

		pledges = ["Anika Gera", "Austin Reinchart", "Colin Higgins", "Jack David Tunstall", "Jesse Thaden", "Karthik Bala", "Micheal Hankin", "Pushkar Lanka", "Robert Le", "Sarah Gorring", "Shay Sayed", "TJ Kidd", "Vanessa Chang"]

		members = [ "Addy Kim", "Andy Anderson","Anika Gera", "Apurva Gorti", "Austin Reinchart", "Basil Hariri", "Braden Stotmeister", "Bri Connley", "Bryan Powell", "Cameron Piel", "Charles Inglis", "Chase Terry", "Claire Bingham","Claudio Wilson", "Clay Smalley", "Colin Higgins", "Colt Whaley", "Danielle Cogburn", "Dan Rutledge", "David Guerrero", "David Talamas", "David Wetterau", "Drew Romanyk", "Eryn Li", "Gregory Cerna", "Haley Connelly", "Hayley Call", "Jack Ceverha", "Jack David Tunstall", "Jena Cameron", "Jesse Thaden", "Josh Slocum", "Karthik Bala", "Kellly McKinnon", "Kieran Vanderslice", "Lindsey Kehlmann", "Maria Belyaeva", "Melody Park", "Micheal Hankin", "Nick Ginther", "Peyton Sarmiento", "Pushkar Lanka", "Rainier Ababoa", "Reid Mckenzie", "Robert Le", "Robert Lynch", "Sam Barani", "Sam Tallent", "Sarah Gorring", "Shay Sayed", "Steven Diaz", "Steven Rogers", "Taylor Barnett", "Thomas Gaubert", "TJ Kidd", "Vanessa Chang"
		"Adolfo Muller", "Zach Casares"]

		classes = ["Founding Class", "Alpha Class", "Beta Class", "Gamma Class"]

		pledgesLeft = pledges

		questions = 
			[selectPledge() + " and " + selectPledge() + "tell me the Greek AlphaBet", 
			selectPledge + " tell me the lineage of " + selectAcive(), 
			selectPledge() + " and " + selectPledge() + " tell me all of " + selectClass()]
		
	printHelp: (msg) ->
		msg.send """
				quiz start - start the quiz with weighted odds
				quiz correct - gives the selected pledges a correct response for the current question and moves on to the next question
				quiz incorrect - gives the slected pledges an incorrect response for the current question and moves on to the next question
				"""

	selectPledge = () ->
		pledge = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
		pledgesLeft.splice(pledgesLeft.indexOf(firstPledge), 1)
		return pledge

	selectActive = () ->
		return members[Math.floor(Math.random() * members.length)]

	selectClass = () ->
		return classes[Math.floor(Math.random() * classes.length)]

	startQuiz: (msg) ->
		msg.send "Welcome Pledges to Quiz Time!
		msg.send "Good luck and may the odds forever be in your favor!"
		for (x = 0, len = questions.length; x < len, x++)
			msg.send questions[x]
			while true
				#if hears correct or incorrect, break the loop
		msg.send "The quiz is now over, hope you did well. Or else...."
