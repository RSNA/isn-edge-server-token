// ----------------------------
// ------ Setup Functions -----
// ----------------------------
function $$(arg) {
    return $(arg);
}

$(document).ready(function() {
    // Style using ShadedBorder.js
    tab_controller.render($(".tab-controller"));
    splitBorderTop.render($("#main_title"));
    splitBorderBottom.render($("#contents"));
    tab_border.render($(".tabs ul li"));

    // Create Menu Events
    /*$(".tab-controller a").each(function(i,element) {
	var e = $(element);
	e.tabs_id = $("#" + e.html().toLowerCase() + "_tabs");
	e.click(function(event) {
	    $(".tab-controller").removeClass("active");
	    e.parent().addClass("active")
	    $(".tabs").hide();
	    e.tabs_id.show();
	    return false;
	});
    });*/
});


// ------------------------------
// ------ Search Functions ------
// ------------------------------
function search_by(params) {
    search_or_filter("/patients/search", params);
}

function filter_by(params) {
    search_or_filter("/admin/audit_filter", params);
}

function search_or_filter(url, params) {
    $.ajax({
	'url': url,
	method: "get",
	data: params,
	success: function(response) {
	    $('#search_spinner').hide();
	    $('#search_results').html(response);
	    $('#search_results').show();
	},
	beforeSend: function() {
	    $('#search_results').hide();
	    $('#search_spinner').show();
	}
    });
}

function toggle_search_form() {
    $('#search_form').toggle();
    $('#advanced_search_form').toggle();
}

// --------------------------------
// ------ Password Functions ------
// --------------------------------
function toggle_pin_visibility() {
    $('input.plain_password').each(function(i,password_input) {
	var element = $(password_input);
	var value = element.attr('value');
	var name = element.attr('name');
	var type = "password";
	if (element.attr('type') == "password") type = "text";
	var new_element = "<input type=\"" + type + "\" name=\"" + name + "\" value=\"" + value + "\" class=\"plain_password\" />";
	element.replaceWith(new_element);
    });
}

// --------------------------------
// ------ CART Functionality ------
// --------------------------------
function add_to_cart(element_id, exam_id) {
    $.ajax({
	url: "/exams/add_to_cart",
	method: 'post',
	data: {'id': exam_id},
	success: function(response) {
	    $("#" +element_id).replaceWith("<input class=\"cart-button\" onclick=\"window.location = '/exams/show_cart'\" type=\"button\" value=\"View Cart (" + response + ")\" />");
	    update_cart_count(response);
	}
    });
}

function update_cart_count(count) {
    $(".cart-count").each(function(i,element) { $(element).html(count) });
    $(".cart-button").each(function(i,element) { $(element).val("View Cart (" + String(count) + ")") });
}

function delete_from_cart(element_id, exam_id) {
    $.ajax({
	url: "/exams/delete_from_cart",
	method: 'post',
	data: {'id': exam_id},
	success: function(response) {
	    $("#" + element_id).parent().parent().replaceWith("");
	    $('#flash-notice').html("Removed exam from cart");
	    update_cart_count(response);
	}
    });
}

function send_cart(form) {
    console.log(form.serialize());
    $.ajax({
	url: "/exams/send_cart",
	method: "post",
	data: form.serialize(),
	success: function(response) {
	    $("#tokenDialog").html(response);
	},
	beforeSend: function() {
	    $("#" + form.attr('id') + " input").attr('disabled', true);
	    $("#submit_spinner").show();
	}
    });
}

function validate_cart(form) {
    $.ajax({
	url: "/exams/validate_cart",
	method: 'post',
	data: form.serialize(),
	success: function(responseData) {
	    $("#submit_spinner").hide();
	    $("#" + form.attr('id') + " input").attr('disabled',false);
	    if (responseData == true) {
		$("#errorExplanation").hide();
		$("#" + form.attr('id') + " input").removeClass("inlineFieldWithErrors");
		send_cart(form);
	    } else {
		$("#errorExplanation ul").html("");
		$("#errorExplanation").show();
		$.each(responseData, function(i,pair) {
		    $('#errorExplanation ul').append("<li>" + pair[0].replace("_"," ") + " " + pair[1] + "</li>");
		    $("input[name='" + pair[0] + "']").addClass('inlineFieldWithErrors');
		});
	    }
	},
	beforeSend: function() {
	    $("#" + form.attr('id') + " input").attr('disabled', true);
	    $("#submit_spinner").show();
	}
    });
}

// -----------------------------------
// --- User Role Editing Functions ---
// -----------------------------------
function update_role(radio_button, id, element_for_update) {
    $.ajax({
	url: "/users/set_role",
	method: 'post',
	data: {'id': id, 'role_id': radio_button.value},
	success: function(response) {
	    $("#" + element_for_update).html(response);
	},
	beforeSend: function() {
	    $("#" + element_for_update).html(" ...");
	}
    });
}

// ----------------------------------
// ---- Consent Dialog Functions ----
// ----------------------------------
var consent_status = 0;

function obtain_consent(patient_id, demographics) {
    macro_dems = ['mrn','dob','sex','patient_name','street']
    for (var i in macro_dems) {
	$('#consent_demographic_' + macro_dems[i]).html(demographics[macro_dems[i]]);
    }
    $('#consent_demographic_area').html(demographics['city'] + ", " + demographics['state'] + " " + demographics['zip_code']);
    $('#consent_patient_id').val(demographics['patient_id']);
    center_dialog($("#consentDialog"));
    load_dialog($("#consentDialog"));
}

function audit_details(job_transaction_id) {
    var dialog = $("#auditDialog");
    var contents = $("#auditDialogContent");
    center_dialog(dialog);
    load_dialog(dialog);
    $.ajax({
	url: "/admin/audit_details",
	data: {id: job_transaction_id},
	success: function(response) {
	    contents.html(response);
	},
	beforeSend: function(xml) {
	    contents.html("<img src=\"/images/ajax-loader.gif\" />");
	}
    });
}

function load_dialog(dialog) {
    //loads dialog only if it is disabled
    if(consent_status==0){
	$("#backgroundDialog").css({
	    "opacity": "0.7"
	});
	$("#backgroundDialog").fadeIn("slow");
	dialog.fadeIn("slow");
	consent_status = 1;
    }
}

function close_dialog(dialog) {
    //disables dialog only if it is enabled
    if(consent_status==1){
	$("#backgroundDialog").fadeOut("slow");
	dialog.fadeOut("slow");
	consent_status = 0;
    }
}

function center_dialog(dialog) {
    var windowWidth = document.documentElement.clientWidth;
    var windowHeight = document.documentElement.clientHeight;
    var dialogHeight = dialog.height();
    var dialogWidth = dialog.width();
    var scrollTop = getPageScroll()[1];

    dialog.css({
	"position": "absolute",
	"top": (windowHeight/2-dialogHeight/2) + scrollTop,
	"left": windowWidth/2-dialogWidth/2
    });

    //only need force for IE6
    $("#backgroundDialog").css({
	"height": windowHeight
    });

}

function getPageScroll() {
    var xScroll, yScroll;
    if (self.pageYOffset) {
      yScroll = self.pageYOffset;
      xScroll = self.pageXOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {
      yScroll = document.documentElement.scrollTop;
      xScroll = document.documentElement.scrollLeft;
    } else if (document.body) {// all other Explorers
      yScroll = document.body.scrollTop;
      xScroll = document.body.scrollLeft;
    }
    return new Array(xScroll,yScroll)
}
