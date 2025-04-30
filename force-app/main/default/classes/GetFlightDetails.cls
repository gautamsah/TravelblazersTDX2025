public without Sharing class GetFlightDetails {
	@InvocableMethod(label='Get Available flights' description='Returns the list of available flights' category='Product')
	public static List<List<flightResponse>> getAvailableFlights(List<flightRequest> requests) {
		Date journeyDate = requests[0].journeyDate;
        String departureLocation =requests[0].departureLocation;
        String arrivalLocation = requests[0].arrivalLocation;
        String airline = requests[0].airline;

        List<Product2> flightDetails = new List<Product2>();
        if(!String.isBlank(airline)){
            flightDetails = [SELECT Id, Name, TDX_Asset__c,Quantity__c, Arrival_Time__c, Departure_Time__c, TDX_Asset__r.Name, Product_Final_Unit_Price__c, Description , (SELECT Id, Start_Date__c, End_Date__c, Booked_Slots__c, Available_Slots__c FROM Booked_Dates__r WHERE Journey_Date__c =: journeyDate) FROM Product2 WHERE TDX_Asset__r.Name =: airline And Departure_Location__c =:departureLocation AND Arrival_Location__c =:arrivalLocation];
        }
        else{
            flightDetails = [SELECT Id, Name, TDX_Asset__c,Quantity__c, Arrival_Time__c, Departure_Time__c, TDX_Asset__r.Name, Product_Final_Unit_Price__c, Description , (SELECT Id, Start_Date__c, End_Date__c, Booked_Slots__c, Available_Slots__c FROM Booked_Dates__r WHERE Journey_Date__c =: journeyDate) FROM Product2 WHERE Departure_Location__c =:departureLocation AND Arrival_Location__c =:arrivalLocation];
        
        }
        List<flightResponse> flightList= new List<flightResponse>();
        if(!flightDetails.isEmpty()) {
            List<Booked_Date__c> bookedflight = new List<Booked_Date__c>();
            for(Product2 flight : flightDetails){
                bookedflight = flight.Booked_Dates__r;
                if(flight.Quantity__c > bookedflight.size()){
                    flightResponse hr = new flightResponse();
                    hr.airline = flight.TDX_Asset__r.Name;
                    hr.departureTime = flight.Departure_Time__c;
                    hr.arrivalTime = flight.Arrival_Time__c;
                    hr.price = (Integer)flight.Product_Final_Unit_Price__c;
                    hr.flightName = flight.Name;
                    flightList.add(hr);
                }
                
            }
           
        }
        return new List<List<flightResponse>>{ flightList };
    }
    public class flightRequest {
        @InvocableVariable(
            required=true
            description='Journey Date for which we want to check the flight. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date journeyDate;
        @InvocableVariable(
            required=true
            description='Departure Location of flight'
        )
        public String departureLocation;
        @InvocableVariable(
            required=true
            description='Arrival Location of flight'
        )
        public String arrivalLocation;
        @InvocableVariable(
            description='Name of airline for which user want to search the flight'
        )
        public String airline;
    }

    public class flightResponse {
        @InvocableVariable(
            description='Name of Airline'
        )
        public String airline;
        @InvocableVariable(
            description='Departure Time of flight'
        )
        public Time departureTime;
        @InvocableVariable(
            description='Arrival Time of flight'
        )
        public Time arrivalTime;
        @InvocableVariable(
            description='price of flight'
        )
        public Integer price;
        @InvocableVariable(
            description='Name of Flight. It just like the flight Code Number'
        )
        public String flightName;
    }
}