//
//  ViewController.m
//
//  Created by Cady Holmes on 2/2/18.
//  Copyright © 2018 Cady Holmes. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "ViewController.h"
#import "KDKit.h"

@interface ViewController () <KDCounterViewDelegate, kdTableViewDelegate, UITextFieldDelegate, UITextViewDelegate, KDAdsViewDelegate, KDInAppHandlerDelegate> {
    NSMutableArray *counters;
    
    UIView *scrollViewMask;
    UIScrollView *scrollView;
    UIView *menuBar;
    UIView *footer;
    UIView *notesView;
    UITextView *notesField;
    
    UILabel *titleLabel;
    UIImageView *unlockIcon;
    
    NSString *notes;
 
    kdTableView *dataTable;
    kdPrimitiveDataStore *dataStore;
    kdPrimitiveDataStore *lastStore;
    kdPrimitiveDataStore *globalSettings;
    
    int openCount;
    
    NSMutableArray *currentData;
    NSArray *defaults;
    
    BOOL wait;
    
    UIView *container;
    
    NSArray *personalAds;
    KDAdsView *bannerAd;
    KDAdsView *interstitialAd;
    
    BOOL devMode;
    
    KDInAppHandler *removeAdsHandler;
    UIView *purchasePage;
}

@end

@implementation ViewController

-(BOOL)shouldAutorotate {
    return NO;
}
- (void)handleOpenCount {
    globalSettings = [[kdPrimitiveDataStore alloc] initWithFile:@"globalSettings"];
    if (!globalSettings.data) {
        int openCount = 1;
        [globalSettings save:@[[NSNumber numberWithInt:openCount]]];
        [self showWelcome];
    } else {
        int openCount = [[globalSettings.data lastObject] intValue];
        openCount++;
        openCount = openCount % 10;
        openCount = MAX(openCount, 1);
        
        [globalSettings save:@[[NSNumber numberWithInt:openCount]]];
        
        if (openCount == 3) {
            [SKStoreReviewController requestReview];
        }
    }
}
- (void)showPurchasePage {
    purchasePage = [KDHelpers popupWithClose:YES onView:self.view withCloseTarget:self forCloseSelector:@selector(tapClosePurchasePage:) withColor:[UIColor whiteColor] withBlurAmount:0];
    
    UILabel *label = [KDHelpers makeLabelWithWidth:VBW(purchasePage)*.85 andAlignment:NSTextAlignmentCenter andText:@"Remove All Ads\n$1.99 USD"];
    [KDHelpers setFontSize:40 forLabel:label];
    label.center = CGPointMake(VBW(purchasePage)/2, VBH(purchasePage)*.25);
    [purchasePage addSubview:label];
    
    UIView *buttons = [removeAdsHandler getButtonContainer];
    buttons.center = CGPointMake(VBW(purchasePage)/2, VBH(purchasePage)*.5);
    [purchasePage addSubview:buttons];
    
    [self.view addSubview:purchasePage];
    [KDAnimations animateViewGrowAndShow:purchasePage then:nil];
}
- (void)tapClosePurchasePage:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [self closePurchasePage];
}
- (void)closePurchasePage {
    [KDAnimations animateViewShrinkAndWink:purchasePage andRemoveFromSuperview:YES then:nil];
}
- (void)kdInAppPurchaseComplete:(KDInAppHandler*)inApp {
    [KDAdsView setRemoveAds:YES];
    [self resetUI];
    [self closePurchasePage];
}
- (void)tapUnlock:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [self showPurchasePage];
}
- (void)kdAd:(KDAdsView*)adView didTapPersonalAdWithGesture:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [self showPurchasePage];
}

- (void)showWelcome {
    UIImageView *welcome = [[UIImageView alloc] initWithFrame:self.view.bounds];
    welcome.image = [UIImage imageNamed:@"welcome"];
    welcome.contentMode = UIViewContentModeScaleAspectFit;
    welcome.userInteractionEnabled = YES;
    welcome.backgroundColor = [UIColor whiteColor];
    
    UILabel *close = [KDHelpers makeLabelWithWidth:VW(welcome) andFontSize:30];
    close.attributedText = [KDHelpers underlinedString:@"Ok!"];
    [KDHelpers setOriginY:VH(welcome)-VH(close)-150 forView:close];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeWelcome:)];
    [welcome addGestureRecognizer:tap];
    
    [welcome addSubview:close];
    [self.view addSubview:welcome];
}
- (void)closeWelcome:(UITapGestureRecognizer*)sender {
    [KDAnimations animateViewShrinkAndWink:sender.view andRemoveFromSuperview:YES then:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self save];
    
    if (![[currentData objectAtIndex:0] isEqualToString:@"_default"]) {
        wait = YES;
        [dataTable addData:currentData forKey:[currentData objectAtIndex:0] canEdit:YES];
        [dataStore save:dataTable.data];
        wait = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KDAdsView setRemoveAds:YES];
    devMode = YES;
    
    [self loadUI];
    
    //[self showWelcome];
}

