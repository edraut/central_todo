function deleteProxy(e){
	proxy = jQuery(e.target);
	form = proxy.parents('form');
	success = form.attr('data-ajax_success_callback');
	form.attr('data-ajax_success_callback', success + 'jQuery("[data-id=' + "'" + form.attr('data-id') + "'" + ']").remove();handleListDisplay();');
	form_method = form.find('input[name="_method"]');
	form_method.val('delete');
	form.attr('method','DELETE');
	form.submit();
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
function getSortElement(target){
	if(!target.attr('data-sort_element')){
		return target.parents("[data-sort_element='true']:first");
	} else {
		return target;
	}
}
var sort_event_lock = 0;
var wants_to_end = false;
function startSort(target){
	if(sort_event_lock++ == 0){
		jQuery(document).data('sort_beginning',true);
		stunt_double = target.clone().appendTo('body');
		stunt_double
			.css('position','absolute')
			.css('left',target.offset().left)
			.css('top',target.offset().top)
			.css('width',target.width());
		stunt_double.addClass('sorting');
		target.data('stunt_double',stunt_double);
		mask = jQuery('<div>&nbsp;</div>');
		target.append(mask);
		mask
		.css('position','absolute')
		.css('left',0)
		.css('top',0)
		.css('width',target.width())
		.css('height',target.height())
		.css('background-color',getBackground(target))
		.css('z-index',10);
		target.data('mask',mask);
		target.data('sorting',true);
		jQuery(document).data('sort_beginning',false);
	}
	sort_event_lock--;
	if(wants_to_end){
		handleSortEnd(wants_to_end);
		wants_to_end = false;
	}
}
function handleSortBegin(e){
	jQuery(document).bind('select',stopSelect);
	if(e.originalEvent.touches){
		touch = e.originalEvent.touches[0];
	} else {
		touch = e;
	}
	target = getSortElement(jQuery(e.target));
	if(!target.data('sorting') && !target.data('timer')){
		jQuery(document).data('element_being_dragged',target);
		jQuery(document).bind('touchmove',handleSortMove);
		jQuery(document).one('touchend',handleSortEnd);
		target_offset = target.offset();
		linked_containers = jQuery("[data-sort_container='true'][data-sort_id='" + target.attr('data-sort_id') + "']:visible");
		linked_container_map = {};
		linked_containers.each(function(i){
			linked_container_map[jQuery(this).attr('id')] = i;
		});
		target.data('linked_containers',linked_containers);
		target.data('linked_container_map',linked_container_map);
		target.data('touchstart_top',touch.pageY);
		target.data('timer',setTimeout(function(){startSort(target)},150));
		target.data('original_offset',target_offset);
		e.preventDefault();
		return false;
	} else {
		handleSortEnd(e);
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
					stunt_double.css('-webkit-transform','translate3d(0,' + y_change + 'px,0)');
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
			}
		}
		if(parent_index != linked_container_last){
			next_uncle = jQuery(linked_containers[parent_index + 1]);
			gap = next_uncle.offset().top - parent.vertical_bottom();
			if(stunt_double.vertical_middle() > (next_uncle.offset().top - (gap / 2))){
				next_uncle.prepend(target);
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
		if(((jQuery(window).scrollTop() + 5) > top) && (jQuery(window).scrollTop() > 0)){
			autoScroll(top,'up','fast');
		} else if((jQuery(window).scrollTop() + 10) > top){
			autoScroll(top,'up','slow');
		}
		if(
				((jQuery(window).scrollTop() + window.innerHeight - 5) < top) &&
				((jQuery(window).scrollTop() + window.innerHeight) < jQuery(document).height())
			){
			autoScroll(top,'down','fast');
		} else if((jQuery(window).scrollTop() + window.innerHeight - 10) < top){
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
function handleSortEnd(e){
	if(sort_event_lock++ == 0){
		jQuery(document).unbind('touchmove',handleSortMove);
		target = jQuery(document).data('element_being_dragged');
		if(target.data('timer')){
			clearTimeout(target.data('timer'));
		}
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
	} else {
		wants_to_end = e;
	}
	sort_event_lock--;
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
function clearSorts(e){
	handleSortEnd(e);
	return true;
}
jQuery(window).bind('orientationchange',function(){
	handleHalfSections();
	handleQuarterSections();
});
jQuery(window).bind('resize',function(){
	handleHalfSections();
	handleQuarterSections();
});
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
function popButtons(){
	jQuery('.button').each(function(i){
		if(jQuery(this).find('.glare').length == 0){
			glare = jQuery('<div class="glare">&nbsp;</div>');
			jQuery(this).prepend(glare);
		} else {
			glare = jQuery(this).find('.glare');
		}
		width = jQuery(this).outerWidth();
		if (!jQuery.browser.msie && jQuery(this).hasClass('round')) {
			if(jQuery(this).hasClass('small')){
				glare.width(width - 16);
			} else {
				glare.width(width - 16);
			}
		}
	});
}
function showTab(control){
	tab_target = jQuery('#' + control.attr('data-tab_target'));
	current_page = jQuery('.current_page');
	current_page_selector = '#'+current_page.attr('id');
	current_page = jQuery(current_page_selector);
	tab_target.find("[data-page_turner],[data-tab_switcher],[data-page_back]").css('visibility','hidden');
	current_page.hide();
	tab_target.show();
	current_page.removeClass('current_page');
	tab_target.addClass('current_page');
	tab_target.find("[data-page_turner],[data-tab_switcher],[data-page_back]").css('visibility','visible');
}
function hideLowerElements(elem){
	elem.find("[data-list_index]").each(function(){
		if(parseInt(jQuery(this).data('list_index')) > 3){
			jQuery(this).hide();
		}
	})
}
function showLowerElements(elem){
	elem.find("[data-list_index]").show();
}
function slidePage(direction,page_target_id){
	window_width = jQuery(window).width() + 'px';
	window_height = jQuery(window).height() + 'px';
	transition_amount = '100%';
	if(direction == 'back'){
		window_width = '-' + window_width;
	}
	if(direction == 'forward'){
		transition_amount = '-' + transition_amount;
	}
	page_target = jQuery('#'+page_target_id);
	page_target.css('left',window_width);
	current_page = jQuery('.current_page');
	current_page_selector = '#'+current_page.attr('id');
	current_page = jQuery(current_page_selector);
	// page_target.parent().show();
	page_target.find("[data-page_turner],[data-tab_switcher],[data-page_back]").css('visibility','hidden');
	hideLowerElements(page_target);
	page_target.show(0,function(){
		// jQuery('body').animate({'scrollTop':0},0,'swing',function(){
			jQuery(window).scrollTop(0);
			hideLowerElements(current_page);
			// alert('scroll done');
			if(!jQuery('#pager_wrapper').hasClass('page_slide')){
				jQuery('#pager_wrapper').addClass('page_slide');
			}
			window.history.pushState(page_target_id, null, jQuery('#pager_wrapper').data('loaded_page_ids')[page_target.attr('id')].replace(/http(s)?:\/\/[^\/]+/,''));
			jQuery('#pager_wrapper').data('current_page',current_page);
			jQuery('#pager_wrapper').data('page_target',page_target);
			jQuery('#pager_wrapper').css('-webkit-transform','translate3d(' + transition_amount + ',0,0)');
			// setTimeout(function(){
				// },2000);
		// });
	});
}
function loadPages(pages){
	ajax_params = {
    type: 'GET',
    dataType: 'html',
    data: {pager:'true'},
    error: function(XMLHttpRequest, textStatus, errorThrown) {
      //handle misfire on loading page
    },
		success: function(data, message){
			new_page = jQuery(data);
			new_page.hide();
			jQuery('#pager_wrapper').append(new_page);
			if(new_page.children().hasClass('pager')){
				new_pages = new_page.children();
				new_page.after(new_page.children());
				new_pages.hide();
				new_pages.each(function(){
					jQuery('#pager_wrapper').data('loaded_page_ids')[jQuery(this).attr('id')] = jQuery(this).data('direct_url');
					jQuery('#pager_wrapper').data('loaded_page_urls')[jQuery(this).data('direct_url')] = jQuery(this).attr('id');
				})
			}
			if(jQuery("[data-page_turner][data-page_loader='" + new_page.attr('id') + "']").length > 0){
				jQuery("[data-page_turner][data-page_loader='" + new_page.attr('id') + "']").css('visibility','visible');
			} else {
				jQuery("[data-page_turner][data-page_target='" + new_page.attr('id') + "']").css('visibility','visible');
			}
			jQuery("[data-tab_switcher][data-tab_target='" + new_page.attr('id') + "']").css('visibility','visible');
			this_url = jQuery('#pager_wrapper').data('loaded_page_ids')[new_page.attr('id')];
			jQuery('#pager_wrapper').data('loaded_page_urls')[this_url] = new_page.attr('id');				
		}
  };
	for(url in pages){
		if(!jQuery('#pager_wrapper').data('loaded_page_urls')[url]){
			jQuery('#pager_wrapper').data('loaded_page_ids')[pages[url]] = url;
	    ajax_params.url = url;
	    jQuery.ajax(ajax_params);
		}
  }
}
function bindPageSlides(){
	jQuery('.page_slide').live(
		     'webkitTransitionEnd', 
		     function( event ) { 
						current_page = jQuery(this).data('current_page');
						page_target = jQuery(this).data('page_target');
						showLowerElements(current_page);
						current_page.hide();
						page_target.css('left',0);
						jQuery('#pager_wrapper').removeClass('page_slide').css('-webkit-transform','none');
						current_page.removeClass('current_page');
						page_target.addClass('current_page');
						showLowerElements(page_target);
						if(page_target.attr('data-children_pages')){
							children_pages = eval(page_target.attr('data-children_pages'));
							loadPages(children_pages);
						}
						page_target.find("[data-page_turner],[data-tab_switcher],[data-page_back]").css('visibility','visible');
		     }, false
	);
}
function bindPagers(){
	jQuery('#pager_wrapper').data('loaded_page_urls',{});
	jQuery('#pager_wrapper').data('loaded_page_ids',{});
	jQuery("[data-page_turner]").live('click',function(e){
		slidePage('forward',jQuery(this).data('page_target'));
	});
	jQuery("[data-page_back]").live('click',function(e){
		slidePage('back',jQuery(this).data('page_target'));
	});
	jQuery("[data-tab_switcher]").live('click',function(e){
		showTab(jQuery(this));
	});
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	bindAutoSubmit();		
    bindLinkToForm();
	bindDeleteProxy();
	bindPreventDoubleClick();
	bindPagers();
	bindPageSlides();
	jQuery(document).live('touchstart',clearSorts);
	jQuery("[data-drag_handle]").live('touchstart',handleSortBegin);
	window.onpopstate = function(e){
		alert("location: " + document.location + ", state: " + JSON.stringify(event.data));
	  // slidePage()
	}
});
jQuery(window).load(function(){
	setTimeout(handleHalfSections,100);
	setTimeout(handleQuarterSections,100);
});
