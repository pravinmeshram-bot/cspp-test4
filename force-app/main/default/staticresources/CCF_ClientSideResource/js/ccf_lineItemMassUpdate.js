/*ccf_lineItemMassUpdate js start*/
		var j$ = jQuery.noConflict();
        j$(document).ready(function(){
            
            var accountsTable = j$('[cid$="accountsTable"]').parent('table').eq(0).DataTable({
                //enables results highlight
                searchHighlight: true,
				"scrollX": true,
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
                            j$(win.document.body)
                            .css( 'font-size', '10pt' )
                            .prepend('<img src="http://datatables.net/media/images/logo-fade.png" style="position:absolute; top:0; left:0;" />');
                            
                            j$(win.document.body).find( 'table' )
                            .addClass( 'compact' )
                            .css( 'font-size', 'inherit' );
                        }
                    }
                ],
            });
            
        });
/*ccf_lineItemMassUpdate js end*/