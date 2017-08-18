# cordova-plugin-mediaPicker
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
            <img  id="img1"  width="100px"  height="100px" >
            <img  id="img2"  width="100px"  height="100px" >
        </div>
        <button id="openBtn" style="width:100px;height:40px;">open</button>
        <button id="uploadBtn" style="width:100px;height:40px;">upload</button>

        <script type="text/javascript" src="cordova.js"></script>
        <script type="text/javascript" src="js/index.js"></script>
    </body>

index.js code:

    var img1=document.getElementById('img1');
    var img2=document.getElementById('img2');
    var data;

    document.getElementById('openBtn').onclick=function(){
        var args={'showThumbnail':true,
                   'selectMode':101,//101=PICKER_IMAGE_VIDEO , 100=PICKER_IMAGE
                   'maxSelectCount':12, //default 40 (Optional)
                   'maxSelectSize':188743680,//188743680=180M (Optional)
                  };
        MediaPicker.getMedias(args,function(dataArray){
            data=dataArray;//[{mediaType: "image",rotate: 90, path:'/storage/emulated/0/DCIM/Camera/20170808_145202.jpg' thumbnailBase64: '9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEB'}]

            //dataArray[0]
            img1.src = 'data:image/jpeg;base64,'+dataArray[0].thumbnailBase64;
            img1.setAttribute('style', 'transform:rotate(' + dataArray[0].rotate + 'deg)');
            //dataArray[1]
            img2.src = 'data:image/jpeg;base64,'+dataArray[1].thumbnailBase64;
            img2.setAttribute('style', 'transform:rotate(' + dataArray[1].rotate + 'deg)');
            //dataArray[2]...

            //or for(var obj in dataArray){
            //        img.src= = 'data:image/jpeg;base64,'+obj.thumbnailBase64;
            //    }
        },function(err){
            console.log(err);
        })
     };

     document.getElementById('uploadBtn').onclick=function(){
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
