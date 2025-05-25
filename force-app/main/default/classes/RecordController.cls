public without sharing class RecordController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRecords(String objectName) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        String query;
        
        Map<String, String> objectSpecificFields = new Map<String, String>{
            'Account'     => 'Website',
                'Contact'     => 'Phone',
                'Opportunity' => 'Amount'
                };
                    
                    // Validate object type
                    if (!objectSpecificFields.containsKey(objectName)) {
                        throw new AuraHandledException('Invalid object type');
                    }
        
        // Common fields for all objects
        String commonFields = 'Id, Name, Owner.Name, CreatedBy.Name, LastModifiedBy.Name, CreatedDate, LastModifiedDate';
        
        // Build final SOQL query
         query = 'SELECT ' + commonFields;
        
        if (!String.isBlank(objectSpecificFields.get(objectName))) {
            query += ', ' + objectSpecificFields.get(objectName);
        }
        
        query += ' FROM ' + objectName +
            ' ORDER BY LastModifiedDate DESC LIMIT 50';
        
        
        // Fetch the records
        List<SObject> records = Database.query(query);
        
        // Process each record
        for (SObject record : records) {
            Map<String, Object> entry = new Map<String, Object>();
            Id recordId = (Id) record.get('Id');
            String recordName = (String) record.get('Name');
            
            // Determine access
            Boolean hasAccess = SharingChecker.userHasRecordAccess(recordId, objectName);
            
            // Add common fields
            entry.put('Id', recordId);
            entry.put('Name', recordName);
            entry.put('hasAccess', hasAccess);
            entry.put('accessIcon', hasAccess ? null : 'utility:lock');
            
            // If accessible, add more details
            if (hasAccess) {
                entry.put('OwnerName', ((SObject)record.getSObject('Owner'))?.get('Name'));
                entry.put('CreatedByName', ((SObject)record.getSObject('CreatedBy'))?.get('Name'));
                entry.put('LastModifiedByName', ((SObject)record.getSObject('LastModifiedBy'))?.get('Name'));
                entry.put('CreatedDate', record.get('CreatedDate'));
                entry.put('LastModifiedDate', record.get('LastModifiedDate'));
                
                if (objectName == 'Account') {
                    entry.put('Website', record.get('Website'));
                } else if (objectName == 'Contact') {
                    entry.put('Phone', record.get('Phone'));
                } else if (objectName == 'Opportunity') {
                    entry.put('Amount', record.get('Amount'));
                }
            }
            
            results.add(entry);
        }
        
        return results;
    }
}