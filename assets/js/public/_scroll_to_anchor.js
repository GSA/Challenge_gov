$(".scroll-to-anchor").on("click", function(e) {
  e.preventDefault()
  anchorName = $(this).data("anchor");
  anchorHash = `#${anchorName}`

  window.location.hash = "";
  window.location.hash = anchorHash;

  // scrollLocation = $(anchorHash).offset().top 

  // $(".main-wrapper").animate({scrollTop: scrollLocation}, 1000, function() {
  //   console.log("Finished")
  // })
})