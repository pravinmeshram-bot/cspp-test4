({
	doInit : function(component, event, helper){
        var availableDateToRender = component.get("v.recentUploadsList");
        console.log('availableDateToRender!!!!@@@@'+availableDateToRender);
    },
    handleDownloadEntity : function(component, event, helper) {
        var selectedFileId = event.currentTarget.id;
        console.log('selectedFileIdRD----'+selectedFileId);
        var paramObj = { fileId : selectedFileId }; // your parameters
        helper.sendRequest(component, 'c.downloadSelectedFile',paramObj)
        .then($A.getCallback(function(records) {
            console.log('First1 From Server-Side: ' + records);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": records
            });
            urlEvent.fire();
        }))
        .catch(function(errors) {
            console.error('ERROR: ' + errors);
        });
        
    },
    getPreviewFile : function(component, event, helper){ 
        var selectedFileId = event.currentTarget.id;
        console.log('selectedPreviewFile----'+selectedFileId);
        
        var mapFilesToPreviewUrl = component.get("v.FilesToPreviewURL");
        console.log('isLieRD----'+JSON.stringify(mapFilesToPreviewUrl[selectedFileId]));
        let selectedFilePreviewURL = mapFilesToPreviewUrl[selectedFileId];
        var pageReference = {
            type : "standard__webPage",
            target : "_blank",
            attributes : {
                "url": selectedFilePreviewURL
            }
        };
        component.set("v.FilePreviewpageReference", pageReference);
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            console.log('ExactURI---'+url);
        }), $A.getCallback(function(error) {
            console.log('Error while generating the file preview URL');
        }));
        // Uses the pageReference definition in the init handler
        var pageReference = component.get("v.FilePreviewpageReference");
        event.preventDefault();
        navService.navigate(pageReference);
        
    },
})