require 'sinatra'
# require "sinatra/reloader" if development?


enable :sessions

greetings = ['Hey there','Greetings!', 'Welcome back!']
timed_greetings = ['Good morning!','Good afternoon!','Good evening!' ]
code = 'daaaniel'

def determine_response body
	#customize response message according to user input

	#keyword lists
	greeting_kwd = ['hi', 'hello', 'hey']
	who_kwd = ['who']
	what_kwd = ['what', 'features', 'functions', 'actions', 'help']
	where_kwd = ['where']
	when_kwd = ['when', 'time']
	why_kwd = ['why']
	joke_kwd = ['joke']
	fact_kwd = ['fact']
	funny_kwd = ['lol', 'haha', 'hh']

	body = body.downcase.strip
	if include_keywords body, greeting_kwd
		return "Hi there, my app tells you a little about me.<br>"
	elsif include_keywords body, who_kwd
		return "It's MeBot created by Daniel here!<br>
						If you want to know more about me, you can input 'fact' to the Body parameter."
	elsif include_keywords body, what_kwd
		return "You can ask anything you are interested about me.<br>"
	elsif include_keywords body, where_kwd
		return "I'm in Pittsburgh~<br>"
	elsif include_keywords body, when_kwd
		return "The bot is made in Spring 2020.<br>"
	elsif include_keywords body, why_kwd
		return "It was made for class project of 49714-pfop.<br>"
	elsif include_keywords body, joke_kwd
		array_of_lines = IO.readlines("jokes.txt")
		return array_of_lines.sample
	elsif include_keywords body, fact_kwd
		array_of_lines = IO.readlines("facts.txt")
		return array_of_lines.sample
	elsif include_keywords body, funny_kwd
		return "Nice one right lol."
	else
		return "Sorry, your input cannot be understood by the bot.<br>
						Try using two parameters called Body and From."
	end
end

def include_keywords body, keywords
	# check if string contains any word in the keywords array
	keywords.each do |keyword|
		puts "now checking" + keyword
		if body.downcase.include?(keyword)
			return true
		end
  end
	return false
end

get "/" do
	redirect "/about"
end

get "/about" do
	time = Time.now
	hour = time.hour
	if hour < 12 && hour >= 0
		timed_greeting = timed_greetings[0]
	elsif hour >= 12 && hour <18
		timed_greeting = timed_greetings[1]
	else
		timed_greeting = timed_greetings[2]
	end
	session["visits"] ||= 0 # Set the session to 0 if it hasn't been set before
  session["visits"] = session["visits"] + 1  # adds one to the current value (increments)
	if session['first_name'].nil?
		greeting = "#{timed_greeting}<br>
					You haven't signed up. <br>"
	else
		greeting = "#{greetings.sample} " + "<span>" + session['first_name'] + "</span><br>"
	end
	msg = "My app helps you develop your personal training plan. You have visited #{session["visits"].to_s} times as of #{time.strftime("%A %B %d, %Y %H:%M")}"

	erb :about, :locals => {:msg => msg, :greeting => greeting}
end

get "/response" do
	if params[:Body].nil?
		return "Sorry, your input cannot be understood by the bot.<br>
						Try using the parameter called Body."
	else
		determine_response params[:Body]
	end
end

get "/signup" do
	if not(session['first_name'].nil? || session['number'].nil?) # if user has signed up
		"Hey #{session['first_name']}, you have signed up. Explore more about the bot!"
	elsif params[:code].nil? || params[:code] != code
		403
	else
		erb :signup
	end
end

post "/signup" do
	if params[:code].nil? || params[:code] != code
		403
	elsif params[:number].nil? || params[:first_name].nil?
		"You didn't enter all of the input fields."
	else
		session['first_name'] = params['first_name']
		session['number'] = params['number']
		"Your first name is #{params[:first_name]}, your number is #{params[:number]}"
	end
end

get "/signup/:first_name/:number" do
	session['first_name'] = params['first_name']
	session['number'] = params['number']
  "Your first name is #{params[:first_name]}, your number is #{params[:number]}"
end

get "/incoming/sms" do
	403
end

get "/test/conversation" do
	if params[:Body].nil? || params[:From].nil? #check if parameters are blank
		return "Sorry, your input cannot be understood by the bot.<br>
						Try using two parameters called Body and From."
	else
		determine_response params[:Body]
	end
end

error 403 do
	"Access Forbidden"
end