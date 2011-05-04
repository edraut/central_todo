/* All Code Copyright 2008 Eric Draut all rights reserved
*/
function vertCenterDiv(div, parent){
	div.css('margin-top',(parent.height() - div.height()) / 2)
}
function bindSortables(){
	jQuery("[data-behavior='sortable']").sortable({
		update: function(e,ui){
			jQuery.ajax({
				type: 'GET', 
				url: jQuery(this).attr('data-sort_url'),
				data: jQuery(this).sortable('serialize')
			});
			if(jQuery(this).attr('data-sort_callback')){
				eval(jQuery(this).attr('data-sort_callback'));
			}
		}
	});
	jQuery("[data-behavior='sortable']").each(function(i){
		if(jQuery(this).find("[data-role='sortable_drag_handle']").length > 0) {
			jQuery(this).sortable('option', 'handle', "[data-role='sortable_drag_handle']");
		}
	});
}
function bindHoverShowMore(){
	jQuery("[data-binding='hover_show_more']").unbind('mouseenter mouseleave');
	jQuery("[data-binding='hover_show_more']").hover(
		function(event) {
			if (jQuery(this).attr('data-hover_fadein_time')){
				fade_speed = parseInt(jQuery(this).attr('data-hover_fadein_time'));
			} else{
				fade_speed = 150
			}
			target_div = jQuery(jQuery(this).attr('data-hover_div'));
			target_div.fadeIn(fade_speed);
	  },
	 	function(event){
			if (jQuery(this).attr('data-hover_fade_time')){
				fade_speed = parseInt(jQuery(this).attr('data-hover_fade_time'));
			} else{
				fade_speed = 250
			}
			jQuery(jQuery(this).attr('data-hover_div')).fadeOut(fade_speed);
		}
	);
}
function bindHoverReveal(){
	jQuery("[data-hover_reveal]").mouseover(
		function(e){
			stunt_double = jQuery(this).clone();
			stunt_double.attr('data-hover_reveal',null)
			jQuery('body').append(stunt_double);
			left_margin = parseInt(jQuery(this).css('margin-left'));
			if(isNaN(left_margin)){
				left_margin = 0;
			}
			stunt_double
				.css('position','absolute')
				.css('left',(jQuery(this).offset().left - left_margin))
				.css('top',jQuery(this).offset().top)
				.css('overflow','visible')
				.css('z-index',1004);
			stunt_double.attr('data-hover_reveal_stunt_double',true);
			stunt_double.attr('id',jQuery(this).attr('id') + 'stunt_double');
			return true;
		}
	);
	jQuery("[data-hover_reveal_stunt_double]").live('mouseout',
		function(e){
			jQuery('#testone').html('out');
			jQuery(this).remove();
			return true;
		}
	);
}
function unbindHoverShowMore(){
	jQuery("[data-binding='hover_show_more']").unbind();
}


