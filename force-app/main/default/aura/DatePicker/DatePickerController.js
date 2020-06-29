({
    doInit: function(component, event, helper) {
        
        for (var i = 0; i < 41; i++) {
            var cellCmp = component.find(i);
            if (cellCmp) {
                cellCmp.addEventHandler("dateCellClick", component.getReference("c.handleClick"));
            }
        }
        var format = component.get("v.formatSpecifier");
        var datestr = component.get("v.value");
        var langLocale = $A.get("$Locale.langLocale");
        
        var currentDate = helper.parseInputDate(component, datestr);
        helper.setDateValues(component, currentDate, currentDate.getDate());
        
        //used prevent dates earlier than min being selected
        var minDateRaw = component.get("v.min");
        if (minDateRaw) {
            component.set("v.minDate", helper.parseInputDate(component, minDateRaw));
        }
        // Set the first day of week
        helper.updateNameOfWeekDays(component);
        helper.generateYearOptions(component, currentDate);
        
        var setFocus = component.get("v.setFocus");
        if (!setFocus) {
            component.set("v._setFocus", false);
        }
        helper.renderGrid(component);
        //addition caspar 2016-12-14
        component.set("v.date", currentDate.getDate());
        if (!$A.util.isEmpty(datestr)) {
            $A.util.removeClass(component.find('clear-button'), 'slds-hide');
        }
    },
    // handleManualDateChange: function(component, event, helper) {
    //   helper.handleManualDateChange(component);
    // },
    handleManualInput: function(component, event, helper) {
        helper.handleManualInput(component, event);
    },
    handleYearChange: function(component, event, helper) {
        console.log('year change');
        var newYear = event.getParam("data");
        var date = component.get("v.date");
        helper.changeYear(component, newYear, date);
    },
    handleClick: function(component, event, helper) {
        console.log('Date picker controller click' + event);
        var overlayDiv = component.find("overlayDiv");
        if(overlayDiv) {
            $A.util.removeClass(overlayDiv, 'sidenav-overlay');
            console.log('**** overlayDiv-->', overlayDiv);
        }
        var grid = component.find('grid');
        console.log('**** drid-->', grid);
        if (grid) {
            console.log('**** drid--> after class');
            $A.util.addClass(grid, "slds-hide");
        }
        //show the clear button
        if (!$A.util.isEmpty(component.get("v.value"))) {
            $A.util.removeClass(component.find('clear-button'), 'slds-hide');
        }
        helper.selectDate(component, event);
    },
    handleClearDate: function(component, event, helper) {
        
        helper.clearDate(component);
        $A.util.addClass(component.find('clear-button'), 'slds-hide');
        //event.stopPropagation();
        event.preventDefault();
        return false;
    },
    goToToday: function(component, event, helper) {
        event.stopPropagation();
        helper.goToToday(component, event);
        return false;
    },
    goToPreviousMonth: function(component, event, helper) {
        event.stopPropagation();
        helper.changeMonth(component, -1);
        return false;
    },
    goToNextMonth: function(component, event, helper) {
        event.stopPropagation();
        helper.changeMonth(component, 1);
        return false;
    },
    handleInputFocus: function(component, event, helper) {
        
        console.log('***** hand;le input focus handled');
        var overlayDiv = component.find("overlayDiv");
        if(overlayDiv) {
            $A.util.addClass(overlayDiv, 'sidenav-overlay');
            console.log('**** overlayDiv-->', overlayDiv);
        }
        let grid = component.find("grid");
        if(grid) {
            $A.util.removeClass(grid, 'slds-hide');
            $A.util.removeClass(grid, 'slds-transition-hide');
        }
    },
    hideDatePicker : function(component, event, helper) {
        console.log('***** hide date picker method called');
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    console.log('*** before grid condition-->');
                    var grid = component.find("grid");
                    if(grid) {
                        $A.util.addClass(grid, 'slds-hide');
                    }
                    var overlayDiv = component.find("overlayDiv");
                    if(overlayDiv) {
                        console.log('*** before grid condition-->', overlayDiv);
                        $A.util.removeClass(overlayDiv, 'sidenav-overlay');
                    }
                }
            }), 0
        );
    },
    checkDateIsValid : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('**** params', params);
        console.log('**** params', params.callback);
        if(params && params.callback ) {
            console.log('*** insdie if');
            let errorMessage = '', selectedValue = component.get("v.value");
            if(!selectedValue) {
                errorMessage = 'Date cannot be blank';
            }
            console.log('*** error-->', errorMessage, selectedValue);
            if(selectedValue) {
                var dateRegEx = /^\d{4}(\-)(((0)[0-9])|((1)[0-2]))(\-)([0-2][0-9]|(3)[0-1])$/;
                console.log('**** ==>', selectedValue.match(dateRegEx));
                if(!selectedValue.match(dateRegEx)) {
                    errorMessage = 'Date should be in MM/dd/yyyy format';
                }
            }
            console.log('**** errorMessage-->', errorMessage);
            params.callback(errorMessage);
        }
    }
});