- (void)kdInAppHandlerGotReceipt:(KDInAppHandler*)inApp receipt:(NSDictionary*)receipt {
    //NSLog(@"%@",receipt);
    [KDWarningLabel flashWarningWithText:@"Success"];
    float originalVersion = [[receipt objectForKey:@"original_application_version"] floatValue];
    if (originalVersion < 1.09) {
        [KDAdsView setRemoveAds:YES];
        [self resetUI];
    }
}

- (void)resetUI {
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [self loadUI];
}

- (void)loadUI {
    personalAds = @[@"Remove all ads via an in-app purchase!",
                    @"You can use your project notes\nto keep track of anything at all."
                    ];
    
    bannerAd = [KDAdsView initWithUID:0 andDelegate:self andDevMode:devMode];
    [bannerAd makeFBBannerAdWithPlacementID:@"159169041539253_159178058205018"];
    bannerAd.personalAds = [NSArray arrayWithArray:personalAds];
    [self.view addSubview:bannerAd];
    
    interstitialAd = [KDAdsView initWithUID:1 andDelegate:self andDevMode:devMode];
    [interstitialAd makeFBInterstitialAdWithPlacementID:@"159169041539253_169385693850921"];
    interstitialAd.personalAds = personalAds;
    [self.view addSubview:interstitialAd];
    
    removeAdsHandler = [KDInAppHandler initWithUID:0 productID:@"removeAds" andDelegate:self];
    removeAdsHandler.checkReceiptOnRestore = YES;
    removeAdsHandler.devMode = devMode;
    //[removeAdsHandler getReceipt];
    
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SW(), SH()-bannerAd.bannerAdHeight-bannerAd.bannerAdOffset)];
    
    wait = YES;
    
    float fontSize = 20;
    float headerHeight = 60;
    
    dataTable = [[kdTableView alloc] initWithFrame:container.bounds];
    dataTable.canReorder = YES;
    dataTable.animate = YES;
    dataTable.allowsEditing = YES;
    dataTable.hasCloseButton = YES;
    dataTable.delegate = self;
    
    dataStore = [[kdPrimitiveDataStore alloc] initWithFile:@"tableData"];
    lastStore = [[kdPrimitiveDataStore alloc] initWithFile:@"lastData"];
    
    menuBar = [[UIView alloc] initWithFrame:CGRectMake(0, SB(), SW(), headerHeight)];
    
    UILabel *save = [KDHelpers makeLabelWithWidth:VW(menuBar)/3 andHeight:VH(menuBar)];
    save.font = [UIFont fontWithName:KDFontNormal size:fontSize];
    save.userInteractionEnabled = YES;
    save.text = @"save";
    
    UILabel *add = [KDHelpers makeLabelWithWidth:VW(menuBar)/3 andHeight:VH(menuBar)];
    add.font = [UIFont fontWithName:KDFontNormal size:fontSize*1.2];
    [KDHelpers setOriginX:(VBW(menuBar)/3) forView:add];
    add.userInteractionEnabled = YES;
    add.text = @"add counter";
    
    UILabel *load = [KDHelpers makeLabelWithWidth:VW(menuBar)/3 andHeight:VH(menuBar)];
    load.font = [UIFont fontWithName:KDFontNormal size:fontSize];
    load.text = @"load";
    load.userInteractionEnabled = YES;
    [KDHelpers setOriginX:(VBW(menuBar)/3)*2 forView:load];
    
    UITapGestureRecognizer *tapAdd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAdd:)];
    [add addGestureRecognizer:tapAdd];
    
    UITapGestureRecognizer *tapSave = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSave:)];
    [save addGestureRecognizer:tapSave];
    
    //    UILongPressGestureRecognizer *lpSave = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lpSave:)];
    //    [save addGestureRecognizer:lpSave];
    
    UITapGestureRecognizer *tapLoad = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLoad:)];
    [load addGestureRecognizer:tapLoad];
    
    [menuBar addSubview:save];
    [menuBar addSubview:add];
    [menuBar addSubview:load];
    [container addSubview:menuBar];
    
    float margin = 5;
    footer = [[UIView alloc] initWithFrame:CGRectMake(0, SH()-headerHeight-bannerAd.bannerAdHeight-bannerAd.bannerAdOffset, SW(), headerHeight)];
    footer.backgroundColor = [UIColor whiteColor];
    
    UILabel *help = [KDHelpers makeLabelWithWidth:headerHeight andHeight:headerHeight];
    [KDHelpers setOriginX:margin forView:help];
    help.text = @"?";
    [footer addSubview:help];
    
    UITapGestureRecognizer *tapHelp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHelp:)];
    [help addGestureRecognizer:tapHelp];
    
    UILabel *details = [KDHelpers makeLabelWithWidth:headerHeight andHeight:headerHeight];
    [KDHelpers setOriginX:SW()-headerHeight-margin forView:details];
    details.text = @"notes";
    [footer addSubview:details];
    
    UITapGestureRecognizer *tapDetails = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetails:)];
    [details addGestureRecognizer:tapDetails];
    
    if (bannerAd.removeAds) {
        titleLabel = [KDHelpers makeLabelWithWidth:VW(footer)/3 andHeight:30];
        [KDHelpers centerView:titleLabel onView:footer];
        [footer addSubview:titleLabel];
    } else {
        unlockIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, footer.bounds.size.width/3, footer.bounds.size.height/2.5)];
        unlockIcon.image = [UIImage imageNamed:@"unlock.pdf"];
        unlockIcon.contentMode = UIViewContentModeScaleAspectFit;
        unlockIcon.userInteractionEnabled = YES;
        [KDHelpers centerView:unlockIcon onView:footer];
        
        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUnlock:)];
        [unlockIcon addGestureRecognizer:t];
        
        [footer addSubview:unlockIcon];
    }
    
    
    [container addSubview:footer];
    
    [self loadScrollView];
    [container addSubview:dataTable];
    
    defaults =  @[@"Counter", // 0 title
                  @"",          // 1 subtitle
                  @0,           // 2 usemin
                  @0,           // 3 usemax
                  @0,           // 4 link
                  @0,           // 5 wrap
                  @0,           // 6 color
                  @0,           // 7 min count
                  @0,           // 8 max count
                  @0            // 9 current count
                  ];
    
    if (lastStore.data.count > 0) {
        currentData = [[NSMutableArray alloc] initWithArray:lastStore.data];
        dataTable.data = [[NSMutableArray alloc] initWithArray:dataStore.data];
    } else {
        NSArray *def = @[@"_default",           //name
                         @[defaults],               //counters
                         @"Tap to edit your notes!" //notes
                         ];
        
        currentData = [[NSMutableArray alloc] initWithArray:def];
        [self save];
        [dataTable addData:currentData forKey:[currentData objectAtIndex:0] canEdit:NO];
        [dataStore save:dataTable.data];
    }
    
    [self loadCounters];
    notes = [currentData objectAtIndex:2];
    titleLabel.text = [currentData objectAtIndex:0];
    wait = NO;
    
    [container sendSubviewToBack:titleLabel];
    [container sendSubviewToBack:scrollView];
    
    [self handleOpenCount];
    
    [self.view addSubview:container];
}

