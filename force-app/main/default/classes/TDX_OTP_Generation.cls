public without sharing class TDX_OTP_Generation {

    private static final Integer OTP_LENGTH = 6;
    private static final Integer OTP_EXPIRATION_MINUTES = 2;
    private static final Integer MAX_VERIFICATION_ATTEMPTS = 3;

    @InvocableMethod(label='Generate OTP' description='This method generates the OTP' category='OTP')
    public static List<String> generateOTP(List<String> agencyIdList) {
        List<String> result = new List<String>();
        System.debug('Entered generateOTP with agencyIdList: ' + agencyIdList);

        try {
            String plainOTP = generateRandomOTP(OTP_LENGTH);
            System.debug('Generated OTP: ' + plainOTP);

            User currentUser = [
                SELECT Id, Email 
                FROM User 
                WHERE Agency_Id__c = :agencyIdList[0] 
                LIMIT 1
            ];
            System.debug('Retrieved User: ' + currentUser);

            // Check if OTP record exists for this user
            // OtpCustomSetting__c.getInstance(UserInfo.getUserId());
            OTP__c existingOtp;
            try {
                //existingOtp = [
                //    SELECT Id, OTP_Code__c, Expiration_Time__c, No_of_Trials__c, Is_Expired__c FROM OTP__c WHERE SetupOwnerId = :currentUser.Id
                //    LIMIT 1];
                existingOtp = OTP__c.getInstance(currentUser.Id);
                System.debug('Existing OTP record found: ' + existingOtp);
            } catch (Exception e) {
                System.debug('No existing OTP record found. Creating a new one.');
                existingOtp = null;
            }

            //if (existingOtp == null) {
              //  existingOtp = new OTP__c(Name = String.valueOf(currentUser.Id));
                //System.debug('New OTP record initialized: ' + existingOtp);
            //}
            if (existingOtp == null) {
            existingOtp = new OTP__c();
        	}

            existingOtp.OTP_Code__c = plainOTP;
            existingOtp.Expiration_Time__c = System.now().addMinutes(OTP_EXPIRATION_MINUTES);
            existingOtp.No_of_Trials__c = 0;
            existingOtp.Is_Expired__c = false;

            if (existingOtp.Id == null) {
                insert existingOtp;
                System.debug('Inserted new OTP record: ' + existingOtp);
            } else {
                update existingOtp;
                System.debug('Updated existing OTP record: ' + existingOtp);
            }

            sendOTP(currentUser.Email, plainOTP);
            System.debug('OTP email sent successfully.');

            result.add('OTP generated successfully');

        } catch (Exception e) {
            System.debug('Error occurred in generateOTP: ' + e.getMessage());
            result.add('Failed to generate OTP: ' + e.getMessage());
        }

        System.debug('Exiting generateOTP with result: ' + result);
        return result;
    }

    private static String generateRandomOTP(Integer length) {
        String otp = '';
        for (Integer i = 0; i < length; i++) {
            otp += String.valueOf(Math.round(Math.random() * 9));
        }
        System.debug('Inside generateRandomOTP: ' + otp);
        return otp;
    }

    private static void sendOTP(String toAddress, String otp) {
        System.debug('Preparing to send OTP email to: ' + toAddress);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{toAddress});
        mail.setSubject('Your One-Time Password');
        mail.setPlainTextBody('Your one-time password is: ' + otp + '. This OTP will expire in ' + OTP_EXPIRATION_MINUTES + ' minutes.');

        OrgWideEmailAddress[] oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'gsah@horizontal.com' LIMIT 1];
        if (!oweaList.isEmpty()) {
            mail.setOrgWideEmailAddressId(oweaList[0].Id);
            System.debug('Using Org-Wide Email Address: ' + oweaList[0].Id);
        } else {
            System.debug('Org-Wide Email Address not found or not verified.');
        }

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            System.debug('Email sent successfully to ' + toAddress);
        } catch (Exception e) {
            System.debug('Error sending OTP email: ' + e.getMessage());
            throw new AuraHandledException('Failed to send OTP email.');
        }
    }
}