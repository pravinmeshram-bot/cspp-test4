({
    doInit : function(component, event, helper){
        helper.showSpinner(component); //Start showing spinner
        //get all UI message value form custom labels
        var SuccessMessageValue = $A.get("$Label.c.DocumentCenter_Success_Message");
        var NoDocumentExcMessageValue = $A.get("$Label.c.DocumentCenter_No_Document_Exception");
        var RecentUploadHintMessageValue = $A.get("$Label.c.DocumentCenter_Recent_Upload_hint");
        helper.setUiMessageValues(component, SuccessMessageValue, NoDocumentExcMessageValue, RecentUploadHintMessageValue);

		//create promise for Box files server callout
        var boxAction = component.get("c.getSelectedFolderSchema");
		var boxActionPromise = helper.executeAction(component, boxAction);
		boxActionPromise.then(
			$A.getCallback(function(records){
				// We have the box server call response
				if(records && records != null){
					component.set("v.filteredFolderMap",records);
					console.log("From server: 2" + JSON.stringify(component.get("v.filteredFolderMap")));
					var subfoldersSchemaMap = new Map();
					subfoldersSchemaMap = component.get("v.filteredFolderMap");
					console.log('subfoldersSchemaMap@@@@'+subfoldersSchemaMap);
					helper.getCategoryLengthMap(component, event, helper, subfoldersSchemaMap);
                }
                if(!SuccessMessageValue){
                    console.log('!!!!@22'+SuccessMessageValue);
                    SuccessMessageValue = 'All Box documents are loaded successfully!';
                }
				helper.showSuccessToast(component, 'Success', SuccessMessageValue);
			}),
			$A.getCallback(function(errors){  // Exception handling here
                console.log('An error occurred getting the Box Files : ' + JSON.stringify(errors));
                if(errors[0].message){
                    var errorMessage = errors[0].message;
                    console.log('errorMessage--'+errorMessage);
                    //create a blank responce when we got a specific exception while fetching box file
                    if(errorMessage && (errorMessage.includes('Box FolderId is not configured for current account!') || errorMessage.includes('Box Authorization Failed!'))){
                        console.log('boxFileError--'+errorMessage);
                        var blankResponse = new Map();
                        component.set("v.selectedCategoryToEntriesMap",blankResponse);
                    }else{
                        console.log('OtherException--'+errorMessage);
                        helper.showErrorToast(component, errors[0].exceptionType, errorMessage);
                    }
                }
				
			})
		);
		//create promise for welcom material server callout
		var welcomeGuideAction = component.get("c.getWelcomeMaterial");
		var welcomeGuideActionPromise = helper.executeAction(component, welcomeGuideAction);
		welcomeGuideActionPromise.then(
			$A.getCallback(function(records){
				//We have the welcomeMaterial server call response
				console.log('Second 2 From Server-Side: ' + records);
				component.set("v.welcomeMaterialDocs",records);
				console.log('welcomeMaterial---'+JSON.stringify(component.get("v.welcomeMaterialDocs")));
                //Need to show welcome_Material seccess message once in a active session
                // Check browser support
                console.log('typeof(Storage)----'+window.sessionStorage);
                if (window.sessionStorage) {
                    if(sessionStorage.getItem("isWelcomeMaterialSuccessMessageAppear") != "Yes"){
                        sessionStorage.setItem("isWelcomeMaterialSuccessMessageAppear", "Yes");
                        helper.showSuccessToast(component, 'Success:', 'All welcome material are available for your review.');
                    }else{
                        console.log('Welcome Material success message already appeared!')
                    }
                    
                }else{
                    console.log("Sorry, your browser does not support Web Storage...");
                    helper.showSuccessToast(component, 'Success:', 'All welcome material are available for your review.');
                }
			}),
			$A.getCallback(function(errors){ // Exception handling here
                console.log('An error occurred getting the welcomeMaterialDocs : ' + errors[0].message);
                if(errors[0].message){
                    var errorMessage = errors[0].message;
                    //create a blank responce when we got a specific exception while fetching Welcome material
                    if(errorMessage && errorMessage.includes('Something went wrong while fetching Welcome material..')){
                        console.log('WelcomematerialFileError--'+errorMessage);
                        var blankResponse = [];
                        component.set("v.welcomeMaterialDocs",blankResponse);
                    }else{
                        console.log('OtherException--'+errorMessage);
                        helper.showErrorToast(component, errors[0].exceptionType, errorMessage);
                    }
                }
			})
			
		);
        helper.hideSpinner(component);  //hide spinner
    },
	iConClicked : function(component, event, helper) {
        var selectedCategory = event.currentTarget.title;
        var selectedCategoryName = event.currentTarget.id;
        console.log('selectedCategory12'+selectedCategory);
        component.set("v.selectedCategory",selectedCategoryName);
        //component.set("v.showLandingPage", false);
        var allSubFolderListing = [];
        if(selectedCategory != 'Welcome_Guides'){ 
            var categoryToEntriesMap = new Map();
            categoryToEntriesMap = component.get("v.selectedCategoryToEntriesMap");
            if(categoryToEntriesMap[selectedCategory] && categoryToEntriesMap[selectedCategory].length > 0){
                for(let i in categoryToEntriesMap[selectedCategory]){ 
                    allSubFolderListing.push(categoryToEntriesMap[selectedCategory][i]);
                }
                if(allSubFolderListing && allSubFolderListing.length > 0){
                    component.set("v.CategoryWiseEntitiesList", allSubFolderListing);
                    component.set("v.showLandingPage", false); 
                }
            }else if(categoryToEntriesMap.size == 0 || categoryToEntriesMap[selectedCategory].length == 0){
                //helper.showErrorToast(component, 'Info:', 'No file found in this selected category!');
                if(allSubFolderListing && allSubFolderListing.length == 0){
                    component.set("v.CategoryWiseEntitiesList", allSubFolderListing);
                    component.set("v.showLandingPage", false); 
                }
            }
            window.scroll(0,0)
    	}else{
            var allWelcomeMaterialFiles = component.get("v.welcomeMaterialDocs");  
            console.log('allWelcomeMaterialFiles!!!!'+JSON.stringify(allWelcomeMaterialFiles));
            if(allWelcomeMaterialFiles && allWelcomeMaterialFiles.length > 0){
                component.set("v.CategoryWiseEntitiesList", allWelcomeMaterialFiles);
                component.set("v.showLandingPage", false); 
            }else if(allWelcomeMaterialFiles && allWelcomeMaterialFiles.length == 0){
                component.set("v.CategoryWiseEntitiesList", allWelcomeMaterialFiles);
                component.set("v.showLandingPage", false); 
                //helper.showErrorToast(component, 'Info:', 'No files found in Welcome Material!');
            }
        }
    },
    handleDownloadEntity : function(component, event, helper) {
        
        var selectedFileId = event.currentTarget.id;
        console.log('selectedFileId----'+selectedFileId);
        var selectedCategory = component.get("v.selectedCategory");
        helper.showSpinner(component); //Start showing spinner
        //download logic for all box files
        if(selectedFileId && selectedCategory && selectedCategory != 'Welcome Materials'){
			var downloadFileAction = component.get("c.downloadSelectedFile");
			var paramObj = { fileId : selectedFileId }; // your parameters
			downloadFileAction.setParams(paramObj);
			var downloadFileActionPromise = helper.executeAction(component, downloadFileAction);
            downloadFileActionPromise.then(
				$A.getCallback(function(records){
					//We have the welcomeMaterial server call response
					console.log('Download Server-Side: ' + records);
					var urlEvent = $A.get("e.force:navigateToURL");
					urlEvent.setParams({
						"url": records
					});
					urlEvent.fire();
				}),
				$A.getCallback(function(errors){       
                    // Something went wrong
					console.log('An error occurred getting downloade the file : ' + errors[0].message);
					helper.showErrorToast(component, errors[0].exceptionType, errors[0].message);
				})
				
			);
        //download logic for WelcomeMaterial files    
        }else if(selectedFileId && selectedCategory && selectedCategory == 'Welcome Materials'){
            var currentUrl = window.location.origin;
            var downloadURL = currentUrl + '/sfc/servlet.shepherd/document/download/' + selectedFileId+'?operationContext=CHATTER';
            var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": downloadURL
                });
            urlEvent.fire();
        }
        helper.hideSpinner(component);  //hide spinner
    },
    /*getPreviewFile : function(component, event, helper){ 
        var selectedFileId = event.currentTarget.id;
        console.log('selectedPreviewFile----'+selectedFileId);
        var selectedCategory = component.get("v.selectedCategory");
        console.log('selectedCategory@@@@'+selectedCategory);
        if(selectedCategory && selectedCategory != 'Welcome Materials'){
            var mapFilesToPreviewUrl = component.get("v.FilesToPreviewURL");
            console.log('isLie----'+JSON.stringify(mapFilesToPreviewUrl[selectedFileId]));
            let selectedFilePreviewURL = mapFilesToPreviewUrl[selectedFileId];
            var pageReference = {
                type : "standard__webPage",
                target : "_blank",
                attributes : {
                    "url": mapFilesToPreviewUrl[selectedFileId]
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
        }else{
            component.set("v.showDocumentPreviewModel", true);
            component.set("v.WelcomeMaterialDocId", selectedFileId);
        }
    },*/

    getPreviewFile : function(component, event, helper){ 
        var selectedFileId = event.currentTarget.id;
        console.log('File to preview :'+selectedFileId);
        var selectedCategory = component.get("v.selectedCategory");
        console.log('selectedCategory@@@@'+selectedCategory);
        if(selectedCategory && selectedCategory != 'Welcome Materials'){
            helper.showSpinner(component);  //start showing spinner
            //making server side callout for all box document preview //create promise for box file preview server callout
            var boxFilePreviewAction = component.get("c.getBoxPreviewLink");
            var params = {"fileId":selectedFileId};
            boxFilePreviewAction.setParams(params);
            var boxFilePreviewActionPromise = helper.executeAction(component, boxFilePreviewAction);
            boxFilePreviewActionPromise.then(
                $A.getCallback(function(records){
                    if(records){
                        console.log('Second 2 From Server-Side: ' + records);
                        var pageReference = {
                            type : "standard__webPage",
                            target : "_blank",
                            attributes : {
                                "url": records
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
                        // Uses the pageReference definition
                        var pageReference = component.get("v.FilePreviewpageReference");
                        event.preventDefault();
                        navService.navigate(pageReference);
                    }
                }),
                $A.getCallback(function(errors){ // Exception handling here
                    console.log('An error occurred getting the welcomeMaterialDocs : ' + errors[0].message);
                    if(errors[0].message){
                        var errorMessage = errors[0].message;
                        //create a blank responce when we got a specific exception while fetching Welcome material
                        if(errorMessage && errorMessage.includes('Something went wrong while preview the file')){
                            console.log('Known Exception while preview the file--'+errorMessage);
                            helper.showErrorToast(component, errors[0].exceptionType, errorMessage);
                        }else{
                            console.log('Exception while preview the file--'+errorMessage);
                            helper.showErrorToast(component, errors[0].exceptionType, errorMessage);
                        }
                    }
                })
                
            );
            helper.hideSpinner(component);  //hide spinner
        }else{
            component.set("v.showDocumentPreviewModel", true);
            component.set("v.WelcomeMaterialDocId", selectedFileId);
        }
        
    },

    backDocument : function(component, event, helper) {
        console.log('--backDocumentCalled---');
        var selectedCategory = "";
        var selectedCategoryToEntries = new Map()
        component.set("v.showLandingPage", true);
        component.set("v.selectedCategory",selectedCategory);
        
    },

    handleModal: function (component, event, helper) {
        component.set("v.openModal", true)
    },

    closeModal: function (component, event, helper) {
        component.set("v.openModal", false)
    },
	closePreviewModel: function (component, event, helper){
        component.set("v.showDocumentPreviewModel", false);
    },

})