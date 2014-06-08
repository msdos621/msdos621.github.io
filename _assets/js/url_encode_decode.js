$(document).ready(function () {
 	$('#encode').click(function() {
  		$('#decode_box').val(encodeURIComponent($('#decode_box').val()));
	});

	$('#decode').click(function() {
  		$('#decode_box').val(decodeURIComponent($('#decode_box').val()));
	});
 });
