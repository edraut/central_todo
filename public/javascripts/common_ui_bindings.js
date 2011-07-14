function getActualLinkTarget(alleged_link_target){
	if (alleged_link_target.is('a') || alleged_link_target.is('div')){
		return alleged_link_target;
	} else if(alleged_link_target.parents('a').length > 0) {
		return alleged_link_target.parents('a');
	} else {
		return alleged_link_target.parents('div:first');
	}
}
function bindLinkToForm(){
    jQuery("[data-behavior='link_to_form']").live('click',function(e){
        var form_string = jQuery('<form method="post" action="' + jQuery(this).attr('href') +'" style="display: none;"><input type="hidden" name="authenticity_token" value="'+ authenticity_token + '"><input type="hidden" name="_method" value="' + jQuery(this).attr('data-method') + '"></form>');
        jQuery(this).after(form_string);
        form_string.submit();
        e.preventDefault();
        return false;
    });
};
function bindClickToSelect(){
	jQuery("[data-click_to_select='true']").click(function(e){
		target = jQuery(this);
		jQuery("[data-click_to_select='true'][data-click_id='" + target.attr('data-click_id') + "']").removeClass('selected');
		target.addClass('selected');
	})
}
function bindClickMultiSelect(){
	jQuery("[data-click_multi_select='true']").unbind('click',clickMultiSelect);
	jQuery("[data-click_multi_select='true']").bind('click',clickMultiSelect);
}
function clickMultiSelect(e){
	target = jQuery(e.target);
	if(!target.attr('data-click_multi_select')){
		target = target.parents("[data-click_multi_select='true']");
	}
	if(target.hasClass('selected')){
		target.removeClass('selected');
	} else {
		target.addClass('selected');
	}
}
function bindAutoSubmit(){
	jQuery("[data-behavior='auto_submit']").live('change',function(e){
		jQuery(e.target).parents('form').submit();
	})
}
function captureReturn(e){
	switch(e.which)
	{
		// user presses the "return" key
		case 13:
			submit = jQuery(this).parents('form').find("[data-submit]");
			if(submit){
				submit.addClass('pseudo_active');
				submit.click();
			} else {
				jQuery(this).parents('form').submit();
			}
			break;
	};
};
function bindReturnSubmit(){
	jQuery("[data-return_submit]").live('focus',function(e){
		jQuery(this).bind('keypress',captureReturn);
	});
	jQuery("[data-return_submit]").live('blur',function(e){
		jQuery(this).unbind('keypress',captureReturn);
	});
}
function flashBackground(id){
	element = jQuery('#'+id);
	old_bg_color = getBackground(element);
	element.find('.overflow_fade').hide();
	element.animate(
		{'background-color':'#DDF5F5'},
		300,
		function(){element.animate(
			{'background-color':old_bg_color},
			1000,
			function(){element.find('.overflow_fade').show()}
		)}
	);
}
function getBackground(jqueryElement) {
    // Is current element's background color set?
    var color = jqueryElement.css("background-color");
    if ((color !== 'rgba(0, 0, 0, 0)') && (color !== 'transparent')) {
        // if so then return that color
        return color;
    }
    // if not: are you at the body element?
    if (jqueryElement.is("body")) {
        // return known 'false' value
        return false;
    } else {
        // call getBackground with parent item
        return getBackground(jqueryElement.parent());
    }
}
jQuery.fn.preventDoubleSubmit = function() {
  jQuery(this).submit(function() {
    if (jQuery(this).data('beenSubmitted')){
      return false;
		}
    else
      jQuery(this).data('beenSubmitted',true);
  });
};
jQuery.fn.rebindSubmit = function(){
	jQuery(this).data('beenSubmitted',false);
}
function preventDoubleClick(e) {
	link = jQuery(e.target);
	if(link.data('beenSubmitted')){
	  e.preventDefault();
	  return false;
	}else{
	  link.data('beenSubmitted',true);
	}
};
function bindPreventDoubleClick(){
	jQuery('a').die('click');
	jQuery('a').unbind('click');
	jQuery('a').live('click',preventDoubleClick);
}
function handleListDisplay(){
	jQuery("[data-role='list']").each(function(i){
		if(jQuery(this).find("[data-role='list_item']").length > 0){
			jQuery(this).show();
		}else{
			jQuery(this).hide();
		}
	});
}
function handleCount(list_id,source_list_id){
	jQuery("[data-sort_count='true'][data-sort_count_id='" + list_id + "']").html(jQuery('#' + source_list_id).children().length);
	jQuery("[data-list_count]").each(function(){
		jQuery(this).html(jQuery('#' + jQuery(this).data('list_count')).children().length);
	})
}
// Refactor Expanders into a jQuery function that applies full functionality to the selected elements.
function bindExpanders(){
	jQuery("[data-behavior='expander'][data-action='expand']").die('click');
	jQuery("[data-behavior='expander'][data-action='expand']").live('click', function(e){
		actual_target = jQuery(e.target);
		if(!actual_target.attr('data-action')){
			actual_target = actual_target.parents("[data-action='expand']:first");
		}
		expandExpander(actual_target.attr('data-id'));
		e.preventDefault();
		return false;
	});
	jQuery("[data-behavior='expander'][data-action='contract']").die('click');
	jQuery("[data-behavior='expander'][data-action='contract']").live('click', function(e){
		actual_target = jQuery(e.target);
		if(!actual_target.attr('data-action')){
			actual_target = actual_target.parents("[data-action='contract']:first");
		}
		contractExpander(actual_target.attr('data-id'));
		e.preventDefault();
		return false;
	});
};
function expandExpander(data_id) {
	jQuery("[data-behavior='expander'][data-state='expanded'][data-id='" + data_id + "']").each(function(){
		if(jQuery(this).data('style') == 'visibility'){
			jQuery(this).css('visibility','visible');
		} else {
			jQuery(this).show();
		}
	});
	jQuery("[data-behavior='expander'][data-state='contracted'][data-id='" + data_id + "']").each(function(){
		if(jQuery(this).data('style') == 'visibility'){
			jQuery(this).css('visibility','hidden');
		} else {
			jQuery(this).hide();
		}
	});
	popButtons();
}
function contractExpander(data_id) {
	jQuery("[data-behavior='expander'][data-state='expanded'][data-id='" + data_id + "']").each(function(){
		if(jQuery(this).data('style') == 'visibility'){
			jQuery(this).css('visibility','hidden');
		} else {
			jQuery(this).hide();
		}
	});
	jQuery("[data-behavior='expander'][data-state='contracted'][data-id='" + data_id + "']").each(function(){
		if(jQuery(this).data('style') == 'visibility'){
			jQuery(this).css('visibility','visible');
		} else {
			jQuery(this).show();
		}
	});
}
function bindTabs(){
	jQuery("[data-tab='tab']").click(function(e){
		jQuery("[data-tab='tab'][data-tab_set='" + jQuery(this).attr('data-tab_set') + "']").removeClass('selected');
		jQuery(this).addClass('selected');
		jQuery("[data-tab='tab_content'][data-tab_set='" + jQuery(this).attr('data-tab_set') + "']").hide();
		jQuery('#' + jQuery(this).attr('data-tab_content')).show();
		return(false);
	});
}
function pausecomp(millis) 
{
var date = new Date();
var curDate = null;

do { curDate = new Date(); } 
while(curDate-date < millis);
} 
jQuery.fn.moveToParent = function(parent){
	var $old_item = jQuery(this);
	var $new_item = $old_item.clone().appendTo(parent);
	var $placeholder = jQuery('<div id="tmp_placeholder' + $old_item.attr('id') + '" class="span-18 last">&nbsp;</div>').appendTo(parent);
	var newOffset = $new_item.offset();
	var oldOffset = $old_item.offset();
	var height = $new_item.outerHeight();
	var $temp = $old_item.clone().appendTo('body');
	var newTop = 0;
	if (newOffset.top > oldOffset.top){
		newTop = newOffset.top - height;
	} else {
		newTop = newOffset.top;
	}
	$temp
	  .css('position', 'absolute')
	  .css('left', oldOffset.left)
	  .css('top', oldOffset.top)
	  .css('zIndex', 1000);
	$new_item.hide();
	$old_item.hide();
	$placeholder.height(height);
	//animate the $temp to the position of the new img
	$temp.animate( {'top': newTop, 'left':newOffset.left}, 1000, function(){
	   //callback function, we remove $old_item and $temp and show $new_item
	   $new_item.show();
	   $old_item.remove();
	   $temp.remove();
	   $placeholder.remove();
	});
}
