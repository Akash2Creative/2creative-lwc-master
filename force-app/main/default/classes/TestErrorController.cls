public with sharing class TestErrorController {
    @AuraEnabled
    public static void throwError() {
        // Intentionally throw an exception
        throw new AuraHandledException('This is a test Apex error!');
    }
}