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
			@storage = @robot.brain.data.quiz ||= {
				members: []
				pledges: []
				classes: []
			}
			@robot.logger.debug "quizMe data loaded: " + JSON.stringify(@storage)

		@channels = ["pledges", "Shell"]

		@admins = ["sexapiel", "stotmeister", "davidtalamas", "Shell"]

		@robot.brain.on "loaded", storageLoaded
		storageLoaded()

		@pledgesLeft = @storage.pledges

	checkPermission: (msg) ->
		if @admins.length == 0 || msg.message.user.name in @admins
			return true
		else
			msg.send "You can't do this bitch"
			return false

	save: -> 
		@robot.logger.debug "Saving Pledge Quiz Data: " + JSON.stringify(@storage)
		@robot.brain.emit 'save'

	askQuestion: (msg) ->
		questions = 
			[selectPledge() + " and " + selectPledge() + "tell me the Greek AlphaBet", 
			selectPledge + " tell me the lineage of " + selectAcive(),  
			selectPledge + " tell me the lineage of " + selectAcive(),
			selectPledge + " tell me the lineage of " + selectAcive(),
			selectPledge() + " and " + selectPledge() + " tell me all of " + selectClass()]

		msg.send questions[@curQuestion]

	selectPledge = () ->
		pledge = @pledgesLeft[Math.floor(Math.random() * @pledgesLeft.length)]
		@pledgesLeft.splice(@pledgesLeft.indexOf(pledge), 1)
		return pledge

	selectActive = () ->
		return @storage.members[Math.floor(Math.random() * @storage.members.length)]

	selectClass = () ->
		return @storage.classes[Math.floor(Math.random() * @storage.classes.length)]

	isMember = (msg, subject) ->
		for member, user of @storage.members
			#msg.send ("Cameron Piel" == member) + member + " " + subject
			if member == subject
				msg.send "hello"
				return true
		return false

	isPledge = (msg, user) ->
		for pledge in @storage.pledges
			if pledge == user
				return true
		return false

	isClass = (msg, user) ->
		for year in @storage.classes
			if year == user
				return true
		return false

	startQuiz: (msg) ->
		msg.send "Welcome Pledges to Quiz Time!"
		msg.send "Good luck and may the odds forever be in your favor!"
		@curQuestion = 0;
		askQuestion()
		@curQuestion = @curQuestion + 1

	stopQuiz: (msg) ->
		msg.send selectAcive
		msg.send selectAcive
		msg.send selectAcive
		msg.send selectClass
		msg.send selectPledge
		msg.send selectPledge
		msg.send selectPledge
		msg.send selectPledge
		msg.send selectPledge

	correct: (msg) ->
		msg.send "Congradulations on getting the question right!"
		msg.send @question[curQuestion]

	incorrect: (msg) ->
		msg.send "Well, you tried"
		msg.send @question[curQuestion]

	addMember: (msg) ->
		user = msg.match[1].split(" ")[1] + " " + msg.match[1].split(" ")[2]
		try
			if not isMember(msg, user)
				@storage.members[user] = 1.0
				msg.send "Added member " + user
			else
				msg.send "Already a Member"
		catch
			@storage.members = []
			@storage.members[user] = 1.0
			msg.send "Forced added member " + user
		finally
			@save
		
 
	addPledge: (msg) ->
		user = msg.match[1].split(" ")[1] + " " + msg.match[1].split(" ")[2]
		try
			if not isPledge(msg, user)
				@storage.pledges[user] = 1.0
			else
				msg.send "Already a Pledge"
		catch
			@storage.pledges = []
			@storage.pledges[user] = 1.0
		finally
			@save

	addClass: (msg) ->
		user = msg.match[1].split(" ")[1]
		try
			if not isClass(msg, user)
				@storage.classes[user] = 1.0
			else
				msg.send "Already a Class"
		catch
			@storage.classes = []
			@storage.classes[user] = 1.0
		finally
			@save

	removeMember: (msg) ->
		user = msg.match[1].split(" ")[1] + " " + msg.match[1].split(" ")[2]
		#if isMember(user)
		delete @storage.members[user]
		#	msg.send "They have been removed as a member"
		#else
		#	msg.send "They are not a user"

	removePledge: (msg) ->
		user = msg.match[1].split(" ")[1] + " " + msg.match[1].split(" ")[2]
		#if isPledge(user)
		delete @storage.pledges[user]
		#	msg.send "They have been removed as a pledge"
		#else
		#	msg.send "They are not a pledge"
	
	removeClass: (msg) ->
		user = msg.match[1].split(" ")[1]
		#if isClass(user)
		delete @storage.classes[user]
		#	msg.send "It have been removed as a class"
		#else
		#	msg.send "It is not a class"
	
	clearMembers: (msg) ->
		#if @storage.members.length > 0
		@storage.members = []
		@save
		msg.send "Members cleared"
		#else
			#msg.send "There are no members to clear"
	
	clearPledges: (msg) ->
		@storage.pledges = []
		@save
		msg.send "Pledges cleared"
	
	clearClasses: (msg) ->
		@storage.classes = []
		@save
		msg.send "Classes cleared"

	results: (msg) ->
		str = "Members:"
		for member, user of @storage.members
            str = str + "\n#{member}"
        msg.send str + "\n"
        
        str = "Pledges:"
		for pledge, user of @storage.pledges
            str = str + "\n#{pledge}"
        msg.send str + "\n"
        
        str = "Classes:"
		for year, user of @storage.classes
            str = str + "\n#{year}"
        msg.send str + "\n"
	
	validChannel: (channel) -> @channels.length == 0 || channel in @channels

	printHelp: (msg) ->
		msg.send """
		quiz start - start the quiz with weighted odds
		quiz correct - gives the selected pledges a correct response for the 	current question and moves on to the next question
		quiz incorrect - gives the slected pledges an incorrect response for the 	current question and moves on to the next question
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
			questions the pledges have left
		 """
module.exports = (robot) ->

	quiz = new pledgeQuiz(robot)

	checkMessage = (msg, cmd) ->
		if quiz.validChannel msg.message.user.room
			cmd msg
		else msg.send "You must be in a valid channel to use this command"

	checkRestrictedMessage = (msg, cmd) ->
		if quiz.checkPermission msg
			checkMessage msg, cmd

	robot.hear /^\s*quiz\s*$/i, (msg) ->
		msg.send "Invalid command, say \"quiz help\" for help"

	robot.hear /^\s*quiz (.*)/i, (msg) ->
		cmd = msg.match[1].split(" ")[0]
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
