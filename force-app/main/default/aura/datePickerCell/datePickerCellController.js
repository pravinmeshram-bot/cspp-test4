({
    handleCellClick : function(component, event, helper) {
        console.log('**** cell clikced');
        var click = component.getEvent("dateCellClick");
        console.log('Datecell controller click' + click);
        click.fire();
        
    }
})