//
//  ViewController.m
//  chatDemo
//
//  Created by Li Bot on 2016/6/25.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "RoomTableViewController.h"
#import "MBProgressHUD.h"
#import "RoomInfo.h"
#import "DateUtils.h"
#import "NSString+AttributedString.h"

@interface RoomTableViewController ()
{
    NSMutableArray *rooms;
    FirebaseProcess *process;
}

@end

@implementation RoomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

    process = [FirebaseProcess sharedInstance];
    [process sync];
    
    rooms = [[NSMutableArray alloc] init];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    NSArray *mySegments = [[NSArray alloc] initWithObjects:
                           @"Global",
                           @"Create",
                           @"Favorite",
                           nil];
    
    self.segmentedCtrl = [[UISegmentedControl alloc] initWithItems:mySegments];
    [self.segmentedCtrl setSelectedSegmentIndex:0];
    [self.segmentedCtrl addTarget:self
                           action:@selector(setDataSource)
                 forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedCtrl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setDataSource)
                                                 name:@"REFRESH"
                                               object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"REFRESH" object:nil];
}

- (void)tappedRightButton:(id)sender
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    NSUInteger segSelectedIndex = [self.segmentedCtrl selectedSegmentIndex];
    if (segSelectedIndex != self.segmentedCtrl.numberOfSegments - 1)
    {
        [self.segmentedCtrl setSelectedSegmentIndex:segSelectedIndex + 1];
        [self setDataSource];
    }
    else
    {
        [self.tabBarController setSelectedIndex:selectedIndex + 1];
    }
}

- (void)tappedLeftButton:(id)sender
{
    NSUInteger segSelectedIndex = [self.segmentedCtrl selectedSegmentIndex];
    if (segSelectedIndex == 0)
    {
        [self.tabBarController setSelectedIndex:[self.tabBarController.viewControllers count] - 1];
    }
    else
    {
        [self.segmentedCtrl setSelectedSegmentIndex:self.segmentedCtrl.selectedSegmentIndex - 1];
        [self setDataSource];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ChatRoomListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ChatRoomListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:CellIdentifier];

        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.delegate = self;
    }
    RoomInfo *room = [rooms objectAtIndex:indexPath.row];
    cell.chatTitleLabel.attributedText = [room.roomName withAttribute:AttributeTypeTitle];
    
    if ([room.favoriteUsers containsObject:[process uid]])
    {
        [cell.favoriteIcon setTintColor:cell.contentView.tintColor];
    }
    else
    {
        [cell.favoriteIcon setTintColor:[UIColor lightGrayColor]];
    }
        
    cell.favoriteCountLabel.attributedText = [[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[room.favoriteUsers count]]] withAttribute:AttributeTypeSubTitle];
    cell.usersCountLabel.attributedText = [[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[room.currentUsers count]]] withAttribute:AttributeTypeSubTitle];
    cell.creatorLabel.attributedText = [[NSString stringWithFormat:@"%@ ( %@ )",[[process getUserByKey:room.creatorID] userName],room.createDate] withAttribute:AttributeTypeSubTitle];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([process user] == nil)
    {
        return;
    }
    RoomInfo *room = [rooms objectAtIndex:indexPath.row];
    //update room users
    [process addUserForRoom:room];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ChatViewController * chatVc = [[ChatViewController alloc] init];
    chatVc.senderId = [process uid];
    chatVc.senderDisplayName = [process user].displayName;
    chatVc.roomID = [room roomID];
    chatVc.title = [room roomName];
    UINavigationController * navVc = [[UINavigationController alloc] initWithRootViewController:chatVc];
    
    [self presentViewController:navVc animated:YES completion:^(void){
     [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [process deleteRoom:[rooms objectAtIndex:indexPath.row]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //Only Room Creator can delete
    if ([[[rooms objectAtIndex:indexPath.row] creatorID] isEqualToString:[process uid]])
    {
        return YES;
    }
    return NO;
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
    [self updateViewForUserStatusChange];
}
- (void) updateViewForUserStatusChange
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:([process user] != nil) ? @"Logout" : @"Login"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(loginButtonPress)
                                              ];

    UIBarButtonItem *addChat = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                action:@selector(addButton)];
    if ([process user] != nil)
    {
        self.navigationItem.leftBarButtonItems = @[addChat];
    }
    else
    {
        self.navigationItem.leftBarButtonItems = nil;
    }
}

- (void) setDataSource
{
    NSArray *tempArray;
    switch (self.segmentedCtrl.selectedSegmentIndex) {
        case 0:
            tempArray = [NSMutableArray arrayWithArray:process.roomInfos];
            break;
        case 1:
            tempArray = [NSMutableArray arrayWithArray:[process.roomInfos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"creatorID = '%@'",[process uid]]]]];
            break;
        case 2:
            tempArray = [NSMutableArray arrayWithArray:[process.roomInfos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.favoriteUsers contains '%@'",[process uid]]]]];
            break;
        default:
            break;
    }
    //sort array
    rooms = [NSMutableArray arrayWithArray:[tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber* first = [NSNumber numberWithInteger:[[(RoomInfo*)a currentUsers] count]];
        NSNumber* second = [NSNumber numberWithInteger:[[(RoomInfo*)b currentUsers] count]];
        if ([first integerValue] > [second integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if ([first integerValue] < [second integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }]];
    
    [self.tableView reloadData];
}

- (void)addButton
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Create Room" message:@"Create your own room!NOW!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[[alertView textFieldAtIndex:0] text] length] == 0)
    {
        return;
    }
    [process createRoom:[[alertView textFieldAtIndex:0] text]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - ChatRoomListTableViewCellDelegate
- (void)ChatRoomListTableViewCell:(ChatRoomListTableViewCell *)cell favoriteIconTapAtIndexPath:(NSIndexPath *)indexPath
{
    RoomInfo *room = [rooms objectAtIndex:indexPath.row];
    [process favoriteForRoom:room];
}

- (void)loginButtonPress
{
    if ([process user] != nil)
    {
        NSError *error;
        [[FIRAuth auth] signOut:&error];
        if (!error) {
            // Sign-out succeeded
            [process stopSync];
            [self setDataSource];
            [self updateViewForUserStatusChange];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERLOGOUT" object:nil];
        }
    }
    else
    {
        //firebaseauthui
        FIRAuthUI *authUI = [FIRAuthUI authUI];
        authUI.delegate = self;
        authUI.signInWithEmailHidden = NO;
        FIRGoogleAuthUI *googleAuthUI =
        [[FIRGoogleAuthUI alloc] initWithClientID:[FIRApp defaultApp].options.clientID];
        
        authUI.signInProviders = @[ googleAuthUI];
        [self presentViewController:authUI.authViewController animated:YES completion:NULL];
    }
}

- (void)authUI:(FIRAuthUI *)authUI
didSignInWithUser:(nullable FIRUser *)user
         error:(nullable NSError *)error {
    // Implement this method to handle signed in user or error if any.
    if (error == nil) {
        [process sync];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:user.displayName forKey:fkUSERNAME];
        
        if ([[[[user providerData] firstObject] providerID] isEqualToString:FIRGoogleAuthProviderID])
        {
            [dic setValue:[user.photoURL absoluteString] == nil ? @"" : [user.photoURL absoluteString] forKey:fkUSERPHOTOURL];
        }
        [[process.userRef child:user.uid] updateChildValues:dic];
        [self updateViewForUserStatusChange];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"USERLOGIN" object:nil];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}
@end
