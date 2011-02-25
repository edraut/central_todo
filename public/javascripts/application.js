function roundCorners(){
	jQuery(".section_wrapper").corner("20px");
	jQuery(".section").corner("13px");
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	roundCorners();
	bindAutoSubmit();		
    bindLinkToForm();
	bindExpanders();
	bindFocusTaskInput();
});
function handleRetirementSuccess(move){
	move = typeof(move) != 'undefined' ? move : false;
	if(move){
		jQuery('#retired_item_list').show();
		jQuery('#unretired_items_wrapper')
			.find("input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked")
				.parents("[data-role='list_item']")
					.each(function(i){
						jQuery(this).moveToParent(jQuery('#retired_items_wrapper'));})
						jQuery('#retired_items_wrapper')
							.find("[data-role='organize_item'],[data-role='sortable_drag_handle']")
								.each(function(i){jQuery(this).remove();});
						handleListDisplay();
	} else {
		jQuery('#unretired_items_wrapper')
			.find("input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked")
				.parents("[data-role='list_item']")
					.each(function(i){
						jQuery(this).remove();})
	}
	setTimeout(handleRetirementLink,2500);
	setTimeout(roundCorners,1500);
}
