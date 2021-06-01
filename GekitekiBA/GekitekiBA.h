//
//  GekitekiBA.h
//  GekitekiBA
//
//  Created by uchiyama_Macmini on 2017/11/06.
//  Copyright © 2017年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControlAcrobat.h"
#import "Setting.h"
@class ControlAcrobat;
@class Setting;
@interface GekitekiBA : NSObject <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSTableView* beforeTable;
    IBOutlet NSTableView* afterTable;
    IBOutlet NSTextField* savePath;
    
    IBOutlet NSPopUpButton* mode;
    
    IBOutlet NSTextField* kyoukaiLine;
    IBOutlet NSTextField* transparent;
    IBOutlet NSTextField* dpi;
    IBOutlet NSButton* useAnti;
    IBOutlet NSButton* usePS;
    
    IBOutlet ControlAcrobat* acroApp;
    IBOutlet Setting*   set;
    NSMutableArray* beforeData;
    NSMutableArray* afterData;
}
-(IBAction)showSetting:(id)sender;
-(IBAction)go:(id)sender;
-(IBAction)clear:(id)sender;
-(IBAction)openSave:(id)sender;
@end
