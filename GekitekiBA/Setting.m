//
//  Setting.m
//  GekitekiBA
//
//  Created by uchiyama_Macmini on 2017/11/06.
//  Copyright © 2017年 uchiyama_Macmini. All rights reserved.
//

#import "Setting.h"

@implementation Setting
@synthesize AcrobatPath,PhotoshopPath;
- (id)init
{
    if(self=[super init]) {
        AcrobatPath = @"";
        PhotoshopPath = @"";
    }
    return self;
}

- (void)awakeFromNib
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString* a = [ud stringForKey:@"ACROBAT"];
    NSString* p = [ud stringForKey:@"PHOTOSHOP"];
    [aPath setIdentifier:@"acro"];
    [aPath setDelegate:self];
    [pPath setIdentifier:@"photo"];
    [pPath setDelegate:self];
    if(a)
    {
        AcrobatPath = a;
        [aPath setStringValue:a];
    }
    if(p)
    {
        PhotoshopPath = p;
        [pPath setStringValue:p];
    }
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    if([[[obj object] identifier] compare:@"acro"] == NSOrderedSame)
    {
        [aPath setStringValue:[[obj object] stringValue]];
    }
    if([[[obj object] identifier] compare:@"photo"] == NSOrderedSame)
    {
        [pPath setStringValue:[[obj object] stringValue]];
    }
}

-(void)showSetting
{
    [settingWindow makeKeyAndOrderFront:self];
}
-(IBAction)append:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[aPath stringValue] forKey:@"ACROBAT"];
    [ud setObject:[pPath stringValue] forKey:@"PHOTOSHOP"];
    AcrobatPath =[aPath stringValue];
    PhotoshopPath =[pPath stringValue];
}
-(IBAction)close:(id)sender
{
    [settingWindow close];
}

@end
