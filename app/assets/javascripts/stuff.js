// ----------------------------
// ------ Setup Functions -----
// ----------------------------
function $$(arg) {
    return $(arg);
}

$(document).on("ready page:load", function() {
    $("#audit-modal").on('click',"#table-selector .dropdown-menu li a",function(e) {
	$(this).parent().siblings().removeClass("active");
	$(this).parent().addClass("active");
	$($(this).attr('href')).siblings(".table-tab-container").hide();
	$($(this).attr('href')).show();
	$("#table-selector button .title").text($(this).text());
	$("#table-selector button").dropdown('toggle');
	return false;
    });

    $("#main").on('click',"#select-all-button",function(e) {
	var ids = $.map($(".add-to-cart"),function(obj,index) { return $(obj).attr('data') });
	add_to_cart(null,ids);
	return false;
    });

    $(".test-button").click(function(e) {
	var contents = $(this).siblings('.test-response');
	$.ajax($(this).attr('href'),
	       { success: function(response) { contents.text(response); },
	         beforeSend: function() { contents.text("..."); }
	       });
	return false;
    });

    $("body").on("click","a.retry-job",retry_job);
    $("body").on("click","a.audit-details",audit_details);

    $("body").on('click',".paginator-buttons button",function(e) {
	var pane = $("#search_results");
	var data = pane.find(".paginator-data");
	var offset = parseInt(data.find(".offset").text());
	var limit = parseInt(data.find(".limit").text());
	var count = parseInt(data.find(".count").text());
	var form_data = $("form").serializeArray();
	if ($(this).hasClass("dec")) { var new_offset = offset - limit; }
	else if ($(this).hasClass("inc")) { var new_offset = offset + limit; }
	else if ($(this).hasClass("begin")) { var new_offset = 0; }
	else if ($(this).hasClass("end")) { var new_offset = count - limit; }
	else { var new_offset = offset; }
	form_data.push({name: 'offset', value: new_offset});
	form_data.push({name:'limit', value: limit});
	$.ajax("/admin/audit_filter",
	       { data: form_data,
		 beforeSend: function() {
		     $('#search_results').hide();
		     $('#search_spinner').show();
		 },
		 success: function(response) {
		     $('#search_spinner').hide();
		     $('#search_results').html(response);
		     $('#search_results').show();
		 }
	       });
	return false;
    });

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
	var new_element = "<input type=\"" + type + "\" name=\"" + name + "\" value=\"" + value + "\" class=\"plain_password form-control\" />";
	element.replaceWith(new_element);
    });
}

// --------------------------------
// ------ CART Functionality ------
// --------------------------------
function add_to_cart(element_id, exam_id) {
    $.ajax({
	url: "/exams/add_to_cart",
	data: {'id': exam_id},
	success: function(response) {
	    var html = "<input class=\"btn btn-primary view-cart\" onclick=\"window.location = '/exams/show_cart'\" type=\"button\" value=\"View Cart (" + response + ")\" />";
	    if (element_id == null) {
		$(".add-to-cart").each(function(index,obj) { $(obj).replaceWith(html); });
	    } else {
		$("#" +element_id).replaceWith(html);
		$(".view-cart").each(function(index,obj) { $(obj).val("View Cart (" + response + ")"); });
	    }
	    update_cart_count(response);
	}
    });
    return false;
}

function update_cart_count(count) {
    $(".cart-count").each(function(i,element) { $(element).html(count) });
    $(".cart-button").each(function(i,element) { $(element).val("View Cart (" + String(count) + ")") });
}

function delete_from_cart(element_id, exam_id) {
    $.ajax({
	url: "/exams/delete_from_cart",
	data: {'id': exam_id},
	success: function(response) {
	    $("#" + element_id).parents('tr').remove()
	    $('#flash-notice').html("Removed exam from cart");
	    update_cart_count(response);
	}
    });
}

function retry_job() {
    var element = $(this);
    var job_id = $(this).attr('data');
    $.ajax({
	url: "/exams/retry_job",
	data: {'id': job_id},
	success: function(response) {
	    $(element).replaceWith("Retrying");
            location.reload();
       	}
    });
    return false;
}

// -----------------------------------
// --- User Role Editing Functions ---
// -----------------------------------
function update_role(label, id, element_for_update) {
    var radio_button = $(label).find('input[type="radio"]');
    $.ajax({
	url: "/users/set_role",
	data: {'id': id, 'role_id': radio_button.val()},
	success: function(response) {
	    $("#" + element_for_update).html(response);
	},
	beforeSend: function() {
	    $("#" + element_for_update).html(" ...");
	}
    });
}

function update_status(label, id, element_for_update) {
    var radio_button = $(label).find('input[type="radio"]');
    $.ajax({
	url: "/users/set_status",
	data: {'id': id, 'active': radio_button.val()},
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
    $('#consent-modal').modal('toggle');
}

function audit_details() {
    var job_transaction_id = $(this).attr('job-transaction-id');
    var job_id = $(this).attr('job-id');
    var contents = $("#audit-modal .modal-body .results");
    $("#audit-modal").modal('toggle');

    $.ajax({
	url: "/admin/audit_details",
	data: {'id': job_transaction_id, 'job_id': job_id},
	success: function(response) {
	    $("#dialog-spinner").hide();
	    contents.html(response);
	},
	beforeSend: function(xml) {
	    contents.html("");
	    $("#dialog-spinner").show();
	}
    });

    return false;
}

function simple_form_dialog(id,url,title) {
    if (title == undefined) { title = "Form" }
    $("#admin-modal").modal('toggle');
    var contents = $("#admin-modal-contents");
    $.ajax({
	'url': url,
	data: {'id': id},
	success: function(response) {
	    $("#admin-modal .modal-body .spinner").hide();
	    $(contents).html(response);
	},
	beforeSend: function(xml) {
	    $("#admin-modal .modal-header h4").text(title);
	    $("#admin-modal .modal-body .spinner").show();
	}
    });
    return false;
}

function reset_password(form) {
    $.ajax({
	'url': '/users/reset_password',
	type: 'post',
	data: form.serialize(),
	success: function(response) {
	    $("#admin-modal .modal-body .spinner").hide();
	    $("#admin-modal-contents").html(response);
	},
	beforeSend: function(xml) {
	    $("#admin-modal-contents").html("");
	    $("#admin-modal .modal-body .spinner").show();
	}
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
