.pragma library

Qt.include('constants.js');

function log(message) {
    if (loggingEnabled && message) {
        console.log(message);
    }
}

function resolveText(indicator, value) {
  return indicator ? value : "";
}

function getFilterTokens(filter) {
    if (filter) {
        return filter.replace(/\s/g, "").toLowerCase().split(",");
    }
    return [];
}

function isFilterTokenMatch(value, filterTokens) {
    // all match
    if (filterTokens.length === 0) {
        return true;
    }
    var match = false;
    for (var t = 0; t < filterTokens.length; t++) {
        if (filterTokens[t] === value.toLowerCase() || value.indexOf(filterTokens[t]) !== -1) {
            match = true;
            break;
        }
    }
    return match;
}

function hasCredentials(userName, password) {
    return (userName && userName.length > 0 && password && password.length > 0);
}

function hasSchoolThreeRows(schoolId) {
    return SCHOOL_ROWS_MAP[schoolId];
}
