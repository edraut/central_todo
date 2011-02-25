function bindLinkToForm(){
    jQuery("[data-behavior='link_to_form']").live('click',function(e){
        var form_string = jQuery('<form method="post" action="' + jQuery(e.target).attr('href') +'" style="display: none;"><input type="hidden" name="authenticity_token" value="'+ authenticity_token + '"><input type="hidden" name="_method" value="' + jQuery(e.target).attr('data-method') + '"></form>');
        jQuery(e.target).after(form_string);
        form_string.submit();
        e.preventDefault();
        return false;
    });
};
function bindAutoSubmit(){
	jQuery("[data-behavior='auto_submit']").live('change',function(e){
		jQuery(e.target).parents('form').submit();
	})
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
jQuery.fn.preventDoubleSubmit = function() {
  jQuery(this).submit(function() {
    if (this.beenSubmitted)
      return false;
    else
      this.beenSubmitted = true;
  });
};
function preventDoubleClick(e) {
	link = jQuery(e.target);
	if(link.data('beenSubmitted')){
	  e.preventDefault();
	  return false;
	}else{
	  link.data('beenSubmitted',true);
	}
};
function bindPreventDoubleClick(){
	jQuery('a').die('click');
	jQuery('a').unbind('click');
	jQuery('a').live('click',preventDoubleClick);
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
