//
//  ChatViewController.m
//  chatDemo
//
//  Created by Li Bot on 2016/6/25.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "ChatViewController.h"
#import "DateUtils.h"
@interface ChatViewController ()
{
    CLLocation *myLocation;
    FirebaseProcess *process;
}
@end
@implementation ChatViewController
{
    JSQMessagesBubbleImage *outgoingBubbleImageView;
    JSQMessagesBubbleImage *incomingBubbleImageView;
    NSMutableArray *messages;
    
    FIRDatabaseReference *messageRef;
    FIRStorageReference *storageRef;
    
    NSString *stopKey;
    
    AVAudioSession *session;
    AVAudioRecorder *recorder;
    NSURL *soundFileURL;
    NSMutableDictionary *recordSettings;
    POVoiceHUD *voiceHud;
    
    NSMutableArray *photos;
    
    BOOL isGroupChat;
    NSString *personalKey;
    FIRDatabaseHandle messageHandle;
    FIRDatabaseHandle statusHandle;
}
@synthesize roomID;

- (id)init
{
    self = [super init];
    if (self)
    {
        myLocation = [[CLLocation alloc] init];
        process = [FirebaseProcess sharedInstance];
        
        [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location){
            myLocation = location;
        }failedBlock:^(NSError *error){
            NSLog(@"AK-%@",error.localizedDescription);
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //init value
    messages = [[NSMutableArray alloc] initWithCapacity:0];
    storageRef = [[FIRStorage storage] reference];
    photos = [[NSMutableArray alloc] init];
    
    [self setupBubbles];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Done"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(doneButtonPress)
                                  ];
    
    UIBarButtonItem *usersButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Users"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(usersButtonPress)
                                   ];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    isGroupChat = roomID!=nil;
    if (!isGroupChat) {
        personalKey = [[[NSArray arrayWithObjects:self.senderId,_receiverID, nil] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] componentsJoinedByString:@""];
        messageRef = [process.personalMessagesRef child:personalKey];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = usersButton;
        messageRef = [process.messagesRef child:roomID];
    }
    
    [self observeMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) doneButtonPress
{
    [self dismissViewControllerAnimated:YES completion:^(void){
        if(isGroupChat) [process removeUserForRoomID:roomID];
        [messages removeAllObjects];
        messages = nil;
        [self.collectionView removeFromSuperview];
        [messageRef removeObserverWithHandle:messageHandle];
        [messageRef removeObserverWithHandle:statusHandle];
    }];
}

- (void)usersButtonPress
{
    UserTableViewController *userListView = [[UserTableViewController alloc] initWithRoomID:roomID];
    userListView.title = [NSString stringWithFormat:@"Users in Room : %@",self.title];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:userListView];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) observeMessages
{
    messageHandle = [[[messageRef queryOrderedByKey] queryLimitedToLast:25] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
                     {
                         self.showLoadEarlierMessagesHeader = YES;
                         if (stopKey == nil)
                         {
                             stopKey = snapshot.key;
                         }
                         [messages addObject:[self fetchMessage:snapshot]];
                         
                         [self finishReceivingMessage];
                     }];
}

