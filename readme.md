# MediaPicker v:2.2.3
android ios mediaPicker support  selection of multiple image and video gif</br>

[GitHub:](https://github.com/dmcBig/cordova-plugin-mediaPicker) https://github.com/dmcBig/cordova-plugin-mediaPicker</br>


How do I use?
-------------------

use npm:

```npm
  cordova plugin add cordova-plugin-mediapicker-dmcbig --variable IOS_PHOTO_LIBRARY_USAGE_DESCRIPTION="your usage message"
```
<font color="#660000">IOS: please use XCode 9</font></br> 

## Example
html code:

    <body>
        <div>
            <img name="imgView"  width="100px"  height="100px" >
            <img name="imgView"  width="100px"  height="100px" >
        </div>
        <button id="openBtn">open</button>
        <button id="uploadBtn">upload</button>

        <script type="text/javascript" src="cordova.js"></script>
        <script type="text/javascript" src="js/index.js"></script>
    </body>


index.js code:
```
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

function loading() {}

//ios Video transcoding compression to MP4 (use AVAssetExportPresetMediumQuality)
document.addEventListener("MediaPicker.CompressVideoEvent", function(data) {
    alert(data.status + "||" + data.index);
}, false);
```    



# Screenshots
## Android
<img src="https://github.com/dmcBig/cordova-plugin-mediaPicker/blob/master/www/demo/android.gif" width="300" alt="android" />

[My Android Source GitHub:](https://github.com/dmcBig/MediaPickerPoject) https://github.com/dmcBig/MediaPickerPoject</br>

## IOS
<img src="https://github.com/dmcBig/cordova-plugin-mediaPicker/blob/master/www/demo/ios.gif" width="300" alt="ios" />

[My IOS Source GitHub:](https://github.com/dmcBig/IOSMediaPicker) https://github.com/dmcBig/IOSMediaPicker</br>

