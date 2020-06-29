({
    qsToEventMap: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleForgotPassword: function (component, event, helpler) {
       console.log('method called');
        var username = component.find("usernameip_forgotPassword").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassword");
        if(username != null)
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        console.log('**** username-->', username);
        console.log('**** checkEmailUrl-->', checkEmailUrl);
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            console.log('**** rtnValue-->', rtnValue);
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            } else {
                component.set("v.isForgetPasswordSent",true);
            }
       });
        $A.enqueueAction(action);
    },

    //Added By Haarati
    handleCheckUserAccess: function (component, event, helper) {
        //var domain = window.location.origin; Isssue in getting the domain 
        //To get the domain URL
        var username = component.find("usernameip_forgotPassword").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        let domain; 
        let portfolioName = '';
        var action = component.get("c.checkUserAccess");
        let uiwrapperMap = component.get("v.uiwrapperMap") || {};
        let pathName = window.location.href.split('/s/');
        if(pathName.length > 1) {
            domain = pathName[0];
        }
        console.log('username--->',username);
        if(uiwrapperMap && uiwrapperMap.isSandbox) {
            let searchString = window.location.search;
            if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
                
                portfolioName = searchString.split('portfolio=')[1];
            }
            if(portfolioName.indexOf('&') !== -1 && portfolioName.split('&').length > 1) {
                
                portfolioName = portfolioName.split('&')[0];
               
            }   
        }
        console.log('portfolioName--->',portfolioName);
        if(username == '' || username == null || username == undefined){
            component.set("v.errorMessage","Username cannot be blank");
            component.set("v.showError",true); 
            return;
        }
        action.setParams({
            username:username,
            domain:domain,
            portfolioName:portfolioName,
            checkEmailUrl:checkEmailUrl
        });
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            console.log('**** rtnValue-->', rtnValue);
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            } else {
                component.set("v.isForgetPasswordSent",true);
            }
            /*if (rtnValue != null && !rtnValue) {
               component.set("v.errorMessage","No access to this domain");
               component.set("v.showError",true);
            } else {
                this.handleForgotPassword(component, event, helper);
            }*/
       });
        $A.enqueueAction(action);
    },
    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }
})