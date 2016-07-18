//
//  ChatViewController.h
//  chatDemo
//
//  Created by Li Bot on 2016/6/25.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
@import Firebase;
@import FirebaseStorage;
@import Photos;
#import <JSQMessagesViewController/JSQMessages.h>
#import "JSQMessageExt.h"
#import "POVoiceHUD.h"
#import "MWPhotoBrowser.h"
#import "UserTableViewController.h"
#import "AKLocationManager.h"
@interface ChatViewController : JSQMessagesViewController<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,POVoiceHUDDelegate,MWPhotoBrowserDelegate>

@property (strong, nonatomic) NSString* roomID;
@property (strong, nonatomic) NSString* receiverID;
@end