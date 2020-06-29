/*ccf_landing js start*/
$(document).ready(function(){    
	tableApply();
	
	$(".clearButton").on("click", function() {
		$(this).closest('.tableFilter').find("input[type=text], select").val("");
	});
});   
function tableApply()
{
	var accountsTable = $('[cid$="accountsTable"]').parent('table').eq(0).DataTable({
		//enables results highlight
		searchHighlight: true,
		"aaSorting": [],
		//sets record lengths to show in picklist
		aLengthMenu: [
			[10, 25, 50, 100, 200, -1],
			[10, 25, 50, 100, 200, "All"]
		],
		"iDisplayLength": 10,
		//adds copy, print buttons...
		dom: 'lBfrtip', //l=length, B=buttons, f=filter(search), r=processing, t=the table, I=table summary, p=page controls
		buttons: [
			
			{
				extend: 'print',
				customize: function(win) {
					$(win.document.body)
					.css( 'font-size', '10pt' )
					.prepend('<img src="http://datatables.net/media/images/logo-fade.png" style="position:absolute; top:0; left:0;" />');
					
					$(win.document.body).find( 'table' )
					.addClass( 'compact' )
					.css( 'font-size', 'inherit' );
				}
			}
		],
	});
}
/*ccf_landing js end*/