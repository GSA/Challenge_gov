
$(".usa-button[data-widget=control-sidebar]").on("click", e => {
   if($(".control-sidebar").css("display") == "none")
    $(".control-sidebar").show()
  else 
    $(".control-sidebar").hide()
    
})

