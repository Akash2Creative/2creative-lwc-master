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

import { ERROR_TYPES, DEFAULT_MESSAGES, ERROR_BODY, ERROR_SEVERITY } from 'c/messages';

/**
 * Safe string-based type checker
 */
function isType(val, expected) {
    return typeof val === ERROR_BODY.STRING
        ? val.toLowerCase().includes(expected.toLowerCase())
        : typeof val === expected;
}

/**
 * Normalize various error shapes for LWC, Apex, and Fetch.
 * @param {any} error - error object, string, or response
 * @param {string} context - optional context label
 * @returns {Object} normalized error
 */
export function normalizeError(error, context = '') {
    let type = ERROR_TYPES.UNKNOWN;
    let message = DEFAULT_MESSAGES.UNKNOWN;
    let stack = '';
    let severity = ERROR_SEVERITY[ERROR_TYPES.UNKNOWN];

    if (!error) return { type, message, stack, severity, context };

    try {
        if (error instanceof Error) {
            type = ERROR_TYPES.JS_ERROR;
            message = error.message || message;
            stack = error.stack || '';
        }
        else if (error.body) {
            if (Array.isArray(error.body)) {
                message = error.body.map(b => b.message || JSON.stringify(b)).join(', ');
            } else if (isType(typeof error.body, ERROR_BODY.OBJECT)) {
                if (error.body.output?.errors?.length) {
                    message = error.body.output.errors.map(e => e.message).join(', ');
                } else {
                    message = error.body.message || JSON.stringify(error.body);
                }
                stack = error.body.stack || '';
            } else if (isType(typeof error.body, ERROR_BODY.STRING)) {
                message = error.body;
            }
            type = error.body.errorCode || error.status || ERROR_TYPES.APEX_ERROR;
        }
        else if (Array.isArray(error)) {
            message = error.map(e => e.message || JSON.stringify(e)).join(', ');
            type = ERROR_TYPES.ARRAY_ERROR;
        }
        else if (error.response && error.response.status) {
            type = ERROR_TYPES.HTTP_ERROR;
            message = error.response.statusText || error.response.data || DEFAULT_MESSAGES.NETWORK;
            stack = error.stack || '';
        }
        else if (isType(typeof error, ERROR_BODY.STRING)) {
            message = error;
            type = ERROR_TYPES.STRING_ERROR;
        }
        else if (isType(typeof error, ERROR_BODY.OBJECT) && error.message) {
            message = error.message;
            stack = error.stack || '';
            type = error.status || ERROR_TYPES.OBJECT_ERROR;
        }
        else if (isType(typeof error, ERROR_BODY.OBJECT)) {
            message = JSON.stringify(error);
            type = error.status || ERROR_TYPES.OBJECT_ERROR;
        }
        else {
            message = String(error);
            type = ERROR_TYPES.UNKNOWN;
        }

        severity = ERROR_SEVERITY[type] || 'error';
        console.log(type, message, stack, severity, context);
        console.log('Normalized Error 2:', message);
        console.log('Stack Trace: 2', stack); 
        console.log('Severity: 2', severity);
    } catch (e) {
        message = typeof error?.toString === 'function' ? error.toString() : DEFAULT_MESSAGES.UNKNOWN;
        stack = '';
        type = ERROR_TYPES.UNKNOWN;
        severity = ERROR_SEVERITY[ERROR_TYPES.UNKNOWN];
    }
    

    return { type, message, stack, severity, context };
}
