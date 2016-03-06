# Description:
#   Quizes for the Meetings
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   quiz start - start the quiz with weighted odds
#	quiz correct - gives the selected quiz taker a correct response for the current question and moves on to the next question
#	quiz incorrect - gives the slected quiz taker an incorrect response for the current 
#		question and moves on to the next question
#
# Author:
#   Cameron Piel

class quizMe
	constructor: (@robot) ->
		storageLoaded = =>
			@storage = @robot.brain.data.quizMe ||= {
				members: []
				quizTakers: []
				classes: []
			}
			@robot.logger.debug "quizMe data loaded: " + JSON.stringify(@storage)

		@channels = ["quizzes", "Shell"]

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
		@robot.logger.debug "Saving Quiz Data: " + JSON.stringify(@storage)
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
			takeQuiz = selectTaker()
			while ((takeQuiz in @curCandidates) || !@storage.quizTakers[takeQuiz][ques])
				takeQuiz = selectTaker()	
			@curCandidates.push (takeQuiz)
			x -= 1
		return true


	selectTaker = (msg) ->
		getTaker = []
		for subject, user of @storage.quizTakers
			getTaker.push(subject)

		return getTaker[Math.floor(Math.random() * getTaker.length)]

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
		msg.send "Welcome to Quiz Time!"
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
				@storage.quizTakers[@curCandidates[0]][0] = false
				@storage.quizTakers[@curCandidates[1]][0] = false
			else if (@curQuestion <= 3 && @curQuestion >= 1)
				@storage.quizTakers[@curCandidates[@curQuestion + 1]][1] = false
				msg.send @curCandidates[@curQuestion + 1]
			else if (@curQuestion == 4)
				@storage.quizTakers[@curCandidates[5]][2] = false
				@storage.quizTakers[@curCandidates[6]][2] = false

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
 
	addTaker: (msg) ->
		@storage.quizTakers = add(msg, @storage.quizTakers)
		@save

	addClass: (msg) ->
		@storage.classes = add(msg, @storage.classes)
		@save

	removeMember: (msg) ->
		delete @storage.members[user]

	removeTaker: (msg) ->
		delete @storage.quizTakers[user]

	removeClass: (msg) ->
		delete @storage.classes[user]
	
	clearMembers: (msg) ->
		@storage.members = []
		@save
		msg.send "Members cleared"
	
	clearTakers: (msg) ->
		@storage.quizTakers = []
		@save
		msg.send "Quiz takers cleared"
	
	clearClasses: (msg) ->
		@storage.classes = []
		@save
		msg.send "Classes cleared"

	results: (msg) ->
		str = "Members:"
		for member, user of @storage.members
            str = str + "\n#{member}"
        msg.send str + "\n"
        
        str = "Quiz Takers:"
        quesLeft = @storage.quizTakers
		for subject, user of quesLeft
            str = str + "\n#{subject}"
            if (quesLeft[subject][0] || quesLeft[subject][1] || quesLeft[subject][2])
            	str += " still needs to answer: "
            	if (quesLeft[subject][0])
            		str += "\n\tQuestion 1"
            	if (quesLeft[subject][1])
            		str += "\n\tQuestion 2"
            	if (quesLeft[subject][2])
            		str += "\n\tQuestion 3"
            else
            	str += " has answered every question \n"
        msg.send str + "\n"
        
        str = "Classes:"
		for year, user of @storage.classes
            str = str + "\n#{year}"
        msg.send str + "\n"
	
	validChannel: (channel) -> @channels.length == 0 || channel in @channels

	printHelp: (msg) ->
		msg.send """
		quizMe start - start the quiz with weighted odds
		quizMe correct - gives the selected quiz taker a correct response for the current question and moves on to the next question
		quizMe incorrect - gives the slected quiz takers an incorrect response for the current question and moves on to the next question
		quizMe addMember ___ - adds a person to the memeber list
		quizMe addTaker ___ - adds a person to the quiz takers list
		quizMe addClass ___ - adds a class to the list
		quizMe removeMember ___ - removes a member from the list
		quizMe removeTaker ___ - removes a quiz taker from the list
		quizMe removeClass ___ - removes a class from the list
		quizMe clearMember - clears the member list
		quizMe clearTakers - clears the quiz taker list
		quizMe clearClass - clears the class list
		quizMe results - prints the list of all what 
			questions the quiz takers have left
		 """
module.exports = (robot) ->

	quizMe = new quizMe(robot)

	checkMessage = (msg, cmd) ->
		if quizMe .validChannel msg.message.user.room
			cmd msg
		else msg.send "You must be in a valid channel to use this command"

	checkRestrictedMessage = (msg, cmd) ->
		if quizMe .checkPermission msg
			checkMessage(msg, cmd)

	robot.hear /^\s*quizMe\s*$/i, (msg) ->
		msg.send "Invalid command, say \"quizMe  help\" for help"

	robot.hear /^\s*quizMe (.*)/i, (msg) ->
		cmd = msg.match[1].split(" ")[0]
		switch cmd
			when "start" 
				return checkRestrictedMessage(msg, quizMe.startQuiz)
			when "stop" 
				return checkRestrictedMessage(msg, quizMe.stopQuiz)
			when "correct" 
				return checkRestrictedMessage(msg, quizMe.correct)
			when "incorrect" 
				return checkRestrictedMessage(msg, quizMe.incorrect)
			when "addMember"
				return checkRestrictedMessage(msg, quizMe.addMember)
			when "addTaker"
				return checkRestrictedMessage(msg, quizMe.addTaker)
			when "addClass" 
				return checkRestrictedMessage(msg, quizMe.addClass)
			when "removeMember" 
				return checkRestrictedMessage(msg, quizMe.removeMember)
			when "removeTaker" 
				return checkRestrictedMessage(msg, quizMe.removeTaker)
			when "removeClass" 
				return checkRestrictedMessage(msg, quizMe.removeClass)
			when "clearMembers"
				return checkRestrictedMessage(msg, quizMe.clearMembers)
			when "clearTakers" 
				return checkRestrictedMessage(msg, quizMe.clearTakers)
			when "clearClasses" 
				return checkRestrictedMessage(msg, quizMe.clearClasses)
			when "results"
				return checkRestrictedMessage(msg, quizMe.results)
			when "help" then quizMe.printHelp msg
			else msg.send "Invalid command, say \"quizMe help\" for help"
