({
	doInit : function(component, event, helper) {
		helper.callServerMethod(
            component,
            helper,
            "getDefaultFormIdList1",                                       
            {},  
            function(result) {
                console.log('***** result', result.attachmentList1);
                if (result) {
                component.set("v.documentWrapper", result);
                console.log(component.get("v.documentWrapper"));
                 }
                 },
            null
        );
	},
    downloadFile : function(component, event, helper) {
        let contentDocId = event.target.getAttribute("data-documentId"); 
        console.log('contentDocId',contentDocId);
        let atag = document.createElement('a');
		atag.href = '/sfc/servlet.shepherd/document/download/'+contentDocId;
        atag.target = '_self';
		atag.click();
    },
    downloadDocument: function (component, event, helper) {
        var index = event.currentTarget.getAttribute("data-index");
        console.log(index) ;
        var finalDocList = component.get("v.documentWrapper");
        console.log(finalDocList) ;
        var currentDocItem = finalDocList.attachmentList1[index];
        console.log(currentDocItem) ;
        var docIdToDownload = currentDocItem.Id;
        console.log(docIdToDownload) ;
        var currentUrl = window.location.origin;
        var downloadUrl = currentUrl + '/sfc/servlet.shepherd/document/download/' + docIdToDownload+'?operationContext=CHATTER';
        window.open(downloadUrl, '_blank');
    },
    showDocumentPreview: function (component, event, helper){
       // let contentDocId = event.target.getAttribute("data-index"); 
       // console.log('contentDocId',contentDocId);
        var index = event.currentTarget.getAttribute("data-index");
        console.log('index',index);
        var finalDocList = component.get("v.documentWrapper");
        console.log('finalDocList',JSON.stringify(finalDocList));
        var currentDocItem = finalDocList.attachmentList1[index];
        console.log('currentDocItem',currentDocItem);
        var docIdToPreview = currentDocItem.Id;
        console.log('docIdToPreview',docIdToPreview);
        component.set("v.documentIdToPreview", docIdToPreview);
        component.set("v.showPreviewModal", true);
    },
     closePreviewModel: function (component, event, helper){
        component.set("v.showPreviewModal", false);
    },
})