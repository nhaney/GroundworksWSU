$(document).ready(function() {
    refreshTable();
    //The default view is active reports
    $('#viewDescriptor').text("Active Reports");
    showRows("active");
    //this function will switch what is displayed on the table
    //based on what mode it is in.
    $('#tableButton').click(function() {
    	if($('#viewDescriptor').text() == "Active Reports"){
    		$('#viewDescriptor').text("In Progress Reports");
    		showRows("in progress");
    	}
  		else if($('#viewDescriptor').text() == "In Progress Reports"){
    		$('#viewDescriptor').text("All Reports");
    		showRows("all");
    	}
    	else if($('#viewDescriptor').text() == "All Reports"){
    		$('#viewDescriptor').text("Completed Reports");
    		showRows("completed");
    	}
    	else if($('#viewDescriptor').text() == "Completed Reports"){
    		$('#viewDescriptor').text("Ignored Reports");
    		showRows("ignored");
    	}
    	else if($('#viewDescriptor').text() == "Ignored Reports"){
    		$('#viewDescriptor').text("Active Reports");
    		showRows("active");
    	}
    });

    $('#refreshButton').click(function() {
        $("#displayTable").html("Table loading...");
        refreshTable();
        $('#viewDescriptor').text("Active Reports");
        showRows("active");
    });
} );

//helper function to show/hide rows of table
function showRows(filterType){
	if(filterType != "all"){
		$('#displayTable tbody tr').each(function(){
			var status = $(this).children(".rowStatus").text();
			if(status.includes(filterType)){
				$(this).show();
			}
			else{
				$(this).hide();
			}
		});
	}
	else{
		$('#displayTable tbody tr').each(function(rowIndex, row){
			$(this).show();
		});
	}
};

//function that refreshes the table
function refreshTable(){
    $.ajax({
            async: false,
            url: "/table",
            type: "get",
            data: {jsdata: "text"},
            success: function(response) {
                $("#tableDiv").html(response);
            },
                error: function(xhr) {
                //Do Something to handle error
                console.log(xhr);
            }
        });
    formatTable();
    //after table is refreshed, it returns to active view
    $('#viewDescriptor').text("Active Reports");
    showRows("active");
};

function formatTable(){
    $('#displayTable').DataTable( {
        "paging": false,
        "info": false,
        "searching": false
    } );
};



