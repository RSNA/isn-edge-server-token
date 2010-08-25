// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function search_by(url, params) {
    new Ajax.Request(url,
		     {method: 'post',
		      parameters: params,
		      onSuccess: function(response) {
			  $('search_spinner').hide();
			  $('search_results').update(response.responseText);
			  $('search_results').show();
		      },
		      onLoading: function() {
			  $('search_results').hide();
			  $('search_spinner').show();
		      }
		     });
}

function add_to_cart(element_id, exam_id) {
    new Ajax.Request("/exams/add_to_cart",
		     {method: 'post',
		      parameters: {'id': exam_id},
		      onSuccess: function(response) {
			  $(element_id).replace("<a href=\"/exams/show_cart\">View Cart (<span class='cart-count'>" + response.responseText + "</span>)</a>");
			  $$(".cart-count").each(function(element) { element.update(response.responseText) });
		      }
		     });
}

function delete_from_cart(element_id, exam_id) {
    new Ajax.Request("/exams/delete_from_cart",
		     {method: 'post',
		      parameters: {'id': exam_id},
		      onSuccess: function(response) {
			  $(element_id).replace("");
			  $('flash-notice').update("Removed exam from cart");
			  $$(".cart-count").each(function(element) { element.update(response.responseText) });
		      }
		     });
}

function update_role(radio_button, id, element_for_update) {
    new Ajax.Request("/users/set_role",
		     {method: 'post',
		      parameters: {'id': id, 'role_id': radio_button.value},
		      onSuccess: function(response) {
			  $(element_for_update).update(response.responseText);
		      },
		      onLoading: function() {
			  $(element_for_update).update(" ...");
		      }
		     });
}