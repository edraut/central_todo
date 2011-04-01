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
	candidate.data('sorting',true);
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
		jQuery(document).bind('touchmove',handleSortMove);
		jQuery(document).one('touchend',handleSortEnd);
		target_offset = target.offset();
		target.data('sorting',false);
		target.data('touchstart_top',touch.pageY);
		target.data('timer',setTimeout(function(){startSort(target)},400));
		if(!target.data('original_offset',target_offset)){
			target.data('original_offset',target_offset);
		}
		siblings = jQuery("[data-sort_element]:not('#" + target.attr('id') + "')");
		siblings.die('touchmove',handleSortMove);
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
function sortMove(top){
	target = jQuery(document).data('element_being_dragged');
	if(!target.attr('data-sort_element')){
		target = target.parents("[data-sort_element]");
	}
	if(target.data('sorting')){
		target_offset = target.data('original_offset');
		y_change = top - target.data('touchstart_top');
		new_top = target_offset.top + y_change;
		target.css('-webkit-transform','translate3d(0,' + y_change + 'px,0)');
		while ((target.data('lower_siblings').length > 0) && (new_top > (target.data('lower_siblings')[0].offset().top) -10)){
			target.data('higher_siblings').unshift(target.data('lower_siblings').shift());
			move_sibling = target.data('higher_siblings')[0];
			move_sibling_offset = move_sibling.offset();
			move_sibling.offset({left: move_sibling_offset.left,top: (move_sibling_offset.top - target.outerHeight())})
		}
		while ((target.data('higher_siblings').length > 0) && (new_top < (target.data('higher_siblings')[0].offset().top +10))){
			target.data('lower_siblings').unshift(target.data('higher_siblings').shift());
			move_sibling = target.data('lower_siblings')[0];
			move_sibling_offset = move_sibling.offset();
			move_sibling.offset({left: move_sibling_offset.left,top: (move_sibling_offset.top + target.outerHeight())})
		}
		if((jQuery(window).scrollTop() + 20) > top){
			autoScroll(top,'up','fast');
		} else if((jQuery(window).scrollTop() + 40) > top){
			autoScroll(top,'up','slow');
		}
		if(((jQuery(window).scrollTop() + window.innerHeight) - 20) < top){
			autoScroll(top,'down','fast');
		} else if(((jQuery(window).scrollTop() + window.innerHeight) - 40) < top){
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
		target.css('-webkit-transform','none');
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
		sorted_items.forEach(function(item){
			var these_parts = item.attr('id').split('_');
			var name = these_parts[0];
			var id = these_parts[1];
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
		jQuery(document).unbind('mousemove',handleSortMove);
		jQuery(document).data('element_being_dragged',null);
		jQuery("[data-drag_handle]").live('touchmove',handleSortMove);
	}
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
});
jQuery(window).load(function(){
	setTimeout(handleHalfSections,100);
	setTimeout(handleQuarterSections,100);
})