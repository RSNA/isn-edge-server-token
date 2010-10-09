// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function $$(arg) {
    return $(arg);
}

$(document).ready(function() {
    // Style using ShadedBorder.js
    tab_border.render($(".tabs ul li"));
    splitBorderTop.render($("#main_title"));
    splitBorderBottom.render($("#contents"));
    tab_controller.render($(".tab-controller"));

    // Create Menu Events
    $(".tab-controller a").each(function(i,element) {
	var e = $(element);
	e.tabs_id = $("#" + e.html().toLowerCase() + "_tabs");
	e.click(function(event) {
	    $(".tab-controller").removeClass("active");
	    e.parent().addClass("active")
	    $(".tabs").hide();
	    e.tabs_id.show();
	    return false;
	});
    });
});

function search_by(params) {
    $.ajax({
	url: "/patients/search",
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
	    $("#" + element_id).replaceWith("");
	    $('#flash-notice').html("Removed exam from cart");
	    update_cart_count(response);
	}
    });
}

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


/* Consent Dialog Functions */
var consent_status = 0;

function obtain_consent(patient_id, demographics) {
    console.log(demographics);
    macro_dems = ['mrn','dob','sex','patient_name','street']
    for (var i in macro_dems) {
	$('#consent_demographic_' + macro_dems[i]).html(demographics[macro_dems[i]]);
    }
    $('#consent_demographic_area').html(demographics['city'] + ", " + demographics['state'] + " " + demographics['zip_code']);
    $('#consent_patient_id').val(demographics['patient_id']);
    center_dialog();
    load_dialog();
}

function load_dialog(){
    //loads dialog only if it is disabled
    if(consent_status==0){
	$("#backgroundDialog").css({
	    "opacity": "0.7"
	});
	$("#backgroundDialog").fadeIn("slow");
	$("#consentDialog").fadeIn("slow");
	consent_status = 1;
    }
}

function close_dialog(){
    //disables dialog only if it is enabled
    if(consent_status==1){
	$("#backgroundDialog").fadeOut("slow");
	$("#consentDialog").fadeOut("slow");
	consent_status = 0;
    }
}

function center_dialog(){
    var windowWidth = document.documentElement.clientWidth;
    var windowHeight = document.documentElement.clientHeight;
    var dialogHeight = $("#consentDialog").height();
    var dialogWidth = $("#consentDialog").width();

    $("#consentDialog").css({
	"position": "absolute",
	"top": windowHeight/2-dialogHeight/2,
	"left": windowWidth/2-dialogWidth/2
    });

    //only need force for IE6
    $("#backgroundDialog").css({
	"height": windowHeight
    });

}

