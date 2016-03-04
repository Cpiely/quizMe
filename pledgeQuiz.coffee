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

		@curCandidates = []
		@activeQuiz = false

	checkPermission: (msg) ->
		if @admins.length == 0 || msg.message.user.name in @admins
			return true
		else
			msg.send "You can't do this bitch"
			return false

	save: -> 
		@robot.logger.debug "Saving Pledge Quiz Data: " + JSON.stringify(@storage)
		@robot.brain.emit 'save'

	askQuestion = (msg) ->
		

		if(@curCandidates.length == 0)
			getCandidate(msg)

		questions = 
			[@curCandidates[0] + " and " + @curCandidates[1] + " tell me the Greek AlphaBet", 
			@curCandidates[2] + " tell me the lineage of " + selectActive(),  
			@curCandidates[3] + " tell me the lineage of " + selectActive(),
			@curCandidates[4] + " tell me the lineage of " + selectActive(),
			@curCandidates[5] + " and " + @curCandidates[6] + " tell me all of " + selectClass()]
		return questions[@curQuestion]

	getCandidate = (msg) ->
		x = 6
		while (x >= 0)
			ques = 0
			if (x == 6 || x == 5)
				ques = 0
			else if (x <= 2 && x >= 4)
				ques = 1
			else if (x == 1 || x == 0)
				ques = 2
			pledge = selectPledge()
			while ((pledge in @curCandidates) || !@storage.pledges[pledge][ques])
				if (!@storage.pledges[pledge][ques])
					msg.send "Got one Coach! " + pledge
				pledge = selectPledge()	
			@curCandidates.push (pledge)
			x -= 1
		return true


	selectPledge = (msg) ->
		getPledge = []
		for pledge, user of @storage.pledges
			getPledge.push(pledge)
		pledge = getPledge[Math.floor(Math.random() * getPledge.length)]

		return pledge

	selectActive = (msg) ->
		getUser = []
		for member, user of @storage.members
			getUser.push(member)
		return getUser[Math.floor(Math.random() * getUser.length)]

	selectClass = (msg) ->
		getClass = []
		for year, user of @storage.classes
			getClass.push(year)
		return getClass[Math.floor(Math.random() * getClass.length)]

	isUser = (object, st) ->
		for subject, user of st
			if subject == object
				return true
		return false

	startQuiz: (msg) ->
		@activeQuiz = true
		@curQuestion = 0
		@curCandidates = []
		msg.send "Welcome Pledges to Quiz Time!"
		msg.send "Good luck and may the odds forever be in your favor!"
		msg.send askQuestion(msg)

	stopQuiz = (msg) ->
		@activeQuiz = false
		@curQuestion = 0
		@curCandidates = []
		return true

	correct: (msg) ->
		if(@activeQuiz)
			msg.send "Congradulations on getting the question right!"
			if (@curQuestion == 0)
				@storage.pledges[@curCandidates[0]][0] = false
				@storage.pledges[@curCandidates[1]][0] = false
			else if (@curQuestion <= 3 && @curQuestion >= 1)
				@storage.pledges[@curCandidates[@curQuestion + 1]][1] = false
				msg.send @curCandidates[@curQuestion + 1]
			else if (@curQuestion == 4)
				@storage.pledges[@curCandidates[6]][2] = false

			if(@curQuestion <=3)
				@curQuestion = @curQuestion + 1
				msg.send askQuestion(msg)
			else
				stopQuiz(msg)
		else
			msg.send "There is not a quiz currently."

	incorrect: (msg) ->
		if(@activeQuiz)
			msg.send "Well, you tried"
			if(@curQuestion <=3)
				@curQuestion = @curQuestion + 1
				msg.send askQuestion(msg)
			else
				stopQuiz(msg)
		else
			msg.send "There is not a quiz currently."

	add = (msg, st) ->
		cmd = msg.match[1].split(" ")
		user = cmd[1] + " " + cmd[2]
		try
			if not isUser(user, st)
				st[user] = [true,true,true]
				msg.send "Added " + user
			else
				msg.send user + " is already on the List"
		catch
			st = []
			st[user] = [true,true,true]
			msg.send "Added " + user

		return st

	addMember: (msg) ->
		@storage.members = add(msg, @storage.members)
		@save
 
	addPledge: (msg) ->
		@storage.pledges = add(msg, @storage.pledges)
		@save

	addClass: (msg) ->
		@storage.classes = add(msg, @storage.classes)
		@save

	removeMember: (msg) ->
		delete @storage.members[user]

	removePledge: (msg) ->
		delete @storage.pledges[user]

	removeClass: (msg) ->
		delete @storage.classes[user]
	
	clearMembers: (msg) ->
		@storage.members = []
		@save
		msg.send "Members cleared"
	
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
			checkMessage(msg, cmd)

	robot.hear /^\s*quiz\s*$/i, (msg) ->
		msg.send "Invalid command, say \"quiz help\" for help"

	robot.hear /^\s*quiz (.*)/i, (msg) ->
		cmd = msg.match[1].split(" ")[0]
		switch cmd
			when "start" 
				return checkRestrictedMessage(msg, quiz.startQuiz)
			when "stop" 
				return checkRestrictedMessage(msg, quiz.stopQuiz)
			when "correct" 
				return checkRestrictedMessage(msg, quiz.correct)
			when "incorrect" 
				return checkRestrictedMessage(msg, quiz.incorrect)
			when "addMember"
				return checkRestrictedMessage(msg, quiz.addMember)
			when "addPledge"
				return checkRestrictedMessage(msg, quiz.addPledge)
			when "addClass" 
				return checkRestrictedMessage(msg, quiz.addClass)
			when "removeMember" 
				return checkRestrictedMessage(msg, quiz.removeMember)
			when "removePledge" 
				return checkRestrictedMessage(msg, quiz.removePledge)
			when "removeClass" 
				return checkRestrictedMessage(msg, quiz.removeClass)
			when "clearMembers"
				return checkRestrictedMessage(msg, quiz.clearMembers)
			when "clearPledges" 
				return checkRestrictedMessage(msg, quiz.clearPledges)
			when "clearClasses" 
				return checkRestrictedMessage(msg, quiz.clearClasses)
			when "results"
				return checkRestrictedMessage(msg, quiz.results)
			when "help" then quiz.printHelp msg
			else msg.send "Invalid command, say \"quiz help\" for help"
