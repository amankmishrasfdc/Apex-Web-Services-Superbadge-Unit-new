public with sharing class selectedAccountCsvController {
    
    public selectedAccountCsvController() {
        // Constructor
    }
    
    // Method to fetch related contacts for a given Account
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id accountId) {
        if(accountId == null) {
            return null;
        }
        try {
            return [SELECT Id, AccountId, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId = :accountId];
        } catch (Exception ex) {
            throw new AuraHandledException('Issue with fetching related contacts: ' + ex.getMessage());
        }
    }

    // Method to upload a CSV file and associate it with the Account
    @AuraEnabled
    public static void uploadFileToAccount(String accountId, String csvData, String fileName) {
        try {
            // Create ContentVersion record for the CSV file
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = Blob.valueOf(csvData);
            contentVersion.IsMajorVersion = true;
            insert contentVersion;
            
            // Get the ContentDocumentId from ContentVersion
            ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id LIMIT 1];
            
            // Create ContentDocumentLink to link the file to the Account
            ContentDocumentLink documentLink = new ContentDocumentLink();
            documentLink.ContentDocumentId = contentDocument.Id;
            documentLink.LinkedEntityId = accountId;  // Link to the Account record
            documentLink.ShareType = 'V'; // Viewer access
            insert documentLink;
            
        } catch (Exception e) {
            System.debug('Error uploading file: ' + e.getMessage());
            throw new AuraHandledException('Error uploading file to Account: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void sendEmailWithCsvAttachment(Id accountId, String csvData, String fileName) {
        try {
            Account account = [SELECT Id, Owner.Email FROM Account WHERE Id = :accountId LIMIT 1];
            if (account.Owner.Email != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { account.Owner.Email });
                mail.setSubject('CSV Export of Contacts');
                mail.setPlainTextBody('Please find the attached CSV file of the contacts related to your account.');
                
                // Attach the CSV file
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(fileName);
                attachment.setBody(Blob.valueOf(csvData));
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error sending email: ' + ex.getMessage());
        }
    }
}