- (void)loadCounters {
    for (KDCounterView *counter in scrollView.subviews) {
        [counter removeFromSuperview];
    }
    [self updateScrollView];
    
    counters = [[NSMutableArray alloc] init];
    NSArray *tempCounters = [NSArray arrayWithArray:[currentData objectAtIndex:1]];
    for (int i = 0; i < tempCounters.count; i++) {
        NSArray *counterData = [NSArray arrayWithArray:[tempCounters objectAtIndex:i]];
        KDCounterView *thisCounter = [KDCounterView initWithID:i];
        thisCounter.borderLineMargin = SW()/15;
        thisCounter.delegate = self;
        
        thisCounter.title = [counterData objectAtIndex:0];
        thisCounter.subtitle = [counterData objectAtIndex:1];
        thisCounter.hasMinCount = [[counterData objectAtIndex:2] boolValue];
        thisCounter.hasMaxCount = [[counterData objectAtIndex:3] boolValue];
        thisCounter.willLink = [[counterData objectAtIndex:4] boolValue];
        thisCounter.willWrap = [[counterData objectAtIndex:5] boolValue];
        thisCounter.currentColor = [[counterData objectAtIndex:6] intValue];
        thisCounter.minCount = [[counterData objectAtIndex:7] intValue];
        thisCounter.maxCount = [[counterData objectAtIndex:8] intValue];
        thisCounter.currentCount = [[counterData objectAtIndex:9] intValue];
        thisCounter.uid = i;
        [thisCounter updateCurrentCountLabel];
        
        if (counters.count > 0) {
            [KDHelpers appendView:thisCounter toView:[counters objectAtIndex:counters.count-1] withMarginY:3 andIndentX:0];
        } else {
            [KDHelpers setOriginY:0 forView:thisCounter];
        }
        
        [counters addObject:thisCounter];
        
        [self updateScrollView];
        [KDAnimations animateViewGrowAndShow:thisCounter then:nil];
        [scrollView addSubview:thisCounter];
    }
}
- (void)loadScrollView {
    if (scrollViewMask) {
        [KDAnimations animateViewShrinkAndWink:scrollViewMask andRemoveFromSuperview:YES then:nil];
    }
    scrollViewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VW(container), VH(container)-VH(menuBar)-SB()-VH(footer))];
    scrollViewMask.backgroundColor = [UIColor whiteColor];
    scrollView = [[UIScrollView alloc] initWithFrame:scrollViewMask.bounds];
    scrollView.contentSize = CGSizeMake(VW(scrollView), 0);
    [KDHelpers appendView:scrollViewMask toView:menuBar withMarginY:0 andIndentX:0];
    [scrollViewMask addSubview:scrollView];
    [KDHelpers addGradientMaskToView:scrollViewMask];
    [container addSubview:scrollViewMask];

}

