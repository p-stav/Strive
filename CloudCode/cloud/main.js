
/* 
// Paul Stavropoulos
// Resolution CloudCode
*/

var NUMBER_QUOTES = 21;
var NUMBER_MEMES = 20;

// Grab pending resolutions
Parse.Cloud.define("getPendingResolutions", function(request, response) {
	// get user id
	var user = request.user;

	// formulate query
	var Resolution = Parse.Object.extend("Resolution");
	var resolutionQuery = new Parse.Query(Resolution);
	resolutionQuery.equalTo("user", user);
	resolutionQuery.greaterThan("weeklyreminders",0);

	resolutionQuery.find({
		success: function(resolutions)
		{
			var resolutionArray = [];
			// create dictionary to return
			if (resolutions.length > 0)
			{
				for (var i = 0; i < resolutions.length; i++)
				{
					var resolution = {};
					var resolutionObject = resolutions[i];

					resolution["id"] =  resolutionObject.id;
					resolution["title"] = resolutionObject.get("title");
					resolution["comment"] = resolutionObject.get("comment");
					resolution["weeklyreminders"] = resolutionObject.get("weeklyreminders");
					resolution["createdAt"] = resolutionObject.createdAt;

					resolutionArray.push(resolution);
				}
			}

			response.success(resolutionArray);

		},
		error: function(error)
		{
			response.error("UH OH! Error getting resolutionArray");
		}
	});

});

// save resolutions
Parse.Cloud.define("saveResolution", function(request, response) {
	// grab title, comment, weeklyreminder, and user
	var title = request.params.goalTitle;
	var comment = request.params.comment;
	var weeklyreminder = Math.round(request.params.weeklyReminder);
	var user = request.user;

	var Resolution =  Parse.Object.extend("Resolution");
	var resolution = new Resolution();
	resolution.set("title", title);
	resolution.set("comment", comment);
	resolution.set("weeklyreminders", weeklyreminder);
	resolution.set("user", user);

	resolution.save({
		success:function(newResolution)
		{
			response.success(newResolution.id);
		},
		error:function(error)
		{
			response.error("ERROR SAVING");
		}
	})




});

// edit resolutions
Parse.Cloud.define("editResolution", function(request, response) {
	// grab title, comment, weeklyreminder, user, id
	var title = request.params.goalTitle;
	var comment = request.params.comment;
	var weeklyreminder = Math.round(request.params.weeklyReminder);
	var objectId = request.params.objectId;
	var user = request.user;

	var Resolution =  Parse.Object.extend("Resolution");
	var resolutionQuery = new Parse.Query(Resolution);
	resolutionQuery.get(objectId, {
		success:function(resolutionObject)
		{
			resolutionObject.set("title", title);
			resolutionObject.set("comment", comment);
			resolutionObject.set("weeklyreminders", weeklyreminder);

			resolutionObject.save({
				success:function(newResolution)
				{
					response.success(newResolution.id);
				},
				error:function(error)
				{
					response.error("ERROR SAVING");
				}
			});
		},
		error:function(error)
		{
			console.log("ERROR UPDATING RESOLUTION");
		}
	})

});

// removeResolution
Parse.Cloud.define("deleteResolution", function(request, response) {
	// grab resolution id
	var objectId = request.params.objectId;

	var Resolution =  Parse.Object.extend("Resolution");
	var resolutionQuery = new Parse.Query(Resolution);
	resolutionQuery.get(objectId, {
		success:function(resolutionObject)
		{
			resolutionObject.set("weeklyreminders", 0);

			resolutionObject.save({
				success:function(newResolution)
				{
					response.success(newResolution.id);
				},
				error:function(error)
				{
					response.error("ERROR SAVING");
				}
			});
		},
		error:function(error)
		{
			console.log("ERROR UPDATING RESOLUTION");
		}
	})

});

// Retrieve a random Quote
Parse.Cloud.define("getQuote", function(request, response) {
	// random number
	var random = Math.floor((Math.random() * 100) % NUMBER_QUOTES);

	// query index
	var Quote = Parse.Object.extend("Quote");
	var quoteQuery = new Parse.Query(Quote);
	quoteQuery.equalTo("index", random);

	quoteQuery.first({
		success:function(quote)
		{
			// standard quote text
			var quoteText = "The secret of getting ahead is getting started - Mark Twain"

			if (quote)
			{
				quoteText = quote.get("text");
			}

			response.success(quoteText);
		},
		error:function(error)
		{
			response.error("ERROR GETTING QUOTE!");
		}
	});

});

