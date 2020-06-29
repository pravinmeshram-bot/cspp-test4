@RestResource(urlMapping='/updateTaskStatus/*')
global class Prizm_UpdateTaskStatus{

    @HttpPost
    global static String updateTaskStatus() {
        
        String jsonStr;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if(!Test.isRunningTest()){
             jsonStr = RestContext.request.requestBody.toString();
        } else {
            List<TaskStatusWrapper> TaskWrapperList = new List<TaskStatusWrapper>();
            TaskStatusWrapper tW = new TaskStatusWrapper();
            tW.TaskId = [Select Id from Task limit 1].Id;
            tW.Status = 'Completed';
            TaskWrapperList.add(tW);
            jsonStr = JSON.serialize(TaskWrapperList);
        }
        List<TaskStatusWrapper> TaskWrapperList = (List<TaskStatusWrapper>)JSON.deserialize(jsonStr,List<TaskStatusWrapper>.class);
        
        List<Task> TaskList = new List<Task>();
        
        for(TaskStatusWrapper TaskWrap : TaskWrapperList){
            Task t = new Task();
            t.Id = TaskWrap.TaskId;
            t.Status = TaskWrap.Status;
            t.Description = TaskWrap.Description;
            TaskList.add(t);
            
        }
        if(TaskList.size()>0)
           Update TaskList;
        return 'true';
        
    }
    
    public class TaskStatusWrapper{
        public string TaskId;
        public String Status;
        public String Description;
        
        public TaskStatusWrapper(){
            TaskId = '';
            Status = '';
            Description = '';
        }
    }

}