/*JQuery Section*/
var jq = jQuery.noConflict();
jq(document).ready(function(){
	
	jq(".filter_ccf").click(function(){
        jq(".tableFilter").toggle({
				effect: "blind",
				duration: 1000
		});
		jq(this).toggleClass("active");
    });
	
	jq(".expand_img").click(function(){
		jq(this).toggleClass("active");
    });
	jq(".expand_img1").click(function(){
		jq(this).toggleClass("active");
    });
	jq(".detail_button").click(function(){
		jq(this).toggleClass("active");
    });	
		
	jq( ".tableHeader ul li" ).each(function( index ) {
		var headerLi = [];
		headerLi = jq(this).text();
		var len = jq(this).length;
		for(var i = 0; i < len; i++){
			if(headerLi[i] == null){
				jq(this).css("display","none");
			}else{
				jq(this).css("display","block");
			}			
		}
	});	
	
	jq("#ccf_headerSection .formTable_section label + span:not(:has(*))")
		.addClass("formTable_section_input")
		.css({
				"display" : "flex", 
				"align-items" : "center"
			});
	jq("#ccf_headerSection .formTable_section label + span.formTable_section_input > span")
		.css({
				"line-height" : "28px"
			});
	jq(".viewPage .formTable_section span:not(:has(*))")
		.addClass("formTable_section_input")
		.css({
				"padding" : "0 0 0 5px"
			});
	jq(".viewPage .formTable_section span:has(a)")
		.addClass("formTable_section_input")
		.css({
				"height" : "70px",
				"display" : "inline-block",
				"padding" : "0 0 0 5px"
			});
	jq(".viewPage .formTable_section span:has(a:only-child)")
		.css({
				"height" : "28px",
				"line-height" : "28px"
			});
			
	jq(".dateInput input[type=text]").addClass("datePickerImage");
	
	jq(".getSupplier").on('click', function (){
		jq(window).scrollTop(0);
	});
	
});	

function showSpinner()
{
   document.getElementById('opaque').style.display='block';
   var popUp = document.getElementById('spinner');
  
   popUp.style.display = 'block';
} 
function hideSpinner()
{
   document.getElementById('opaque').style.display='none';
   var popUp = document.getElementById('spinner');
  
   popUp.style.display = 'none';
}