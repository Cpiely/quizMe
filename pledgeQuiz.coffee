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
#		question and moves on to the next question
#	quiz incorrect - gives the slected pledges an incorrect response for the current 
#		question and moves on to the next question
#
# Author:
#   Cameron Piel

class pledgeQuiz
	
	constructor: (@robot) ->
		storageLoaded = =>
			@storage = @robot.brain.data.pledgeQuiz ||= {
				members: {}
				pledges: {}
				classes: {}
			}
			@robot.logger.debug "quizMe data loaded: " + JSON.stringify(@storage)

		@channels = ["pledges", "shell"]

		@admins = ["sexapiel", "stotmeister", "davidtalamas", "shell"]

		@robot.brain.on "loaded", storageLoaded
		storageLoaded()

		@pledgesLeft = @storage.pledges

		@questions = 
			[selectPledge() + " and " + selectPledge() + "tell me the Greek AlphaBet", 
			selectPledge + " tell me the lineage of " + selectAcive(), 
			selectPledge() + " and " + selectPledge() + " tell me all of " + selectClass()]

	checkPermission: (msg) ->
		if @admins.length == 0 || msg.message.user.name in @admins
			return true
		else
			msg.send "You can't do this bitch"
			return false

	save: -> 
		@robot.logger.debug "Saving Pledge Quiz Data: " + JSON.stringify(@storage)
		@robot.brain.emit 'save'

	selectPledge = () ->
		pledge = @pledgesLeft[Math.floor(Math.random() * @pledgesLeft.length)]
		@pledgesLeft.splice(@pledgesLeft.indexOf(firstPledge), 1)
		return pledge

	selectActive = () ->
		return @storage.members[Math.floor(Math.random() * @storage.members.length)]

	selectClass = () ->
		return @storage.classes[Math.floor(Math.random() * @storage.classes.length)]

	isMember = (user) ->
		for member in @storage.members
			if member == user
				return true
		return false

	isPledge = (user) ->
		for pledge in @storage.pledges
			if pledge == user
				return true
		return false

	isClass = (user) ->
		for year in @storage.classes
			if year == user
				return true
		return false

	startQuiz: (msg) ->
		msg.send "Welcome Pledges to Quiz Time!"
		msg.send "Good luck and may the odds forever be in your favor!"
		@curQuestion = 0;
		msg.send @questions[curQuestion]
		@curQuestion = @curQuestion + 1

	stopQuiz: (msg) ->
		msg.send "Hello"

	correct: (msg) ->
		msg.send "Congradulations on getting the question right!"
		msg.send @question[curQuestion]

	incorrect: (msg) ->
		msg.send "Well, you tried"
		msg.send @question[curQuestion]

	addMember: (msg) ->
		user = msg.message.user.name.toLowerCase()
		if isMember(user)
			msg.send "That person is already a member"
		@storage.members[user] = 1.0
 
	addPledge: (msg) ->
		user = msg.message.user.name.toLowerCase()
		if isPledge(user)
			msg.send "That person is already a pledge"
		@storage.pledges[user] = 1.0

	addClass: (msg) ->
		user = msg.message.user.name.toLowerCase()
		if isClass(user)
			msg.send "That is already a class"
		@storage.classes[user] = 1.0

	removeMember: (msg) ->
		user = msg.message.user.name.toLowerCase()
		if isMember(user)
			delete @storage.members[user]
			msg.send "They have been removed as a member"
		else
			msg.send "They are not a user"

	removePledge: (msg) ->
		user = msg.message.user.name.toLowerCase()
		if isPledge(user)
			delete @storage.pledges[user]
			msg.send "They have been removed as a pledge"
		else
			msg.send "They are not a pledge"
	
	removeClass: (msg) ->
		user = msg.message.user.name.toLowerCase()
		if isClass(user)
			delete @storage.classes[user]
			msg.send "It have been removed as a class"
		else
			msg.send "It is not a class"
	
	clearMembers: (msg) ->
		if Objects.keys(@storage.memebers).length > 0
			@storage.memebers = {}
			@save
			msg.send "Members cleared"
		else
			msg.send "There are no memebers to clear"
	
	clearPledges: (msg) ->
		if Objects.keys(@storage.pledges).length > 0
			@storage.pledges = {}
			@save
			msg.send "Pledges cleared"
		else
			msg.send "There are no pledges to clear"
	
	clearClasses: (msg) ->
		if Objects.keys(@storage.classes).length > 0
			@storage.classes = {}
			@save
			msg.send "Classes cleared"
		else
			msg.send "There are no classes to clear"

	results: (msg) ->
		msg.send "Hi"
	
	printHelp: (msg) ->
		msg.send """
		quiz start - start the quiz with weighted odds
		quiz correct - gives the selected pledges a correct response for the 	current question and moves on to the next question
		quiz incorrect - gives the slected pledges an incorrect response for 	the current question and moves on to the next question
		quiz addMember ___ - adds a person to the memeber list
		quiz addPledge ___ - adds a person to the pledge list
		quiz addClass ___ - adds a class to the list
		quiz removeMember ___ - removes a member from the list
		quiz removePledge ___ - removes a pledge from the list
		quiz removeClass ___ - removes a class from the list
		quiz clearMember - clears the member list
		quiz clearPledge - clears the pledge list
		quiz clearClass - clears the class list
		quiz results - prints the list of all what 
			questions the pledges have 	left
		 """
module.exports = (robot) ->

	quiz = new pledgeQuiz robot
	msg.send "Hello"
	# super janky way to pass data to methods bc random things are undefined
	# for no apparent reason
	checkMessage = (msg, cmd, data = null, data2 = null) ->
		if quiz.validChannel msg
			if data
				if data2
					cmd msg, data, data2
				else
					cmd msg, data
			else
				cmd msg

	checkRestrictedMessage = (msg, cmd) ->
		if quiz.checkPermission msg
			checkMessage msg, cmd

	robot.hear /^\s*quiz\s*$/i, (msg) ->
		msg.send "Invalid command, say \"quiz help\" for help"

	robot.hear /^\s*quiz (.*)/i, (msg) ->
		cmd = msg.match[1]
		switch cmd
			when "start" then checkMessage msg, quiz.startQuiz
			when "stop" then checkMessage msg, quiz.stoptQuiz            
			when "correct" then checkMessage msg, quiz.correct
			when "incorrect" then checkMessage msg, quiz.incorrect
			when "addMember" then checkMessage msg, quiz.addMember
			when "addPledge" then checkMessage msg, quiz.addPledge
			when "addClass" then checkMessage msg, quiz.addClass
			when "removeMember" then checkMessage msg, quiz.removeMember
			when "removePledge" then checkMessage msg, quiz.removePledge
			when "removeClass" then checkMessage msg, quiz.removeClass
			when "clearMembers" then checkRestrictedMessage msg, quiz.clearMembers
			when "clearPledges" then checkRestrictedMessage msg, quiz.clearPledges
			when "clearClasses" then checkRestrictedMessage msg, quiz.clearClasses
			when "results" then checkRestrictedMessage msg, quiz.results
			when "help" then quiz.printHelp msg
			else msg.send "Invalid command, say \"quiz help\" for help"
