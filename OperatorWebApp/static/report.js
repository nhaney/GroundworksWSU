$(document).ready(function() {
	$('.statusbutton').click(function(e){
		var text = e.target.textContent;
		var reportID = $('#rid').text();
		var url = 'https://******api.us-west-2.amazonaws.com/beta/changestatus';
		var obj = '{ "reportID" : "'+reportID+'", "status" : "'+text+ '" }';
		
		$(this).addClass("temp");

		console.log(text,reportID, obj);
		$.post(url, obj).
		done(function(data){
				console.log(data);
				console.log($(".temp"));
				//remove the id from the current selected button
				$('#selectedButton').prop('id',null);
				//make the id of temp button (clicked button) be selected button
				$('.temp').attr("id", "selectedButton");
				//remove temp class
				$('.temp').removeClass();
				//change status text on the page
				$('#statusText').text($('#selectedButton').text());
			}).
		fail(function(xhr, status, error) {
			console.log(xhr);
			console.log(status);
			console.log(error);
		});
	});

	$('#flipButton').click(function(e){
		$("#imgDiv").toggleClass("flip");
	});
});
