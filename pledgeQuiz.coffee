pledges = ["Anika Gera ", "Austin Reinchart ", "Colin Higgins ", "Jack 'David' Tunstall ", "Jesse Thaden ", "Karthik Bala ", "Micheal Hankin ", "Pushkar Lanka ", "Robert Le ", "Sarah Gorring ", "Shay Sayed ", "TJ Kidd ", "Vanessa Chang "]

actives = ["Adolfo Muller", "Addy Kim", "Andy Anderson", "Apurva Gorti", "Basil Hariri", "Braden Stotmeister", "Bri Connley", "Bryan Powell", "Cameron Piel", "Charles Inglis", "Chase Terry", "Claire Bingham", "Claudio Wilson", "Clay Smalley", "Colt Whaley", "Dan Rutledge", "Danielle Cogburn", "David Guerrero", "David Talamas", "David Wetterau", "Drew Romanyk", "Eryn Li", "Gregory Cerna", "Haley Connelly", "Hayley Call", "Jack Ceverha", "Jena Cameron", "Josh Slocum", "Kellly McKinnon", "Kieran Vanderslice", "Lindsey Kehlmann", "Maria Belyaeva", "Melody Park", "Nick Ginther", "Peyton Sarmiento", "Rainier Ababoa", "Reid Mckenzie", "Robert Lynch", "Sam Barani", "Sam Tallent", "Steven Diaz", "Steven Rogers", "Taylor Barnett", "Thomas Gaubert", "Zach Casares"]

classes = ["Founding Class", "Alpha Class", "Beta Class"]

pledgesLeft = pledges

pledge1 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge1), 1)

pledge2 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge2), 1)

pledge3 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge3), 1)

pledge4 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge4), 1)

pledge5 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge5), 1)

pledge6 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge6), 1)

pledge7 = pledgesLeft[Math.floor(Math.random() * pledgesLeft.length)]
pledgesLeft.splice(pledgesLeft.indexOf(pledge7), 1)


questionOne = pledge1 + "and " + pledge2 + "tell me the Greek Alphabet"

questionTwo = pledge3 + "tell me the line of " + actives[Math.floor(Math.random() * actives.length)]

question3 = pledge4 + "tell me the line of " + actives[Math.floor(Math.random() * actives.length)]

question4 = pledge5 + "tell me the line of " + actives[Math.floor(Math.random() * actives.length)]

questionThree = pledge6 + "and " + pledge7 + "tell me all of " + classes[Math.floor(Math.random() * classes.length)]

alert questionOne
alert questionTwo
alert question3
alert question4
alert questionThree