- (void)tapAdd:(UITapGestureRecognizer*)sender {
    [self addCounter];
    [KDAnimations jiggle:sender.view];
}
- (void)tapSave:(UITapGestureRecognizer*)sender {

    if (!bannerAd.removeAds) {
        UIView *placeholder = [[UIView alloc] initWithFrame:self.view.bounds];
        placeholder.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [KDHelpers makeLabelWithWidth:placeholder.bounds.size.width*.9 andAlignment:NSTextAlignmentCenter andText:@"Hey, check out this short video while your project is being saved.\n\nPurchasing the full version will remove this step and make your saves instant!"];
        label.center = CGPointMake(placeholder.bounds.size.width/2, placeholder.bounds.size.height*.25);
        
        UILabel *label2 = [KDHelpers makeLabelWithWidth:placeholder.bounds.size.width*.9 andAlignment:NSTextAlignmentCenter andText:@"Ok!"];
        label2.tag = 0;
        [KDHelpers setFontSize:45 forLabel:label2];
        [KDHelpers setWidth:placeholder.bounds.size.width*.9 forView:label2];
        label2.center = CGPointMake(placeholder.bounds.size.width/2, placeholder.bounds.size.height*.5);
        
        UILabel *label3 = [KDHelpers makeLabelWithWidth:placeholder.bounds.size.width*.9 andAlignment:NSTextAlignmentCenter andText:@"Nevermind."];
        label3.tag = 1;
        [KDHelpers setFontSize:30 forLabel:label3];
        [KDHelpers setWidth:placeholder.bounds.size.width*.9 forView:label3];
        label3.center = CGPointMake(placeholder.bounds.size.width/2, placeholder.bounds.size.height*.75);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSaveReally:)];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSaveReally:)];
        [label2 addGestureRecognizer:tap];
        [label3 addGestureRecognizer:tap2];
        
        [placeholder addSubview:label];
        [placeholder addSubview:label2];
        [placeholder addSubview:label3];
        
        [self.view addSubview:placeholder];
        [KDAnimations animateViewGrowAndShow:placeholder then:nil];
    } else {
        [dataTable openSaveDialogue];
    }

