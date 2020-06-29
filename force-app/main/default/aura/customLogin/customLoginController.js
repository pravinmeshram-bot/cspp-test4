({
	doInit : function(component, event, helper) {
		
        let domainURL; //= window.location.origin;
        
        let pathName = window.location.href.split('/s/');
        if(pathName.length > 1) {
            domainURL = pathName[0];
        }
        
        /* Added for testing in UAT */
        console.log('**** portfolio url', window.location.search);
        let portfolioName = '';
        let searchString = window.location.search;
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            
			//console.log('**** portfolio url', searchString.split('portfolio='));
            portfolioName = searchString.split('portfolio=')[1];
            
            console.log('**** portfolioName', portfolioName);

            portfolioName = portfolioName.replace(new RegExp("\\%20","g"),' ');
            portfolioName = portfolioName.replace(new RegExp("\\+","g"),' ');            
        }
        console.log('**** domainURL-->', domainURL, '<--domainURL-->');
        console.log('**** portfolioName-->', portfolioName);
        /* END of Added for testing in UAT */
        
		if(domainURL) {
			helper.callServerMethod(
	            component,
	            helper,
	            "getCustomPortalUIValues",                                       
	            {
	            	domainURL : domainURL,
                    portfolioName : portfolioName
	            },  
	            function(result) {
	                console.log('***** result', result);
	                component.set("v.uiwrapperMap", result);
	            },
	            null
	        );
		}
       
	},
    afterScriptsLoaded : function(component, event, helper) {
        console.log('One signal script is loaded.');
        console.log('window.globalInformation_onesignal.',window.globalInformation_onesignal);
    }
   
})