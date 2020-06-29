({
    handleForgotPassword: function (component, event, helper) {
        helper.handleCheckUserAccess(component, event, helper);
        //helpler.handleForgotPassword(component, event, helper);
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            //helpler.handleForgotPassword(component, event, helpler);
            helper.handleCheckUserAccess(component, event, helper);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
       // var uname = component.get("v.username");
    },
    
    redirectToLoginPage : function(component, event, helper) {
        
        let domainURL;
        let pathName = window.location.href.split('/s/');
        if(pathName.length > 1) {
            domainURL = pathName[0] + '/s/login/';
        }
      
        let uiwrapperMap = component.get("v.uiwrapperMap") || {};
        if(uiwrapperMap && uiwrapperMap.isSandbox) {
            if(pathName[1].split('portfolio=').length > 1) {
                let portfolioName = pathName[1].split('portfolio=')[1];
                if (portfolioName) {
                    domainURL += '?portfolio='+portfolioName;
                }
            }
        }if(domainURL.includes('&')){
           domainURL = domainURL.split('&')[0]; 
        }
      
        let atag = document.createElement('a');
        atag.href = domainURL ;
        atag.target = "_self";
        atag.click();
    }
})