//
//  UserTableViewController.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/5.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "UserTableViewController.h"
#import "JSQMessagesAvatarImage.h"
#import "ChatViewController.h"
#import "MBProgressHUD.h"
#import "UserInfo.h"
#import "RoomInfo.h"
#import "NSString+AttributedString.h"

@interface UserTableViewController ()
{
    NSMutableArray *users;
    FirebaseProcess *process;
}
@end
@implementation UserTableViewController
@synthesize roomID;

- (id)initWithRoomID:(NSString*)rid
{
    self = [super init];
    
    if (self)
    {
        self.roomID = rid;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLogin)
                                                     name:@"USERLOGIN"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLogout)
                                                     name:@"USERLOGOUT"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setDataSource)
                                                     name:@"REFRESH"
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    process = [FirebaseProcess sharedInstance];
    [self setDataSource];
    if (!self.tabBarController)
    {        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(doneButtonPress)
                                       ];
        
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    else
    {
        NSArray *mySegments = [[NSArray alloc] initWithObjects:
                               @"All Users",
                               @"Favorite",
                               nil];
        
        self.segmentedCtrl = [[UISegmentedControl alloc] initWithItems:mySegments];
        [self.segmentedCtrl setSelectedSegmentIndex:0];
        [self.segmentedCtrl addTarget:self
                               action:@selector(setDataSource)
                     forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = self.segmentedCtrl;
    }
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

- (void)tappedRightButton:(id)sender
{
    if (!self.tabBarController) {
        return;
    }
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
    if (!self.tabBarController) {
        return;
    }
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    NSUInteger segSelectedIndex = [self.segmentedCtrl selectedSegmentIndex];
    if (segSelectedIndex == 0)
    {
        [self.tabBarController setSelectedIndex:selectedIndex - 1];
    }
    else
    {
        [self.segmentedCtrl setSelectedSegmentIndex:self.segmentedCtrl.selectedSegmentIndex - 1];
        [self setDataSource];
    }
}

- (void) setDataSource
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];

    if (roomID)
    {
        RoomInfo *room = [process getRoomByKey:roomID];
        
        [tempArray removeAllObjects];
        for (NSString *uid in room.currentUsers)
        {
            [tempArray addObject:[process getUserByKey:uid]];
        }
    }
    else
    {
        switch (self.segmentedCtrl.selectedSegmentIndex) {
            case 0:
                tempArray = [NSMutableArray arrayWithArray:process.userInfos];
                [tempArray removeObject:[process getUserByKey:[process uid]]];
                break;
            case 1:
                tempArray = [NSMutableArray arrayWithArray:[process.userInfos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.followerUser contains '%@'",[process uid]]]]];
                break;
            default:
                break;
        }
    }
    
    users = [NSMutableArray arrayWithArray:tempArray];
    if (process.user == nil)
    {
        [users removeAllObjects];
    }
    
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERLOGIN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USERLOGOUT" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"REFRESH" object:nil];
}

- (void) userLogin
{
    
}

- (void) userLogout
{
    [users removeAllObjects];
    [self.tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) doneButtonPress
{
    [self dismissViewControllerAnimated:YES completion:^(void){
        roomID = nil;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [users count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UserListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                reuseIdentifier:CellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.delegate = self;
    }

    UserInfo *user = [users objectAtIndex:indexPath.row];
    cell.chatTitleLabel.attributedText = [[[process getUserByKey:[user userID]] userName] withAttribute:AttributeTypeTitle];
    cell.chatImageView.image = [[process getUserByKey:[user userID]] image];
    cell.chatImageView.layer.cornerRadius = [self tableView:tableView heightForRowAtIndexPath:indexPath]/2-1;
    cell.chatImageView.clipsToBounds = YES;

    if ([[process getUserByKey:[process uid]].followeeUser containsObject:[user userID]])
    {
        [cell.favoriteIcon setTintColor:cell.contentView.tintColor];
    }
    else
    {
        [cell.favoriteIcon setTintColor:[UIColor lightGrayColor]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *receiverID = [[users objectAtIndex:[indexPath row]] userID];
    if ([receiverID isEqualToString:[process uid]])
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ChatViewController * chatVc = [[ChatViewController alloc] init];
    chatVc.senderId = [process uid];
    chatVc.senderDisplayName = [[process user] displayName];
    chatVc.receiverID = receiverID;
    chatVc.title = [(UserListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] chatTitleLabel].text;
    UINavigationController * navVc = [[UINavigationController alloc] initWithRootViewController:chatVc];
    
    [self presentViewController:navVc animated:YES completion:^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - UserListTableViewCellDelegate
- (void)UserListTableViewCell:(UserListTableViewCell*)cell favoriteIconTapAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfo *userInfo = [users objectAtIndex:[indexPath row]];
    
    [process favoriteForUser:userInfo];
}
@end
