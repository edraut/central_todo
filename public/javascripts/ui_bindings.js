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
		},
		handle: (jQuery(this).find("[data-role='sortable_drag_handle']").length == 0) ? false : "[data-role='sortable_drag_handle']"
	});
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
function bindHoverShowMore(){
	jQuery("[data-binding='hover_show_more']").hover(
		function(){jQuery('#' + jQuery(this).attr('data-hover_div')).fadeIn(150);},
		function(){jQuery('#' + jQuery(this).attr('data-hover_div')).fadeOut(250);}
	);
}

