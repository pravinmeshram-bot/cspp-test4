global class TaskTabCtrl {
	public Task tsk;
    public static String sortBy {get;set;}
    private boolean sortAscending {get;set;}
    public string titleStr {get; set;}
    public list<TaskModel> tmList {get; set;}
    
    public TaskTabCtrl(ApexPages.StandardController Ctrl){
        tsk = (task)Ctrl.getRecord();
        tmList=new list<TaskModel>();
        titleStr='';
        searchTasks();
    }
    
    public void searchTasks(){
        tmList=new list<TaskModel>();
        String strSoql = 'SELECT ActivityDate, OwnerId, SOP__c, SOP__r.Title, Status, Subject, RecordTypeId, CreatedById';
        strSoql += ' FROM task Where SOP__c != \'\'';
        if(titleStr != null && titleStr.trim().length()>0){
            String tempStr = '%'+titleStr+'%';
            strSoql += ' AND SOP__r.Title like: tempStr';
        }
        strSoql += ' Order By ActivityDate DESC, SOP__r.Title limit 1000';
        List<Task> tsks = Database.Query(strSoql);
        System.debug('######Tasksize: ' + tsks.size());
        if(tsks != null && tsks.size()>0){
            Integer i=1;
            for(Task t: tsks){
                tmList.add(new TaskModel(String.valueOf(i), t));
                i++;
            }
        }
    }
    
    public void sortActivities() {    	
        try {
            //Check to see if the same column was clicked, if so, reverse the sort order        
            sortBy = ApexPages.currentPage().getParameters().get('sortBy');
            if(tsk.Subject == sortBy) {
                sortAscending = !sortAscending;
            } else {
                sortAscending = true;
            }
            
            //Use the tsk.Subject object to store the previous column click
            tsk.Subject = sortBy;
            tmList.sort();
            //If ascending = false, reverse the order of the results to be in descending order
            if(!sortAscending) {
                list<TaskModel> cloneList = tmList.clone();
                Integer size = tmList.size();
                for(Integer i=0; i < size; i++) {
                    tmList[i] = cloneList[size-1-i];
                }
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
        }
    }
    
    global Class TaskModel implements Comparable{
        public String SrNo {get; set;}
        public Task tsk {get; set;}
        public Date dueDate {get; set;}
        public String title {get; set;}
        public String status {get; set;}

        public TaskModel(String srNo, Task tsk){
            this.srNo=srNo;
            this.tsk=tsk;
            this.dueDate=tsk.ActivityDate;
            this.title=tsk.SOP__r.Title;
            this.status=tsk.Status;
        }
        
        // Implement the compareTo() method
        global Integer compareTo(Object compareTo) {
            TaskModel compareToTM = (TaskModel)compareTo;
			if(sortBy == 'dueDate'){
                if(dueDate == null && compareToTM.dueDate == null)
                    return 0;
                if(dueDate == null)
                    return 1;
                if(compareToTM.dueDate == null)
                    return -1;
                if(dueDate < compareToTM.dueDate)
                    return -1;
                if(dueDate > compareToTM.dueDate)
                    return 1;
                return 0;
            }else if(sortBy == 'title'){
				if(title == null && compareToTM.title == null)
                    return 0;
                if(title == null)
                    return 1;
                if(compareToTM.title == null)
                    return -1;
                return title.compareTo(compareToTM.title);
            }else if(sortBy == 'status'){
                if(status == null && compareToTM.status == null)
                    return 0;
                if(status == null)
                    return 1;
                if(compareToTM.status == null)
                    return -1;
                return status.compareTo(compareToTM.status);
            }
            return 0;
        }
        
        // Implement the compareTo() method
        /*global String compareTo(Object compareTo) {
            TaskModel compareToTM = (TaskModel)compareTo;
            if (tsk.SOP__r.Title == compareToTM.tsk.SOP__r.Title) return '0';
            if (tsk.SOP__r.Title > compareToTM.tsk.SOP__r.Title) return '1';
            return '-1';        
        }*/
    }
}