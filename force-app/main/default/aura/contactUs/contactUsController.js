({  
    doInit : function(component,event,helper) {
        helper.callServerMethod(
            component,
            helper,
            "getDefaultValue",
            false,
            function(response){
                if(response){
                    console.log("Contact Us response::",response);
                    let urlParam = window.location.search;
                    if(urlParam && urlParam.indexOf('?subject') !== -1) {
                        let emailInstance = component.get("v.emailInstance");
                        emailInstance.Request_Subject__c = "Feedback";
                        response.disableSubject = true;
                        component.set("v.emailInstance", emailInstance);
                    }
                    component.set("v.defaultValueMap",response);
                    component.set("v.isDoInitFired", true);
                }
            }
        );
        
    },
    onSendMail : function(component, event, helper) {
        let fieldList = [{'isRequired' : true, 'fieldLabel' : 'Subject'}, {'isRequired' : true, 'fieldLabel' : 'Message'}];
        var returnedValue = helper.fieldValidationHelper(component, event, fieldList, component.find("validation_contactUs"));
        var contentDocumnentList = component.get("v.contentDocumentList");
        var emailInstance = component.get("v.emailInstance");        
        if (returnedValue.isFormValid) {
            var documentId ='';
            for(var i = 0;i < contentDocumnentList.length;i++) {
                documentId += contentDocumnentList[i].documentId + ';' ;  
            }
            emailInstance.RelatedToId = documentId;
            helper.callServerMethod(
                component,
                helper,
                "sendMail",
                {
                    "message": emailInstance,
                    "accountId" : component.get("v.defaultValueMap").accountId
                },
                function(response) {
                    let defaultValueMap = component.get("v.defaultValueMap");
                    defaultValueMap.disableSubject = false;
                    component.set("v.defaultValueMap", defaultValueMap);
                    component.set("v.emailInstance",{});
                    component.set("v.contentDocumentList",[]);
                    component.set("v.isModalOpen1",true);
                    component.set("v.successMessageString", $A.get("$Label.c.SFSPortal_Contact_Us_Success_Message"));
                }
            );
        } else {
             component.set("v.isModalOpen2",true);
             component.set("v.errorMessageString", returnedValue.errorMessage);
        }
    },
    handleUpload : function(component,event,helper) {
        var uploadedFiles = event.getParam("files");
        var contentDocumnentList = component.get("v.contentDocumentList");
        for(var i = 0;i < uploadedFiles.length;i++) {
            contentDocumnentList.push(uploadedFiles[i]);
        }
        component.set("v.contentDocumentList",contentDocumnentList);
    },
     closeModal1 : function(component, event, helper) {
        component.set("v.isModalOpen1",false);
        component.set("v.isModalOpen2",false);
    },
    onDelete : function(component,event,helper) {
        var contentDocumentList = component.get("v.contentDocumentList");
        var index = event.currentTarget.getAttribute("data-index");
        helper.callServerMethod(
            component,
            helper,
            "deleteDocument",
            {
                "deleteDocumentId": contentDocumentList[index].documentId
            },
            function(response){
                contentDocumentList.splice(index,1);
                component.set("v.contentDocumentList",contentDocumentList);
            }
        );
    }
})