function handleRetirementLink(){
	if( jQuery('#unretired_items_wrapper').find(
		"input[type='checkbox'][name='task[state]']:checked,input[type='checkbox'][name='project[state]']:checked").length > 0)
	{
		jQuery('#retire_completed_items').show();
	} else {
		jQuery('#retire_completed_items').hide();
	}
}
function checkBoxProxy(e){
	target = jQuery(e.target);
	checkbox = jQuery('#' + target.attr('data-check_box'));
	if(checkbox.val() == 'f'){
		checkbox.val('t');
	}else{
		checkbox.val('f');
	}
	checkbox.change();
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