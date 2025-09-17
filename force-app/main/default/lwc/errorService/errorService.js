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
// force-app/main/default/lwc/utils/errorService/errorService.js

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import logError from '@salesforce/apex/InsertExceptionLog.logError';
import { normalizeError } from 'c/errorHandler';
import { DEFAULT_ERROR_TITLE, ERROR_SEVERITY, STICKY_VARIANT, ERROR_TYPES } from 'c/messages';

class ErrorService {
    /**
     * Handle error: show toast + log server-side
     * @param {any} error - raw error
     * @param {object|function} componentOrDispatchFn - LWC "this" or dispatch function
     * @param {String} context - optional context/component name
     * @returns {Object} normalized error
     */
    async handleError(error, componentOrDispatchFn) {
        const normalized = normalizeError(error);
        

        const title = DEFAULT_ERROR_TITLE;

        // Show toast
        try {
            const toastEvent = new ShowToastEvent({
                title,
                message: normalized.message,
                variant: normalized.severity || ERROR_SEVERITY[ERROR_TYPES.UNKNOWN],
                mode: STICKY_VARIANT
            });

            if (typeof componentOrDispatchFn === 'function') {
                componentOrDispatchFn(toastEvent);
            } else if (componentOrDispatchFn?.dispatchEvent) {
                componentOrDispatchFn.dispatchEvent(toastEvent);
            } else {
                console.error('Toast cannot be dispatched: ', normalized.message);
            }
        } catch (e) {
            console.error('ErrorService: toast dispatch failed', e);
        }

        // Log server-side (best effort)
        try {
            console.log('Normalized Error 1:', normalized.message);
        console.log('Stack Trace: 1', normalized.type);
            await logError({
                errorType: normalized.type,
                errorMessage: normalized.message,
                stackTrace: normalized.stack || null,
                recordId:  null,
                severity: normalized.severity || ERROR_SEVERITY[ERROR_TYPES.UNKNOWN]
            });
        } catch (e) {
            console.error('ErrorService: server logging failed', e);
        }

        // Re-throw normalized error if caller wants chaining
        return normalized;
    }
}

// Export singleton
export const errorService = new ErrorService();