- (id) fetchMessage:(FIRDataSnapshot *)snapshot
{
    NSString *messageBottomLabel = [[NSString alloc] init];
    //process status to read
    if (!isGroupChat
        && ![snapshot.value[fkMESSAGESENDERID] isEqualToString:self.senderId]
        && ![snapshot.value[fkMESSAGESTATUS] isEqualToString:fkMESSAGESTATUSREAD])
    {
        [[messageRef child:snapshot.key] updateChildValues:@{fkMESSAGESTATUS:fkMESSAGESTATUSREAD}];
        
        NSDictionary* userInfo = @{fkMESSAGESENDERID:snapshot.value[fkMESSAGESENDERID]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"badgeCountDown" object:self userInfo:userInfo];
    }
    if (!isGroupChat && [snapshot.value[fkMESSAGESENDERID] isEqualToString:self.senderId])
    {
        messageBottomLabel = snapshot.value[fkMESSAGESTATUS];
        //if unread add observe
        if ([messageBottomLabel isEqualToString:fkMESSAGESTATUSUNREAD])
        {
            statusHandle = [[messageRef child:snapshot.key] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snap)
                            {
                                //set status to read
                                [[[messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.messageKey = '%@'",snapshot.key]]] objectAtIndex:0] setMessageBottomLabel:fkMESSAGESTATUSREAD];
                                [self.collectionView reloadData];
                            }];
        }
    }
    
    if ([snapshot.value[fkMESSAGETYPE] isEqualToString:fkMESSAGETYPEPHOTO])
    {
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        
        JSQMessageExt *defaultPhotoMessage = [[JSQMessageExt alloc]
                                              initWithSenderId:snapshot.value[fkMESSAGESENDERID]
                                              senderDisplayName:snapshot.value[fkMESSAGESENDERDISPLAYNAME]
                                              date:[DateUtils stringToDate:snapshot.value[fkMESSAGEDATE]]
                                              media:photoItem
                                              messageKey:snapshot.key
                                              messageBottomString:messageBottomLabel];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            photoItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:snapshot.value[fkMESSAGECONTENT]]]];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                [self.collectionView reloadData];
            });
        });
        
        return defaultPhotoMessage;
    }
    else if ([snapshot.value[fkMESSAGETYPE] isEqualToString:fkMESSAGETYPEAUDIO])
    {
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithData:nil];
        JSQMessageExt *audioMessage = [[JSQMessageExt alloc]
                                       initWithSenderId:snapshot.value[fkMESSAGESENDERID]
                                       senderDisplayName:snapshot.value[fkMESSAGESENDERDISPLAYNAME]
                                       date:[DateUtils stringToDate:snapshot.value[fkMESSAGEDATE]]
                                       media:audioItem
                                       messageKey:snapshot.key
                                       messageBottomString:messageBottomLabel];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            audioItem.audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:snapshot.value[fkMESSAGECONTENT]]];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                [self.collectionView reloadData];
            });
        });
        
        return audioMessage;
    }
    else if ([snapshot.value[fkMESSAGETYPE] isEqualToString:fkMESSAGETYPEVIDEO])
    {
        NSURL *videoURL = [NSURL URLWithString:snapshot.value[fkMESSAGECONTENT]];
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
        JSQMessageExt *videoMessage = [[JSQMessageExt alloc]
                                       initWithSenderId:snapshot.value[fkMESSAGESENDERID]
                                       senderDisplayName:snapshot.value[fkMESSAGESENDERDISPLAYNAME]
                                       date:[DateUtils stringToDate:snapshot.value[fkMESSAGEDATE]]
                                       media:videoItem
                                       messageKey:snapshot.key
                                       messageBottomString:messageBottomLabel];
        return videoMessage;
    }
    else if ([snapshot.value[fkMESSAGETYPE] isEqualToString:fkMESSAGETYPELOCATION])
    {
        NSArray *array = [snapshot.value[fkMESSAGECONTENT] componentsSeparatedByString:@","];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[array objectAtIndex:0] floatValue] longitude:[[array objectAtIndex:1] floatValue]];
        
        JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
        [locationItem setLocation:location withCompletionHandler:^{
            [self.collectionView reloadData];
        }];
        
        JSQMessageExt *locationMessage = [[JSQMessageExt alloc]
                                          initWithSenderId:snapshot.value[fkMESSAGESENDERID]
                                          senderDisplayName:snapshot.value[fkMESSAGESENDERDISPLAYNAME]
                                          date:[DateUtils stringToDate:snapshot.value[fkMESSAGEDATE]]
                                          media:locationItem
                                          messageKey:snapshot.key
                                          messageBottomString:messageBottomLabel];
        return locationMessage;
    }
    else
    {
        JSQMessageExt *addMessage = [[JSQMessageExt alloc]
                                     initWithSenderId:snapshot.value[fkMESSAGESENDERID]
                                     senderDisplayName:snapshot.value[fkMESSAGESENDERDISPLAYNAME]
                                     date:[DateUtils stringToDate:snapshot.value[fkMESSAGEDATE]]
                                     text:snapshot.value[fkMESSAGECONTENT]
                                     messageKey:snapshot.key
                                     messageBottomString:messageBottomLabel];
        return addMessage;
    }
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [messages objectAtIndex:indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:[[[FIRAuth auth] currentUser] uid]])
    {
        return outgoingBubbleImageView;
    }
    else
    {
        return incomingBubbleImageView;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:[[[FIRAuth auth] currentUser] uid]])
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    return cell;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    UIImage *image = [[process getUserByKey:message.senderId] image];
    if (!image)
    {
        return [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"^_^"
                                                          backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                     font:[UIFont systemFontOfSize:14.0f]
                                                                 diameter:30.0f];;
    }
    return [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0f];
}