// schedule weekly reminders for your goals
Parse.Cloud.job("scheduleReminders", function(request, status) 
{	
	// grab resolutions that have 1 reminder
	var Resolution =  Parse.Object.extend("Resolution");
	var resolutionQuery = new Parse.Query(Resolution);

	// check what day it is to pull correct resolutions
	var dayofWeekCheck = new Date();
	if (dayofWeekCheck.getDay() == 0)
	{
		// compound query
		var onceAWeek = new Parse.Query(Resolution);
		onceAWeek.equalTo("weeklyreminders",1);
		var threeAWeek = new Parse.Query(Resolution);
		threeAWeek.equalTo("weeklyreminders",3);
		resolutionQuery = Parse.Query.or(onceAWeek, threeAWeek);
	}

	else if (dayofWeekCheck.getDay() == 1 || dayofWeekCheck.getDay() == 3)
	{
		resolutionQuery.equalTo("weeklyreminders",2);
	}

	else if (dayofWeekCheck.getDay() == 2 || dayofWeekCheck.getDay() == 4)
	{
		resolutionQuery.equalTo("weeklyreminders",3);
	}	

	else
	{
		status.success("not a day to schedule pushes");
	}

	// schedule for tomorrow
	var date = Date.now();
	var delta = 1000*3600*24; // 1 day
	var tomorrow = new Date(date + delta);

	// actual query
	resolutionQuery.each(function(resolution)
	{
		var resTitle = resolution.get("title");

		// schedule this push
		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.equalTo("user", resolution.get("user"));

		Parse.Push.send({
		  where: pushQuery,
		  data: {
		    alert: "Reminder: " + resTitle 
		  },
		  push_time: tomorrow
		});
	}).then(function() {
		status.success("scheduled all reminders");
	});
});

// send weekly funny email (#motivationalMonday email)
Parse.Cloud.job("sendEmail", function(request, status) 
{
	// check if it's Monday and if we should send an email
	var dayofWeekCheck = new Date();
	if (dayofWeekCheck.getDay() != 6)
		status.success("Wrong Day. Don't send");


	// access a random meme from database
	var Meme =  Parse.Object.extend("meme");
	var random = Math.floor((Math.random() * 100) % NUMBER_MEMES);
	var memeQuery = new Parse.Query(Meme);
	memeQuery.equalTo("index", random);

	var memeUrl;
	var userDictionary = {};
	var usersArray = [];
	
	// execute query
	memeQuery.first().then(function(meme) {
		memeUrl = meme.get("image").url();
		console.log("memeURL is " + memeUrl);


		// query for each user with an email
		var userQuery = new Parse.Query(Parse.User);
		userQuery.exists("email");

		return userQuery.find();
	}).then(function(users){

		for (var i=0; i<users.length; i++)
		{
			usersArray.push(users[i]);

			if (users[i].get("email").indexOf("@") != -1)
			{
				userDictionary[users[i].id] = {"email":users[i].get("email"), "username":users[i].get("username"), "resolutions":""};
			}
		}

		// query for resolutions 
		var Resolution = Parse.Object.extend("Resolution");
		var resolutionQuery = new Parse.Query(Resolution);
		resolutionQuery.containedIn("user", usersArray);

		return resolutionQuery.find();
	}).then(function(resolutions){
		for (var k=0; k<resolutions.length; k++)
		{
			userDictionary[resolutions[k].get("user").id]["resolutions"] += "<li>"+resolutions[k].get("title") +"</li>"
		}
	}).then(function() {
		// send emails
		var Mandrill = require('mandrill');
		for(var j=0; j<Object.keys(userDictionary).length; j++)
		{
			Mandrill.initialize(request.params.mandrillKey);

			Mandrill.sendEmail({
				message: {
					html: "<body style='font-family:sans-serif'>Hi " + userDictionary[Object.keys(userDictionary)[j]]["username"] + ",<br/><br/>This is your weekly #MondayMotviation email from Strive.<br/><br/><br/>Your weekly goals are:<ul>" + userDictionary[Object.keys(userDictionary)[j]]["resolutions"] +  "</ul><br/><p align='center'>Have a great week!<br/><img syle='width:500px' src='" + memeUrl +"'/></p><br/><br/><br/>-Paul from Strive</body>",
					subject: "Your Monday Motivation!",
					from_email: "getStrive@gmail.com",
					from_name: "Paul from Strive",
					to: [
					  {
					    email: userDictionary[Object.keys(userDictionary)[j]]["email"],
						name: userDictionary[Object.keys(userDictionary)[j]]["username"],
					  }
					]
				},
				async: true
			},{
				success: function(httpResponse) {
					console.log(httpResponse);
				},
				error: function(httpResponse) {
					console.error(httpResponse);
				}
			});
		}
	}).then(function() {
		status.success("sent emails for monday motivation");
	});
});
