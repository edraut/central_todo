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
