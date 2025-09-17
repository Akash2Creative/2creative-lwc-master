# Salesforce LWC + Apex Boilerplate

## Overview
This boilerplate provides a reusable architecture for **Lightning Web Components (LWC)** and **Apex controllers** with a focus on:

- Standardized **CRUD operations** via `BaseController`.
- **Centralized error handling** for both client-side and server-side errors.
- Paginated, searchable data tables.
- **Reusable utility services** for API calls and error logging.
- Compliance with **CloudKaptan best practices** for LWC and Apex development.

---

## Table of Contents
1. [Architecture](#architecture)
2. [Apex Utilities](#apex-utilities)
3. [Lightning Web Components](#lightning-web-components)
4. [Error Handling Framework](#error-handling-framework)
5. [Usage](#usage)
6. [Best Practices](#best-practices)
7. [Changelog](#changelog)

---

## Architecture

LWC (UI Layer)
│
├─ ErrorBoundary
│ └─ Catches UI errors, delegates to errorService
│
├─ AccountList
│ └─ Paginated, searchable Lightning Datatable
│ └─ Calls API via apiService → Apex
│
Utility Services
├─ apiService.js → Wraps Apex / Fetch calls
├─ errorService.js → Normalizes errors, displays toast, logs server-side
├─ errorHandler.js → LWC-level error normalization
├─ messages.js → Constants for error types, severity, and default messages

Apex Controllers
├─ BaseController → Generic CRUD, fetch with pagination, count, delete
├─ AccountController → Example controller for Accounts
├─ InsertExceptionLog → Persists errors to Error_Log__c
├─ ExceptionLogger → Centralized logging wrapper
├─ CustomMessage → Error messages and constants
├─ LoggedException → Custom exception type


---

## Apex Utilities

### **BaseController**
- Provides generic CRUD and query utilities:
  - `fetchRecords()`: Paginated queries with `SECURITY_ENFORCED`.
  - `fetchById()`: Fetch single record by ID.
  - `saveRecord()`: Insert/Update record.
  - `deleteRecord()`: Delete record by ID.
  - `countRecords()`: Count records matching a search key.

### **InsertExceptionLog**
- Persists error logs in **Error_Log__c**.
- Supports **batch inserts** and individual logging.
- Uses `CustomMessage` constants for field references.

### **ExceptionLogger**
- Wraps exceptions and forwards them to `InsertExceptionLog`.
- Handles optional **severity** and **recordId** context.

### **CustomMessage**
- Central repository for field names, default messages, max page sizes, etc.

---

## Lightning Web Components

### **ErrorBoundary**
- Wraps child components.
- Catches errors in templates, reactive properties, or manually via `catchError()`.
- Delegates to `errorService`.

### **AccountList**
- Displays paginated, searchable `Account` datatable.
- Uses `callApex()` from `apiService` for server calls.
- Handles loading state, pagination controls, and search input.

### **apiService.js**
- Generic wrapper for Apex calls (`callApex`) and HTTP fetch (`callFetch`).
- Centralizes error handling through `errorService`.

### **errorService.js**
- Displays toast messages for errors.
- Logs normalized errors server-side via `InsertExceptionLog`.
- Handles both LWC and Apex errors uniformly.

### **errorHandler.js**
- Normalizes diverse error shapes:
  - JS errors
  - Apex errors
  - HTTP errors
  - Arrays or objects
- Maps errors to standard types and severities.

### **messages.js**
- Error constants for type, severity, default messages, toast variants.

---

## Error Handling Framework

1. **Client-Side**
   - LWC errors captured in `ErrorBoundary` or `catch` blocks.
   - Normalized via `errorHandler.js`.
   - Toast displayed and server log recorded via `errorService`.

2. **Server-Side**
   - Apex controllers log exceptions via `ExceptionLogger`.
   - Persisted in `Error_Log__c` for audit and debugging.
   - Custom severities and record context supported.

---

## Usage

### **Wrap a component in an ErrorBoundary**
```html
<c-error-boundary component-name="AccountList">
    <c-account-list></c-account-list>
</c-error-boundary>

### **Make server calls via apiService**
```js
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import { callApex } from 'c/apiService';

const accounts = await callApex(getAccounts, { pageSize: 10, pageNumber: 1 }, this);

### **Log a manual exception**
```js
import { errorService } from 'c/errorService';

try {
    // risky logic
} catch (err) {
    await errorService.handleError(err, this, 'CustomComponent');
}
