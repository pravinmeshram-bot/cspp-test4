global class TaskViewController {
    
    public Id parentId {get; set;}
    public String taskCallType {get; set;}
    
    public Date today {get; set;}
    
    private List<TaskWraper> taskList;
    
    
    @RemoteAction
    global static List<TaskWraper> getTaskList(String parentId) {
        Date activityDateFilter = System.Date.today().addDays(14);
        List<Task> taskList = [SELECT Id, Subject, Status, ActivityDate, Call_Type__c FROM Task WHERE IsDispositionTask__c = false AND Call_Type__c != null AND WhatId = :parentId AND Status != 'Completed' and  ActivityDate <=:activityDateFilter ];
        List<TaskWraper> taskWraperList = new List<TaskWraper>();
        
        for(Task task : taskList) {
            taskWraperList.add(new TaskWraper(task));
        }
        return taskWraperList;
    }
    
    public TaskViewController() {
        this.today = System.today();
    }
    
    global class TaskWraper {
        public String subject {get; set;}
        public Id taskId {get; set;}
        public String callType {get; set;}
        public String dueDate {get; set;}
        public String color {get; set;}
        public Boolean openTask {get; set;}
        public String status {get; set;}
        
        public TaskWraper(Task task) {
            this.openTask = false;
            
            this.subject = task.Subject;
            this.taskId = task.Id;
            this.callType = task.Call_Type__c;
            this.dueDate = TaskViewController.toDateString(task.ActivityDate, 'MM/dd/YYYY');
            this.status = task.Status;
            
            if(this.status != 'Completed') {
                this.openTask = true;
                if(task.ActivityDate != null && task.ActivityDate < System.today()) {
                    this.color = 'over-due';
                }else if(task.ActivityDate != null && (task.ActivityDate >= System.today() && task.ActivityDate <= System.Date.today().addDays(7)) && task.ActivityDate == System.today()) {
                    //This Week
                    this.color = 'this-week-today';
                }else if(task.ActivityDate != null && (task.ActivityDate >= System.Date.today().addDays(7) && task.ActivityDate <= System.Date.today().addDays(14))) {
                    //Next Week
                    this.color = 'next-week';
                }else if(task.ActivityDate != null && task.ActivityDate > System.today()){
                    
                    this.color='future';
                    
                }else {
                    this.color = 'due';
                }
            }
        }
    }
    
    public static String toDateString(Date activityDate, String dateFormat) {
        if(activityDate != null) {
            DateTime dt = DateTime.newInstance(activityDate.year(), activityDate.month(), activityDate.day());
            return dt.format(dateFormat);
        }
        return '';
    }
    
    @RemoteAction
    global static void closeTask(Id taskId) {
        Task currentTask = new Task(Id = taskId);
        currentTask.Status = 'Completed';
        update currentTask;
    }
    
}