({
	doInit : function(component, event, helper) {
		/*let domainURL = window.location.origin;
        
        let pathName = window.location.pathname.split('/');
        if(pathName.length > 1) {
            domainURL = domainURL + '/' + pathName[1];
        }
        */
        console.log("window.location.href",window.location.href);
        var domainName = window.location.href;
        domainName = domainName.replace("%40", "@");
        var fullURL = domainName.split("&");
        var userName1 =  (fullURL.length > 1) ? fullURL[1] : '';
        var userName = (userName1 != '') ? userName1.split('=')[1] : '';
        
        component.set("v.username",userName); 
        let domainURL; //= window.location.origin;
        
        let pathName = fullURL[0];//window.location.href.split('/s/');
        if(pathName.length > 1) {
            domainURL = pathName;
            console.log("domainURL@@@",domainURL);
        }
        /* Added for testing in UAT */
        console.log('**** domainURL-->', domainURL, '<--domainURL-->');
        console.log('**** portfolio url', window.location.search);
        let portfolioName = '';
        //let searchString = window.location.search;
        let searchString = domainURL;
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            
            console.log('**** portfolio url', searchString.split('portfolio='));
            portfolioName = searchString.split('portfolio=')[1];
        }
              
        /* END of Added for testing in UAT */
        console.log('domainURL===>@@@',domainURL);
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
	                component.set("v.uiwrapperMap", result);
	            },
	            null
	        );
		}
	}
})