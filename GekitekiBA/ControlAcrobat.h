//
//  ControlAcrobat.h
//  ProjectDB
//
//  Created by uchiyama_Macmini on 2017/06/13.
//  Copyright © 2017年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AcrobatPro.h"
#import "Distiller.h"
#import "Setting.h"
@class Setting;
@interface ControlAcrobat : NSObject
{
    AcrobatProApplication* app;
    DistillerApplication* appDist;
    IBOutlet Setting*   set;
}

- (NSMutableArray*)getPageCount:(NSArray*)paths;
- (void)splitAllPage:(NSString*)filepath savePath:(NSString*)savePath ofst:(int)ofst usePDFOffset:(BOOL)usePDFOffset;
- (void)splitPages:(NSString*)filepath savePath:(NSString*)savePath pages:(NSArray*)pages ofst:(int)ofst usePDFOffset:(BOOL)usePDFOffset;
- (void)revertPageOrder:(NSString*)filepath savePath:(NSString*)savePath rangePage:(NSRange)rng isAllPage:(BOOL)isAllPage;
- (void)deletePageAt:(NSString*)filepath page:(int)page;
- (void)addPageAt:(NSString*)filepath to:(NSString*)naosiPage page:(int)page;
- (NSArray*)getPageSize:(NSArray*)paths;
- (NSString*)getText:(NSString*)filepath pageNum:(NSInteger)num;
- (void)distillEPS:(NSString*)filePath;
- (void)closeAll:(BOOL)isSave;
- (NSString*)PDF2PS:(NSString*)ProcessFolder isBeforeData:(BOOL)isB;
@end
