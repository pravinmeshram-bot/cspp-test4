({
    doInit : function(component, event, helper) {
        
        component.set("v.successMessageString", "");
        var newRec = component.get("v.newReceipt");
        let groupTaskRecId;
        var domain = window.location.search;
        if(domain) {
            var parm = domain.split('=');
            if(parm && parm.length && parm.length > 1) {
                var id = parm[1].split('&');
                groupTaskRecId = id[0];
                component.set("v.isURLHavingId", true);
            }
        }
        helper.callServerMethod(
            component,
            helper,
            "getTradelineInstance",
            {
                groupTaskId : groupTaskRecId
            },
            function(response){
                console.log('***** response add new debt-->', response);
                if(response){
                    component.set("v.fieldSetList",response.fieldSetMemberList);
                    component.set("v.newReceipt", response.groupTaskInstance);
                    component.set("v.recordId", response.groupTaskInstance.Id);
                }
            }
        );
        component.set("v.isModalOpen1",false); 
        component.set("v.isModalOpen2",false);
    },
    onSave : function(component,event,helper) {
        
        var contentDocumnentList = component.get("v.contentDocumentList");       
        var selectionObject = component.get("v.selectionObject");
        var returnedValue = helper.fieldValidationHelper(component, event, component.get("v.fieldSetList"), component.find("validation_newTradeline"));        
        if(!selectionObject || (selectionObject && !selectionObject.Id) ) {
            console.log('selectionObject--->',selectionObject);
            console.log('**** returnedValue.errorMessage-->', returnedValue.errorMessage);
            if (returnedValue.errorMessage) {
                returnedValue.errorMessage = returnedValue.errorMessage.replace(
                    (returnedValue.errorMessage.includes(',') ? " are required fields." : " is required field." ) ,", Creditor Name are required fields.");
            } else {
                returnedValue.errorMessage += 'Creditor Name is required. ';
            }
            returnedValue.isFormValid = false;
            var lookupComponent = component.find("creditorStandardizationLookup")  
            console.log('lookupComponent--->',lookupComponent);
            var lookup = lookupComponent.find("lookup-element");
            console.log('lookup--->',lookup);
            $A.util.addClass(lookup, 'addError');
        } else {
            var lookupComponent = component.find("creditorStandardizationLookup")  
            console.log('lookupComponent--->',lookupComponent);
            var lookup = lookupComponent.find("lookup-element");
            console.log('lookup--->',lookup);
            $A.util.removeClass(lookup, 'addError');
        }
        if(contentDocumnentList.length == 0) {
            returnedValue.errorMessage = (returnedValue.errorMessage)? returnedValue.errorMessage.replace(returnedValue.errorMessage.includes(',') ? " are required fields." : " is required field.", " and A Recent Bank statement is required to submit your request") : "A Recent Bank statement is required to submit your request."
            returnedValue.isFormValid = false;
        }
        if (!returnedValue.isFormValid) {
            component.set("v.isModalOpen2",true);
            component.set("v.errorMessageString", returnedValue.errorMessage);
        } else {
            var newRec = component.get("v.newReceipt");
            if(selectionObject && selectionObject.Name ) {
                newRec.Creditor_Name__c = selectionObject.Name; 
            }
            console.log('new:::::',JSON.stringify(component.get("v.newReceipt")));
            helper.callServerMethod(
                component,
                helper,
                "saveReceipt",
                {
                    "newReceipt":component.get("v.newReceipt")
                },
                function(response){
                    component.set("v.newReceipt",{});
                    component.set("v.contentDocumentList",[]);
                    let isURLHavingId = component.get("v.isURLHavingId");
                    if(isURLHavingId) {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/"
                        });
                        urlEvent.fire(); 
                    } else {
                        component.set("v.isModalOpen1",true);
                        component.set("v.successMessageString", $A.get("$Label.c.SFSPortal_New_Debt_Success_Message"));
                    }
                }
            );
        }
    },
    
    handleEvent : function(component,event,helper) {
        var newRec = component.get("v.newReceipt");
        var fieldName = event.getSource().get("v.fieldName");
        var fieldvalue = event.getParam("value");
        newRec[fieldName] = fieldvalue;
        component.set("v.newReceipt",newRec);
        console.log("new:::::",component.get("v.newReceipt"));
    },
    handleUpload : function(component,event,helper) {
        var uploadedFiles = event.getParam("files");
        var contentDocumnentList = component.get("v.contentDocumentList");
        for(var i = 0;i < uploadedFiles.length;i++) {
            contentDocumnentList.push(uploadedFiles[i]);
        }
        component.set("v.contentDocumentList",contentDocumnentList);
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
    },
    cancelModel : function(component, event, helper) {
        component.set("v.isModalOpen1",false);
        component.set("v.isModalOpen2",false);
    },
    changedHashURL : function(component, event, helper) {
        var loc = event.getParam("token");
    }
})