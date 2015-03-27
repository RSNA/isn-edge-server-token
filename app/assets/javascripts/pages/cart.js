$(document).on("ready page:load", function() {

    var send_cart = function(override) {
        $('#cart-form input[name="override_delay"]').val(override);
	$.ajax({
	    url: "/exams/send_cart",
	    data: $('#cart-form').serialize(),
	    success: function(response) {
                $("#cart-dialog").html(response);
	    },
	    beforeSend: function() {
		$("#cart-form input").attr('disabled', true);
		$("#submit_spinner").show();
	    }
	});
    };

    $("#send-cart-button").click(function() { $("#cart-modal").modal('toggle'); return false; });

    $(".send-type-choice").click(function(e) {
	$("#cart-send-type-dialog").hide();
	if ($(this).attr('data') == "site-to-site") {
	    $("#cart-form").append('<input type="hidden" name="send_to_site" value="true" />');
	    $("#cart-send-dialog").hide();
	    $("#cart-email-dialog").hide();
	    send_cart(2);
	} else if($("#cart-form input[name='email']").val().length > 0) {
	    $("#cart-use-previous-dialog").show();
	} else {
	    $("#cart-form").append('<input type="hidden" name="new_email" value="true" />');
	    $("#cart-email-dialog").show();
	}
	return false;
    });

    $("#cart-modal").on('click',".use-old-button",function(e) {
	$("#cart-use-previous-dialog").hide();
	if ($(this).val() == "Yes") {
	    $("#cart-form").append('<input type="hidden" name="new_email" value="false" />');
	    $("#cart-send-dialog").show();
	} else {
	    $("#cart-form").append('<input type="hidden" name="new_email" value="true" />');
	    $("#cart-email-dialog").show();
	}
	return false;
    });

    $("#cart-modal").on('click',"#validate-email-button",function(e) {
	if (($("#cart-form input[name='email']").val().length > 0) || ($(".send-type-choice").attr('data') == "site-to-site")) {
	    $("#errorExplanation").html("").hide();
	    $("#cart-email-dialog").hide();
	    $("#cart-send-dialog").show();
	} else {
	    $("#errorExplanation ul").html("");
	    $("#errorExplanation").show();
	    $('#errorExplanation ul').append("<li>" + "Email cannot be blank" + "</li>");
	    $("#cart-form input[name='email']").addClass('inlineFieldWithErrors');
	}
	return false;
    });

    $("#cart-modal").on('click',".send-cart-button",function() {
	send_cart($(this).attr('data'));
	return false;
    });

});
