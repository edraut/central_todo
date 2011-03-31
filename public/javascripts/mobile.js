function deleteProxy(e){
	proxy = jQuery(e.target);
	if(!proxy.attr('data-confirm') || confirm(proxy.attr('data-confirm'))){
		form = proxy.parents('form');
		success = form.attr('data-ajax_success_callback');
		form.attr('data-ajax_success_callback', success + 'jQuery("[data-id=' + "'" + form.attr('data-id') + "'" + ']").remove();handleListDisplay();');
		form_method = form.find('input[name="_method"]');
		form_method.val('delete');
		form.attr('method','DELETE');
		form.submit();
	}
	e.preventDefault();
	return false;
}
function bindDeleteProxy(){
	jQuery("[data-role='delete']").die('click');
	jQuery("[data-role='delete']").live('click',deleteProxy);
}
function handleHalfSections(){
	first_half_section = jQuery('.half_section:first');
	last_half_section = jQuery('.half_section:last');
	if(first_half_section){
		wrapper = first_half_section.parent();
		first_half_section.css('width','50%');
		if (wrapper.width() != last_half_section.width() + first_half_section.width()){
			first_half_section.width(last_half_section.width() + 1);
		}
	}
}
function handleQuarterSections(){
	first_section = jQuery('.quarter_nav:first');
	second_section = jQuery('.quarter_nav:eq(1)');
	third_section = jQuery('.quarter_nav:eq(2)');
	last_section = jQuery('.quarter_nav:last');
	if(first_section){
		wrapper = first_section.parent();
		first_section.css('width','25%');
		second_section.css('width','25%');
		third_section.css('width','25%');
		section_total = first_section.width() + second_section.width() + third_section.width() + last_section.width();
		if (wrapper.width() != section_total){
			difference = wrapper.width() - section_total;
			i = 0;
			while(i < difference) {
				jQuery('.quarter_nav:eq(' + i + ')').width(last_section.width() + 1);
				i++;
			}
		}
	}
}
function startSort(candidate){
	candidate.addClass('sorting');
	target.data('sorting',true);
}
function handleSortBegin(e){
	if(e.originalEvent.touches){
		touch = e.originalEvent.touches[0];
	} else {
		touch = e.pageY;
	}
	target = jQuery(e.target);
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element='true']");
	}
	target_offset = target.offset();
	target.data('sorting',false);
	target.data('touchstart_top',touch.pageY);
	target.data('timer',setTimeout(function(){startSort(target)},150));
	target.data('original_offset',target_offset);
	siblings = jQuery("[data-sort_element]:not('#" + target.attr('id') + "')");
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
function handleSortMove(e){
	if(e.originalEvent.touches){
		touch = e.originalEvent.touches[0];
	} else {
		touch = e;
	}
	target = jQuery(e.target);
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element]");
	}
	if(target.data('sorting')){
		jQuery('#testone').html(target.get(0).style.length);
		target_offset = target.data('original_offset');
		y_change = touch.pageY - target.data('touchstart_top');
		new_top = target_offset.top + y_change;
		target.css('-webkit-transform','translate3d(0,' + y_change + 'px,0)');
		// target.offset({left: target_offset.left,top: new_top});
		if(y_change > 0){
			target.data('lower_siblings').forEach(function(sibling){
				if (new_top < sibling.offset().top){
					break;
				} else {
					target.data('higher_siblings').unshift(target.data('lower_siblings').shift());
					move_sibling = target.data('higher_siblings')[0];
					move_sibling_offset = move_sibling.offset();
					move_sibling.offset({left: move_sibling_offset.left,top: (move_sibling_offset.top - target.outerHeight())})
				}
			});
		} else if(y_change < 0) {
			target.data('higher_siblings').forEach(function(sibling){
				if (new_top > sibling.offset().top){
					break;
				} else {
					target.data('lower_siblings').unshift(target.data('higher_siblings').shift());
					move_sibling = target.data('lower_siblings')[0];
					move_sibling_offset = move_sibling.offset();
					move_sibling.offset({left: move_sibling_offset.left,top: (move_sibling_offset.top + target.outerHeight())})
				}
			});
		}
		e.preventDefault();
		return false;
	} else {
		return true;
	}
}
function handleSortEnd(e){
	target = jQuery(e.target);
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element]");
	}
	if(target.data('timer')){
		clearTimeout(target.data('timer'));
	}
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
	sorted_items = [];
	higher_siblings.reverse();
	sorted_items = sorted_items.concat(target.data('higher_siblings'));
	sorted_items.push(target);
	sorted_items = sorted_items.concat(target.data('lower_siblings'));
	sorted_ids = [];
	sorted_items.forEach(function(item){
		these_parts = item.attr('id').split('_');
		name = these_parts[0];
		id = these_parts[1];
		sorted_ids.push(name + '[]=' + id);
	});
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
}
jQuery(window).bind('orientationchange',function(){
	handleHalfSections();
	handleQuarterSections();
});
jQuery(window).bind('resize',function(){
	handleHalfSections();
	handleQuarterSections();
});
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	bindAutoSubmit();		
    bindLinkToForm();
	bindDeleteProxy();
	bindPreventDoubleClick();
	jQuery("[data-drag_handle]").live('touchstart',handleSortBegin);
	jQuery("[data-drag_handle]").live('touchmove',handleSortMove);
	jQuery("[data-drag_handle]").live('touchend',handleSortEnd);
	jQuery("[data-drag_handle]").live('mousedown',handleSortBegin);
	jQuery("[data-drag_handle]").live('mousemove',handleSortMove);
	jQuery("[data-drag_handle]").live('mouseup',handleSortEnd);
});
jQuery(window).load(function(){
	setTimeout(handleHalfSections,100);
	setTimeout(handleQuarterSections,100);
})