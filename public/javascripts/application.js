function roundCorners(){
	jQuery(".list_section").corner("20px");
	jQuery(".section").corner("13px");
	jQuery(".label").corner("4px");
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	roundCorners();
	bindAutoSubmit();		
  bindLinkToForm();
	bindExpanders();
	bindSortables();
	bindFocusTaskInput();
	bindHoverShowMore();
	jQuery("[data-role='top_nav_element']").each(function(i){
		vertCenterDiv(jQuery(this),jQuery('#top_nav_wrapper'));
	});
	jQuery("#left_nav_spacer").height(jQuery("#header_wrapper").outerHeight(true));
	if (jQuery.browser.msie) {
		jQuery('.page_content').addIEShadow('large');
		jQuery('div.vert-line-nav-wrapper-main.selected').addIEShadow('large');
	}
	setTimeout(addDatePicker,750);
});
jQuery.fn.addIEShadow = function(size) {
	shadow_div = jQuery('<div class="ie_shadow_' + size + '">&nbsp;</div>');
	jQuery('body').append(shadow_div);
	element_offset = jQuery(this).offset();
	shadow_div.offset({top: element_offset.top, left: element_offset.left})
	shadow_div.height(jQuery(this).outerHeight());
	shadow_div.width(jQuery(this).outerWidth());
}
function repositionDialog(selector){
	var window_height = jQuery(window).height();
	var scroll_top = jQuery(window).scrollTop();
	var window_width = jQuery(window).width();
	var dialog_top =  window_height/2-jQuery(selector).outerHeight()/2+scroll_top;
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
function addDatePicker(){
	jQuery("[data-behavior='date_picker']").datetimepicker({
  	ampm: true,
  	stepMinute: 5
  });
}
