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
	}
};

module.exports = MediaPicker;