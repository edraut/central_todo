function handleArchivementLink(){
	if( jQuery('#unarchived_items_wrapper').find(
		"input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked").length > 0)
	{
		jQuery('#archive_completed_items').show();
	} else {
		jQuery('#archive_completed_items').hide();
	}
}
function checkBoxProxy(e){
	target = jQuery(e.target);
	if(!target.attr('data-check_box')){
		target = target.parents("[data-check_box]");
	}
	checkbox = jQuery('#' + target.attr('data-check_box'));
	if(checkbox.is("input[type='checkbox']")){
		if(checkbox.is(':checked')){
			checkbox.attr('checked', false);
		}else{
			checkbox.attr('checked', true);
		}
	}else{
		if(checkbox.val() == 'f'){
			checkbox.val('t');
		}else{
			checkbox.val('f');
		}
	};
	checkbox.change();
}
function attributeControl(e){
	target = jQuery(e.target);
	link = target.find("[data-behavior='link_to_form']");
	if(link){
		link.click();
	}
}
function bindAttributeControl(){
	jQuery("[data-behavior='attribute_control']").die('click');
	jQuery("[data-behavior='attribute_control']").live('click',attributeControl);
}
function bindCheckBoxProxy(){
	jQuery("[data-behavior='check_box_proxy']").die('click');
	jQuery("[data-behavior='check_box_proxy']").live('click',checkBoxProxy);
}
function focusPrimaryInput(){
	jQuery('#primary_input').focus();
}
function bindFocusTaskInput(){
	jQuery("[data-behavior='expander'][data-id='new_task_form']").live('click',function(e){
      focusPrimaryInput();
    });
}
function handleArchivementSuccess(move){
	jQuery('#archive_completed_items').hide();
	move = typeof(move) != 'undefined' ? move : false;
	if(move){
		jQuery('#archived_item_list').show();
		jQuery('#unarchived_items_wrapper')
			.find("input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked")
				.parents("[data-role='list_item']")
					.each(function(i){
						jQuery(this).moveToParent(jQuery('#archived_items_wrapper'));})
						jQuery('#archived_items_wrapper')
							.find("[data-role='organize_item'],[data-role='sortable_drag_handle']")
								.each(function(i){jQuery(this).remove();});
						handleListDisplay();
	} else {
		jQuery('#unarchived_items_wrapper')
			.find("input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked")
				.parents("[data-role='list_item']")
					.each(function(i){
						jQuery(this).remove();})
	}
	if(typeof(roundCornders) != 'undefined'){
		setTimeout(roundCorners,1500);
	}
}
