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
function hiddenFieldProxy(e){
	target = jQuery(e.target);
	if(!target.attr('data-hidden_field')){
		target = target.parents("[data-hidden_field]");
	}
	hidden_field = jQuery('#' + target.attr('data-hidden_field'));
	hidden_field.val(target.attr('data-value'));
}
function hiddenMultiProxy(e){
	target = jQuery(e.target);
	if(!target.attr('data-hidden_field')){
		target = target.parents("[data-hidden_field]");
	}
	hidden_field = jQuery("input[type='hidden'][name='" + target.attr('data-hidden_field') + "[]'][value='" + target.attr('data-value') + "']");
	if(hidden_field.length == 0){
		hidden_field = jQuery('<input type="hidden" name="' + target.attr('data-hidden_field') + '[]" value="' + target.attr('data-value') + '"/>');
		target.parents('form').append(hidden_field);
	} else {
		hidden_field.remove();
	}
}
function attributeControl(e){
	target = jQuery(e.target);
	if(target.attr('data-behavior') != 'attribute_control'){
		target = target.parents("[data-behavior='attribute_control']");
	}
	link = target.find("[data-behavior='link_to_form']");
	if(link.length == 0){
		link = target.find("[data-role='delete']");
	}
	if(link){
		link.click();
	}
	if(link.length == 0){
		link = target.find('a');
		if(link){
			document.location.href = link.attr('href');
		}
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
function bindHiddenFieldProxy(){
	jQuery("[data-behavior='hidden_field_proxy']").die('click');
	jQuery("[data-behavior='hidden_field_proxy']").live('click',hiddenFieldProxy);
}
function bindHiddenMultiProxy(){
	jQuery("[data-behavior='hidden_multi_proxy']").die('click');
	jQuery("[data-behavior='hidden_multi_proxy']").live('click',hiddenMultiProxy);
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
jQuery.fn.reDraw = function(){
	dummy = jQuery(" <!--placeholder--> ");
	jQuery(this).append(dummy);
	dummy.remove();
}
jQuery(document).ready(function(){
	bindAttributeControl();
	bindButtonDisplay();	
});
