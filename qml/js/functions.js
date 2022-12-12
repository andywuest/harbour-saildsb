.pragma library

Qt.include('constants.js');

function log(message) {
    if (loggingEnabled && message) {
        console.log(message);
    }
}
