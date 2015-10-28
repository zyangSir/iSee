//
//  ViewController.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/11.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "ViewController.h"
#import "ObjectFileItem.h"
#import "GSCommonDefine.h"

@interface ViewController()

@property (nonatomic, retain) NSString *linkMapFilePath;

@property (nonatomic, retain) NSArray *originalResults;

@property (nonatomic, retain) NSArray *sortedResults;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registNotification];
    _resultsTextView.editable = NO;
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Actions methods
- (IBAction)sortResultsBtnClicked:(NSButton *)sender {
    
    if (!_originalResults) {
        NSAlert *alertView = [[NSAlert alloc] init];
        [alertView setAlertStyle: NSAlertFirstButtonReturn];
        [alertView setMessageText:@"提示"];
        [alertView setInformativeText: @"请先加载linkmap文件"];
        [alertView beginSheetModalForWindow: [[NSApplication sharedApplication] mainWindow] completionHandler: nil];
        return;
    }
    
    if (!_sortedResults) {
        self.sortedResults = [_originalResults sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSComparisonResult ret;
            ObjectFileItem *preObj = (ObjectFileItem *)obj1;
            ObjectFileItem *nextObj = (ObjectFileItem *)obj2;
            if (preObj.funcSize < nextObj.funcSize) {
                ret = NSOrderedDescending;
            }else if (preObj.funcSize > nextObj.funcSize){
                ret = NSOrderedAscending;
            }else{
                ret = NSOrderedSame;
            }
            
            return ret;
        }];
        
    }
    
    _resultsTextView.string = [self formOutputWithResultsArray: _sortedResults];
}

- (IBAction)resetResultsBtnClicked:(NSButton *)sender {
    if (!_originalResults) {
        NSAlert *alertView = [[NSAlert alloc] init];
        [alertView setAlertStyle: NSAlertFirstButtonReturn];
        [alertView setMessageText:@"提示"];
        [alertView setInformativeText: @"请先加载linkmap文件"];
        [alertView beginSheetModalForWindow: [[NSApplication sharedApplication] mainWindow] completionHandler: nil];
        return;
    }
    _resultsTextView.string = [self formOutputWithResultsArray: _originalResults];
}

#pragma mark - inner logic
- (NSString *)formOutputWithResultsArray:(NSArray *)resultArray
{
    NSMutableString *resultText = [[NSMutableString alloc] initWithCapacity: 1000];
    NSEnumerator *enumerator = [resultArray objectEnumerator];
    ObjectFileItem *objectItem = nil;
    while (objectItem = [enumerator nextObject]) {
        NSString *aLineStr = [NSString stringWithFormat: @"%@,   Length: %lu\n", objectItem.name, objectItem.funcSize];
        [resultText appendString: aLineStr];
    }
    return [NSString stringWithString: resultText];
}


#pragma mark - notifications

- (void)registNotification
{
    SEL handler = @selector(onHandleResultsMsgDone:);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:handler name: RESULTS_DONE_NOTIFICATION object: nil];
    
    SEL arcTypeHandler = @selector(onHandleArchTypeFoundMsg:);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:arcTypeHandler name:ARC_TYPE_FIOUND_NOTIFICATION object: nil];
}

- (void)onHandleResultsMsgDone:(NSNotification *)notification
{
    //清除之前的结果
    self.originalResults = nil;
    self.sortedResults = nil;
    
    
    NSMutableArray *objectsArray = notification.object;
    NSUInteger length = objectsArray.count - 2;
    NSRange range = NSMakeRange(2, length);
    self.originalResults = [objectsArray subarrayWithRange: range];
    
    NSMutableString *resultText = [[NSMutableString alloc] initWithCapacity: 1000];
    if (_originalResults && _originalResults.count > 0) {
        NSEnumerator *enumerator = [_originalResults objectEnumerator];
        ObjectFileItem *objectItem = nil;
        while (objectItem = [enumerator nextObject]) {
            if ([objectItem.name hasSuffix:@"\n"]) {
                
                objectItem.name = [objectItem.name substringToIndex: objectItem.name.length - 1];
                
            }
            NSString *aLineStr = [NSString stringWithFormat: @"%@,   Length: %lu\n", objectItem.name, objectItem.funcSize];
            [resultText appendString: aLineStr];
        }
        [_resultsTextView setString: resultText];
    }
}

- (void)onHandleArchTypeFoundMsg:(NSNotification *)notification
{
    [_arcTypeTextField setStringValue: (NSString *)notification.object];
}

@end
