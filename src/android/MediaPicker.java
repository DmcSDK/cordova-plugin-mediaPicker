package com.dmc.mediaPickerPlugin;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;

import com.dmcbig.mediapicker.PickerActivity;
import com.dmcbig.mediapicker.PickerConfig;
import com.dmcbig.mediapicker.TakePhotoActivity;
import com.dmcbig.mediapicker.entity.Media;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;


/**
 * This class echoes a string called from JavaScript.
 */
public class MediaPicker extends CordovaPlugin {
    private  CallbackContext callback;
    private  int thumbnailQuality=50;
    private  int quality=100;//default original
    private  int thumbnailW=200;
    private  int thumbnailH=200;
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        getPublicArgs(args);

        if (action.equals("getMedias")) {
            this.getMedias(args, callbackContext);
            return true;
        }else if(action.equals("takePhoto")){
            this.takePhoto(args, callbackContext);
            return true;
        }else if(action.equals("photoLibrary")){
            this.getMedias(args, callbackContext);
            return true;
        }else if(action.equals("extractThumbnail")){
            this.extractThumbnail(args, callbackContext);
            return true;
        }else if(action.equals("compressImage")){
            this.compressImage(args, callbackContext);
            return true;
        }else if(action.equals("fileToBlob")){
            this.fileToBlob(args.getString(0), callbackContext);
            return true;
        }else if(action.equals("getExifForKey")){
            this.getExifForKey(args.getString(0),args.getString(1),callbackContext);
            return true;
        }else if(action.equals("getFileInfo")){
            this.getFileInfo(args,callbackContext);
            return true;
        }
        return false;
    }

    private void takePhoto(JSONArray args, CallbackContext callbackContext) {
        this.callback=callbackContext;
        Intent intent =new Intent(cordova.getActivity(), TakePhotoActivity.class); //Take a photo with a camera
        this.cordova.startActivityForResult(this,intent,200);
    }

    private void getMedias(JSONArray args, CallbackContext callbackContext) {
        this.callback=callbackContext;
        Intent intent =new Intent(cordova.getActivity(), PickerActivity.class);
        intent.putExtra(PickerConfig.MAX_SELECT_COUNT,10);  //default 40 (Optional)
        JSONObject jsonObject=new JSONObject();
        if (args != null && args.length() > 0) {
            try {
                jsonObject=args.getJSONObject(0);
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                intent.putExtra(PickerConfig.SELECT_MODE,jsonObject.getInt("selectMode"));//default image and video (Optional)
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                intent.putExtra(PickerConfig.MAX_SELECT_SIZE,jsonObject.getLong("maxSelectSize")); //default 180MB (Optional)
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                intent.putExtra(PickerConfig.MAX_SELECT_COUNT,jsonObject.getInt("maxSelectCount"));  //default 40 (Optional)
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                ArrayList<Media> select= new ArrayList<Media>();
                JSONArray jsonArray=jsonObject.getJSONArray("defaultSelectedList");
                for(int i=0;i<jsonArray.length();i++){
                    select.add(new Media(jsonArray.getString(i), "", 0, 0,0,0,""));
                }
                intent.putExtra(PickerConfig.DEFAULT_SELECTED_LIST,select); // (Optional)
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        this.cordova.startActivityForResult(this,intent,200);
    }

    public  void getPublicArgs(JSONArray args){
        JSONObject jsonObject=new JSONObject();
        if (args != null && args.length() > 0) {
            try {
                jsonObject = args.getJSONObject(0);
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                thumbnailQuality = jsonObject.getInt("thumbnailQuality");
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                thumbnailW = jsonObject.getInt("thumbnailW");
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                thumbnailH = jsonObject.getInt("thumbnailH");
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                quality = jsonObject.getInt("quality");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        try {
            if(requestCode==200&&resultCode==PickerConfig.RESULT_CODE){
                final ArrayList<Media> select=intent.getParcelableArrayListExtra(PickerConfig.EXTRA_RESULT);
                final JSONArray jsonArray=new JSONArray();

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        try {
                            int index=0;
                            for(Media media:select){
                                JSONObject object=new JSONObject();
                                object.put("path",media.path);
                                object.put("uri",Uri.fromFile(new File(media.path)));//Uri.fromFile(file).toString() || [NSURL fileURLWithPath:filePath] absoluteString]
                                object.put("size",media.size);
                                object.put("name",media.name);
                                object.put("index",index);
                                object.put("mediaType",media.mediaType==3?"video":"image");
                                jsonArray.put(object);
                                index++;
                            }
                            MediaPicker.this.callback.success(jsonArray);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public  void extractThumbnail(JSONArray args, CallbackContext callbackContext){
        JSONObject jsonObject=new JSONObject();
        if (args != null && args.length() > 0) {
            try {
                jsonObject = args.getJSONObject(0);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            try {
                thumbnailQuality = jsonObject.getInt("thumbnailQuality");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            try {
                String path =jsonObject.getString("path");
                jsonObject.put("exifRotate",getBitmapRotate(path));
                int mediatype = "video".equals(jsonObject.getString("mediaType"))?3:1;
                jsonObject.put("thumbnailBase64",extractThumbnail(path,mediatype,thumbnailQuality));
            } catch (Exception e) {
                e.printStackTrace();
            }
            callbackContext.success(jsonObject);
        }
    }

    public  String extractThumbnail(String path,int mediaType,int quality) {
        String encodedImage = null;
        try {
            Bitmap thumbImage;
            if (mediaType == 3) {
                thumbImage = ThumbnailUtils.createVideoThumbnail(path, MediaStore.Images.Thumbnails.MINI_KIND);
            } else {
                thumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(path), thumbnailW, thumbnailH);
            }
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            thumbImage.compress(Bitmap.CompressFormat.JPEG, quality, baos);
            byte[] imageBytes = baos.toByteArray();
            encodedImage = Base64.encodeToString(imageBytes, Base64.NO_WRAP);
            baos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return encodedImage;
    }

    public void  compressImage( JSONArray args, CallbackContext callbackContext){
        this.callback=callbackContext;
        try {
            JSONObject jsonObject = args.getJSONObject(0);
            String path = jsonObject.getString("path");
            int quality=jsonObject.getInt("quality");
            if(quality<100) {
                File file = compressImage(path, quality);
                jsonObject.put("path", file.getPath());
                jsonObject.put("uri", Uri.fromFile(new File(file.getPath())));
                jsonObject.put("size", file.length());
                jsonObject.put("name", file.getName());
                callbackContext.success(jsonObject);
            }else{
                callbackContext.success(jsonObject);
            }
        } catch (Exception e) {
            callbackContext.error("compressImage error"+e);
            e.printStackTrace();
        }
    }

    public void  getFileInfo( JSONArray args, CallbackContext callbackContext){
        this.callback=callbackContext;
        try {
            String type=args.getString(1);
            File file;
            if("uri".equals(type)){
                file=new File(FileHelper.getRealPath(args.getString(0),cordova));
            }else{
                file=new File(args.getString(0));
            }
            JSONObject jsonObject=new JSONObject();
            jsonObject.put("path", file.getPath());
            jsonObject.put("uri", Uri.fromFile(new File(file.getPath())));
            jsonObject.put("size", file.length());
            jsonObject.put("name", file.getName());
            String mimeType = FileHelper.getMimeType(jsonObject.getString("uri"),cordova);
            String mediaType = mimeType.indexOf("video")!=-1?"video":"image";
            jsonObject.put("mediaType",mediaType);
            callbackContext.success(jsonObject);
        } catch (Exception e) {
            callbackContext.error("getFileInfo error"+e);
            e.printStackTrace();
        }
    }

    public File compressImage(String path,int quality){
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        String compFileName="dmcMediaPickerCompress"+System.currentTimeMillis()+".jpg";
        File file= new File(cordova.getActivity().getExternalCacheDir(),compFileName);
        rotatingImage(getBitmapRotate(path),BitmapFactory.decodeFile(path)).compress(Bitmap.CompressFormat.JPEG, quality, baos);
        try {
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(baos.toByteArray());
            fos.flush();
            fos.close();
        } catch (Exception e) {
            MediaPicker.this.callback.error("compressImage error"+e);
            e.printStackTrace();
        }
        return  file;
    }

    public  int getBitmapRotate(String path) {
        int degree = 0;
        try {
            ExifInterface exifInterface = new ExifInterface(path);
            int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION,ExifInterface.ORIENTATION_NORMAL);
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    degree = 90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    degree = 180;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    degree = 270;
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return degree;
    }

    private static Bitmap rotatingImage(int angle, Bitmap bitmap) {
        //rotate image
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);

        //create a new image
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix,
                true);
    }


    public  byte[] extractThumbnailByte(String path,int mediaType,int quality) {

        try {
            Bitmap thumbImage;
            if (mediaType == 3) {
                thumbImage = ThumbnailUtils.createVideoThumbnail(path, MediaStore.Images.Thumbnails.MINI_KIND);
            } else {
                thumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(path), thumbnailW, thumbnailH);
            }
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            thumbImage.compress(Bitmap.CompressFormat.JPEG, quality, baos);
            return baos.toByteArray();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public  void getExifForKey(String path,String tag, CallbackContext callbackContext) {
        try {
            ExifInterface exifInterface = new ExifInterface(path);
            String object = exifInterface.getAttribute(tag);
            callbackContext.success(object);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public  String fileToBase64(String path) {
        byte[] data = null;
        try {
            BufferedInputStream in = new BufferedInputStream(new FileInputStream(path));
            data = new byte[in.available()];
            in.read(data);
            in.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return Base64.encodeToString(data, Base64.NO_WRAP);
    }

    public  void fileToBlob(String path, CallbackContext callbackContext) {
        byte[] data = null;
        try {
            BufferedInputStream in = new BufferedInputStream(new FileInputStream(path));
            data = new byte[in.available()];
            in.read(data);
            in.close();
        } catch (IOException e) {
            callbackContext.error("fileToBlob "+e);
            e.printStackTrace();
        }
        callbackContext.success(data);
    }
}
