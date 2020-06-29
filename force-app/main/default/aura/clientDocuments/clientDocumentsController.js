({
    doInit : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "getFolderNames",                                       
            {},  
            function(result) {
                console.log('***** result', result);
                if(result) {
                    let foldersAndSubFoldersMap = {'0' : []};
                    let folderPathList = [{'name' : 'All', 'id' : '0'}];
                    for(let i = 0; i < result.length; i++) {
                        foldersAndSubFoldersMap['0'].push(result[i]);
                    }
                    component.set("v.foldersAndSubFoldersMap", foldersAndSubFoldersMap);
                    
                    component.set("v.folderPathList", folderPathList);
                    component.set("v.folderList", result);
                }
                
            },
            null
        );
    },
    getSubFolderDetails : function(component, event, helper) {
        let folderId = event.currentTarget.getAttribute('data-folderId');
        console.log('**** folderName-->', folderId);
        let index = event.currentTarget.getAttribute('data-index');
        let folderList = component.get("v.folderList") || [];
        
        let foldersAndSubFoldersMap = component.get("v.foldersAndSubFoldersMap") || {};
        
        if(folderList[index].type === 'file') {
            component.set("v.currentFileDetails", folderList[index]);
            component.set("v.isModalOpened", true);
        } else {
            let folderPathList = component.get("v.folderPathList") || [];
            
            folderPathList.push(folderList[index]);
            component.set("v.folderPathList", folderPathList);
            if(!foldersAndSubFoldersMap[folderId]) {
                helper.callServerMethod(
                    component,
                    helper,
                    "getAllSubFoldersAndFiles",                                       
                    {
                        'selctedFolderId' : folderId
                    },  
                    function(result) {
                        console.log('***** result', result);
                        
                        foldersAndSubFoldersMap[folderId] = [];
                        for(let i = 0; i < result.length; i++) {
                            foldersAndSubFoldersMap[folderId].push(result[i]);
                        }
                        component.set("v.foldersAndSubFoldersMap", foldersAndSubFoldersMap);
                        console.log('***** foldersAndSubFoldersMap-->', JSON.stringify(foldersAndSubFoldersMap));
                        component.set("v.folderList", result);
                    },
                    null
                );
            } else {
                component.set("v.folderList", foldersAndSubFoldersMap[folderId]);
            }
        }
    },
    renderFolderAndSubFolders : function(component, event, helper) {
        let folderId = event.getSource().get('v.name');
        let indexPosition = event.getSource().get('v.class');
        console.log('**** folderName-->', folderId);
        console.log('****** foldersAndSubFoldersMap-->', component.get("v.foldersAndSubFoldersMap"));
        let foldersAndSubFoldersMap = component.get("v.foldersAndSubFoldersMap") || {};
        console.log('***** foldersAndSubFoldersMap[folderId]-->', JSON.stringify(foldersAndSubFoldersMap[folderId]));
        component.set("v.folderList", foldersAndSubFoldersMap[folderId]);
        let folderPathList = component.get("v.folderPathList") || [];
        folderPathList.length = indexPosition + 1;
        component.set("v.folderPathList", folderPathList);
    },
    cancelModal : function(component, event, helper) {
        component.set("v.isModalOpened", false);
    }
})