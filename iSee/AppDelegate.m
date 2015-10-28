//
//  AppDelegate.m
//  iSee
//
//  Created by Yangtsing.Zhang on 15/8/11.
//  Copyright (c) 2015年 ___Baidu Inc.___. All rights reserved.
//

#import "AppDelegate.h"
#import "DDFileReader.h"
#import "GSLinkMapParser.h"
#import "GSCommonDefine.h"

@interface AppDelegate ()

@property (nonatomic, retain) NSOpenPanel *fileSelectPanel;

@property (nonatomic, retain) NSString *selectedFilePath;

@property (nonatomic, retain) DDFileReader *textFileReader;

@property (nonatomic, retain) GSLinkMapParser *linkMapParser;

@end

@implementation AppDelegate

- (void)constructManager
{
    _fileSelectPanel = [[NSOpenPanel alloc] init];
    [_fileSelectPanel setCanChooseFiles: YES];
    [_fileSelectPanel setCanChooseDirectories: NO];
    [_fileSelectPanel setAllowsMultipleSelection: NO];
    [_fileSelectPanel setTreatsFilePackagesAsDirectories: YES];
    [_fileSelectPanel setAllowedFileTypes:@[@"txt"]];
    
    _linkMapParser = [[GSLinkMapParser alloc] init];

}

- (void)constructFileReader
{
    if (_textFileReader) {
        self.textFileReader = nil;
    }
    
    _textFileReader = [[DDFileReader alloc] initWithFilePath: _selectedFilePath];
    _linkMapParser.linkMapfileReader = _textFileReader;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self constructManager];
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openDocument:(id)sender
{
    [_fileSelectPanel beginSheetModalForWindow:  [[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *selectURL = [[self.fileSelectPanel URLs] firstObject];
            self.selectedFilePath = [selectURL path];
            [self constructFileReader];
            [self extractLinkMapDataFromFile];
            [self outputAnalysisResults];
        }
    }];
}

- (void)extractLinkMapDataFromFile
{
    NSString *aLineStr = [_textFileReader readLine];
    while (aLineStr) {
        if ([aLineStr hasPrefix: @"# Arch:"]) {//found code type
            NSRange range = [aLineStr rangeOfString: @":"];
            range.location += 2;
            range.length = aLineStr.length - range.location;
            NSString *arcTypeStr = [aLineStr substringWithRange: range];
            [[NSNotificationCenter defaultCenter] postNotificationName: ARC_TYPE_FIOUND_NOTIFICATION  object: arcTypeStr];
        }
        if ([_linkMapParser isSectionStartFlag:aLineStr]) {
            
            [_linkMapParser startSubParserWithStartFlag: aLineStr];
            aLineStr = [_linkMapParser lastLinkMapLineLog];
            
            continue;
        }
        
        aLineStr = [_textFileReader readLine];
    }
}

- (void)outputAnalysisResults
{
    [_linkMapParser outputObjectFileSize];
}



@end
