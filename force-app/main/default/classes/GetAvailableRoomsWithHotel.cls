public class GetAvailableRoomsWithHotel {
	@InvocableMethod(label='Get Available Rooms in Hotel' description='Returns the list of available Rooms in user selected hotel' category='Product')
	public static List<List<RoomResponse>> getAvailableHotels(List<RoomRequest> requests) {
		Date startDate = requests[0].startDate;
        Date endDate =requests[0].endDate;
        String hotelName = requests[0].hotelName;

        List<Product2> roomDetails = [SELECT Id, Name, ProductCode, TDX_Asset__c, TDX_Asset__r.Name, TDX_Asset__r.City__c, Room_Type__c, Hotel_Product_Type__c, Product_Final_Unit_Price__c, Max_No_Of_Guest__c, Description , (SELECT Id, Start_Date__c, End_Date__c, Booked_Slots__c, Available_Slots__c FROM Booked_Dates__r WHERE Start_Date__c >=:startDate AND End_Date__c <=:endDate) FROM Product2 WHERE TDX_Asset__r.Name =: hotelName];
		
        List<RoomResponse> roomList= new List<RoomResponse>();
        if(!roomDetails.isEmpty()) {
            for(Product2 room : roomDetails){
                RoomResponse hr = new RoomResponse();
                hr.RoomName = room.Name;
                hr.price = (Integer)room.Product_Final_Unit_Price__c;
                roomList.add(hr);
            }
           
        }
        return new List<List<RoomResponse>>{ roomList };
    }
    public class RoomRequest {
        @InvocableVariable(
            required=true
            description='Check In Date for which we want to check the hotel. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date startDate;
        @InvocableVariable(
            required=true
            description='Check out Date for which we want to check the hotel. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date endDate;
        @InvocableVariable(
            required=true
            description='Name of hotel from which room will be displayed'
        )
        public String hotelName;
    }

    public class RoomResponse {
        @InvocableVariable(
            description='Name of Room Type'
        )
        public String RoomName;
        @InvocableVariable(
            description='Number of person can stay in that room'
        )
        public Integer price;
    }
}