/*ccf_contract_form js start*/
        var newWin=null;
        function openLookupPopup(headerID)
        {
            var url="/CCFCPMO/CCF_ChildagreementUpload?headerid="+headerID;
            newWin=window.open(url, 'Popup','height=400,width=400,left=100,top=100,resizable=no,scrollbars=yes,toolbar=no,status=no');
            if (window.focus) 
            {
                newWin.focus();
            }
            
            return false;
        }
        
        function checkAll(cb)
        {
            var inputElem = document.getElementsByTagName("input");
            for(var i=0; i<inputElem.length; i++)
            {
                if(inputElem[i].id.indexOf("checkedone")!=-1)
                    inputElem[i].checked = cb.checked;
            }
        }
        
        function format ( d ) {
        
			var pc1;
			var pc2;
			var pc3;
			var pc4;
			var pc5;
			var pc6;
			var upuom;
			var tname;
			var mgn;
			var md;
			var upbd;
			var uped;
			var moq;
			var pt;
			var po;
			var sapupc;
			var taxcode;
			var personid;
			var companycode;
            var pc1check = '{!pc1}';
            var pc2check = '{!pc2}';
            var pc3check = '{!pc3}';
            var pc4check = '{!pc4}';
            var pc5check = '{!pc5}';
            var pc6check = '{!pc6}';
            var UnitPriceUOM = '{!UnitPriceUOM}';
            var unitbdate = '{!unitbdate}';
            var unitedate = '{!unitedate}';
            var Moqc = '{!Moqcheck}';
            var payterms = '{!payterms}';
			
			var arr = d[11].split(" ");
			var removed = arr.splice(3, 2);
			d[11] = arr.join(" ");
			
			var arr = d[12].split(" ");
			var removed = arr.splice(3, 2);
			d[12] = arr.join(" ");
					
					
           if(pc1check=='true')
            {
            pc1 = '<td style="background-color:Orange"> Pricing Condition1 : '+d[1]+'</td>'    
            }else{
            pc1 = '<td> Pricing Condition 1: '+d[1]+'</td>'
            }
            if(pc2check=='true')
            {
            pc2 = '<td style="background-color:orange"> Pricing Condition2 : '+d[2]+'</td>'    
            }else{
            pc2 = '<td> Pricing Condition 2: '+d[2]+'</td>'
            }
            if(pc3check=='true')
            {
            pc3 = '<td style="background-color:orange"> Pricing Condition3 : '+d[3]+'</td>'    
            }else{
            pc3 = '<td> Pricing Condition 3: '+d[3]+'</td>'
            }
            if(pc4check=='true')
            {
            pc4 = '<td style="background-color:orange"> Pricing Condition4 : '+d[4]+'</td>'    
            }else{
            pc4 = '<td> Pricing Condition 4: '+d[4]+'</td>'
            }
            if(pc5check=='true')
            {
            pc5 = '<td style="background-color:orange"> Pricing Condition5 : '+d[5]+'</td>'    
            }else{
            pc5 = '<td> Pricing Condition 5: '+d[5]+'</td>'
            }
            if(pc6check=='true')
            {
            pc6 = '<td style="background-color:orange"> Pricing Condition6 : '+d[6]+'</td>'    
            }else{
            pc6 = '<td> Pricing Condition 6: '+d[6]+'</td>'
            }
            if(UnitPriceUOM=='true')
            {
            upuom = '<td style="background-color:orange"> Unit Price UOM : '+d[7]+'</td>'    
            }else{
            upuom = '<td>  Unit Price UOM* : '+d[7]+'</td>'
            }
            
            tname = '<td>  Trade Name : '+d[8]+'</td>'           
            
            mgn = '<td>Material Group* : '+d[9]+'</td>'      
            
            md = '<td>Material Description : '+d[10]+'</td>'
           
            if(unitbdate=='true')
            {
            upbd = '<td style="background-color:orange">Unit Price Begin Date : '+d[11]+'</td>'    
            }else{
            upbd = '<td>Unit Price Begin Date : '+d[11]+'</td>'
            }
            if(unitedate=='true')
           {
            uped = '<td style="background-color:orange">Unit Price Expiration Date : '+d[12]+'</td>'    
            }else{
            uped = '<td>Unit Price Expiration Date : '+d[12]+'</td>'
            }
            if(Moqc=='true')
            {
            moq = '<td style="background-color:orange"> MOQ : '+d[13]+'</td>'    
            }else{
            moq = '<td> MOQ : '+d[13]+'</td>'
            }
            if(payterms=='true')
            {
            pt = '<td style="background-color:orange"> Payment Terms* : '+d[14]+'</td>'    
            }else{
            pt = '<td> Payment Terms* : '+d[14]+'</td>'
            }           
            po = '<td> Purchasing Organisation*  : '+d[15]+'</td>'
            sapupc='<td> SAP UPC Type*  : '+d[16]+'</td>'
            taxcode='<td> Tax Code* : '+d[17]+'</td>'
			personid='<td> Person Responsible SAP ID*  : '+d[18]+'</td>'
			companycode='<td>Company Code*  : '+d[19]+'</td>'
        if(d[0]=='Submitted to Buyers'){
            tar = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+'<tr>'+pc1+pc2+pc3+'</tr>'+'<tr>'+pc4+pc5+pc6+'</tr>'+'<tr>'+upuom+tname+mgn+'</tr>'+'<tr>'+md+upbd+uped+'</tr>'+'<tr>'+moq+pt+po+'</tr>'+'<tr>'+sapupc+taxcode+personid+'</tr>'+'<tr>'+companycode+'</tr>'+'</table>';
        }else{
        
        tar = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+'<tr>'+'<td> Pricing Condition1 : '+d[1]+'</td>'+'<td> Pricing Condition2 : '+d[2]+'</td>'+'<td> Pricing Condition3 : '+d[3]+'</td>'+'</tr>'+'<tr>'+'<td> Pricing Condition4 : '+d[4]+'</td>'+'<td> Pricing Condition5 : '+d[5]+'</td>'+'<td> Pricing Condition6 : '+d[6]+'</td>'+'</tr>'+'<tr>'+'<td>  Unit Price UOM* : '+d[7]+'</td>'+'<td>  Trade Name : '+d[8]+'</td>'+'<td>Material Group* : '+d[9]+'</td>'+'</tr>'+'<tr>'+'<td>Material Description : '+d[10]+'</td>'+'<td>Unit Price Begin Date : '+d[11]+'</td>'+'<td>Unit Price Expiration Date : '+d[12]+'</td>'+'</tr>'+'<tr>'+'<td> MOQ : '+d[13]+'</td>'+'<td> Payment Terms* : '+d[14]+'</td>'+'<td> Purchasing Organisation*  : '+d[15]+'</td>'+'<tr>'+'<td> SAP UPC Type* : '+d[16]+'</td>'+'<td> Tax Code* : '+d[17]+'</td>'+'<td> Person Responsible SAP ID*  : '+d[18]+'</td>'+'</tr>'+'<tr>'+'<td> Company Code* : '+d[19]+'</td>'+'</tr>'+'</table>';
        
        }
        return tar;
        }
        var j$ = jQuery.noConflict(); 
        j$(document).ready(function(){
            tableApply();
        });   
        
        function tableApply()
        {
           var lineItemTable = j$('[id$="lineItemTable"]').DataTable({
                columnDefs: [
                    { orderable: false, targets: 1 }
                ]
            });
            j$('.list.dataTable tbody').on('click', '.detail_button', function () {
                var expandData = j$(this).attr('data');
                var data = j$(expandData.split('|'));
                var tr = j$(this).closest('tr');
                var row = lineItemTable.row( tr );
                if ( row.child.isShown() ) {
                    row.child.hide();
                }
                else {
                    row.child( format(data) ).show();
                }
            });
        }
		
        var j$ ;
        var selectedValue=0;
        var previousOnload = window.onload; 
        window.onload = function() {
            if (previousOnload) 
            {
                previousOnload(); 
            }
            j$ = jQuery.noConflict();
            selectedValue=0;
        } 
        
        function getSelectedTabName() {
            
            if (RichFaces) {
                
                var tabs = RichFaces.panelTabs['CCF_Form:form1:tabPanel'];
                
                for (var i = 0; i < tabs.length; i++) {
                    var tab = tabs[i];
                    if (RichFaces.isTabActive(tab.id + '_lbl')) {
                        
                        return tab.name;
                        
                    }
                }
            }
            return null;
        }
        function setSelectedTabOnController() {
            selectTabActionFunction(getSelectedTabName());
        }
        function alertUser(){
            
            window.confirm("Do you want to delete the selected line items");
            
            }
/*ccf_contract_form js end*/
