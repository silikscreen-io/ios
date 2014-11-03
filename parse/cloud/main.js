
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


var Image = require("parse-image");

Parse.Cloud.define('getLocationAverage', function(request, response) {
  var LocationObject = Parse.Object.extend('Arts');
  var query = new Parse.Query(LocationObject);

  //query.equalTo('objectId', 'GfZXmCdJaj');
  query.limit(100);
  query.find({
    success: function(results) {
      if (results.length > 0) {
      	console.log(results[0].get('work_status'));
      	console.log("if (results.length > 0) {");
		var url = results[0].get('image').url();
    			console.log("Art Id: start");
    			console.log(results[0].id);
    			console.log(results[0].get('objectId'));
    			console.log("Art Id: end");
		Parse.Cloud.httpRequest({ url: url }).then(function(response) {
			console.log("Cloud.httpRequest({ url: url })");
		  // Create an Image from the data.
		  var image = new Image();
			console.log("image = new Image()");
		  return image.setData(response.buffer);
		 
		}).then(function(image) {
		  // Scale the image to a certain size.
			console.log("Scale the image to a certain size.");
			console.log("Image is " + image.width() + "x" + image.height() + ".");
		  return image.scale({ width: 64, height: 64 });
		 
		}).then(function(image) {
			console.log("Get the bytes of the new image.");
			console.log("Image is " + image.width() + "x" + image.height() + ".");
		  // Get the bytes of the new image.
			//response.success(image);
		  return image.data();
	  	// 	return image.data();
 
  		}).then(function(buffer) {
    // // Save the image into a new file.
     		var base64 = buffer.toString("base64");
     		var cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
     		console.log("new Parse.File(\"thumbnail.jpg\", { base64: base64 });");
     		cropped.save().then(function() {
    			// The file has been saved to Parse.
    			console.log("The file has been saved to Parse.");
    			var object = new Parse.Object("AdditionalResources");
    			object.set("thumbnail", cropped);
    			console.log("Art Id: start");
    			console.log(results[0].id);
    			console.log(results[0].get('objectId'));
    			console.log("Art Id: end");
    // 			var relation = object.relation("PostId");
				// relation.add(myComment);

    			object.set("art", results[0]);
    			object.save();
    			response.success(cropped);
  			}, function(error) {
    			// The file either could not be read, or could not be saved to Parse.
  			});
     		// response.success(cropped);
    	});
		// var Image = require("parse-image");

  //     	var image = new Image();
  //     	image.setData(results[0].image, {
  //     		success: function() {
  //       		console.log("Image is " + image.width() + "x" + image.height() + ".");
  //     		},
  //     		error: function(error) {
  //       		console.log(error);
  //     		}
  //   	})
		// image.scale({
		//   width: 64,
		//   height: 64,
		//   success: function(image) {
		//     console.log("Image scaled to " + image.width() + "x" + image.height() + ".");
		//   },
		//   error: function(error) {
		//   	console.log(error);
		//     // The image could not be scaled.
		//   }
		// });

      	// console.log("response.success(image.data());");
      	// console.log("Image scaled to " + image.width() + "x" + image.height() + ".");
       //  response.success(image);
      } else {
        response.error('Average not available');
      }
    },
    error: function(error) {
      response.error('Oups something went wrong');
    }
  });
});
