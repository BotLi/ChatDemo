//
//  ChatTableViewController.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/5.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "ChatTableViewController.h"
#import "JSQMessagesAvatarImage.h"
#import "ChatViewController.h"
#import "MBProgressHUD.h"
#import "DateUtils.h"
#import "NSString+AttributedString.h"

@interface ChatTableViewController ()
{
    int badgeCount;
    FirebaseProcess *process;
    NSMutableArray *userInfos;
}
@end
@implementation ChatTableViewController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        process = [FirebaseProcess sharedInstance];
        [self receiveData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveData)
                                                     name:@"USERLOGIN"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logout)
                                                     name:@"USERLOGOUT"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(badgeCountDown:)
                                                     name:@"badgeCountDown"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refresh)
                                                     name:@"REFRESH"
                                                   object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERLOGIN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERLOGOUT" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"badgeCountDown" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"REFRESH" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    badgeCount = 0;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:userInfos];
    
    //keep old data
    [tempArray enumerateObjectsUsingBlock:^(UserInfo *info,NSUInteger idx,BOOL *stop) {
        NSString *lastMessage = info.lastMessage;
        NSString *dateString = info.dateString;
        NSInteger bc = info.badgeCount;
        
        UserInfo *newObj = [process getUserByKey:info.userID];
        newObj.lastMessage = lastMessage;
        newObj.dateString = dateString;
        newObj.badgeCount = bc;
        
        [tempArray replaceObjectAtIndex:idx withObject:newObj];
    }];
    
    //sort array
    userInfos = [NSMutableArray arrayWithArray:[tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *obj1 = [DateUtils stringToDate:[(UserInfo*)a dateString]];
        NSDate *obj2 = [DateUtils stringToDate:[(UserInfo*)b dateString]];
        return -1*[obj1 compare:obj2];
    }]];
    [self.tableView reloadData];
}

- (void)receiveData
{
    userInfos = [[NSMutableArray alloc] init];
    FIRDatabaseReference *messageRef = process.personalMessagesRef;
    [messageRef keepSynced:YES];
    [messageRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snap)
     {
         if ([snap.key containsString:[process uid]])
         {
             [self messageAdd:snap.key];
         }
     }];
}

- (void)logout
{
    [userInfos removeAllObjects];
    badgeCount = 0;
    self.navigationController.tabBarItem.badgeValue = nil;
    [self.tableView reloadData];
}

- (void) badgeCountDown:(NSNotification*)notification
{
    badgeCount--;
    if (badgeCount <= 0)
    {
        badgeCount = 0;
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    else
    {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
    }
    
    NSDictionary* info = notification.userInfo;
    UserInfo *userInfo = [[userInfos filteredArrayUsingPredicate:
                           [NSPredicate predicateWithFormat:
                            [NSString stringWithFormat:@"self.userID = '%@'",info[fkMESSAGESENDERID]]
                            ]
                           ] objectAtIndex:0];
    userInfo.badgeCount--;
    [self.tableView reloadData];
}

- (void)tappedRightButton:(id)sender
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    
    if (selectedIndex == [self.tabBarController.viewControllers count] - 1)
    {
        [self.tabBarController setSelectedIndex:0];
    }
    else
    {
        [self.tabBarController setSelectedIndex:selectedIndex + 1];
    }
}

- (void)tappedLeftButton:(id)sender
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    
    if (selectedIndex == 0)
    {
        [self.tabBarController setSelectedIndex:[self.tabBarController.viewControllers count] - 1];
    }
    else
    {
        [self.tabBarController setSelectedIndex:selectedIndex - 1];
    }
}

- (void) messageAdd:(NSString*)child
{
    NSString *receiverID = [child stringByReplacingOccurrencesOfString:[process uid] withString:@""];
    FIRDatabaseReference *ref = [process.personalMessagesRef child:child];
    [ref keepSynced:YES];
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snap)
     {
         [self updateLastMessage:receiverID andSnap:snap];
     }];
    
    UserInfo *info = [process getUserByKey:receiverID];
    [userInfos addObject:info];
    
    [self.tableView reloadData];
}

