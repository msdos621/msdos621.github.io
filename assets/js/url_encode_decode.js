document.addEventListener('DOMContentLoaded', function() {
	document.getElementById('encode').addEventListener('click', function(el) {
    var input = document.getElementById('decode_box').value;
    document.getElementById('decode_box').value = window.encodeURIComponent(input);
  });
  document.getElementById('decode').addEventListener('click', function(el) {
    var input = document.getElementById('decode_box').value;
    document.getElementById('decode_box').value = window.decodeURIComponent(input);
  });
});