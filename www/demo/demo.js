var imgs = document.getElementsByName('imgView');
var args = {
    'selectMode': 101, //101=picker image and video , 100=image , 102=video
    'maxSelectCount': 40, //default 40 (Optional)
    'maxSelectSize': 188743680, //188743680=180M (Optional)
};

document.getElementById('openBtn').onclick = function() {
    MediaPicker.getMedias(args, function(medias) {
        //medias [{mediaType: "image", path:'/storage/emulated/0/DCIM/Camera/20170808_145202.jpg', size: 21993}]
        window.medias = medias;
        getThumbnail(medias);
    }, function(e) { console.log(e) })
};

function getThumbnail(medias) {
    for (var i = 0; i < medias.length; i++) {
        //medias[i].thumbnailQuality=50; (Optional)
        //loading(); //show loading ui
        MediaPicker.extractThumbnail(medias[i], function(data) {
            imgs[data.index].src = 'data:image/jpeg;base64,' + data.thumbnailBase64;
            imgs[data.index].setAttribute('style', 'transform:rotate(' + data.exifRotate + 'deg)');
        }, function(e) { console.log(e) });
    }
}

document.getElementById('uploadBtn').onclick = function() {
    //please:  cordova plugin add cordova-plugin-file-transfer
    //see:  https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-file-transfer/index.html
    //use medias[index].path

    //OR
    //compressImage(); //upload compress img
};

function compressImage() {
    for (var i = 0; i < medias.length; i++) {
        // if(medias[i].size>1048576){ medias[i].quality=50; } else {d ataArray[i].quality=100;}
        medias[i].quality = 30; //when the value is 100,return original image
        MediaPicker.compressImage(medias[i], function(compressData) {
            //user compressData.path upload compress img
            console.log(compressData.path);
        }, function(e) { console.log(e) });
    }
}

document.getElementById('takePhotoBtn').onclick = function() {
    var cameraOptions={ quality: 25,mediaType: Camera.MediaType.PICTURE };//see cordova camera docs
    MediaPicker.takePhoto(function(media) {
            media.index=0;//index use to imgs[data.index].src; // media.index=resultMedias.length;
            resultMedias.push(media);
            getThumbnail(resultMedias);
      }, function(e) { console.log(e) }, cameraOptions);
};

function loading() {}


//ios Video transcoding compression to MP4 (use AVAssetExportPresetMediumQuality)
document.addEventListener("MediaPicker.CompressVideoEvent", function(data) {
    alert(data.status + "||" + data.index);
}, false);



function getExifForKey(){
    MediaPicker.getExifForKey(resultMedias[i].path,"Orientation", function(data) {
        alert(data);
    }, function(e) { console.log(e) });
}


function fileToBlob(){
    MediaPicker.fileToBlob(resultMedias[i].path, function(data) {
        var blob = new Blob([data], {"type": "image/jpeg"});
        var domURL = window.URL || window.webkitURL;
        imgs[0].src = domURL.createObjectURL(blob);        
    }, function(e) { console.log(e) });
}