//    if ([[currentData objectAtIndex:0] isEqualToString:@"_default"]) {
//        [dataTable openSaveDialogue];
//    } else {
//        for (int i = 0; i < dataTable.data.count; i++) {
//            NSArray *arr = [dataTable.data objectAtIndex:i];
//
//            if ([[currentData objectAtIndex:0] isEqualToString:[arr objectAtIndex:0]]) {
//                [dataTable deleteDataAtIndex:i];
//                [dataTable insertData:currentData forKey:[currentData objectAtIndex:0] atIndex:i canEdit:YES];
//                [dataStore save:dataTable.data];
//            }
//        }
//    }

    [KDAnimations jiggle:sender.view];
}
- (void)kdAdDidFinishInterstitial:(KDAdsView *)adView {
    [dataTable openSaveDialogue];
    [interstitialAd resetInterstitialAdFB];
}
- (void)tapSaveReally:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    if (sender.view.tag < 1) {
        [interstitialAd showInterstitialAdFB];
    }
    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
}

//- (void)lpSave:(UILongPressGestureRecognizer*)sender {
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        [dataTable openSaveDialogue];
//        [KDAnimations jiggle:sender.view];
//    }
//}

- (void)tapLoad:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    
    [dataTable show];
}
- (void)tapHelp:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view amount:1.2 then:nil];
    
    UIView *help = [KDHelpers popupWithClose:YES onView:self.view withCloseTarget:self forCloseSelector:@selector(closeHelp:) withColor:[UIColor whiteColor] withBlurAmount:0];
    [KDAnimations animateViewGrowAndShow:help then:nil];
    
    float topMargin = 80;
    if ([KDHelpers iPhoneXCheck]) {
        topMargin = 90;
    }
    float margin = 10;
    
    UIView *maskedView = [[UIView alloc] initWithFrame:CGRectMake(margin, topMargin, VW(help)-(margin*2), VH(help)-margin-topMargin)];
    maskedView.backgroundColor = [UIColor whiteColor];
    maskedView.layer.cornerRadius = 20;
    
    maskedView.layer.masksToBounds = NO;
    maskedView.layer.shadowOffset = CGSizeMake(0, 1);
    maskedView.layer.shadowRadius = 3;
    maskedView.layer.shadowOpacity = 0.2;
    
    UIView *mask = [[UIView alloc] initWithFrame:maskedView.bounds];
    [KDHelpers addGradientMaskToView:mask];
    
    float pad = 20;
    KDScrollView *container = [KDScrollView initWithID:0 andFrame:CGRectMake(pad,0,VW(maskedView)-(pad*2),VH(maskedView))];
    
    NSArray *helpImages = @[[UIImage imageNamed:@"fig0"],
                            [UIImage imageNamed:@"fig1"],
                            [UIImage imageNamed:@"fig2"],
                            [UIImage imageNamed:@"fig3"],
                            [UIImage imageNamed:@"fig3b"],
                            [UIImage imageNamed:@"fig4"],
                            [UIImage imageNamed:@"fig5"],
                            [UIImage imageNamed:@"fig6"],
                            [UIImage imageNamed:@"fig7"],
                            [UIImage imageNamed:@"fig7b"]];
    
    float height = 250;
    if ([KDHelpers iPadCheck]) {
        height = 500;
    }
    for (int i = 0; i < helpImages.count; i++) {
        UIImage *image = [helpImages objectAtIndex:i];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VW(container), height)];
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFit;
        [container appendView:view];
    }
    
    UILabel *footer = [KDHelpers makeLabelWithWidth:VW(container) andFontSize:16];
    [KDHelpers setHeight:height forView:footer];
    footer.text = @"superofficial@notnatural.co";
    [container appendView:footer];
    
    [mask addSubview:container];
    [maskedView addSubview:mask];
    [help addSubview:maskedView];
    [self.view addSubview:help];
}

- (void)closeHelp:(UITapGestureRecognizer*)sender {
    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
}

