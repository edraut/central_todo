function bindCheckBoxProxy(){
	jQuery("[data-behavior='check_box_proxy']").live('click',function(e){
		target = jQuery(e.target)
		checkbox = jQuery('#' + target.attr('data-check_box'));
		if(checkbox.val() == 'f'){
			checkbox.val('t');
		}else{
			checkbox.val('f')
		}
		checkbox.change();
	});
}
function roundCorners(){
	jQuery(".section_wrapper").corner("20px");
	jQuery(".section").corner("13px");
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	roundCorners();
	bindAutoSubmit();		
    bindLinkToForm();
});
function handleRetirementLink(){
	if( jQuery('#unretired_items_wrapper').find(
		"input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked").length > 0)
	{
		jQuery('#retire_completed_items').show();
	} else {
		jQuery('#retire_completed_items').hide();
	}
}
function handleRetirementSuccess(){
	// jQuery('#retired_item_list').show();
	jQuery('#unretired_items_wrapper')
		.find("input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked")
			.parents("[data-role='list_item']")
				.each(function(i){
					jQuery(this).remove();})
					// jQuery(this).moveToParent(jQuery('#retired_items_wrapper'));})
	// jQuery('#retired_items_wrapper')
	// 	.find("[data-role='organize_item'],[data-role='sortable_drag_handle']")
	// 		.each(function(i){jQuery(this).remove();});
	// handleListDisplay();
	setTimeout(handleRetirementLink,2500);
	setTimeout(roundCorners,1500);
}
