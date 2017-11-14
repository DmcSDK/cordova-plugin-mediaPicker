package com.dmc.mediaPicker;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.media.ThumbnailUtils;
import android.provider.MediaStore;
import android.util.Base64;
import android.net.Uri;
import com.dmcbig.mediapicker.PickerActivity;
import com.dmcbig.mediapicker.PickerConfig;
import com.dmcbig.mediapicker.entity.Media;
import com.dmcbig.mediapicker.TakePhotoActivity;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;


/**
 * This class echoes a string called from JavaScript.
 */
public class MediaPicker extends CordovaPlugin {


    private  CallbackContext callback;

    private  boolean showBase64=false;
    private  boolean showThumbnail=false;
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getMedias")) {
            this.getMedias(args, callbackContext);
            return true;
        }else if(action.equals("takePhoto")){
            this.takePhoto(args, callbackContext);
            return true;
        }else if(action.equals("photoLibrary")){
            this.getMedias(args, callbackContext);
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
                showBase64=jsonObject.getBoolean("showBase64");
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                showThumbnail=jsonObject.getBoolean("showThumbnail");
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                intent.putExtra(PickerConfig.SELECT_MODE,jsonObject.getInt("selectMode"));//default image and video (Optional)
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                intent.putExtra(PickerConfig.MAX_SELECT_SIZE,jsonObject.getInt("maxSelectSize")); //default 180MB (Optional)
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


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        try {
            if(requestCode==200&&resultCode==PickerConfig.RESULT_CODE){
                ArrayList<Media> select=intent.getParcelableArrayListExtra(PickerConfig.EXTRA_RESULT);
                JSONArray jsonArray=new JSONArray();
                for(Media media:select){
                    String path=media.path;
                    JSONObject object=new JSONObject();
                    if(showThumbnail){
                        object.put("thumbnailBase64",thumbToBase64(path,media.mediaType));
                    }
                    object.put("path",path);
                    object.put("size",media.size);
                    object.put("uri",Uri.parse(path));
                    object.put("exifRotate",getBitmapRotate(path));
                    object.put("mediaType",media.mediaType==3?"video":"image");
                    jsonArray.put(object);
                }
                this.callback.success(jsonArray);

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public  String thumbToBase64(String path,int mediaType) {
            Bitmap thumbImage;
            if (mediaType == 3) {
                thumbImage = ThumbnailUtils.createVideoThumbnail(path, MediaStore.Images.Thumbnails.MICRO_KIND);
            } else {
                thumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(path), 150, 150);
            }
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            thumbImage.compress(Bitmap.CompressFormat.JPEG, 100, baos);
            byte[] imageBytes = baos.toByteArray();
            String encodedImage = Base64.encodeToString(imageBytes, Base64.DEFAULT);
            return encodedImage;
    }

    public static String fileToBase64(String path,int mediaType) {
        byte[] data = null;
        try {
            BufferedInputStream in = new BufferedInputStream(new FileInputStream(path));
            data = new byte[in.available()];
            in.read(data);
            in.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return Base64.encodeToString(data, Base64.DEFAULT);
    }



    public static int getBitmapRotate(String path) {
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

}
