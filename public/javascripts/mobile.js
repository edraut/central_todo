function deleteProxy(e){
	proxy = jQuery(e.target);
	if(!proxy.attr('data-confirm') || confirm(proxy.attr('data-confirm'))){
		form = proxy.parents('form');
		success = form.attr('data-ajax_success_callback');
		form.attr('data-ajax_success_callback', success + 'jQuery("[data-id=' + "'" + form.attr('data-id') + "'" + ']").remove();handleListDisplay();');
		form_method = form.find('input[name="_method"]');
		form_method.val('delete');
		form.attr('method','DELETE');
		form.submit();
	}
	e.preventDefault();
	return false;
}
function bindDeleteProxy(){
	jQuery("[data-role='delete']").die('click');
	jQuery("[data-role='delete']").live('click',deleteProxy);
}
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	bindAutoSubmit();		
    bindLinkToForm();
	bindDeleteProxy();
});
jQuery(document).load(function(){
	bindPreventDoubleClick();
})