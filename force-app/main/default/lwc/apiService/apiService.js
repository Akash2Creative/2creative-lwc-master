/**
 * @description                : This utility module provides generic wrappers for making server-side calls in Lightning Web Components. 
 *                               The callApex function handles calling Apex methods imperatively with automatic error normalization and 
 *                               routing through a centralized errorService, promoting consistent backend error handling across the app. 
 *                               Similarly, the callFetch function wraps the standard Fetch API to handle HTTP responses, including parsing 
 *                               JSON or text, and routes errors through the same errorService for uniform client-side error management. 
 *                               Both functions accept the LWC component context or a custom dispatch function to enable UI updates or event 
 *                               dispatching from error handlers. This abstraction enforces separation of concerns by keeping error handling 
 *                               centralized and components focused on UI logic, in line with 2Creative standards for reusable components 
 *                               and error handling.
 * @author                     : Akash Das
 * @group                      : Utilities
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
 * @last modification details  :  
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   09-16-2025   Akash Das   Initial Version
**/
// force-app/main/default/lwc/utils/apiService/apiService.js

import { errorService } from 'c/errorService';

/**
 * Generic wrapper for calling Apex imperatively
 * @param {function} apexMethod - imported Apex method
 * @param {object} params - parameters for the method
 * @param {object|function} componentOrDispatchFn - LWC "this" or dispatch function
 * @returns {Promise<any>} - resolved data or throws normalized error
 */
export async function callApex(apexMethod, params = {}, componentOrDispatchFn) {
    try {
        console.log('Calling Apex:', apexMethod.name, params);
        return await apexMethod(params);
    } catch (error) {
        const normalized = await errorService.handleError(error, componentOrDispatchFn);
        throw normalized; // rethrow so caller can decide
    }
}

/**
 * Generic wrapper for Fetch API
 * @param {string} url - endpoint
 * @param {object} options - fetch options (method, headers, body, etc.)
 * @param {object|function} componentOrDispatchFn - LWC "this" or dispatch function
 * @returns {Promise<any>} - parsed JSON or text
 */
export async function callFetch(url, options = {}, componentOrDispatchFn) {
    try {
        const response = await fetch(url, options);
        if (!response.ok) {
            throw {
                response,
                message: `HTTP ${response.status}: ${response.statusText}`
            };
        }
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
            return await response.json();
        }
        return await response.text();
    } catch (error) {
        const normalized = await errorService.handleError(error, componentOrDispatchFn);
        throw normalized;
    }
}
