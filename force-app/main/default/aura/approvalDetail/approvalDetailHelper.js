({
	getOfferInfo : function(component, event, helper, parm) {
		helper.callServerMethod(
                component,
                helper,
                "getOfferInfo",
                {
                    offerId : parm
                },
                function(result){
                    if (result) {
                        console.log("result::::", result);
                        component.set("v.offerInfo", JSON.parse(JSON.stringify(result)));
                        console.log("offerInfo---->", component.get("v.offerInfo"));
                        /*if (result != null && result.offerList.length > 0 
                            && result.offerList[0].Source_of_Payment__c == 'PSA' 
                            && result.offerList[0].Tradeline_Litigation_Status__c == 'Non Lit') {
                            component.set("v.offerInfo.offerList[0].Is_Terms_Conditions_Checked__c", true);
                        }*/
                    }
                },
                null 
            );
	}
})