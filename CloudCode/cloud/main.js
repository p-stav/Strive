
/* 
// Paul Stavropoulos
// Resolution CloudCode
*/

var NUMBER_QUOTES = 21

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

// automatically spread content to our test accounts if they have not been propagated
// run on Sunday
Parse.Cloud.job("schedule1xReminders", function(request, status) 
{	
	// grab resolutions that have 1 reminder
	var Resolution =  Parse.Object.extend("Resolution");
	var resolutionQuery = new Parse.Query(Resolution);
	resolutionQuery.equalTo("weeklyreminders",1);

	resolutionQuery.find({
		success:function(resolutions)
		{
			// schedule on Monday
			var date = Date.now();
			var delta = 1000*3600*9; // 1 day
			var tomorrow = new Date(date + delta);

			// loop through resolution
			for(var i=0; i<resolutions.length; i++)
			{
				var resolution = resolutions[i];
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
				}, {
				  success: function() {
				    console.log("scheduled resolution for user " + resolution.get("user").id)
				  },
				  error: function(error) {
				  	console.log("ERROR SCHEDULING PUSH: " + error.code)
				  }
				});
			}
		},
		error:function(error)
		{
			response.error("ERROR GETTING QUOTE!");
		}
	});
});

Parse.Cloud.job("schedule2xReminders", function(request, status) 
{	
	
});

Parse.Cloud.job("schedule3xReminders", function(request, status) 
{	
	
});