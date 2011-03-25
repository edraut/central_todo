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
	jQuery("[data-binding='hover_show_more']").hover(
		function(){
			target_div = jQuery('#' + jQuery(this).attr('data-hover_div'));
			target_div.fadeIn(150);
		},
		function(){
			jQuery('#' + jQuery(this).attr('data-hover_div')).fadeOut(250);
		}
	);
}

