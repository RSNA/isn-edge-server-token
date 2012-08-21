$(document).ready(function() {
    var hostname = window.location.hostname;
    var username = $("#ctp-frame-username").text();
    var password = $("#ctp-frame-password").text();
    var url = $("#ctp-frame-url").text();
    var iframe_source = 'http://' + hostname + '/login?' + 'username=' + username + '&password=' + password + '&url=' + url;
    $("#ctp-frame").html('<iframe id="ctp-iframe" src="' + iframe_source + '"></iframe>');
    var i = $("#ctp-iframe");
    var width = i.parent().width() - 20;
    var height = $(document).height() - 200;
    $("#ctp-frame").width(width);
    $("#ctp-frame").height(height);
    i.width(width);
    i.height(height);
});