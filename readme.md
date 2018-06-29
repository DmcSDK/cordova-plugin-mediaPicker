# MediaPicker v:2.3.0 (Support Chinese and English)
android ios mediaPicker support  selection of multiple image and video gif</br>

[GitHub:](https://github.com/DmcSDK/cordova-plugin-mediaPicker) https://github.com/DmcSDK/cordova-plugin-mediaPicker</br>

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

### simple
index.js **simple** code:
```
var resultMedias=[];
var imgs = document.getElementsByName('imgView');
var args = {
    'selectMode': 101, //101=picker image and video , 100=image , 102=video
    'maxSelectCount': 40, //default 40 (Optional)
    'maxSelectSize': 188743680, //188743680=180M (Optional)
};

document.getElementById('openBtn').onclick = function() {
    MediaPicker.getMedias(args, function(medias) {
        //medias [{mediaType: "image", path:'/storage/emulated/0/DCIM/Camera/20170808_145202.jpg', size: 21993}]
        resultMedias = medias;
        getThumbnail(medias);
    }, function(e) { console.log(e) })
};

function getThumbnail(medias) {
    for (var i = 0; i < medias.length; i++) {
        //medias[i].thumbnailQuality=50; (Optional)
        //loadingUI(); //show loading ui
        MediaPicker.extractThumbnail(medias[i], function(data) {
            imgs[data.index].src = 'data:image/jpeg;base64,' + data.thumbnailBase64;
            imgs[data.index].setAttribute('style', 'transform:rotate(' + data.exifRotate + 'deg)');
        }, function(e) { console.log(e) });
    }
}

function loadingUI() {}
```    

### upload compress
index.js **upload** and **compress** code:
```
document.getElementById('uploadBtn').onclick = function() {
    //please:  cordova plugin add cordova-plugin-file-transfer
    //see:  https://github.com/apache/cordova-plugin-file-transfer
    //use medias[index].path

    //OR
    //compressImage(); //upload compress img
};

function compressImage() {
    for (var i = 0; i < resultMedias.length; i++) {
        // if(resultMedias[i].size>1048576){ resultMedias[i].quality=50; } else {d ataArray[i].quality=100;}
        resultMedias[i].quality = 30; //when the value is 100,return original image
        MediaPicker.compressImage(resultMedias[i], function(compressData) {
            //user compressData.path upload compress img
            console.log(compressData.path);
        }, function(e) { console.log(e) });
    }
}

//ios Video transcoding compression to MP4 Event(use AVAssetExportPresetMediumQuality)
document.addEventListener("MediaPicker.CompressVideoEvent", function(data) {
    alert(data.status + "||" + data.index);
}, false);
```    


# Screenshots

| Android         | iOS          |
|:---------------:|:------------:|
| <img src="https://github.com/DmcSDK/cordova-plugin-mediaPicker/blob/master/www/demo/Screenshots1.png" width="270px" height="480"> | <img src="https://github.com/DmcSDK/cordova-plugin-mediaPicker/blob/master/www/demo/ios.png" width="270px" height="480"> |

[My Android Source GitHub:](https://github.com/dmcBig/MediaPickerPoject) https://github.com/dmcBig/MediaPickerPoject</br>

[My IOS Source GitHub:](https://github.com/dmcBig/IOSMediaPicker) https://github.com/dmcBig/IOSMediaPicker</br>



