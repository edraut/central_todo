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
	if(!(target.attr("data-behavior") == 'hidden_field_proxy')){
		target = target.parents("[data-behavior='hidden_field_proxy']");
	}
	hidden_field = jQuery('#' + target.attr('data-hidden_field'));
	hidden_field.val(target.attr('data-value'));
}
function hiddenMultiProxy(e){
	target = jQuery(this);
	hidden_field = jQuery("input[type='hidden'][name='" + target.attr('data-hidden_field') + "[]'][value='" + target.attr('data-value') + "'][data-id='" + target.attr('data-id') + "']");
	if(hidden_field.length == 0){
		hidden_field = jQuery('<input type="hidden" name="' + target.attr('data-hidden_field') + '[]" value="' + target.attr('data-value') + '" data-id="' + target.attr('data-id') + '"/>');
		target.parents('form').append(hidden_field);
	} else {
		hidden_field.remove();
	}
	if(target.parents("[data-behavior='expander']").length > 0){
		save_button = jQuery("[data-hidden_proxy_save='true'][data-id='" + target.parents("[data-behavior='expander']:first").attr('data-id') + "']");
		close_button = jQuery("[data-hidden_proxy_close='true'][data-id='" + target.parents("[data-behavior='expander']:first").attr('data-id') + "']");
	} else {
		save_button = jQuery("[data-hidden_proxy_save='true']");
		close_button = jQuery("[data-hidden_proxy_close='true']");
	}
	close_button.hide();
	save_button.show();
}
function bindLabelSubmit(){
	jQuery("[data-label_submit='true']").live('click',function(e){
		target = jQuery(e.target);
		if(!target.attr('data-label_submit')){
			target = target.parents("[data-label_submit]");
		}
		labels_field = jQuery('<input type="hidden" name="has_labels" value="true" data-id="' + target.attr('data-id') + '"/>');
		target.parents('form').append(labels_field);
		target.trigger('submitme');
	})
}

function buttonControl(e){
	target = jQuery(e.target);
	if(!target.attr('data-button')){
		target = target.parents("[data-button]");
	}
	if(target.data('confirm')){
		if(!confirm(target.data('confirm'))){
			e.preventDefault();
			return false;
		};
	}
	if(target.data('submit')){
		if(target.data('submit_value')){
			target.parents('form').find('input[name="submit_value"]');
		}
		target.parents('form').submit();
		e.preventDefault();
		e.stopPropagation();
		return false;
	}
	if(target.attr('href')){
		document.location = target.attr('href');
		return false;
	}
	link = target.find("[data-behavior='link_to_form']");
	if(link.length == 0){
		link = target.find("[data-role='delete']");
	}
	if(link.length == 0){
		link = target.find("[data-ajax_behavior='ajax_link']");
	}
	if(link.length == 0){
		link = target.find("[data-behavior='expander'][data-action]");
	}
	if(link.length > 0){
		e.stopPropagation();
		e.preventDefault();
		link.click();
		return false;
	}
	if(link.length == 0){
		link = target.find('[href]');
		if(link.length > 0){
			document.location.href = link.attr('href');
			return true;
		}
	}
	if(link.length == 0){
		form = target.find('form');
		if(form.length > 0){
			form.submit();
		}
	}
}
function bindButtonControl(){
	jQuery("[data-button]").die('click');
	jQuery("[data-button]").live('click',buttonControl);
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
						bindHoverShowMore();
	} else {
		jQuery('#unarchived_items_wrapper')
			.find("input[type='checkbox'][name='task[state]']:checked,a.completed")
				.parents("[data-role='list_item']")
					.each(function(i){
						jQuery(this).fadeOut(600,function(){jQuery(this).remove()});
					});
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
	// bindConfirm();
	bindButtonControl();
	popButtons();
	bindExpanders();
});
function printObj(myObj){
	output = "";
	for (myKey in myObj){
		output = output.concat(myKey+" = "+myObj[myKey]+"\n");
	}
	return output;
}