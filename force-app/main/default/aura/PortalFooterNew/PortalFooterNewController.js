({
    doInit : function(component, event, helper) {
        
        var domainURL = window.location.origin;
        console.log('testme==>',domainURL);
        /* Added for testing in UAT */
        let portfolioname = '';
        let portfolioname1 = '';
        let searchString = window.location.search;
        console.log('testmeSearchString===>',searchString);
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            portfolioname = searchString.split('portfolio=')[1];
            console.log('portfolioname1===>',portfolioname);
        }
        if(portfolioname.indexOf('&') !== -1 && portfolioname.split('&').length > 1) {
              portfolioname = portfolioname.substring(0,portfolioname.indexOf('&'));
              console.log('res===>',portfolioname);
        }
      
        /* END of Added for testing in UAT */
        if(domainURL) {
            helper.callServerMethod(
                component,
                helper,
                "getFooterValue",                                       
                {
                    domainURL : domainURL,
                    portfolioName : portfolioname
                },  
                function(result) {
                    component.set("v.footerValueMap", result);
                    if(result.ReferralUrl) {
                        component.set("v.ReferralURL", result.ReferralUrl);
                    }
                },
                null
            );
        }
    },
    redirectToFeedbackUrl : function(component, event, helper) {
        let footerValueMap = component.get("v.footerValueMap");
        var urlEvent = $A.get("e.force:navigateToURL");
        let urlToSend = footerValueMap.portfolioInstance.Portfolio__r.Submit_Feedback__c;
        if(footerValueMap && footerValueMap.currentUserType !== 'Guest') {
            urlToSend = '/s/contactsupport?subject=feed'
        } 
        urlEvent.setParams({
            "url": urlToSend
        });
        urlEvent.fire();
    }
})