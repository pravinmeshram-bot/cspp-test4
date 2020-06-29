({
	initialized : function() {
	let searchHerfString = window.location.href;	
        let UserName = window.localStorage.getItem(searchHerfString) || "[]";	
        UserName = JSON.parse(UserName);
        if(UserName != null)
        component.set('v.isUserLoggedIn',true);
	}
})