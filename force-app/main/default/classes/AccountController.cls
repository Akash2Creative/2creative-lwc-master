/**
 * @description                : Controller class responsible for managing Account records and related data in Salesforce.
*                                It provides Aura-enabled methods for Lightning components to perform CRUD operations
*                                and fetch related child records (Contacts and Opportunities) efficiently.
*
*                                Key functions include:
*                                - Fetching paginated Account records with search functionality.
*                                - Retrieving a single Account record with related Contacts and Opportunities by Id.
*                                - Saving and deleting Account records.
*                                - Counting Accounts based on search criteria.
*
*                                The class handles exceptions gracefully by logging errors and throwing user-friendly
*                                AuraHandledExceptions for better client-side error handling.
 * @author                     : Akash Das
 * @group                      : 
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
 * @last modification details  :  
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   09-16-2025   Akash Das   Initial Version
**/


public with sharing class AccountController extends BaseController {

    // Field list constant
    private static final String ACCOUNT_FIELDS = 
        'Id, Name, Type, Industry, Rating, Phone, Website, OwnerId, ' +
        '(SELECT Id, FirstName, LastName, Email, Phone FROM Contacts), ' +
        '(SELECT Id, Name, StageName, Amount, CloseDate FROM Opportunities)';

    /**
     * Fetch paginated Accounts based on search key
     * @param searchKey : string filter on Name
     * @param pageSize  : records per page
     * @param pageNumber: page index
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> getAccounts(String searchKey, Integer pageSize, Integer pageNumber) {
        try {
            List<SObject> rawRecords = fetchRecords(
                'Account',
                'Name',
                searchKey,
                pageSize,
                pageNumber,
                'LastModifiedDate DESC',
                ACCOUNT_FIELDS
            );
            return (List<Account>) rawRecords;
        } catch (Exception ex) {
            ExceptionLogger.log('AccountController.getAccounts', ex, null, ExceptionLogger.Severity.ERROR);
            throw new AuraHandledException(CustomMessage.ACCOUNT_CONTROLLER_FETCH_ERROR);
        }
    }

    /**
     * Fetch single Account by Id
     * @param accountId : Id of Account
     * @return Account
     */
    @AuraEnabled(cacheable=true)
    public static Account getAccountById(Id accountId) {
        try {
            return (Account) fetchById('Account', accountId, ACCOUNT_FIELDS);
        } catch (Exception ex) {
            ExceptionLogger.log('AccountController.getAccountById', ex, accountId, ExceptionLogger.Severity.ERROR);
            throw new AuraHandledException(CustomMessage.ACCOUNT_CONTROLLER_FETCH_ERROR);
        }
    }

    /**
     * Save Account record (insert or update)
     * @param acc : Account record
     * @return Id of saved Account
     */
    @AuraEnabled
    public static Id saveAccount(Account acc) {
        try {
            return saveRecord(acc);
        } catch (Exception ex) {
            ExceptionLogger.log('AccountController.saveAccount', ex, acc != null ? acc.Id : null, ExceptionLogger.Severity.ERROR);
            throw new AuraHandledException(CustomMessage.ACCOUNT_CONTROLLER_SAVE_ERROR);
        }
    }

    /**
     * Delete Account by Id
     * @param accountId : Id of Account
     */
    @AuraEnabled
    public static void deleteAccount(Id accountId) {
        try {
            deleteRecord(accountId, 'Account');
        } catch (Exception ex) {
            ExceptionLogger.log('AccountController.deleteAccount', ex, accountId, ExceptionLogger.Severity.ERROR);
            throw new AuraHandledException(CustomMessage.ACCOUNT_CONTROLLER_COUNT_ERROR);
        }
    }

    /**
     * Count Accounts for pagination
     * @param searchKey : optional string filter
     * @return Integer
     */
    @AuraEnabled(cacheable=true)
    public static Integer getAccountCount(String searchKey) {
        try {
            return countRecords('Account', 'Name', searchKey);
        } catch (Exception ex) {
            ExceptionLogger.log('AccountController.getAccountCount', ex, null, ExceptionLogger.Severity.ERROR);
            throw new AuraHandledException(CustomMessage.ACCOUNT_CONTROLLER_COUNT_ERROR);
        }
    }
}
