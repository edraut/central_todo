function roundCorners(){
	jQuery(".section_wrapper").corner("20px");
	jQuery(".section").corner("13px");
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	bindAttributeControl();
	roundCorners();
	bindAutoSubmit();		
    bindLinkToForm();
	bindExpanders();
	bindFocusTaskInput();
});
function repositionDialog(selector){
	var window_height = jQuery(window).height();
	var window_width = jQuery(window).width();
	var dialog_top =  window_height/2-jQuery(selector).outerHeight()/2;
	var dialog_left = window_width/2-jQuery(selector).outerWidth()/2;
	if(dialog_top < 0){ dialog_top = 0};
	if(dialog_left < 0){ dialog_left = 0};
	jQuery(selector).css('top',dialog_top);
	jQuery(selector).css('left', dialog_left);
};
function showDialog(selector) {

	var mask_height = jQuery(document).height();
	var mask_width = jQuery(document).width();

	jQuery('#modal_mask').css('top', '0px');
	jQuery('#modal_mask').css('left', '0px');
	jQuery('#modal_mask').css('height', mask_height);
	jQuery('#modal_mask').css('width', mask_width);
	jQuery('#modal_mask').show();
	jQuery('#modal_mask').fadeTo('fast',0.4);
	repositionDialog(selector);
	jQuery(selector).show();
	roundCorners();
};
function hideDialog(selector){
  location.reload();
}
