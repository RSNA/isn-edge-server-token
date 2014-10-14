$(document).ready(function() {
    var hostname = window.location.hostname;
    var ctpport = $("#ctp-frame-port").text();
    var ctpprotocol = $("#ctp-frame-protocol").text();
    var url = $("#ctp-frame-url").text();
    var iframe_source = ctpprotocol + '://' + hostname + ':' + ctpport + url;
    $("#ctp-frame").html('<iframe id="ctp-iframe" src="' + iframe_source + '"></iframe>');
    var i = $("#ctp-iframe");
    var width = i.parent().width() - 20;
    var height = $(document).height() - 200;
    $("#ctp-frame").width(width);
    $("#ctp-frame").height(height);
    i.width(width);
    i.height(height);
});
