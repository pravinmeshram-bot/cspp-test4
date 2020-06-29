({
    afterRender : function(component, helper) {
        this.superAfterRender();
        let dynamicTable = component.find("dynamicTable").getElement();
        let isLazyLoad = component.get("v.isLazyLoad");
        console.log('dynamicTable--->',component.find("dynamicTable"));
        console.log('dynamicTable-Element--->',dynamicTable);
        console.log('isLazyLoad--->',isLazyLoad);
        if(dynamicTable && isLazyLoad ) { 
            console.log('***** inside if condtion');
            dynamicTable.addEventListener('scroll', $A.getCallback(function(event){
                console.log('**** inside event listener');
                let dataList = component.get("v.dataList") || [];
                let totalCount = component.get("v.totalCount") || 0;
                console.log('dataList--->',dataList);
                console.log('totalCount--->',totalCount);
                if (dataList && dataList.length < totalCount) {
                    console.log('scrollTop--->',dynamicTable.scrollTop);
                    console.log('scrollHeight--->',dynamicTable.scrollHeight);
                    console.log('offsetHeight--->',dynamicTable.offsetHeight); // - 0.75
                    if((dynamicTable.scrollTop) === (dynamicTable.scrollHeight - dynamicTable.offsetHeight)) {
                        var lazyLoadEvent = component.getEvent("lazyLoadEvent");
                        lazyLoadEvent.setParams({
                            'action': component.get("v.totalCountVariable")
                        });
                        lazyLoadEvent.fire();
                    }
                }
            }));
        }
    }
})