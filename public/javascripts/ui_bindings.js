/* All Code Copyright 2008 Eric Draut all rights reserved
*/
function getActualLinkTarget(alleged_link_target){
	if (alleged_link_target.is('a')){
		return alleged_link_target;
	} else {
		return alleged_link_target.parents('a');
	}
}
function vertCenterDiv(div, parent){
	div.css('margin-top',(parent.height() - div.height()) / 2)
}
function bindExpanders(){
	jQuery(document).ready(function(){
		jQuery("[data-behavior='expander'][data-action='expand']").unbind('click');
		jQuery("[data-behavior='expander'][data-action='expand']").click(function(e){
			actual_target = getActualLinkTarget(jQuery(e.target));
			jQuery("[data-behavior='expander'][data-state='expanded'][data-id='" + actual_target.attr('data-id') + "']").show();
			jQuery("[data-behavior='expander'][data-state='contracted'][data-id='" + actual_target.attr('data-id') + "']").hide();
		});
		jQuery("[data-behavior='expander'][data-action='contract']").unbind('click');
		jQuery("[data-behavior='expander'][data-action='contract']").click(function(e){
			actual_target = getActualLinkTarget(jQuery(e.target));
			jQuery("[data-behavior='expander'][data-state='expanded'][data-id='" + actual_target.attr('data-id') + "']").hide();
			jQuery("[data-behavior='expander'][data-state='contracted'][data-id='" + actual_target.attr('data-id') + "']").show();
		});
	});
};
function bindAutoSubmit(){
	jQuery("[data-behavior='auto_submit']").live('change',function(e){
		jQuery(e.target).parents('form').submit();
	})
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
function handleListDisplay(){
	jQuery("[data-role='list']").each(function(i){
		if(jQuery(this).find("[data-role='list_item']").length > 0){
			jQuery(this).show();
		}else{
			jQuery(this).hide();
		}
	});
}
function bindHoverShowMore(){
	jQuery("[data-binding='hover_show_more']").hover(
		function(){jQuery('#' + jQuery(this).attr('data-hover_div')).show(150);},
		function(){jQuery('#' + jQuery(this).attr('data-hover_div')).hide(150);}
	);
}
function flashBackground(id){
	element = jQuery('#'+id);
	old_bg_color = getBackground(element);
	element.animate(
		{'background-color':'#DDF5F5'},
		300,
		function(){element.animate(
			{'background-color':old_bg_color},
			1000
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
function bindLinkToForm(){
        jQuery("[data-behavior='link_to_form']").live('click',function(e){
                var form_string = jQuery('<form method="post" action="' + jQuery(e.target).attr('href') +'" style="display:none;"><input type="hidden" name="authenticity_token" value="'+ authenticity_token + '"><input type="hidden" name="_method" value="' + jQuery(e.target).attr('data-method') + '"></form>');
                jQuery(e.target).after(form_string);
                form_string.submit();
                e.preventDefault();
                return false;
        });
};

