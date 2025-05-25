public with sharing class SharingChecker {
    public static Boolean userHasRecordAccess(Id recordId, String objectName) {
        try {
            String query = 'SELECT Id FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
            List<SObject> result = Database.query(query);

            // FIX: Access decision wrapper
            SObjectAccessDecision accessDecision = Security.stripInaccessible(AccessType.READABLE, result);
            List<SObject> filtered = accessDecision.getRecords();

            Boolean hasAccess = !filtered.isEmpty();

            System.debug('Access check for record: ' + recordId + ', object: ' + objectName + ' — hasAccess: ' + hasAccess);
            return hasAccess;
        } catch (QueryException qe) {
            System.debug('QueryException in access check: ' + qe.getMessage());
            return false;
        } catch (Exception e) {
            System.debug('Unexpected error in access check: ' + e.getMessage());
            return false;
        }
    }
}