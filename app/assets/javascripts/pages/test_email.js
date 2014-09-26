$(document).ready(function() {
    $("#email-form").submit(function(e) {
        $.ajax("/email_configurations/try_email",
               {data: $(this).serializeArray(),
                beforeSend: function() { $("#debug-window").html('testing...'); },
                error: function(e) { $("#debug-window").html("An error occured. Check the console and log files for details"); },
                success: function(response) { $("#debug-window").html(response); }});
	return false;
    });
});
