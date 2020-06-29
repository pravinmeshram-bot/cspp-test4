({
	getCategoryLengthMap : function(component, event, helper, subfoldersSchemaMap) {
        console.log('subfoldersSchemaMap!!!!'+JSON.stringify(subfoldersSchemaMap)+'!!!!');
        const CategoryToEntriesMap = new Map();
		const FilesToPreviewURL = new Map();
        const categoryToFileCount = new Map();
        var categoryEntryCount ;
        var allCategoryList = component.get("v.allCategoryList");
        var recentUploadeItems = [];
        var entriesWithInCategory = [];
        for(let availableCateg in allCategoryList){
            var testCategoryName = '';
            if(allCategoryList[availableCateg].includes('_')){
                testCategoryName = allCategoryList[availableCateg].replace('_', ' ');
            }else{
                testCategoryName = allCategoryList[availableCateg];
            }
            console.log('availableCateg!@!@!'+testCategoryName+'!@!@!@'+subfoldersSchemaMap[testCategoryName]);
			if(subfoldersSchemaMap[testCategoryName] && subfoldersSchemaMap[testCategoryName].length > 0){
                categoryEntryCount = 0;
                for(let categoryWiseSubfolders of subfoldersSchemaMap[testCategoryName]){ 
                    if(categoryWiseSubfolders.total_count && categoryWiseSubfolders.total_count > 0){
                        categoryEntryCount = categoryEntryCount + parseInt(categoryWiseSubfolders.total_count);
                        //add those element which recently uploaded
                        for(let eachFiles in categoryWiseSubfolders.entries){
                            console.log('eachfiles----'+JSON.stringify(categoryWiseSubfolders.entries[eachFiles]));
                            if(categoryWiseSubfolders.entries[eachFiles].modified_at){
                                console.log('!@!@!@!@'+ this.calculateDaysBetweenDates(categoryWiseSubfolders.entries[eachFiles].modified_at));
                                var fileAge = parseInt(this.calculateDaysBetweenDates(categoryWiseSubfolders.entries[eachFiles].modified_at));
                                console.log('21212122'+fileAge);
                                if(fileAge <= parseInt(5) &&  fileAge >= parseInt(0)){
                                    console.log('!!!!!TEst--'+fileAge);
                                    var temmpFile = categoryWiseSubfolders.entries[eachFiles];
                                    console.log('categoryWiseSubfolders.entries[eachFiles]----'+categoryWiseSubfolders.entries[eachFiles]);
                                    recentUploadeItems.push(temmpFile);
                                }
                            }
                            entriesWithInCategory.push(categoryWiseSubfolders.entries[eachFiles]);  
							//fill map for preview link
                            /*if(!FilesToPreviewURL.has(categoryWiseSubfolders.entries[eachFiles].id)){
                                FilesToPreviewURL[categoryWiseSubfolders.entries[eachFiles].id] =  categoryWiseSubfolders.entries[eachFiles].expiring_embed_link.url;
                            }*/
                        }
                    }
                    
                }
                if(!CategoryToEntriesMap.has(allCategoryList[availableCateg].toString())){
                  
					categoryToFileCount[allCategoryList[availableCateg].toString()] =  categoryEntryCount
                    console.log('JSON.str121212'+JSON.stringify(entriesWithInCategory));
                    CategoryToEntriesMap[allCategoryList[availableCateg].toString()] =  entriesWithInCategory;
                    entriesWithInCategory = [];
                }
            }
        }
        console.log('recentUploadeItems!@!@!@'+JSON.stringify(recentUploadeItems));
        console.log('categoryToFileCount!@!@!@'+JSON.stringify(categoryToFileCount));
        console.log('CategoryToEntriesMap>>!!!!!'+JSON.stringify(CategoryToEntriesMap));
        if(recentUploadeItems && recentUploadeItems.length > 0){
            component.set("v.recentUploadsEntityList",recentUploadeItems);
        }
		if(categoryToFileCount){
            component.set("v.categoryToFileCount", categoryToFileCount);
        }
        
        if(CategoryToEntriesMap){
            console.log('CategoryToEntriesMap>>>>'+JSON.stringify(CategoryToEntriesMap));
            component.set("v.selectedCategoryToEntriesMap", CategoryToEntriesMap);
        }
        /*if(FilesToPreviewURL){
            console.log('FilesToPreviewURL>>>>'+JSON.stringify(FilesToPreviewURL));
            component.set("v.FilesToPreviewURL", FilesToPreviewURL);
        }*/
        
    },
    calculateDaysBetweenDates : function(fileModifiedDate){
        var varfileModifiedDate = new Date(fileModifiedDate); 
        var varcurrentDate = new Date();    //current date value based on current browser itself
        var Difference_In_Time = varcurrentDate.getTime() - varfileModifiedDate.getTime(); // To calculate the time difference of two dates 
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24); // To calculate the no. of days between two dates 
        console.log("Total number of days between dates  <br>"
                       + varfileModifiedDate + "<br> and <br>" 
                       + varcurrentDate + " is: <br> " 
                       + Difference_In_Days); 
        return Difference_In_Days;            
        
    },
    // function automatic called by aura:waiting event  
    showSpinner : function(component) {
        component.set("v.spinner", true);  // make Spinner attribute true for displaying loading spinner 
    },
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component){   
        component.set("v.spinner", false); // make Spinner attribute to false for hiding loading spinner 
    },
    //show success message
    showSuccessToast : function(component, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title.toString(),
            message: message.toString(),
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    //show error message
    showErrorToast : function(component, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title.toString(),
            message: message.toString(),
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    //call server side action
    executeAction: function(cmp, action, callback) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var retVal=response.getReturnValue();
                    resolve(retVal);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
							console.log("Error message: " + errors[0].message);
                        }
                    }
                    reject(action.getError());
                }
            });
        $A.enqueueAction(action);
        });
    },
    setUiMessageValues : function(component , SuccessMessageValue, NoDocumentExcMessageValue, RecentUploadHintMessageValue){
        if(SuccessMessageValue){
            component.set("v.SuccessMessageValue",SuccessMessageValue);
        }else{

        }
        if(NoDocumentExcMessageValue){
            component.set("v.NoDocumentExcMessageValue",NoDocumentExcMessageValue);
        }else{

        }
        if(RecentUploadHintMessageValue){
            component.set("v.RecentUploadHintMessageValue",RecentUploadHintMessageValue);
        }else{
            component.set("v.RecentUploadHintMessageValue","There is no one in recent!");
        }
    }
})