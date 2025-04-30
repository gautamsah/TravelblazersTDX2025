public class AgentIAInvoker {
    @InvocableMethod(
        label='Get Booking Agent Response'
        description='Get response from agent based on the customer query'
    )
   public static List<AgentResponse> invokeAction(List<UserRequest> request) {
       AgentResponse response = new AgentResponse();
       try {
         	
           // Create an instance of the invocable action with type ‘generateAiAgentResponse’ and name ‘Agentforce_Service_Agent_new’
           Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', 'Travel_Booking_Agent');
          
           action.setInvocationParameter('userMessage', request[0].requestMessage);
          
           // Execute the action
           List<Invocable.Action.Result> results = action.invoke();
           Invocable.Action.Result result = results[0];

           // Handle the response
           if (result.isSuccess()) {
               response.responseMessage = (String)result.getOutputParameters().get('agentResponse');
               //System.debug('Output Session Id: ' + result.getOutputParameters().get('sessionId'));
               //System.debug('Output Agent Response: ' + result.getOutputParameters().get('agentResponse'));

           } else {
               response.responseMessage = JSON.serialize(result.getErrors());
           }
       } catch (Exception e) {
           response.responseMessage = e.getMessage();
       }
       return new List<AgentResponse>{response};
   }
    public class UserRequest {
        @InvocableVariable(
            required=true
            description='Request corresponding to hotels enquiry by user'
        )
        public String requestMessage;
    }
    public class AgentResponse {
        @InvocableVariable(
            description='Response returned by agent'
        )
        public String responseMessage;
    }
}