var exec = require('cordova/exec');


var MediaPicker = {
    getMedias:function(arg0, success, error) {
    	exec(success, error, "MediaPicker", "getMedias", [arg0]);
	}
};

module.exports = MediaPicker;