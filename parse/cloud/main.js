
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


var Image = require("parse-image");

Parse.Cloud.define('getLocationAverage', function(request, response) {
  var artsObject = Parse.Object.extend("Arts");
  var query = new Parse.Query(artsObject);
  query.limit(5);
  query.find({ success: function(results) {
    	var images = []
		var promises = [];
		console.log("results length");
		console.log(results.length);
		for (var i = 0; i < results.length; i++) { 
			var art = results[i];
			var AdditionalResources = Parse.Object.extend("AdditionalResources");
			var queryResources = new Parse.Query(AdditionalResources);
			queryResources.equalTo("art", art);
			promises.push(queryResources.find({
			 	success: function(results) {
					if (results.length > 0) {
						console.log("Resource found");
					} else {
						console.log("Resource not found");
						var url = art.get('image').url();
						console.log(url);

						promises.push(Parse.Cloud.httpRequest({ url: url }).then(function(response) {
							console.log("Parse.Cloud.httpRequest");
						  var image = new Image();
						  return image.setData(response.buffer);
						}).then(function(image) {
						  return image.scale({ width: 64, height: 64 });
						}).then(function(image) {
							console.log("Get the bytes of the new image.");
							console.log("Image is " + image.width() + "x" + image.height() + ".");
						  return image.data();
						}).then(function(buffer) {
					 		var base64 = buffer.toString("base64");
					 		var cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
					 		console.log("new Parse.File(\"thumbnail.jpg\", { base64: base64 });");
					 		return cropped.save();
					 	// 	cropped.save().then(function() {
							// 	console.log("The file has been saved to Parse.");
							// 	var object = new Parse.Object("AdditionalResources");
							// 	object.set("thumbnail", cropped);
							// 	object.set("art", art);
							// 	object.save();
							// 	images.push(cropped);
							// 	//response.success(cropped);
							// }, function(error) {
							// 	// The file either could not be read, or could not be saved to Parse.
							// });
					 		// response.success(cropped);
						}).then(function(cropped) {
								console.log("The file has been saved to Parse.");
								var object = new Parse.Object("AdditionalResources");
								object.set("thumbnail", cropped);
								object.set("art", art);
								object.save();
								images.push(cropped);
						}));
					}
			 	},
			  	error: function(error) {
					alert("Error: " + error.code + " " + error.message);
			  	}
			}));
			// Start this delete immediately and add its promise to the list.
			//promises.push(result.destroy());
    	}

		// _.each(results, function(art) {
		// });
		// Return a new promise that is resolved when all of the deletes are finished.
		Parse.Promise.when(promises).then(function(results) {
			console.log("Parse.Promise.when(promises).then(function(results)");
			response.success(images);
		});
    }, error: function(error) {
      response.error('Oups something went wrong');
    }
  });
});



Parse.Cloud.define('getArtsSizes', function(request, response) {
  var artsObject = Parse.Object.extend("Arts");
  var query = new Parse.Query(artsObject);
  query.limit(1000);
  query.find({ success: function(results) {
    	var images = [];
		var promises = [];
		// console.log("results length");
		// console.log(results.length);
		for (var i = 0; i < results.length; i++) { 
			
			    (function(i) {
			    	var art = results[i];
 						var url = art.get('image').url();
						// console.log(url);

						promises.push(Parse.Cloud.httpRequest({ url: url }).then(function(response) {
							// console.log("Parse.Cloud.httpRequest");
						  var image = new Image();
						  return image.setData(response.buffer);
						}).then(function(image) {
							// console.log("Get the bytes of the new image.");
							// console.log("Image is " + image.width() + "x" + image.height() + ".");
							var imageSize = [];
							imageSize.push(image.width());
							imageSize.push(image.height());
							//images.push(imageSize);
							var art = results[i];
							console.log("Image size: " + imageSize);
							console.log("art " + art.get("image_alt"));

							art.set("size", imageSize);
							images.push(image.width() / image.height());
							return art.save();


							// return art.save({
							//     player: "Jake Cutter",
							//     diceRoll: 2
							//   }).then(function(gameTurnAgain) {
							//     // The save was successful.
							//   }, function(error) {
							//     // The save failed.  Error is an instance of Parse.Error.
							//   });
						}).then(function(saved) {
								console.log("The file has been saved to Parse.");
						}));
   				})(i);

						// var url = art.get('image').url();
						// // console.log(url);

						// promises.push(Parse.Cloud.httpRequest({ url: url }).then(function(response) {
						// 	// console.log("Parse.Cloud.httpRequest");
						//   var image = new Image();
						//   return image.setData(response.buffer);
						// }).then(function(image) {
						// 	// console.log("Get the bytes of the new image.");
						// 	// console.log("Image is " + image.width() + "x" + image.height() + ".");
						// 	var imageSize = [];
						// 	imageSize.push(image.width());
						// 	imageSize.push(image.height());
						// 	//images.push(imageSize);
						// 	var art = results[i];
						// 	console.log("Image is " + image.width() + "x" + image.height() + ".");
						// 	console.log("art " + art.get("image_alt"));

						// 	art.set("size", imageSize);
						// 	art.save();
						// 	images.push(image.width() / image.height());
						// }));
    	}

		// _.each(results, function(art) {
		// });
		// Return a new promise that is resolved when all of the deletes are finished.
		Parse.Promise.when(promises).then(function(results) {
			// console.log("Parse.Promise.when(promises).then(function(results)");
			response.success(images);
		});
    }, error: function(error) {
      response.error('Oups something went wrong');
    }
  });
});

		// for (var i = 0; i < results.length; i++) {
		// 	var art = results[i];
		// 	var AdditionalResources = Parse.Object.extend("AdditionalResources");
		// 	var queryResources = new Parse.Query(AdditionalResources);
		// 	queryResources.equalTo("art", art);
		// 	queryResources.find({
		// 	 	success: function(results) {
		// 			if (results.length > 0) {
		// 				console.log("Resource found");
		// 			} else {
		// 				var url = art.get('image').url();

		// 				Parse.Cloud.httpRequest({ url: url }).then(function(response) {
		// 				  var image = new Image();
		// 				  return image.setData(response.buffer);
		// 				}).then(function(image) {
		// 				  return image.scale({ width: 64, height: 64 });
		// 				}).then(function(image) {
		// 					console.log("Get the bytes of the new image.");
		// 					console.log("Image is " + image.width() + "x" + image.height() + ".");
		// 				  return image.data();
		// 				}).then(function(buffer) {
		// 			 		var base64 = buffer.toString("base64");
		// 			 		var cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
		// 			 		console.log("new Parse.File(\"thumbnail.jpg\", { base64: base64 });");
		// 			 		cropped.save().then(function() {
		// 						console.log("The file has been saved to Parse.");
		// 						var object = new Parse.Object("AdditionalResources");
		// 						object.set("thumbnail", cropped);
		// 						object.set("art", art);
		// 						object.save();
		// 						images.push(cropped);
		// 						//response.success(cropped);
		// 					}, function(error) {
		// 						// The file either could not be read, or could not be saved to Parse.
		// 					});
		// 			 		// response.success(cropped);
		// 				});
		// 			}
		// 	 	},
		// 	  	error: function(error) {
		// 			alert("Error: " + error.code + " " + error.message);
		// 	  	}
		// 	});
		// }

