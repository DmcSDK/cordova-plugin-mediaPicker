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
    }
};

module.exports = MediaPicker;
