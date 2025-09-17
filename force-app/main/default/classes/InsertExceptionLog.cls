/**
 * @description                : Centralized server-side exception log persister using CustomMessage constants
 * @author                     : Akash Das
 * @group                      : Utilities
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
 * @last modification details  : Refactored to use CustomMessage constants
**/
public with sharing class InsertExceptionLog {

    // Wrapper for a single error log entry
    public class ErrorLogItem {
        public String errorType;
        public String errorMessage;
        public String stackTrace;
        public Id recordId;
        public String severity;

        public ErrorLogItem(String errorType, String errorMessage, String stackTrace, Id recordId, String severity) {
            this.errorType = errorType;
            this.errorMessage = errorMessage;
            this.stackTrace = stackTrace;
            this.recordId = recordId;
            this.severity = severity;
        }
    }

    /**
     * Logs a single error
     */
    @AuraEnabled
    public static void logError(String errorType, String errorMessage, String stackTrace, Id recordId, String severity) {
        System.debug(errorType + ' | ' + errorMessage + ' | ' + stackTrace + ' | ' + recordId + ' | ' + severity);
        logErrors(new List<ErrorLogItem>{
            new ErrorLogItem(errorType, errorMessage, stackTrace, recordId, severity)
        });
    }

    /**
     * Logs multiple errors in batch
     */
    @AuraEnabled
    public static void logErrors(List<ErrorLogItem> errorList) {
        if (errorList == null || errorList.isEmpty()) return;

        try {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            // Check if custom Error_Log__c exists using CustomMessage
            if (!globalDescribe.containsKey(CustomMessage.ERROR_LOG_OBJECT)) {
                System.debug('InsertExceptionLog: ' + CustomMessage.Error_Log_Object + ' object does not exist.');
                return;
            }

            List<Error_Log__c> logsToInsert = new List<Error_Log__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Error_Log__c.fields.getMap();

            for (ErrorLogItem item : errorList) {
                Error_Log__c logRecord = new Error_Log__c();

                if (fieldMap.containsKey(CustomMessage.ERROR_TYPE_FIELD) && item.errorType != null) {
                    logRecord.Error_Type__c = item.errorType;
                }
                if (fieldMap.containsKey(CustomMessage.ERROR_MESSAGE_FIELD) && item.errorMessage != null) {
                    logRecord.Error_Message__c = item.errorMessage;
                }
                if (fieldMap.containsKey(CustomMessage.STACK_TRACE_FIELD) && item.stackTrace != null) {
                    logRecord.Stack_Trace__c = item.stackTrace;
                }
                if (fieldMap.containsKey(CustomMessage.RECORD_ID_FIELD) && item.recordId != null) {
                    logRecord.Record_Id__c = item.recordId;
                }
                if (fieldMap.containsKey(CustomMessage.SEVERITY_FIELD) && item.severity != null) {
                    logRecord.Severity__c = item.severity;
                }

                logsToInsert.add(logRecord);
            }

            if (!logsToInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(logsToInsert, false);
                for (Database.SaveResult res : results) {
                    if (!res.isSuccess()) {
                        for (Database.Error err : res.getErrors()) {
                            System.debug('InsertExceptionLog failed for record: ' + err.getMessage());
                        }
                    }
                }
            }

        } catch (Exception ex) {
            System.debug('InsertExceptionLog outer exception: ' + ex.getMessage());
        }
    }
}
