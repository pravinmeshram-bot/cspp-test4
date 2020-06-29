({
	/*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper) {
        
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var startIndex = (pageNumber-1) * pageSize;
        var endIndex = startIndex + pageSize;
        var totalPages = Math.ceil(allData.length / pageSize);
        component.set('v.totalPages',totalPages);
        component.set("v.startIndex", startIndex);
        let endPosition = endIndex;
        if(endIndex >= allData.length) {
            endPosition = allData.length;
        } 
        component.set("v.endIndex", endPosition);
        console.log('allData--->',allData);
        console.log('pageSize--->',pageSize);
        console.log('pageNumber--->',pageNumber);
        
        //creating data-table data
        if(allData && allData !== '') {
            
            var data = [];
            var j=0;
            for(var i=startIndex ; i < endIndex ; i++){
                if(allData[i]){
                    data[j] = allData[i];
                }
                j++;
            }
            console.log('Data-->',data);
            component.set('v.data',data);
        }
    }
})