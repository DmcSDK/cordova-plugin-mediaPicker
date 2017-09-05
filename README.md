# mediaPicker v:1.0.6
android  mediaPicker support  selection of multiple image and video 

How do I use?
-------------------

use npm:

```npm
  cordova plugin add cordova-plugin-mediapicker-dmcbig
```
remove npm:

```npm
  cordova plugin remove cordova-plugin-mediapicker-dmcbig
  or
  cordova plugin remove cordova-plugin-mediaPicker
```

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

    var imgs=document.getElementsByName('imgView');
    var args={ 'showThumbnail':true,
               'selectMode':101,//101=PICKER_IMAGE_VIDEO , 100=PICKER_IMAGE , 102=PICKER_VIDEO
               'maxSelectCount':12, //default 40 (Optional)
               'maxSelectSize':188743680,//188743680=180M (Optional)
              };

    document.getElementById('openBtn').onclick=function(){

        MediaPicker.getMedias(args,function(dataArray){
            //dataArray [{mediaType: "image",rotate: 90, path:'/storage/emulated/0/DCIM/Camera/20170808_145202.jpg' thumbnailBase64: '9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEB'}]
            for(var i=0; i<dataArray.length; i++){
                imgs[i].src= 'data:image/jpeg;base64,'+dataArray[i].thumbnailBase64;
                imgs[i].setAttribute('style', 'transform:rotate(' + dataArray[i].rotate + 'deg)');
            }
        },function(err){
            console.log(err);
        })
     };

     document.getElementById('uploadBtn').onclick=function() {
        //please:  cordova plugin add cordova-plugin-file-transfer
        //see:  https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-file-transfer/index.html
     };



# Screenshots
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots1.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots2.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots3.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots4.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots5.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots6.png)
