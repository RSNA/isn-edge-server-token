$(document).on("ready page:load", function() {
    $("#conf-form").submit(function(e) {
        $.ajax("/edge_configurations/try_xds",
               {data: $(this).serializeArray(),
                beforeSend: function() { $("#debug-window").html('testing...'); },
                error: function(e) { $("#debug-window").html("An error occured. Check the console and log files for details"); },
                success: function(response) { $("#debug-window").html(response); }});
	return false;
    });
});
