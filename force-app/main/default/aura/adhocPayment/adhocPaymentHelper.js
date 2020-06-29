({
    defaultMethod : function(component, event, helper, isDoInit, filterMap, isFilter) {
        
        helper.callServerMethod(
            component,
            helper,
            "getDefaultValue",                                       
            {
                isDoInit : isDoInit,
                filterMap : filterMap,
                isFilter : isFilter
            },  
            function(result) {
                if (result) {
                    component.set("v.isAddFundsVisible", result.addFunds)
                    component.set("v.isAddNewBankAccountVisible", result.addNewBankAccount)
                    let filterMap = component.get("v.filterMap") || {};
                    let adhocPaymentWrapper = {};
                    if (filterMap.offset == '0') {
                        if (filterMap.paymentStatus) {
                            adhocPaymentWrapper = component.get("v.adhocPaymentWrapper");
                            adhocPaymentWrapper.pastPaymentList = [];
                            adhocPaymentWrapper.futurePaymentList = [];
                            adhocPaymentWrapper.pastPaymentList = result.pastPaymentList;
                            adhocPaymentWrapper.futurePaymentList = result.futurePaymentList;
                            adhocPaymentWrapper.totalPaymentCount = result.totalPaymentCount;
                        } else {
                            adhocPaymentWrapper = result;
                        }
                    } else {
                        
                        adhocPaymentWrapper = component.get("v.adhocPaymentWrapper");
                        adhocPaymentWrapper.pastPaymentList = adhocPaymentWrapper.pastPaymentList || [];
                        adhocPaymentWrapper.pastPaymentList = adhocPaymentWrapper.pastPaymentList.concat(result.pastPaymentList);
                        adhocPaymentWrapper.futurePaymentList = adhocPaymentWrapper.futurePaymentList || [];
                        adhocPaymentWrapper.futurePaymentList = adhocPaymentWrapper.futurePaymentList.concat(result.futurePaymentList);
                    }
                    component.set("v.adhocPaymentWrapper",adhocPaymentWrapper);
                }
            },null
        ); 
    }
})