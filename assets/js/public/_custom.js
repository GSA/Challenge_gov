// ipad and mobile menu
$('body').on('click', '.mobile-icon a, .menu-close a, .menu-overlay', function(){
	if($('body').hasClass('show-menu')){
		$('body').removeClass('show-menu');
		$('.menu-overlay').remove();
	}else{
		$('body').addClass('show-menu');
		$('.main-wrapper').append('<div class="menu-overlay"></div>');
	}
});

// sidebar active class only for html
var selector = '.side-nav li';
var url = window.location.href;
var target = url.split('/');
$(selector).each(function(){
	if($(this).find('a').attr('href')===('/'+target[target.length-1])){
		$(selector).removeClass('active');
		$(this).removeClass('active').addClass('active');
	}
});

// font render hanlding
if (/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) ||
	(/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.platform))) {
		$('body').addClass('small-device-detected');
}

// filter active class
$('.filter-items li a:not(.btn-submit-idea)').on('click', function(){
	$('.filter-items li a').removeClass('active');
	$(this).addClass('active');
});

// custom dropdown 
$('.custom-dropdown a').on('click', function(){
	$('.custom-dropdown').removeClass('show-custom-dd');
	if($(this).parents('.custom-dropdown').hasClass('show-custom-dd')){
		$('.custom-dropdown').removeClass('show-custom-dd');
		$('.custom-dd-overlay').remove();
	}else{
		$(this).parents('.custom-dropdown').addClass('show-custom-dd');
		$('.main-wrapper').append('<div class="custom-dd-overlay"></div>');
	}
});
$('body').on('click', '.custom-dd-overlay', function(){
	$('.custom-dropdown').removeClass('show-custom-dd');
	$('.custom-dd-overlay').remove();
	$('.filter-items li a').removeClass('active');
});

// team image show on upload
function readURL(input, $this) {
	
	if (input.files && input.files[0]) {
			var reader = new FileReader();
			
			reader.onload = function (e) {
					$this.parent('.image-uploader-wrap').find('.team-profile-img').attr('src', e.target.result);
					$this.parent('.image-uploader-wrap').addClass('profile-img-uploaded');
			}
			
			reader.readAsDataURL(input.files[0]);
	}
}

$(".image-uploader").change(function(){
	var $this = $(this);
	readURL(this, $this);
});
	
$(".truncate").each(function() {
	charLimit = 400
	content = $(this)[0].innerHTML.trim()
	link = $(this).data("link")

	if (content.length > charLimit) {
		content = content.substring(0, charLimit).trim()
		$(this).html(`${content}...`)
	}

	$(this).append(` <a href='${link}'>view more<a>`)
})