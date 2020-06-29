({
    doInit : function(component, event, helper) {
        
        var domainURL = window.location.origin;
        /*
        var pathName = window.location.pathname.split('/');
        console.log('domainURL',domainURL,'pathName',pathName);
        if(pathName.length > 1) {
            domainURL = domainURL + '/' + pathName[1];
        }
        */
        
        /* Added for testing in UAT */
        let portfolioname = '';
        let searchString = window.location.search;
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            
            portfolioname = searchString.split('portfolio=')[1];
        }
        console.log('**** domainURL-->', domainURL);
        
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
                    console.log('response Footer test****', result);
                    component.set("v.footerValueMap", result);
                    var today = new Date();
                    console.log('**** today-->', today);
                    component.set('v.currentYear', today.getFullYear());
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