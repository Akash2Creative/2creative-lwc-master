/**
 * @description                : 
 * @author                     : Akash Das
 * @group                      : 
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
 * @last modification details  :  
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   09-16-2025   Akash Das   Initial Version
**/
public with sharing class CustomMessage {
    public static final String ERROR_TYPE_FIELD = 'Error_Type__c';
    public static final String ERROR_MESSAGE_FIELD = 'Error_Message__c';
    public static final String STACK_TRACE_FIELD = 'Stack_Trace__c';
    public static final String ERROR_LOG_OBJECT = 'Error_Log__c';
    public static final String RECORD_ID_FIELD = 'Record_Id__c';
    public static final String SEVERITY_FIELD = 'Severity__c';
    public static final String ACCOUNT_CONTROLLER_FETCH_ERROR = 'Unable to fetch Accounts. Please try again later.';
    public static final String ACCOUNT_CONTROLLER_SAVE_ERROR = 'Unable to save Account. Please try again later.';
    public static final String ACCOUNT_CONTROLLER_DELETE_ERROR = 'Unable to delete Account. Please try again later.';
    public static final String ACCOUNT_CONTROLLER_COUNT_ERROR = 'Unable to count Accounts. Please try again later.';
    public static final Integer MAX_PAGE_SIZE = 2000;
}