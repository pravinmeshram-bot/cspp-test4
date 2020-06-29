/*ccf_customusersearch js start*/
            function fillIn(){                
                 
                var ProjectNames = $('input[id$=csvProjName]').val();            
                var Projectid = $('input[id$=csvProjId]').val();
                var usercouid = $('input[id$=ucId]').val();
                         
                var winMain1 = window.opener;
                if (null == winMain1){
                     winMain1=window.parent.opener;
                }
                   var num = "{!ccfreq}";
                            var rc = "{!rcount}";
                            if(num=='one')
                                 {
                var elem = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':phoneNumberFieldId');            
                var elemName = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':phuserId1');
                  var elemcou = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':ucountry1');                    
                elem.value = ProjectNames ;//document.getElementById('mainPageId:mainFormId:csvPhoneNumberId').value;    
                elemName.value = Projectid ;//document.getElementById('mainPageId:mainFormId:csvPhoneNameId').value;
                elemcou.value = usercouid;                     
                                           }else if(num=='two')
                                 {
                var elem = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':phoneNumberFieldId2');            
                var elemName = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':phuserId2');
                    var elemcou = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':ucountry2');                    
                elem.value = ProjectNames ;//document.getElementById('mainPageId:mainFormId:csvPhoneNumberId').value;    
               elemName.value = Projectid ;//document.getElementById('mainPageId:mainFormId:csvPhoneNameId').value;
                                      elemcou.value = usercouid;
                                           }else if(num=='three')
                                 {
                var elem = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':phoneNumberFieldId3');            
                var elemName = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':phuserId3');
                     var elemcou = winMain1.document.getElementById('pageId:mainFormId:pgBId:tabids:'+rc+':ucountry3');                   
                elem.value = ProjectNames ;//document.getElementById('mainPageId:mainFormId:csvPhoneNumberId').value;    
                elemName.value = Projectid ;//document.getElementById('mainPageId:mainFormId:csvPhoneNameId').value;
                                      elemcou.value = usercouid;
                                           }
            }
            function onClose(){
              var winMain=window.opener;
              if (null==winMain)
              {
                 winMain=window.parent.opener;
              }
              winMain.closeLookupPopup();
           }          
           //To select All
           function selectAll(src){           
               if(src.checked){ 
                   $('.case').attr('checked', true);
               }else{
                   $('.case').removeAttr("checked");
               }
               fillIn();
           }
/*ccf_customusersearch js end*/