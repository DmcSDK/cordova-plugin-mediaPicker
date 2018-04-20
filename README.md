# MediaPicker v:2.0.0
android  mediaPicker support  selection of multiple image and video 

How do I use?
-------------------

use npm:

```npm
  cordova plugin add cordova-plugin-mediapicker-dmcbig
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
    var args={
        'selectMode':101,//101=PICKER_IMAGE_VIDEO , 100=PICKER_IMAGE , 102=PICKER_VIDEO
        'maxSelectCount':40, //default 40 (Optional)
        'maxSelectSize':188743680,//188743680=180M (Optional)
    };

    document.getElementById('openBtn').onclick=function(){
          MediaPicker.getMedias(args,function(dataArray){
              //dataArray [{mediaType: "image", path:'/storage/emulated/0/DCIM/Camera/20170808_145202.jpg', path:'/storage/emulated/0/DCIM/Camera/20170808_145202.jpg'}]
              getThumbnail(dataArray);
          },err())
    };

    function getThumbnail(dataArray){
          for(var i=0; i<dataArray.length; i++){
                //dataArray[i].thumbnailQuality=50; (Optional)
                //loading(); //show loading ui
                MediaPicker.extractThumbnail(dataArray[i],function(data){
                            imgs[data.index].src= 'data:image/jpeg;base64,'+data.thumbnailBase64;
                            imgs[data.index].setAttribute('style', 'transform:rotate(' + data.exifRotate + 'deg)');
                },err());
          }
    }

    document.getElementById('uploadBtn').onclick=function() {
        //please:  cordova plugin add cordova-plugin-file-transfer
        //see:  https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-file-transfer/index.html
    };

    function err(data){
        console.log(err);
    }

    function loading(){}



# Screenshots
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots1.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots2.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots3.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots4.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots5.png)
![](https://github.com/dmcBig/MediaPickerPoject/blob/master/Screenshots/Screenshots6.png)
