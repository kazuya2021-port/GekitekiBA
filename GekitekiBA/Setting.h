//
//  Setting.h
//  GekitekiBA
//
//  Created by uchiyama_Macmini on 2017/11/06.
//  Copyright © 2017年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject<NSTextFieldDelegate>
{
    NSString*   AcrobatPath;
    NSString*   PhotoshopPath;
    IBOutlet NSWindow* settingWindow;
    IBOutlet    NSTextField*    aPath;
    IBOutlet    NSTextField*    pPath;
}
@property (nonatomic, copy)NSString*   AcrobatPath;
@property (nonatomic, copy)NSString*   PhotoshopPath;
-(IBAction)append:(id)sender;
-(IBAction)close:(id)sender;
-(void)showSetting;
@end
