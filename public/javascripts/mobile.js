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
function handleHalfSections(){
	first_half_section = jQuery('.half_section:first');
	last_half_section = jQuery('.half_section:last');
	if(first_half_section){
		wrapper = first_half_section.parent();
		first_half_section.css('width','50%');
		if (wrapper.width() != last_half_section.width() + first_half_section.width()){
			first_half_section.width(last_half_section.width() + 1);
		}
	}
}
function handleQuarterSections(){
	first_section = jQuery('.quarter_nav:first');
	second_section = jQuery('.quarter_nav:eq(1)');
	third_section = jQuery('.quarter_nav:eq(2)');
	last_section = jQuery('.quarter_nav:last');
	if(first_section){
		wrapper = first_section.parent();
		first_section.css('width','25%');
		second_section.css('width','25%');
		third_section.css('width','25%');
		section_total = first_section.width() + second_section.width() + third_section.width() + last_section.width();
		if (wrapper.width() != section_total){
			difference = wrapper.width() - section_total;
			i = 0;
			while(i < difference) {
				jQuery('.quarter_nav:eq(' + i + ')').width(last_section.width() + 1);
				i++;
			}
		}
	}
}
jQuery(window).bind('orientationchange',function(){
	handleHalfSections();
	handleQuarterSections();
});
jQuery(window).bind('resize',function(){
	handleHalfSections();
	handleQuarterSections();
});
jQuery(document).ready(function(){
	bindCheckBoxProxy();
	bindAutoSubmit();		
    bindLinkToForm();
	bindDeleteProxy();
	bindPreventDoubleClick();
});
jQuery(window).load(function(){
	setTimeout(handleHalfSections,100);
	setTimeout(handleQuarterSections,100);
})