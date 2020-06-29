({
    doInit : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "getContentDocument",                                       
            {},  
            function(result) {
                console.log('result--->',result);
                if (result) {
                    component.set("v.defaultValueMap",result);
                    component.set("v.isInit",true);
                    var contentDocWrapList = result.contentDocWrapList ;
                    console.log('*****ABCD*** ' + JSON.stringify(contentDocWrapList)) ;
                    for(var i = 0; i< contentDocWrapList.length ; i++) {
                        contentDocWrapList[i].Subject = contentDocWrapList[i].Subject.replace(' Requested to upload ', '') ;
                        console.log('**** ' + JSON.stringify(contentDocWrapList[i])) ;
                    }
                }
            },
            null
        );
        component.set("v.isModalOpen1",false);
        component.set("v.isModalOpen2",false);
    },
    uploadEmail : function(component, event, helper) {
        component.set("v.isModal", true);
        console.log("isModal--->",component.get("v.isModal"))
    },
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        console.log("uploadedFiles--->",uploadedFiles)
        var contentDocumentList = component.get("v.contentDocumentList");
        for (var i = 0 ; i < uploadedFiles.length ; i++) {
            contentDocumentList.push(uploadedFiles[i]);
        }
        console.log("contentDocumentList--->",contentDocumentList);
        component.set("v.contentDocumentList",contentDocumentList);
    }, 
    deleteContentDocument : function(component, event, helper) {
        let contentDocumentList = component.get("v.contentDocumentList");
        let documentId = '';
        let index = event.currentTarget.getAttribute("data-index");
        
        if (contentDocumentList[index]) {
            documentId = contentDocumentList[index].documentId;
            contentDocumentList.splice(index,1);
        }
        helper.callServerMethod(
            component,
            helper,
            "deleteDocument",
            {
                "documentId" : documentId
            },
            function(response){
                if (response) {
                    helper.notifierTost(component,{
                        "variant" : "Success",
                        "message" : "Document Deleted successfully"
                    });
                }
            }
        );
        component.set("v.contentDocumentList", contentDocumentList);
    },
    downloadDocument: function (component, event, helper) {
        var index = event.currentTarget.getAttribute("data-index");
        console.log(index) ;
        var finalDocList = component.get("v.newContentDocumentList");
        console.log(finalDocList) ;
        var currentDocItem = finalDocList[index];
        console.log(currentDocItem) ;
        var docIdToDownload = currentDocItem.docId;
        console.log(docIdToDownload) ;
        var currentUrl = window.location.origin;
        var downloadUrl = currentUrl + '/sfc/servlet.shepherd/document/download/' + docIdToDownload+'?operationContext=S1';
        window.open(downloadUrl, '_blank');
    },
    showDocumentPreview: function (component, event, helper){
        var index = event.currentTarget.getAttribute("data-index");
        var finalDocList = component.get("v.newContentDocumentList");
        var currentDocItem = finalDocList[index];
        var docIdToPreview = currentDocItem.docId;
        component.set("v.documentIdToPreview", docIdToPreview);
        console.log('docIdToPreview',docIdToPreview);
        component.set("v.showPreviewModal", true);
    },
     closePreviewModel: function (component, event, helper){
        component.set("v.showPreviewModal", false);
    },

    cancelModel : function(component, event, helper) {
        let documentId ='';
        let contentDocumnentList = component.get("v.contentDocumentList");
        if (contentDocumnentList) {
            for (let i = 0;i < contentDocumnentList.length;i++) {
                if (documentId) {
                    documentId += ';'+contentDocumnentList[i].documentId;
                } else {
                    documentId += contentDocumnentList[i].documentId;  
                }
            }
            helper.callServerMethod(
                component,
                helper,
                "deleteDocument",
                {
                    "documentId" : documentId
                },
                function(response){
                    if (response) {
                        component.set("v.contentDocumentList",[]);
                    }
                }
            );
        }        
        component.set("v.newEmail",{'sobjectType': 'EmailMessage'});
        component.set("v.isModal", false);        
    },
    flipView : function(component, event, helper) {
        component.set("v.hideUpload", false);
    },
    sendMail : function(component, event, helper) {
        let documentId ='';
        let fieldList = [{'isRequired' : true, 'fieldLabel' : 'Document Title'}, {'isRequired' : true, 'fieldLabel' : 'Comments'}];
        let returnedValue = helper.fieldValidationHelper(component, event, fieldList, component.find("validation_sendEmailFromDoc"));
        let contentDocumnentList = component.get("v.contentDocumentList") || [];
        if (returnedValue.isFormValid && contentDocumnentList.length) {
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
                console.log('newEmail--->',component.get("v.newEmail"));
                helper.callServerMethod(
                    component,
                    helper,
                    "sendEmail",
                    {
                        "emailMessage" : component.get("v.newEmail"),
                        "accountId" : component.get("v.defaultValueMap.accountId")
                    },
                    function(response){
                        console.log('response--->',response);
                        var defaultValueMap = component.get("v.defaultValueMap");
                        defaultValueMap.contentDocWrapList = [];
                        defaultValueMap.contentDocWrapList = response.contentDocWrapList;                        
                        component.set("v.defaultValueMap", defaultValueMap);
                        component.set("v.isModal", false);
                        component.set("v.contentDocumentList",[]);
                        component.set("v.newEmail",{'sobjectType': 'EmailMessage'});
                        component.set("v.isModalOpen1",true);
                        component.set("v.successMessageString", $A.get("$Label.c.SFSPortal_Add_documents_Success_Message"));
                    }
                );
            }
        } else {
            if(!contentDocumnentList.length) {
                returnedValue.errorMessage += ' There should be atleast one attachment to Upload Document.';
            }
            component.set("v.isModalOpen2",true); 
            component.set("v.errorMessageString",returnedValue.errorMessage); 
        }
    },
    closeToast : function(component, event, helper) {
        component.set("v.hideUpload",false);
    },
    toggleSection: function(component, event, helper) {
        component.set("v.isDocumentHistoryExpanded",!component.get("v.isDocumentHistoryExpanded"));
    },
    cancelModel1 : function(component, event, helper) {
        component.set("v.isModalOpen1",false);
        component.set("v.isModalOpen2",false);
    }
})