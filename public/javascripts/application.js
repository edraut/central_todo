function roundCorners(){
	jQuery(".list_section").corner("20px");
	jQuery(".section").corner("13px");
	jQuery(".label").corner("4px");
	jQuery(".line_item_expand_control_plan,.project_folder_select").corner("7px");
	jQuery(".line_item_expand_control_labels").corner("tr bottom 7px");
	jQuery(".count").corner(".5em");
	jQuery(".nav_tools").corner(".5em");
	if (jQuery.browser.msie) {
		jQuery("#main_logo_glare").corner("top 24px").parent().css('padding','1px').corner("25px").parent().css('padding','5px').corner("30px");
	}
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	roundCorners();
	bindAutoSubmit();
	bindReturnSubmit();
  bindLinkToForm();
	bindLineItemControls();
	bindTabs();
	bindSortables();
	bindHoverShowMore();
	bindHoverReveal();
	bindLabelSubmit();
	bindModalTriggers();
	bindFocusAfterExpand();
	jQuery("[data-drag_handle]").live('mousedown',handleSortBegin);
	jQuery("[data-role='top_nav_element']").each(function(i){
		vertCenterDiv(jQuery(this),jQuery('#top_nav_wrapper'));
	});
	jQuery("#left_nav_spacer").height(jQuery("#header_wrapper").outerHeight(true));
	if (jQuery.browser.msie) {
		page_content = jQuery('.page_content');
		if(page_content.length > 0){
			page_content.addIEShadow('large');
		}
		selected_nav = jQuery('div.vert-line-nav-wrapper-main.selected');
		if(selected_nav.length > 0){
			selected_nav.addIEShadow('large');
		}
		// other_nav = jQuery('div.vert-line-nav-wrapper-main:not(.selected)');
		// if(other_nav.length > 0){
		// 	other_nav.each(function(){
		// 		jQuery(this).addIEShadow('small');
		// 	});
		// }
		content_tab = jQuery('.attach_above.selected');
		if(content_tab.length > 0){
			content_tab.addIEShadow('large');
		}
	}
	setTimeout(addDatePicker,750);
});
jQuery.fn.addIEShadow = function(size,corner_radius) {
	shadow_div = jQuery('<div class="ie_shadow_' + size + '" data-shadowed="' + jQuery(this).attr('id') + '">&nbsp;</div>');
	jQuery(this).append(shadow_div);
	element_offset = jQuery(this).offset();
	shadow_div.offset({top: element_offset.top -3, left: element_offset.left -5})
	shadow_div.height(jQuery(this).outerHeight());
	shadow_div.width(jQuery(this).outerWidth());
	if(typeof(corner_radius) != 'undefined'){
		shadow_div.corner(corner_radius);
	}
}
function bindModalTriggers(){
	jQuery("[data-modal_trigger]").live('click',function(e){
		modal = jQuery("[data-modal][data-modal_id='" + jQuery(this).attr('data-modal_id') + "']");
		jQuery('body').append(modal);
		insert_field = modal.find("[data-modal_insert]");
		if(insert_field.length > 0){
			insert_field.val(jQuery(this).attr('data-modal_insert_value'));
		}
		display_name_element = modal.find("[data-modal_display_name]");
		if(display_name_element.length > 0){
			display_name_element.html(jQuery(this).attr('data-modal_display_name'));
		}
		showModalMask();
		modal.show();
		repositionDialog(modal,'center');
		popButtons();
	});
	jQuery("[data-modal_closer]").live('click',function(e){
		modal = jQuery("[data-modal][data-modal_id='" + jQuery(this).attr('data-modal_id') + "']");
		modal.hide();
		hideModalMask();
	});
}
function repositionDialog(selector,vertical_position){
	var scroll_top = jQuery(window).scrollTop();
	var window_width = jQuery(window).width();
	if(vertical_position == 'center'){
		var window_height = jQuery(window).height();
		var dialog_top =  window_height/2-jQuery(selector).outerHeight()/2+scroll_top;
		var dialog_left = window_width/2-jQuery(selector).outerWidth()/2;
	}
	if(vertical_position == 'top'){
		var dialog_top = scroll_top;
		var dialog_left = window_width/2-jQuery(selector).outerWidth()/2;
	}
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
	repositionDialog(selector,'center');
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
	jQuery("[data-behavior='date_picker']").datepicker({
			dateFormat: 'M d, yy'
	  });
}
function bindLineItemControls(){
	jQuery("[data-auto_submit='true']").bind('submitme',function(e){
		jQuery(this).parents('form').submit();
	});
	jQuery("[data-hover_stop='true']").live('click', function(e){
		jQuery("[data-hover_stop='true']").each(
			function(){jQuery(this).removeClass('line_item_control_expander_active');}
		);
		jQuery("[data-hover_rebind='true']").each(
			function(){
				contractExpander(jQuery(this).parents("[data-behavior='expander'][data-state='expanded']:first").attr('data-id'));
			}
		);
		jQuery(this).addClass('line_item_control_expander_active');
		unbindHoverShowMore();
	});
	jQuery("[data-hover_rebind='true']").live('click change', function(e){
		jQuery(this).parents("[data-behavior='expander'][data-state='expanded']:first").hide();
		jQuery("[data-hover_stop='true']").removeClass('line_item_control_expander_active');
		bindHoverShowMore();
	});
	bindClickMultiSelect();
	bindHiddenMultiProxy();
}
function getSortElement(target){
	if(!target.attr('data-sort_element')){
		return target.parents("[data-sort_element='true']:first");
	} else {
		return target;
	}
}
function startSort(target){
	target.data('sorting',true);
	stunt_double = target.clone();
	jQuery('body').append(stunt_double);
	left_margin = parseInt(target.css('margin-left'));
	if(isNaN(left_margin)){
		left_margin = 0;
	}
	stunt_double
		.css('position','absolute')
		.css('left',(target.offset().left - left_margin))
		.css('top',target.offset().top);
	stunt_double.addClass('sorting');
	target.data('stunt_double',stunt_double);
	mask = jQuery('<div>&nbsp;</div>');
	target.append(mask);
	mask
	.css('position','absolute')
	.css('left',0)
	.css('top',0)
	.css('width',target.outerWidth())
	.css('height',target.outerHeight())
	.css('background-color',getBackground(target))
	.css('z-index',1003);
	target.data('mask',mask);
}
function handleSortBegin(e){
	jQuery(document).bind('select',stopSelect);
	if(e.originalEvent.touches){
		touch = e.originalEvent.touches[0];
	} else {
		touch = e;
	}
	target = getSortElement(jQuery(e.target));
	if(!target.data('sorting')){
		jQuery(document).data('element_being_dragged',target);
		jQuery(document).bind('mousemove',handleSortMove);
		jQuery(document).one('mouseup',handleSortEnd);
		target_offset = target.offset();
		linked_containers = jQuery("[data-sort_container='true'][data-sort_id='" + target.attr('data-sort_id') + "']:visible");
		linked_container_map = {};
		linked_containers.each(function(i){
			linked_container_map[jQuery(this).attr('id')] = i;
		});
		target.data('linked_containers',linked_containers);
		target.data('linked_container_map',linked_container_map);
		target.data('sorting',false);
		target.data('touchstart_top',touch.pageY);
		target.data('timer',setTimeout(function(){startSort(target)},150));
		target.data('original_offset',target_offset);
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
	sortMove(touch.pageY)
	e.preventDefault();
	return false;
}
function stopSelect(e){
	e.preventDefault();
	return false;
}
function sortMove(top){
	target = jQuery(document).data('element_being_dragged');
	if(target && target.data('sorting')){
		stunt_double = target.data('stunt_double');
		target_offset = target.data('original_offset');
		y_change = top - target.data('touchstart_top');
		new_top = target_offset.top + y_change;
		if(((jQuery(window).scrollTop() > 10) || (new_top > 10)) && 
			(((jQuery(window).scrollTop() + jQuery(window).height()) < (jQuery(document).height() - 20)) ||
				((new_top + target.outerHeight()) < (jQuery(document).height() - 20)))){
			stunt_double.offset({left: target_offset.left,top: new_top});
		} else {
			return true;
		}
		linked_containers = target.data('linked_containers');
		linked_container_map = target.data('linked_container_map');
		var parent = target.parent();
		parent_index = linked_container_map[parent.attr('id')];
		linked_container_last = linked_containers.length - 1;
		if(parent_index != 0){
			prev_uncle = jQuery(linked_containers[parent_index - 1]);
			gap = parent.offset().top - prev_uncle.vertical_bottom();
			if(stunt_double.vertical_middle() < (prev_uncle.vertical_bottom() + (gap / 2))){
				prev_uncle.append(target);
				updateSort(parent.attr('data-sort_mirror'),parent.getSortElementIds(),parent.attr('data-sort_type'));
				updateSort(prev_uncle.attr('data-sort_mirror'),prev_uncle.getSortElementIds(),parent.attr('data-sort_type'));
			}
		}
		if(parent_index != linked_container_last){
			next_uncle = jQuery(linked_containers[parent_index + 1]);
			gap = next_uncle.offset().top - parent.vertical_bottom();
			if(stunt_double.vertical_middle() > (next_uncle.offset().top - (gap / 2))){
				next_uncle.prepend(target);
				updateSort(parent.attr('data-sort_mirror'),parent.getSortElementIds(),parent.attr('data-sort_type'));
				updateSort(next_uncle.attr('data-sort_mirror'),next_uncle.getSortElementIds(),parent.attr('data-sort_type'));
			}
		}
		last_id = target.parent().children().last().attr('id');
		parent = target.parent();
		parent_index = linked_container_map[parent.attr('id')];
		target_id = target.attr('id');
		while ((target_id != parent.children().first().attr('id')) && (stunt_double.vertical_middle() < (target.prev().vertical_bottom()))){
			target.prev().before(target);
		}
		while ((target_id != parent.children().last().attr('id')) && (stunt_double.vertical_middle() > (target.next().offset().top))){
			target.next().after(target);
		}
		if(((jQuery(window).scrollTop() + 8) > top) && (jQuery(window).scrollTop() > 0)){
			autoScroll(top,'up','fast');
		} else if((jQuery(window).scrollTop() + 16) > top){
			autoScroll(top,'up','slow');
		}
		if(
				(((jQuery(window).scrollTop() + jQuery(window).height()) - 8) < top) &&
				((jQuery(window).scrollTop() + jQuery(window).height()) < jQuery(document).height())
			){
			autoScroll(top,'down','fast');
		} else if(((jQuery(window).scrollTop() + jQuery(window).height()) - 16) < top){
			autoScroll(top,'down','slow');
		}
		return true;
	} else {
		return false;
	}
}
jQuery.fn.vertical_middle = function() {
	return jQuery(this).offset().top + (jQuery(this).outerHeight() / 2);
}
jQuery.fn.vertical_bottom = function() {
	return jQuery(this).offset().top + jQuery(this).outerHeight();
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
function sendSortData(sort_container,target){
	sort_url = sort_container.attr('data-sort_url');
	var sorted_ids = [];
	sort_container.children().each(function(i){
		var item = jQuery(this);
		var these_parts = item.attr('id').split('_');
		var name = these_parts[0];
		var id = these_parts[1];
		sorted_ids.push(name + '[]=' + id);
	});
	jQuery.ajax({
		type: 'GET',
		dataType: 'html',
		data: sorted_ids.join('&'),
		url: sort_url,
		success: function(data,textStatus){
			jQuery("[data-sort_container='true'][data-sort_id='" + target.attr('data-sort_id') + "']").each(function(i){
				jQuery("[data-sort_count='true'][data-sort_count_id='" + jQuery(this).attr('data-sort_count_id') + "']").html(jQuery(this).children().length);
			});
		}
	});
}
function handleSortEnd(e){
	jQuery(document).unbind('mousemove',handleSortMove);
	target = jQuery(document).data('element_being_dragged');
	if(target.data('timer')){
		clearTimeout(target.data('timer'));
	}
	if(target.data('sorting')){
		target.data('stunt_double').remove();
		target.data('mask').remove();
		sort_container = target.parent();
		sendSortData(sort_container,target);
		target.data('sorting',false);
		target.data('touchstart_top',null);
		target.data('timer',null);
		target.data('original_offset',null);
		jQuery(document).data('element_being_dragged',null);
		jQuery(document).unbind('select',stopSelect)
	}
	if(sort_container.attr('data-sort_mirror')){
		if(jQuery(sort_container).attr('data-sort_mirror') && (jQuery(jQuery(sort_container).attr('data-sort_mirror')).length > 0)){
			updateSort(jQuery(sort_container).attr('data-sort_mirror'),sort_container.getSortElementIds(),jQuery(sort_container).attr('data-sort_type'));
		}
	}
}
jQuery.fn.getSortElementIds = function() {
	var sorted_child_ids = [];
	jQuery(this).children().each(function(i){
		var item = jQuery(this);
		var these_parts = item.attr('id').split('_');
		var name = these_parts[0];
		var id = parseInt(these_parts[1]) + '';
		sorted_child_ids.push(id);
	});
	return sorted_child_ids;
}
function updateSort(container_selector,child_id_list,type){
	old_ids = jQuery(container_selector).getSortElementIds();
	delete_ids = old_ids.slice(0);
	for(i=0;i<child_id_list.length;i++){
		this_selector = "[data-sort_element_type='" + type + "'][data-sort_element_id='" + child_id_list[i] + "']";
		this_elem = jQuery(this_selector);
		jQuery(container_selector).append(jQuery(this_selector));
		for(j=0;j<delete_ids.length;j++){
			if(delete_ids[j] == child_id_list[i]){
				delete_ids.splice(j,1);
				break;
			}
		}
	};
	for(j=0;j<old_ids.length;j++){
		for(k=0;k<child_id_list.length;k++){
			if(old_ids[j] == child_id_list[k]){
				child_id_list.splice(k,1);
				break;
			}
		}
	}
}
function popButtons(){
	jQuery('.button').each(function(i){
		if(jQuery(this).find('.glare').length == 0){
			glare = jQuery('<div class="glare">&nbsp;</div>');
			jQuery(this).prepend(glare);
		} else {
			glare = jQuery(this).find('.glare');
		}
		width = jQuery(this).outerWidth();
		if (!jQuery.browser.msie) {
			if(jQuery(this).hasClass('small')){
				glare.width(width - 10);
			} else {
				glare.width(width - 16);
			}
		}
	});
}
function focusAfterExpand(expander){
  jQuery("[data-behavior='expander'][data-state='expanded'][data-id='" + expander.data('id') + "']").find("[data-primary_input]").focus()
}
function bindFocusAfterExpand(){
	jQuery("[data-behavior='expander'][data-action='expand']").click(function(e){
    x = jQuery(this);
    setTimeout(function(){focusAfterExpand(x)},750);
  });
}
