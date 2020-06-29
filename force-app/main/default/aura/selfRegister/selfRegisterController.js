({
    initialize: function(component, event, helper) {
        
        var query = decodeURIComponent(window.location.href);
        //var query = window.location.href;
        var accountId = '';
        var isClient= true;
        if (query.includes('i=')) {
                        
            accountId = (query && (query.split('i=')).length > 0 )? query.split('i=')[1].toString() : '';
             /*
            ///var searchCon = (query && (query.split('i=')).length > 0 )? query.split('i=')[1].toString() : '';
            
            //console.log('searchCon-->',searchCon);
            
            if (searchCon.includes('&c=')) {
                
                var splitString = (searchCon && (searchCon.split('&c=')).length > 0 )? searchCon.split('&c=') : [];
                console.log('splitString-->',splitString);
                if (splitString && splitString.length > 0) {
                    
                    accountId = splitString[0];
                    if (splitString[1] != null  && splitString[1] == '1') {
                        isClient = true;
                    } else {
                        isClient = false;
                    }
                }
            }      */
            
        }
        
        if(query.includes('src=')) {
            let firstSplit = (query && (query.split('src=')).length > 0 ) ? query.split('src=')[1].toString() : '';
            let sourceType = firstSplit.split('&')[0].toString() || '';
            console.log('sourceType--->',sourceType);
            component.set("v.sourceType", sourceType);
        }
        
		if(query.includes('cid=')) {
            let splitText = (query && (query.split('cid=')).length > 0 ) ? query.split('cid=')[1].toString() : '';
            let campaignId = splitText.split('&')[0].toString() || '';
            console.log('campaignId--->',campaignId);
            component.set("v.campaignId", campaignId);
        }        
        
        console.log('accountId-->',accountId);
        console.log('isClient-->',isClient);
        
        helper.callServerMethod(
            component,
            helper,
            "getdefault",
            {
                parsedAccountId : accountId,
                isClientEmail  : isClient
            },
            function(response){
                console.log('**** response-->', response);
                if (response.userInstance) {
                    component.set("v.userInstance", response.userInstance);
                    component.set("v.toRenderView", "ToEndSessionOrRegister");
                } else if (response.accountWrapper) {
                    component.set("v.accountWrapper",response.accountWrapper)
                }
            },function(error){
                   
                component.set("v.showError", true); 
                component.set("v.errorMessage", error);  
            }
        );
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
    },
    
    handleSelfRegister: function (component, event, helpler) {
        helpler.handleSelfRegister(component, event, helpler);
    },
    
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    toRediredtToUser : function (component, event, helper) {
        let domain = window.location.origin;
        console.log('domain--->',domain);
        /*
        let pathName = window.location.pathname.split('/');
        console.log('pathName--->',pathName);
        if (pathName.length > 1) {
            domain = domain + '/' + pathName[1];
        }
        */
        let atag = document.createElement('a');
        atag.href = domain+"/";
        atag.target="_self";
        atag.click();
    },
    toSelfRegistration : function (component, event, helper) {
        
        let domain = window.location.origin;
        console.log('domain--->',domain);
        /*
        let pathName = window.location.pathname.split('/');
        console.log('pathName--->',pathName);
        if (pathName.length > 1) {
            domain = domain + '/' + pathName[1];
        }
        */
        sessionStorage.setItem('redirectFrom', 'SelfRegister');
        let atag = document.createElement('a');
        atag.href = domain+"/secur/logout.jsp?retURL="+domain+"/login/SelfRegister";
        atag.target = "_self";
        atag.click();
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    findAccount: function(component, event, helper){
        
        let domain; //= window.location.origin;
        
        let pathName = window.location.href.split('/s/');
        if(pathName.length > 1) {
            
            domain = pathName[0];
        }
        
        /* Added for testing in UAT */

        console.log('**** portfolio url', window.location.search);
        let portfolioName = '';
        let searchString = window.location.search;
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            
            portfolioName = searchString.split('portfolio=')[1];
        } 
        console.log('domain--->',domain);
        
        var errorMessage = '';
        var showError = false;
        
        console.log('ssn--->',component.find("ssn_selfRegister").get("v.value"));
        console.log('email--->',component.find("email_selfRegister"));
        console.log('dob--->',component.find("dob_selfRegister"));
        let dateofBirth = component.find("dateofBirth");
        console.log('**** dateofBirth-->', dateofBirth);
        if (dateofBirth) {
            
            dateofBirth.validateDateFormat( function(isValid) {
                console.log('***** isValid-->', isValid);
                if (isValid) {
                    showError = true; 
                    errorMessage += isValid + ' <br/>';
                }
            });
        }
        var email = component.find("email_selfRegister");
        console.log('****email',email);
        if(!Array.isArray(email)){
            console.log('****');
            email = [email];
        }
        console.log('*****email--->',email);
        console.log('*****email[0]--->',email[0]);
        console.log('*****email[0]--->',email[0].get("v.value"));
        if (!email[0].get("v.value")) {
            showError = true; 
            errorMessage += 'Email is required. <br/>';
        } 
        if (!component.find("ssn_selfRegister").get("v.value")) {
            showError = true; 
            errorMessage += 'Last 4 digit of SSN is required. <br/>';
        } else {
            let ssnRegExp = '^[0-9]+$';
            if(!component.find("ssn_selfRegister").get("v.value").match(ssnRegExp)) {
                showError = true; 
                errorMessage += 'SSN should only contains numbers. <br/>';
            }
        }  
        
        /*
        if (!component.find("dob").getElement().value) {
            showError = true; 
            errorMessage += 'Date Of Birth is required. <br/>';
        } 
        /*
        if (component.find("dob").get("v.validity") && !component.find("dob").get("v.validity").valid) {
            showError = true; 
            errorMessage += 'Invalid Date Format. <br/>';
        }
        */
        console.log('showError--->',showError);
        console.log('errorMessage--->',errorMessage);
        
        component.set("v.showError", showError); 
        component.set("v.errorMessage", errorMessage);  
        
        //showError = false;
        
        if (!showError) {
            
            console.log('email--->',email);
            var dob = component.get("v.selectedDOB");//component.find("dob").getElement().value; 
            console.log('dob--->',dob);
            
            //let selctedDate = //new Date(dob);
            //dob = selctedDate.getFullYear() + '-' + (selctedDate.getMonth() + 1) + '-' + selctedDate.getDate() + ' 00:00:00'; 
            var ssn = component.find("ssn_selfRegister").get("v.value");
            console.log('ssn--->',ssn.toString());
            console.log('domain--->',domain);
            helper.callServerMethod(
                component,
                helper,
                "findTheRelatedAccount",
                {
                    email:email[0].get("v.value"), 
                    dob:dob, 
                    ssn:ssn.toString(), 
                    domain:domain,
                    portfolioName:portfolioName
                },
                function(response){
                    console.log("response::::", response);
                    if (response) {
                        
                        component.set("v.showError", false); 
                        component.set("v.errorMessage", '');  
                        component.set("v.accountWrapper", response);  
                       // component.set("v.toRenderView", "FoundAccountView");  
                    }
                    let accountWrapper = component.get("v.accountWrapper");
                    accountWrapper.userName = accountWrapper.email;
                    component.set("v.accountWrapper", JSON.parse(JSON.stringify(component.get("v.accountWrapper"))));
                    console.log('****** accountWrapper-->', JSON.stringify(component.get("v.accountWrapper")));
                    component.set("v.toRenderView", "SelfRegister");
                },
                function(error){
                    console.log('***** error-->', error, '<--string ends');
                    if(error.indexOf('Required information is not populated in program. Please contact system admin.') !== -1) {
                        //component.set("v.toRenderView", "AccountNotFound"); 
                    } else {
                        component.set("v.showError", true); 
                        component.set("v.errorMessage", error); 
                    }
                }
            );
        }
    },
    backToSearchAccount : function(component, event, helper){
        let renderView = component.get("v.toRenderView");
        console.log('renderView--->'+renderView);
        if (renderView == 'FoundAccountView') {
            
            component.set("v.toRenderView", "SearchAccount"); 
            component.find("email_selfRegister").set("v.value","");
            component.find("dob_selfRegister").set("v.value","");
            component.find("ssn_selfRegister").set("v.value","");
        } else if (renderView == 'AccountNotFound') {
            component.set("v.toRenderView", "FoundAccountView"); 
        } else if (renderView == 'SelfRegister') {
            
            component.set("v.toRenderView", "FoundAccountView"); 
            component.find("password_selfRegister").set("v.value","");
            component.find("confirmPassword_selfRegister").set("v.value","");
            component.find("username_selfRegister").set("v.value","");
        }
        component.set("v.showError", false); 
        component.set("v.errorMessage", '');  
    },
    accountConfirmed : function(component, event, helper){
        let accountWrapper = component.get("v.accountWrapper");
        accountWrapper.userName = accountWrapper.email;
        component.set("v.accountWrapper", JSON.parse(JSON.stringify(component.get("v.accountWrapper"))));
        console.log('****** accountWrapper-->', JSON.stringify(component.get("v.accountWrapper")));
        component.set("v.toRenderView", "SelfRegister");  
    },
    accountNotConfirmed : function(component, event, helper){
        component.set("v.toRenderView", "AccountNotFound");  
    },
    registerUser : function(component, event, helper){
        helper.handleSelfRegister(component, event, helper);
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    },
    validateSSN  : function(component, event, helper) {
        var ssn = component.find("ssn_selfRegister").get("v.value");
        if(ssn.toString().length > 4) {
            //component.find("ssn").set("v.value",ssn.toString().substring(0, 4));
        }
    },
    handleDateChange : function(component, event, helper) {
        var dateSelector = event.getSource().getLocalId();
        console.log('****** dateSelector-->', dateSelector);
        console.log('**** get params-->', event.getParams());
        console.log('**** valud-->', event.getParam("value"));
        
        console.log('***** uiwrapperMap-->', component.get("v.uiwrapperMap.dateofBirth"));
    },
    redirectToLogin : function(component, event, helper) {
        let domainURL;
        let pathName = window.location.href.split('/s/');
        let uiwrapperMap = component.get("v.uiwrapperMap") || {};
        if(pathName.length > 1) {
            domainURL = pathName[0] + '/s/login/';
        }
        if(uiwrapperMap && uiwrapperMap.isSandbox) {
            if(pathName[1].split('portfolio=').length > 1) {
                let portfolioName = pathName[1].split('portfolio=')[1];
                if (portfolioName) {
                    domainURL += '?portfolio='+portfolioName;
                }
            }
        }
        var attributes = { url: domainURL};
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    }
})