- (void) updateLastMessage:(NSString*)receiverID andSnap:(FIRDataSnapshot *)snap
{
    NSString *lastMessage;
    NSString *dateString = snap.value[fkMESSAGEDATE];
    if (![snap.value[fkMESSAGETYPE] isEqualToString:fkMESSAGETYPETEXT])
    {
        lastMessage = [NSString stringWithFormat:@"sent %@",snap.value[fkMESSAGETYPE]];
    }
    else
    {
        lastMessage = snap.value[fkMESSAGECONTENT];
    }
    UserInfo *userInfo = [[userInfos filteredArrayUsingPredicate:
                           [NSPredicate predicateWithFormat:
                            [NSString stringWithFormat:@"self.userID = '%@'",receiverID]
                            ]
                           ] objectAtIndex:0];
    //update last message
    [userInfo setLastMessage:lastMessage];
    [userInfo setDateString:dateString];
    
    if (![snap.value[fkMESSAGESENDERID] isEqualToString:[process uid]] && [snap.value[fkMESSAGESTATUS] isEqualToString:fkMESSAGESTATUSUNREAD])
    {
        //increase badget count
        badgeCount++;
        NSString *badgeStr = [[NSString alloc] initWithFormat:@"%d",badgeCount];
        //show badge on tabbar
        self.navigationController.tabBarItem.badgeValue = badgeStr;
        
        //show badge in cell
        userInfo.badgeCount++;
        
        //move cell to top
        [userInfos exchangeObjectAtIndex:0 withObjectAtIndex:[userInfos indexOfObject:userInfo]];
    }
    
    [self.tableView reloadData];
}

- (void) doneButtonPress
{
    [self dismissViewControllerAnimated:YES completion:^(void){
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userInfos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ChatListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                reuseIdentifier:CellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    UserInfo *user = [userInfos objectAtIndex:indexPath.row];
    cell.chatTitleLabel.attributedText = [[user userName] withAttribute:AttributeTypeTitle];
    cell.chatImageView.image = [user image];
    cell.chatImageView.layer.cornerRadius = [self tableView:tableView heightForRowAtIndexPath:indexPath]/2-1;
    cell.chatImageView.clipsToBounds = YES;
    cell.lastMessageLabel.attributedText = [[user lastMessage] withAttribute:AttributeTypeSubTitle];
    cell.lastMessageDateLabel.attributedText = [[user dateString] withAttribute:AttributeTypeSubTitle];
    
    //for badge
    NSInteger badgeNumber = user.badgeCount;
    if (badgeNumber == 0)
    {
        cell.accessoryView = nil;
    }
    else
    {
        CGFloat size = 26;
        CGFloat digits = [[NSString stringWithFormat:@"%ld",(long)badgeNumber] length];
        CGFloat width = MAX(size, 0.7 * size * digits);
        UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, size)];
        badge.text = [NSString stringWithFormat:@"%ld",(long)badgeNumber];
        badge.layer.cornerRadius = size / 2;
        badge.layer.masksToBounds = YES;
        badge.textAlignment = NSTextAlignmentCenter;
        badge.textColor = [UIColor whiteColor];
        badge.backgroundColor = [UIColor redColor];
        
        cell.accessoryView = badge;
    }
    //end for badge
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *receiverID = [[userInfos objectAtIndex:[indexPath row]] userID];
    if ([receiverID isEqualToString:[process uid]])
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ChatViewController * chatVc = [[ChatViewController alloc] init];
    chatVc.senderId = [process uid];
    chatVc.senderDisplayName = [[process user] displayName];
    chatVc.receiverID = receiverID;
    chatVc.title = [(ChatListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] chatTitleLabel].text;
    UINavigationController * navVc = [[UINavigationController alloc] initWithRootViewController:chatVc];
    
    [self presentViewController:navVc animated:YES completion:^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
@end
