/**
 * @description                : Centralized exception logging utility
 * @author                     : Akash Das
 * @group                      : Utilities
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
 * @last modification details  : Refactored for 2Creative best practices
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   09-16-2025   Akash Das   Initial Version
 * 2.0   09-17-2025   Akash Das   Refactor for batch logging, severity, recordId support
**/
public with sharing class ExceptionLogger {

    public enum Severity { INFO, WARN, ERROR }

    /**
     * Logs a single exception with optional context and recordId
     * @param context    : Source of error (Class.Method or descriptive string)
     * @param ex         : The caught exception
     * @param recordId   : Optional primary record Id related to error
     * @param severity   : Optional severity level (INFO, WARN, ERROR). Default = ERROR
     */
    public static void log(String context, Exception ex, Id recordId, Severity severity) {
        if (ex == null) return;

        try {
            // Properly qualify enum reference for static context
            String sev = (severity != null) ? severity.name() : ExceptionLogger.Severity.ERROR.name();

            InsertExceptionLog.logErrors(new List<InsertExceptionLog.ErrorLogItem>{
                new InsertExceptionLog.ErrorLogItem(
                    ex.getTypeName(),
                    'Location: ' + context + ' | Message: ' + ex.getMessage(),
                    ex.getStackTraceString(),
                    recordId,
                    sev
                )
            });
        } catch (Exception loggerEx) {
            // Fallback debug log if even the logger fails
            System.debug('ExceptionLogger failed at ' + context + ': ' + loggerEx.getMessage());
        }
    }

    /**
     * Logs multiple exceptions in batch
     * @param context    : Source context for all exceptions
     * @param exceptions : List of exceptions to log
     * @param recordId   : Optional record Id associated
     * @param severity   : Severity level
     */
    public static void logBatch(String context, List<Exception> exceptions, Id recordId, Severity severity) {
        if (exceptions == null || exceptions.isEmpty()) return;

        List<InsertExceptionLog.ErrorLogItem> logItems = new List<InsertExceptionLog.ErrorLogItem>();
        String sev = (severity != null) ? severity.name() : ExceptionLogger.Severity.ERROR.name();

        for (Exception ex : exceptions) {
            logItems.add(new InsertExceptionLog.ErrorLogItem(
                ex.getTypeName(),
                'Location: ' + context + ' | Message: ' + ex.getMessage(),
                ex.getStackTraceString(),
                recordId,
                sev
            ));
        }

        try {
            InsertExceptionLog.logErrors(logItems);
        } catch (Exception loggerEx) {
            System.debug('ExceptionLogger batch failed at ' + context + ': ' + loggerEx.getMessage());
        }
    }
}
