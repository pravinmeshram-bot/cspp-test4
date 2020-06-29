({  
    doInit : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "getContentDocument",                                       
            {},  
            function(result) {
                console.log('resultUP--->',result);
                if (result) {
                    component.set("v.defaultValueMap",result);
                    var contentDocWrapList = result.contentDocWrapList ;
                    for(var i = 0; i< contentDocWrapList.length ; i++) {
                        contentDocWrapList[i].Subject = contentDocWrapList[i].Subject.replace(' Requested to upload ', '') ;
                    }
                }
            },
            null
        );
        component.set("v.isSuccessModalOpen",false);
        component.set("v.isErrorModalOpen",false);
    }, 

    sendMail : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var contentDocumentList = component.get("v.contentDocumentList");
        for (var i = 0 ; i < uploadedFiles.length ; i++) {
            contentDocumentList.push(uploadedFiles[i]);
        }
        component.set("v.contentDocumentList",contentDocumentList);
        let documentId =''; 
       
        //let fieldList = [{'isRequired' : true, 'fieldLabel' : 'Document Title'}, {'isRequired' : true, 'fieldLabel' : 'Comments'}];
        //console.log('2--'+fieldList);
        //let returnedValue = helper.fieldValidationHelper(component, event, fieldList, component.find("validation_sendEmailFromDoc"));
        //console.log('3--'+JSON.stringify(returnedValue));
        let contentDocumnentList = component.get("v.contentDocumentList") || [];
        //if (returnedValue.isFormValid && contentDocumnentList.length) {
        if (contentDocumnentList.length > 0) {
            let emailInstance = component.get("v.newEmail");
            for (let i = 0;i < contentDocumnentList.length;i++) {
                if (documentId) {
                    documentId += ';'+contentDocumnentList[i].documentId;
                } else {
                    documentId += contentDocumnentList[i].documentId;  
                }
            }
            if (documentId) {
                emailInstance.RelatedToId = documentId;
                component.set("v.newEmail",emailInstance);
                helper.callServerMethod(
                    component,
                    helper,
                    "sendEmail",
                    {
                        "emailMessage" : component.get("v.newEmail"),
                        "accountId" : component.get("v.defaultValueMap.accountId")
                    },
                    function(response){
                        var defaultValueMap = component.get("v.defaultValueMap");
                        defaultValueMap.contentDocWrapList = [];
                        defaultValueMap.contentDocWrapList = response.contentDocWrapList;                        
                        component.set("v.defaultValueMap", defaultValueMap);
                        component.set("v.contentDocumentList",[]);
                        component.set("v.newEmail",{'sobjectType': 'EmailMessage'});
                        component.set("v.isSuccessModalOpen",true);
                        component.set("v.showSuccessModelMessage", $A.get("$Label.c.SFSPortal_Add_documents_Success_Message"));
                    }
                );
            }
        } else {
            //console.log('insideElse--'+JSON.stringify(returnedValue));
            //if(!contentDocumnentList.length) {
                //returnedValue.errorMessage += ' There should be atleast one attachment to Upload Document.';
            var errorMessage = ' There should be atleast one attachment to Upload Document.';
            //}
            component.set("v.isErrorModalOpen",true); 
            component.set("v.showErrorModelMessage",errorMessage); 
        }
    },
})