/********* MediaPicker.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "DmcPickerViewController.h"
@interface MediaPicker : CDVPlugin <DmcPickerDelegate>{
  // Member variables go here.
    NSString* callbackId;
}

- (void)getMedias:(CDVInvokedUrlCommand*)command;
- (void)takePhoto:(CDVInvokedUrlCommand*)command;
- (void)extractThumbnail:(CDVInvokedUrlCommand*)command;

@end

@implementation MediaPicker

- (void)getMedias:(CDVInvokedUrlCommand*)command
{
    callbackId=command.callbackId;
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    DmcPickerViewController * dmc=[[DmcPickerViewController alloc] init];
    @try{
        dmc.selectMode=[[options objectForKey:@"selectMode"]integerValue];
    }@catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    @try{
        dmc.maxSelectCount=[[options objectForKey:@"maxSelectCount"]integerValue];
    }@catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    dmc._delegate=self;
    [self.viewController presentViewController:[[UINavigationController alloc]initWithRootViewController:dmc] animated:YES completion:nil];
}

-(void) resultPicker:(NSMutableArray*) selectArray
{
    
    NSString * tmpDir = NSTemporaryDirectory();
    NSString *dmcPickerPath = [tmpDir stringByAppendingPathComponent:@"dmcPicker"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dmcPickerPath ]){
       [fileManager createDirectoryAtPath:dmcPickerPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableArray * aListArray=[[NSMutableArray alloc] init];
    if([selectArray count]<=0){
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aListArray] callbackId:callbackId];
        return;
    }

    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int index=0;
        for(PHAsset *asset in selectArray){
            @autoreleasepool {
                if(asset.mediaType==PHAssetMediaTypeImage){
                    [self imageToSandbox:asset dmcPickerPath:dmcPickerPath aListArray:aListArray selectArray:selectArray index:index];
                }else{
                    [self videoToSandboxCompress:asset dmcPickerPath:dmcPickerPath aListArray:aListArray selectArray:selectArray index:index];
                }
            }
            index++;
        }
    });

}



-(void)imageToSandbox:(PHAsset *)asset dmcPickerPath:(NSString*)dmcPickerPath aListArray:(NSMutableArray*)aListArray selectArray:(NSMutableArray*)selectArray index:(int)index{


    [[PHImageManager defaultManager] requestImageDataForAsset:asset  options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSString *filename=[asset valueForKey:@"filename"];
        NSString *fullpath=[NSString stringWithFormat:@"%@/%@%@", dmcPickerPath,[[NSProcessInfo processInfo] globallyUniqueString], filename];
        NSNumber *size=[NSNumber numberWithInt:imageData.length];
        NSError *error = nil;
        if (![imageData writeToFile:fullpath options:NSAtomicWrite error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]] callbackId:callbackId];
        } else {
           
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:fullpath,@"path",@"image",@"mediaType",size,@"size",[NSNumber numberWithInt:index],@"index", nil];
            [aListArray addObject:dict];
            if([aListArray count]==[selectArray count]){
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aListArray] callbackId:callbackId];
            }
        }
        
    }];
}



-(void)videoToSandbox:(PHAsset *)asset dmcPickerPath:(NSString*)dmcPickerPath aListArray:(NSMutableArray*)aListArray selectArray:(NSMutableArray*)selectArray index:(int)index{

    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avsset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([avsset isKindOfClass:[AVURLAsset class]]) {
            NSString *filename = [asset valueForKey:@"filename"];
            AVURLAsset* urlAsset = (AVURLAsset*)avsset;
            
            NSString *fullpath=[NSString stringWithFormat:@"%@/%@", dmcPickerPath,filename];
            NSLog(@"%@", urlAsset.URL);
            NSData *data = [NSData dataWithContentsOfURL:urlAsset.URL options:NSDataReadingUncached error:nil];
            NSUInteger size=data.length;
            NSError *error = nil;
            if (![data writeToFile:fullpath options:NSAtomicWrite error:&error]) {
                NSLog(@"%@", [error localizedDescription]);
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]] callbackId:callbackId];
            } else {
                
                NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:fullpath,@"path",size,@"size",@"video",@"mediaType" ,[NSNumber numberWithInt:index],@"index", nil];
                [aListArray addObject:dict];
                if([aListArray count]==[selectArray count]){
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aListArray] callbackId:callbackId];
                }
            }
           
        }
    }];

}

-(void)videoToSandboxCompress:(PHAsset *)asset dmcPickerPath:(NSString*)dmcPickerPath aListArray:(NSMutableArray*)aListArray selectArray:(NSMutableArray*)selectArray index:(int)index{
    NSString *compressStartjs = [NSString stringWithFormat:@"MediaPicker.compressEvent('%@',%i)", @"start",index];
    [self.commandDelegate evalJs:compressStartjs];
    [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:nil exportPreset:AVAssetExportPresetMediumQuality resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info) {
        

        NSString *fullpath=[NSString stringWithFormat:@"%@/%@.%@", dmcPickerPath,[[NSProcessInfo processInfo] globallyUniqueString], @"mp4"];
        NSURL *outputURL = [NSURL fileURLWithPath:fullpath];
        
        NSLog(@"this is the final path %@",outputURL);
        
        exportSession.outputFileType=AVFileTypeMPEG4;
        
        exportSession.outputURL=outputURL;

        [exportSession exportAsynchronouslyWithCompletionHandler:^{

            if (exportSession.status == AVAssetExportSessionStatusFailed) {
               [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"compress failed"] callbackId:callbackId];
                NSLog(@"failed");
                
            } else if(exportSession.status == AVAssetExportSessionStatusCompleted){
                
                NSLog(@"completed!");
                NSString *compressCompletedjs = [NSString stringWithFormat:@"MediaPicker.compressEvent('%@',%i)", @"completed",index];
                [self.commandDelegate evalJs:compressCompletedjs];
                NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:fullpath,@"path",@"video",@"mediaType" ,[NSNumber numberWithInt:index],@"index", nil];
                [aListArray addObject:dict];
                if([aListArray count]==[selectArray count]){
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aListArray] callbackId:callbackId];
                }
            }
            
        }];
        
    }];
}



-(NSString*)thumbnailVideo:(NSString*)path quality:(NSInteger)quality {
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    CGFloat q=quality/100.0f;
    NSString *thumbnail=[UIImageJPEGRepresentation(shotImage,q) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return thumbnail;
}

- (void)takePhoto:(CDVInvokedUrlCommand*)command
{


}

-(NSString*)thumbnailImage:(NSString*)path quality:(NSInteger)quality{
    UIImage *result = [[UIImage alloc] initWithContentsOfFile:path];
    NSInteger qu = quality>0?quality:3;
    CGFloat q=qu/100.0f;
    NSString *thumbnail=[UIImageJPEGRepresentation(result,q) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return thumbnail;
}



- (void)extractThumbnail:(CDVInvokedUrlCommand*)command
{
    callbackId=command.callbackId;
    NSMutableDictionary *options = [command.arguments objectAtIndex: 0];
    NSString *thumbnail;
    if([@"image" isEqualToString: [options objectForKey:@"mediaType"]]){
        thumbnail=[self thumbnailImage:[options objectForKey:@"path"] quality:[[options objectForKey:@"thumbnailQuality"] integerValue]];
    }else{
        thumbnail=[self thumbnailVideo:[options objectForKey:@"path"] quality:[[options objectForKey:@"thumbnailQuality"] integerValue]];
    }
    
    
    [options setObject:thumbnail forKey:@"thumbnailBase64"];
    NSNumber* rotate = [NSNumber numberWithInt:0];
    [options setObject:rotate forKey:@"exifRotate"];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:options] callbackId:callbackId];
}

-(int)getOrientation:(UIImage *)image{
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
            return 180;
        case UIImageOrientationDownMirrored:
            return 180;
        case UIImageOrientationLeft:
            return 270;
        case UIImageOrientationLeftMirrored:
            return 270;
        case UIImageOrientationRight:
            return 90;
        case UIImageOrientationRightMirrored:
            return 90;
        case UIImageOrientationUp:
            return 0;
        case UIImageOrientationUpMirrored:
            return 0;
        default:
            return 0;
    }
}
@end