- (void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [self
     sendMessage:text
     andSenderId:senderId
     andSenderDisplayName:senderDisplayName
     andMessageType:fkMESSAGETYPETEXT
     ];
}
//===>For DisplayName
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessageExt *currentMessage = [messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessageExt *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessageExt *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}
//==>End DisplayName

//==>For Timestamp
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}
//==>End Timestamp

//==>For Bottom Label
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGroupChat)
    {
        return 0;
    }
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    
    if (![message.senderId isEqualToString:self.senderId]) {
        return 0;
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",message.messageBottomLabel]];
}
//==>End Bottom Label

-(void) setupBubbles
{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageView = [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    incomingBubbleImageView = [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            NSLocalizedString(@"Send Media - Album", nil),
                            NSLocalizedString(@"Send Media - Camera", nil),
                            NSLocalizedString(@"Send Audio", nil),
                            NSLocalizedString(@"Send Location", nil),
                            nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self addMedia:UIImagePickerControllerSourceTypeSavedPhotosAlbum andMediaTypes:@[@"public.image",@"public.movie"]];
            break;
            
        case 1:
            [self addMedia:UIImagePickerControllerSourceTypeCamera andMediaTypes:@[@"public.image",@"public.movie"]];
            break;
            
        case 2:
        {
            voiceHud = [[POVoiceHUD alloc] initWithParentView:self.view];
            voiceHud.title = @"Speak Now";
            
            [voiceHud setDelegate:self];
            [self.view addSubview:voiceHud];
            [voiceHud show];
        }
            break;
        case 3:
        {
            NSString *locationString = [NSString stringWithFormat:@"%f,%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude];
            [self
             sendMessage:locationString
             andSenderId:self.senderId
             andSenderDisplayName:self.senderDisplayName
             andMessageType:fkMESSAGETYPELOCATION
             ];
        }
            break;
    }
    
    [self finishSendingMessageAnimated:YES];
}

- (void) addMedia:(UIImagePickerControllerSourceType)sourceType andMediaTypes:(NSArray*)mediaTypes
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = sourceType;
    pickerController.mediaTypes = mediaTypes;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"])
    {
        NSString *mediaPath =
        [NSString stringWithFormat:@"%@/medias/%lld.mov",
         self.senderId,
         (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"video/quicktime";
        [[storageRef child:mediaPath] putData:[NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]] metadata:metadata
                                   completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                       if (error) {
                                           NSLog(@"Error uploading: %@", error);
                                           return;
                                       }
                                       [self
                                        sendMessage:[[metadata downloadURL] absoluteString]
                                        andSenderId:self.senderId
                                        andSenderDisplayName:self.senderDisplayName
                                        andMessageType:fkMESSAGETYPEVIDEO
                                        ];
                                   }];
        return;
    }
    NSURL *referenceUrl = info[UIImagePickerControllerReferenceURL];
    if (referenceUrl)
    {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = [assets firstObject];
        [asset requestContentEditingInputWithOptions:nil
                                   completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                       NSDictionary *info) {
                                       NSURL *imageFile = contentEditingInput.fullSizeImageURL;
                                       FIRStorageMetadata *metadata = [FIRStorageMetadata new];
                                       metadata.contentType = @"image/jpeg";
                                       NSString *filePath =
                                       [NSString stringWithFormat:@"%@/images/%lld.jpg",
                                        self.senderId,
                                        (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)
                                        ];
                                       // [START uploadimage]
                                       [[storageRef child:filePath]
                                        putData:[NSData dataWithContentsOfURL:imageFile] metadata:metadata
                                        completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error uploading: %@", error);
                                                return;
                                            }
                                            [self
                                             sendMessage:[[metadata downloadURL] absoluteString]
                                             andSenderId:self.senderId
                                             andSenderDisplayName:self.senderDisplayName
                                             andMessageType:fkMESSAGETYPEPHOTO
                                             ];
                                        }];
                                       // [END uploadimage]
                                   }];
    }
    else
    {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSString *imagePath =
        [NSString stringWithFormat:@"%@/images/%lld.jpg",
         self.senderId,
         (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"image/jpeg";
        [[storageRef child:imagePath] putData:imageData metadata:metadata
                                   completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                       if (error) {
                                           NSLog(@"Error uploading: %@", error);
                                           return;
                                       }
                                       [self
                                        sendMessage:[[metadata downloadURL] absoluteString]
                                        andSenderId:self.senderId
                                        andSenderDisplayName:self.senderDisplayName
                                        andMessageType:fkMESSAGETYPEPHOTO
                                        ];
                                   }];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) sendMessage:(NSString*)text andSenderId:(NSString*)senderId andSenderDisplayName:(NSString*)senderDisplayName andMessageType:(NSString*)messageType
{
    NSString *key = [[messageRef childByAutoId] key];
    if (isGroupChat)
    {
        [messageRef
         updateChildValues:@{key:@{
                                     fkMESSAGECONTENT:text,
                                     fkMESSAGESENDERID:senderId,
                                     fkMESSAGESENDERDISPLAYNAME:senderDisplayName,
                                     fkMESSAGETYPE:messageType,
                                     fkMESSAGEDATE:[DateUtils dateToString]
                                     }}
         ];
    }
    else
    {
        [messageRef
         updateChildValues:@{key:@{
                                     fkMESSAGECONTENT:text,
                                     fkMESSAGESENDERID:senderId,
                                     fkMESSAGESENDERDISPLAYNAME:senderDisplayName,
                                     fkMESSAGETYPE:messageType,
                                     fkMESSAGEDATE:[DateUtils dateToString],
                                     fkMESSAGESTATUS:fkMESSAGESTATUSUNREAD
                                     }}
         ];
    }
    [self finishSendingMessage];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    [[[[messageRef queryOrderedByKey] queryEndingAtValue:stopKey] queryLimitedToLast:26] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         NSUInteger index = 0;
         NSString *tempKey = nil;
         for (FIRDataSnapshot *snap in snapshot.children)
         {
             if (tempKey == nil)
             {
                 tempKey = snap.key;
             }
             if ([snap.key isEqualToString:stopKey])
             {
                 break;
             }
             [messages insertObject:[self fetchMessage:snap] atIndex:index];
             index++;
         }
         stopKey = tempKey;
         if (index < 25)
         {
             self.showLoadEarlierMessagesHeader = NO;
         }
         [self finishReceivingMessage];
         [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//         [self scrollToBottomAnimated:NO];
     }];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessageExt *message = [messages objectAtIndex:indexPath.item];
    BOOL isPhoto = [[NSStringFromClass([[message media] class]) lowercaseString] containsString:fkMESSAGETYPEPHOTO];
    BOOL isVideo = [[NSStringFromClass([[message media] class]) lowercaseString] containsString:fkMESSAGETYPEVIDEO];
    BOOL isLocation = [[NSStringFromClass([[message media] class]) lowercaseString] containsString:fkMESSAGETYPELOCATION];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:0];
    
    if (isVideo)
    {
        [photos removeAllObjects];
        MWPhoto *photo = [MWPhoto photoWithImage:nil];
        photo.videoURL = [(JSQVideoMediaItem*)[message media] fileURL];
        [photos addObject:photo];
    }
    if (isPhoto)
    {
        [photos removeAllObjects];
        [photos addObject:[MWPhoto photoWithImage:[(JSQPhotoMediaItem*)[message media] image]]];
    }
    
    if (isPhoto || isVideo)
    {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
    
    if (isLocation)
    {
        CLLocation *location = [(JSQLocationMediaItem*)[message media] location];
        NSString *urlString = [[NSString stringWithFormat:@"https://maps.apple.com/maps?ll=%f,%f&z=15",location.coordinate.latitude,location.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication]openURL:url];
    }
}
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}
- (void)POVoiceHUD:(POVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength
{
    NSData *data = [NSData dataWithContentsOfFile:recordPath];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"audio/caf";
    NSString *filePath =
    [NSString stringWithFormat:@"%@/audios/%lld.caf",
     self.senderId,
     (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)
     ];
    // [START uploadAudio]
    [[storageRef child:filePath]
     putData:data metadata:metadata
     completion:^(FIRStorageMetadata *metadata, NSError *error) {
         if (error) {
             NSLog(@"Error uploading: %@", error);
             return;
         }
         [self
          sendMessage:[[metadata downloadURL] absoluteString]
          andSenderId:self.senderId
          andSenderDisplayName:self.senderDisplayName
          andMessageType:fkMESSAGETYPEAUDIO
          ];
     }];
    // [END uploadAudio]
}
@end
