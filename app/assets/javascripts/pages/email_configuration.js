$(document).on("ready page:load", function() {
    $('.btn-group.enabler label').click(function(e) {
	var id = "#" + $(this).parent().attr('data');
	if ($(this).find('input').val() == 'true') {
	    $(id).show();
	} else {
	    $(id).hide();
	}
    });

    $("input.complex-checkbox").click(function(e) {
	var hidden = $(this).siblings('input[type="hidden"]');
	console.log(hidden);
	if ($(this).is(':checked')) { hidden.attr('value','true'); }
	else { hidden.attr('value','false'); }
    });
});