- (void)tapDetails:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    
    notesView = [KDHelpers popupWithClose:YES onView:self.view withCloseTarget:self forCloseSelector:@selector(tapCloseNotes:) withColor:[UIColor whiteColor] withBlurAmount:0];
    
    float marginX = 10;
    float topMargin = 65;
    float titleMargin = 10;
    UILabel *notesTitleLabel = [KDHelpers makeLabelWithWidth:(VW(self.view)/2)-titleMargin andHeight:30];
    [KDHelpers setOriginX:titleMargin andY:topMargin forView:notesTitleLabel];
    notesTitleLabel.textAlignment = NSTextAlignmentLeft;
    notesTitleLabel.text = [currentData objectAtIndex:0];
    [notesView addSubview:notesTitleLabel];
    
    float yPad = 10;
    UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VW(notesView)-(marginX*2), VH(notesView)-topMargin-marginX-VH(notesTitleLabel)-yPad)];
    [KDHelpers appendView:mask toView:notesTitleLabel withMarginY:yPad andIndentX:marginX];
    mask.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* noteScroll = [[UIScrollView alloc] initWithFrame:mask.bounds];
    noteScroll.contentSize = CGSizeMake(VW(noteScroll), VH(scrollView)*4);

    notesField = [[UITextView alloc] initWithFrame:noteScroll.bounds];
    notesField.delegate = self;
    notesField.font = [UIFont fontWithName:KDFontNormal size:18];
    notesField.text = notes;

    UIToolbar *tools = [[UIToolbar alloc] init];
    [tools sizeToFit];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(doneClicked)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cancelClicked)];
    [tools setItems:[NSArray arrayWithObjects:cancel, spacer, done, nil]];

    notesField.inputAccessoryView = tools;
    
    
    
    [noteScroll addSubview:notesField];
    [mask addSubview:noteScroll];
    [KDHelpers addGradientMaskToView:mask];
    [notesView addSubview:mask];
    
    [self.view addSubview:notesView];
    [KDAnimations animateViewGrowAndShow:notesView then:nil];
}

- (void)doneClicked {
    notes = notesField.text;
    [currentData replaceObjectAtIndex:2 withObject:notes];
    [self save];
    [notesField resignFirstResponder];
}
- (void)cancelClicked {
    notesField.text = notes;
    [notesField resignFirstResponder];
}

- (void)tapCloseNotes:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [KDAnimations animateViewShrinkAndWink:notesView andRemoveFromSuperview:YES then:nil];
}

- (void)addCounter {
    wait = YES;
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[currentData objectAtIndex:1]];
    [temp addObject:defaults];
    [currentData replaceObjectAtIndex:1 withObject:temp];
    
    KDCounterView *counter = [self makeCounter];
    [counters addObject:counter];
    
    [self updateScrollView];
    [KDAnimations animateViewGrowAndShow:counter then:nil];
    [scrollView addSubview:counter];
    [self save];
    wait = NO;
}
- (void)updateScrollView {
    float counterHeight = 0;
    if (counters.count > 0) {
        counterHeight = VH([counters firstObject]);
    }
    float scrollViewHeight = counterHeight * (counters.count + 2);
    scrollView.contentSize = CGSizeMake(VW(scrollView), scrollViewHeight);
}

- (KDCounterView*)makeCounter {
    KDCounterView *counter = [KDCounterView initWithID:(int)counters.count];
    counter.title = @"Counter";
    counter.borderLineMargin = SW()/15;
    counter.delegate = self;
    
    if (counters.count > 0) {
        [KDHelpers appendView:counter toView:[counters objectAtIndex:counters.count-1] withMarginY:3 andIndentX:0];
    } else {
        [KDHelpers setOriginY:0 forView:counter];
    }
    
    return counter;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSString *text = textView.text;
    if ([text isEqualToString:@"Tap to edit your notes!"]) {
        textView.text = @"";
    }
}

