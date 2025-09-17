// utils/messages.js
export const ERROR_TYPES = {
    UNKNOWN: 'UNKNOWN',
    JS_ERROR: 'JS_ERROR',
    APEX_ERROR: 'APEX_ERROR',
    ARRAY_ERROR: 'ARRAY_ERROR',
    HTTP_ERROR: 'HTTP_ERROR',
    STRING_ERROR: 'STRING_ERROR',
    OBJECT_ERROR: 'OBJECT_ERROR'
};

export const DEFAULT_MESSAGES = {
    UNKNOWN: 'An unknown error occurred',
    NETWORK: 'A network error occurred. Please try again later.',
    SERVER: 'A server error occurred. Please contact support.'
};

export const ERROR_BODY = {
    STRING: 'string',
    OBJECT: 'object'
};

// Map error types to severity for toast/logging
export const ERROR_SEVERITY = {
    [ERROR_TYPES.UNKNOWN]: 'error',
    [ERROR_TYPES.JS_ERROR]: 'error',
    [ERROR_TYPES.APEX_ERROR]: 'error',
    [ERROR_TYPES.ARRAY_ERROR]: 'warning',
    [ERROR_TYPES.HTTP_ERROR]: 'error',
    [ERROR_TYPES.STRING_ERROR]: 'info',
    [ERROR_TYPES.OBJECT_ERROR]: 'error'
};

export const DEFAULT_ERROR_TITLE = 'Something went wrong';
export const STICKY_VARIANT = 'sticky';

export const ERROR_MAP = {
    NETWORK_ERROR: 'Network error. Please check your connection and try again.',
    JS_ERROR: 'A client-side error occurred. Please try again or contact support.',
    APEX_ERROR: 'A server error occurred. Please try again later.',
};