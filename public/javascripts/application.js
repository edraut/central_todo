function roundCorners(){
	jQuery(".list_section").corner("20px");
	jQuery(".section").corner("13px");
	jQuery(".label").corner("4px");
	jQuery(".line_item_expand_control_plan").corner("7px");
	jQuery(".line_item_expand_control_labels").corner("tr bottom 7px");
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
	bindLabelSubmit();
	bindLineItemControls();
	bindConfirm();
	jQuery("[data-drag_handle]").live('mousedown',handleSortBegin);
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
function showModalMask() {

	var mask_height = jQuery(document).height();
	var mask_width = jQuery(document).width();

	jQuery('#modal_mask').css('top', '0px');
	jQuery('#modal_mask').css('left', '0px');
	jQuery('#modal_mask').css('height', mask_height);
	jQuery('#modal_mask').css('width', mask_width);
	jQuery('#modal_mask').show();
	jQuery('#modal_mask').fadeTo('fast',0.4);
	roundCorners();
};
function hideModalMask(){
	jQuery('#modal_mask').hide();
}
function hideDialog(selector){
  location.reload();
}
function addDatePicker(){
	jQuery("[data-behavior='date_picker']").datetimepicker({
  	ampm: true,
  	stepMinute: 5
  });
}
function bindLineItemControls(){
	jQuery("[data-auto_submit='true']").bind('submitme',function(e){
		jQuery(e.target).parents('form').submit();
	});
	jQuery("[data-hover_stop='true']").live('click', function(e){
		showModalMask();
		jQuery(e.target).addClass('line_item_control_expander_active');
		unbindHoverShowMore();
	});
	jQuery("[data-hover_rebind='true']").live('click change', function(e){
		hideModalMask();
		jQuery("[data-hover_stop='true']").removeClass('line_item_control_expander_active');
		bindHoverShowMore();
	});
	bindClickMultiSelect();
	bindHiddenMultiProxy();
}
function startSort(candidate){
	candidate.addClass('sorting');
	candidate.data('sorting',true);
	jQuery(document).bind('select',stopSelect);
}
function handleSortBegin(e){
	if(e.originalEvent.touches){
		touch = e.originalEvent.touches[0];
	} else {
		touch = e;
	}
	target = jQuery(e.target);
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element='true']");
	}
	if(!target.data('sorting')){
		jQuery(document).data('element_being_dragged',target);
		jQuery(document).bind('mousemove',handleSortMove);
		jQuery(document).one('mouseup',handleSortEnd);
		target_offset = target.offset();
		target.data('sorting',false);
		target.data('touchstart_top',touch.pageY);
		target.data('timer',setTimeout(function(){startSort(target)},150));
		if(!target.data('original_offset',target_offset)){
			target.data('original_offset',target_offset);
		}
		siblings = jQuery("[data-sort_element]:not('#" + target.attr('id') + "')");
		siblings.die('mousemove',handleSortMove);
		lower_siblings = [];
		higher_siblings = [];
		siblings.each(function(i){
			sibling = jQuery(this);
			if (sibling.offset().top > target_offset.top){
				lower_siblings.push(sibling);
			} else {
				higher_siblings.push(sibling);
			}
		});
		lower_siblings.sort(function(a,b){
			return a.offset().top - b.offset().top;
		});
		higher_siblings.sort(function(a,b){
			return b.offset().top - a.offset().top;
		});
		target.data('lower_siblings',lower_siblings);
		target.data('higher_siblings',higher_siblings);
		e.preventDefault();
		return false;
	}
}
function handleSortMove(e){
	clearTimeout(jQuery(document).data('scrollTimer'));
	if(e.originalEvent.touches){
		touch = e.originalEvent.touches[0];
	} else {
		touch = e;
	}
	if(sortMove(touch.pageY)){
		e.preventDefault();
		return false;
	} else {
		return true;
	}
}
function stopSelect(e){
	e.preventDefault();
	return false;
}
function sortMove(top){
	target = jQuery(document).data('element_being_dragged');
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element]");
	}
	if(target.data('sorting')){
		target_offset = target.data('original_offset');
		y_change = top - target.data('touchstart_top');
		new_top = target_offset.top + y_change;
		target.offset({left: target_offset.left,top: new_top});
		while ((target.data('lower_siblings').length > 0) && (new_top > (target.data('lower_siblings')[0].offset().top) -10)){
			target.data('higher_siblings').unshift(target.data('lower_siblings').shift());
			move_sibling = target.data('higher_siblings')[0];
			move_sibling_offset = move_sibling.offset();
			move_sibling.offset({left: move_sibling_offset.left,top: (move_sibling_offset.top - target.outerHeight())})
		}
		while ((target.data('higher_siblings').length > 0) && (new_top < (target.data('higher_siblings')[0].offset().top) +10)){
			target.data('lower_siblings').unshift(target.data('higher_siblings').shift());
			move_sibling = target.data('lower_siblings')[0];
			move_sibling_offset = move_sibling.offset();
			move_sibling.offset({left: move_sibling_offset.left,top: (move_sibling_offset.top + target.outerHeight())})
		}
		if((jQuery(window).scrollTop() + 8) > top){
			autoScroll(top,'up','fast');
		} else if((jQuery(window).scrollTop() + 16) > top){
			autoScroll(top,'up','slow');
		}
		if(((jQuery(window).scrollTop() + jQuery(window).height()) - 8) < top){
			autoScroll(top,'down','fast');
		} else if(((jQuery(window).scrollTop() + jQuery(window).height()) - 16) < top){
			autoScroll(top,'down','slow');
		}
		return true;
	} else {
		return false;
	}
}
function autoScroll(top,direction,speed){
	if(speed == 'fast'){
		pixels = 12;
	} else {
		pixels = 8
	}
	if(direction == 'up'){
		jQuery(window).scrollTop(jQuery(window).scrollTop() - pixels);
		jQuery(document).data('scrollTimer',setTimeout(function(){sortMove(top - pixels)},15));
	} else {
		jQuery(window).scrollTop(jQuery(window).scrollTop() + pixels);
		jQuery(document).data('scrollTimer',setTimeout(function(){sortMove(top + pixels)},15));
	}
}
function handleSortEnd(e){
	target = jQuery(document).data('element_being_dragged');
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element]");
	}
	if(target.data('timer')){
		clearTimeout(target.data('timer'));
	}
	if(target.data('sorting')){
		target_offset = target.offset();
		same_left = target_offset.left;
		if(target.data('higher_siblings').length > 0){
			sibling_above = target.data('higher_siblings')[0];
			new_top = sibling_above.offset().top + sibling_above.outerHeight();
			target.offset({left: same_left,top:new_top});
		} else {
			new_top = target.parent().offset().top;
			target.offset({left: same_left,top:new_top});
		}
		target.removeClass('sorting');
		sort_container = target.parents("[data-sort_container]");
		sort_url = sort_container.attr('data-sort_url');
		higher_siblings.reverse();
		var sorted_items = [];
		sorted_items = sorted_items.concat(target.data('higher_siblings'));
		sorted_items.push(target);
		sorted_items = sorted_items.concat(target.data('lower_siblings'));
		var sorted_ids = [];
		for(var i = 0; i < sorted_items.length; i++){
			var item = sorted_items[i];
			var these_parts = item.attr('id').split('_');
			var name = these_parts[0];
			var id = these_parts[1];
			sorted_ids.push(name + '[]=' + id);
		};
		jQuery.ajax({
			type: 'GET',
			dataType: 'html',
			data: sorted_ids.join('&'),
			url: sort_url
		});
		target.data('sorting',false);
		target.data('touchstart_top',null);
		target.data('timer',null);
		target.data('higher_siblings',null);
		target.data('lower_siblings',null);
		jQuery(document).unbind('mousemove',handleSortMove);
		jQuery(document).data('element_being_dragged',null);
		jQuery(document).unbind('select',stopSelect)
	}
}