- (void)kdCounterHitMax:(KDCounterView*)counter {
    
}
- (void)kdCounterHitMin:(KDCounterView*)counter {

}
- (void)kdCounterDidWrap:(KDCounterView*)counter {

}
- (void)kdCounterWillEditTitle:(KDCounterView*)counter {
    float yCorrect = 0;
    if (counter.uid > 0) {
        yCorrect = VH(counter)/2;
    }
    CGPoint offset = CGPointMake(counter.frame.origin.x, counter.frame.origin.y-yCorrect);
    [scrollView setContentOffset:offset animated:YES];
}
- (void)kdCounterDidLink:(KDCounterView*)counter {
    if (counters.count-1 > counter.uid) {
        KDCounterView *linked = [counters objectAtIndex:counter.uid+1];
        if (counter.lastCount < counter.currentCount) {
            [linked upCount];
        } else {
            [linked downCount];
        }
    }
}
- (void)kdCounterDeleteTapped:(KDCounterView*)counter {
    wait = YES;
    int index = counter.uid;
    [KDAnimations animateViewShrinkAndWink:counter andRemoveFromSuperview:YES then:^{
        [counters removeObjectAtIndex:index];
        NSMutableArray *temp = [currentData objectAtIndex:1];
        [temp removeObjectAtIndex:index];
        [currentData replaceObjectAtIndex:1 withObject:temp];
        if (index < counters.count) {
            for (int i = index;i < counters.count; i++) {
                KDCounterView *thisCounter = [counters objectAtIndex:i];
                thisCounter.uid = i;
                [KDHelpers setOriginY:OY(thisCounter)-VH(thisCounter) forView:thisCounter];
                [self updateScrollView];
            }
        }
        if (counters.count < 1) {
            [self addCounter];
        }
        wait = NO;
        [self save];
    }];
}
- (void)kdCounterDidChange:(KDCounterView*)counter {
    if (!wait) {
        NSString *title = @" ";
        if (counter.title) {
            title = counter.title;
        }
        NSString *subtitle = @" ";
        if (counter.subtitle) {
            subtitle = counter.subtitle;
        }
        NSArray *temp = @[title,                                    // 0 title
                          subtitle,                                 // 1 subtitle
                          [NSNumber numberWithBool:counter.hasMinCount],    // 2 usemin
                          [NSNumber numberWithBool:counter.hasMaxCount],    // 3 usemax
                          [NSNumber numberWithBool:counter.willLink],       // 4 link
                          [NSNumber numberWithBool:counter.willWrap],       // 5 wrap
                          [NSNumber numberWithInt:counter.currentColor],   // 6 color
                          [NSNumber numberWithInt:counter.minCount],       // 7 min count
                          [NSNumber numberWithInt:counter.maxCount],       // 8 max count
                          [NSNumber numberWithInt:counter.currentCount]    // 9 current count
                          ];
        NSMutableArray *temp2 = [[NSMutableArray alloc] initWithArray:[currentData objectAtIndex:1]];
        [temp2 replaceObjectAtIndex:counter.uid withObject:temp];
        [currentData replaceObjectAtIndex:1 withObject:temp2];
        [self save];
    }
}

-(void)kdTableView:(kdTableView*)tableView didSaveWithKey:(NSString*)key {
    wait = YES;
    [currentData replaceObjectAtIndex:0 withObject:key];
    [dataTable addData:currentData forKey:key canEdit:YES];
    [dataStore save:dataTable.data];
    wait = NO;
    titleLabel.text = key;
}
-(void)kdTableView:(kdTableView*)tableView didSelectRowAtIndex:(int)index {
    if (![[currentData objectAtIndex:0] isEqualToString:@"_default"]) {
        for (int i = 0; i < dataTable.data.count; i++) {
            NSArray *arr = [dataTable.data objectAtIndex:i];
            
            if ([[currentData objectAtIndex:0] isEqualToString:[arr objectAtIndex:0]]) {
                [dataTable deleteDataAtIndex:i];
                [dataTable insertData:currentData forKey:[currentData objectAtIndex:0] atIndex:i canEdit:YES];
                [dataStore save:dataTable.data];
            }
        }
    }
    
    wait = YES;
    [counters removeAllObjects];
    counters = nil;
    currentData = [[NSMutableArray alloc] initWithArray:[[tableView.data objectAtIndex:index] objectAtIndex:1]];
    NSLog(@"loaded %@",[currentData objectAtIndex:0]);
    [self save];
    [self loadCounters];
    notes = [currentData objectAtIndex:2];
    [KDHelpers wait:.4 then:^{
        if (tableView.hasCloseButton) {
            [tableView hide];
        }
        titleLabel.text = [currentData objectAtIndex:0];
        wait = NO;
    }];
}
-(void)kdTableView:(kdTableView*)tableView movedRowFromIndex:(int)fromIndex toIndex:(int)toIndex {
}
-(void)kdTableView:(kdTableView*)tableView finishedMovingRowTo:(int)index {
    [dataStore save:dataTable.data];
}
-(void)kdTableView:(kdTableView*)tableView didDeleteDataAtIndex:(int)index {
    [dataStore save:dataTable.data];
}
-(void)kdTableView:(kdTableView*)tableView didRenameDataAtIndex:(int)index {
    [dataStore save:dataTable.data];
}

- (void)save {
    NSArray *arr = [NSArray arrayWithArray:currentData];
    [lastStore save:arr];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
