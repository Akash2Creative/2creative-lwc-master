/**
 * @description                : The BaseController class is designed as a reusable Apex utility class providing generic 
 *                               CRUD operations for Salesforce sObjects. It includes methods to perform:
 *                                - Record retrieval by ID (fetchById) with field and sharing enforcement,
 *                                - Filtered record fetching with optional pagination (fetchRecords),
 *                                - Grouped record counting (countRecords)
 *                                - Upsert operation (saveRecord), and
 *                                - Record deletion by ID (deleteRecord).
 *
 *                              This class supports dynamic sObject types and field sets via parameters, 
 *                              enabling broad applicability across different Salesforce objects without specific customization. 
 *                              It facilitates common operations while enforcing record-level security and sharing rules.
 * 
 * @author                     : Akash Das
 * @group                      : Utilities
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
**/
public virtual with sharing class BaseController {

    /**
     * Generic fetch with pagination and optional search
     * @param objectName : API name of object
     * @param searchField: Field API name to filter
     * @param searchKey  : Search string
     * @param pageSize   : Number of records per page
     * @param pageNumber : Page index (1-based)
     * @param orderBy    : Field(s) to sort by
     * @param fields     : Comma-separated list of fields to return
     * @return List<SObject> : Paginated result
     */
    public static List<SObject> fetchRecords(
        String objectName,
        String searchField,
        String searchKey,
        Integer pageSize,
        Integer pageNumber,
        String orderBy,
        String fields
    ) {
        try {
            pageSize = (pageSize == null || pageSize <= 0) ? 10 : Math.min(pageSize, CustomMessage.MAX_PAGE_SIZE);
            pageNumber = (pageNumber == null || pageNumber <= 0) ? 1 : pageNumber;
            orderBy = String.isBlank(orderBy) ? 'LastModifiedDate DESC' : orderBy;
            fields = String.isBlank(fields) ? 'Id' : fields;

            String key = String.isBlank(searchKey) ? '%' : '%' + searchKey + '%';
            Integer offsetValue = (pageNumber - 1) * pageSize;

            String soql = 'SELECT ' + fields +
              ' FROM ' + objectName +
              ' WHERE ' + searchField + ' LIKE :key ' +
              ' WITH SECURITY_ENFORCED ' +
              ' ORDER BY ' + orderBy +
              ' LIMIT ' + pageSize +
              ' OFFSET ' + offsetValue;

            return Database.query(soql);

        } catch (Exception ex) {
            ExceptionLogger.log('BaseController.fetchRecords', ex, null, ExceptionLogger.Severity.ERROR);
            return new List<SObject>();
        }
    }

    /**
     * Fetch a record by Id
     */
    public static SObject fetchById(String objectName, Id recordId, String fields) {
        if (recordId == null) throw new AuraHandledException('Record Id is required.');
        fields = String.isBlank(fields) ? 'Id' : fields;
        try {
            String soql = 'SELECT ' + fields + ' FROM ' + objectName +
                          ' WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1';
            return Database.query(soql);
        } catch (Exception ex) {
            ExceptionLogger.log('BaseController.fetchById', ex, recordId, ExceptionLogger.Severity.ERROR);
            return null;
        }
    }

    /**
     * Save record (insert/update)
     */
    public static Id saveRecord(SObject record) {
        if (record == null) throw new AuraHandledException('Record is required.');
        try {
            Database.UpsertResult result = Database.upsert(record, false); // allOrNone=false for bulk
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    ExceptionLogger.log('BaseController.saveRecord', new LoggedException(err.getMessage()), record.Id, ExceptionLogger.Severity.ERROR);
                }
            }
            return record.Id;
        } catch (Exception ex) {
            ExceptionLogger.log('BaseController.saveRecord', ex, record.Id, ExceptionLogger.Severity.ERROR);
            return null;
        }
    }

    /**
     * Delete record by Id
     */
    public static void deleteRecord(Id recordId, String objectName) {
        if (recordId == null) throw new AuraHandledException('Record Id is required.');
        try {
            String soql = 'SELECT Id FROM ' + objectName + ' WHERE Id = :recordId WITH SECURITY_ENFORCED';
            SObject record = Database.query(soql);
            Database.DeleteResult result = Database.delete(record, false); // allOrNone=false
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    ExceptionLogger.log('BaseController.deleteRecord', new LoggedException(err.getMessage()), recordId, ExceptionLogger.Severity.ERROR);
                }
            }
        } catch (Exception ex) {
            ExceptionLogger.log('BaseController.deleteRecord', ex, recordId, ExceptionLogger.Severity.ERROR);
        }
    }

    /**
     * Count records matching searchKey
     */
    public static Integer countRecords(String objectName, String searchField, String searchKey) {
        try {
            String key = String.isBlank(searchKey) ? '%' : '%' + searchKey + '%';
            String soql = 'SELECT COUNT() FROM ' + objectName +
                          ' WHERE ' + searchField + ' LIKE :key WITH SECURITY_ENFORCED';
            return (Integer) Database.countQuery(soql);
        } catch (Exception ex) {
            ExceptionLogger.log('BaseController.countRecords', ex, null, ExceptionLogger.Severity.ERROR);
            return 0;
        }
    }
}
