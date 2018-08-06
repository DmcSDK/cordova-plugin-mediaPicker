cordova.define("cordova-plugin-mediapicker-dmcbig.MediaPicker", function(require, exports, module) {
var exec = require('cordova/exec');


var MediaPicker = {
    getMedias:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "getMedias", [arg0]);
    },
    photoLibrary:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "photoLibrary", [arg0]);
    },
    takePhoto:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "takePhoto", [arg0]);
    },
    extractThumbnail:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "extractThumbnail", [arg0]);
    },
    compressEvent:function(s,i) {
        cordova.fireDocumentEvent('MediaPicker.CompressVideoEvent', {'status':s,'index':i});
    },
    compressImage:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "compressImage", [arg0]);
    },
    fileToBlob:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "fileToBlob", [arg0]);
    },
    getExif:function(arg0, success, error) {
        exec(success, error, "MediaPicker", "getExif", [arg0]);
    }
};

module.exports = MediaPicker;



});
