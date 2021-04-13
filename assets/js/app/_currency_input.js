$(document).ready(function(){
  var currencyInput = document.querySelectorAll('[data-inputmask]');
  Inputmask({
    onBeforeMask: function (value, opts) {
        return value/100
    }}
  ).mask(currencyInput);
});