@isTest
private class RecordControllerTest {

    @IsTest
    static void testGetRecords() {
        Account testAccount = new Account(Name = 'Test Account', Website = 'https://www.example.com', Phone = '9897472251');
        insert testAccount;

        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '123-456-7890');
        insert testContact;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert testOpportunity;

        List<Map<String, Object>> accountRecords = RecordController.getRecords('Account');
        System.assertEquals(1, accountRecords.size());
        System.assertEquals(testAccount.Id, accountRecords[0].get('Id'));

        List<Map<String, Object>> contactRecords = RecordController.getRecords('Contact');
        System.assertEquals(1, contactRecords.size());
        System.assertEquals(testContact.Id, contactRecords[0].get('Id'));

        List<Map<String, Object>> opportunityRecords = RecordController.getRecords('Opportunity');
        System.assertEquals(1, opportunityRecords.size());
        System.assertEquals(testOpportunity.Id, opportunityRecords[0].get('Id'));
    }

    @IsTest
    static void testUserHasRecordAccess() {
        Account testAccount = new Account(Name = 'Test Account', Phone = '9897472251');
        insert testAccount;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@test.com'
        );
        insert testUser;

        AccountShare testShare = new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = testUser.Id,
            AccountAccessLevel = 'Read',
            OpportunityAccessLevel = 'None',
            CaseAccessLevel = 'None'
        );
        insert testShare;

        System.runAs(testUser) {
            Boolean hasAccess = SharingChecker.userHasRecordAccess(testAccount.Id, 'Account');
            System.assertEquals(true, hasAccess, 'User should have access to the test record');
        }
    }

    @IsTest
    static void testUserHasRecordAccessExceptionHandling() {
        // Use a real record ID but an invalid object type to trigger exception
        Account dummyAccount = new Account(Name = 'Dummy',Phone = '9897472251');
        insert dummyAccount;

        // Pass a valid record Id with a fake object API name
        Test.startTest();
        Boolean result = SharingChecker.userHasRecordAccess(dummyAccount.Id, 'InvalidObjectName');
        Test.stopTest();
        System.assertEquals(false, result, 'Access check should return false when exception occurs due to invalid object');
    }
}