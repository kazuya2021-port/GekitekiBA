//
//  GekitekiBA.m
//  GekitekiBA
//
//  Created by uchiyama_Macmini on 2017/11/06.
//  Copyright © 2017年 uchiyama_Macmini. All rights reserved.
//

#import "GekitekiBA.h"

@implementation GekitekiBA

#pragma mark -
#pragma mark Init/Dealloc/Finalize

- (id)init
{
    if(self=[super init]) {
        beforeData		= [NSMutableArray array];
        afterData       = [NSMutableArray array];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [afterTable registerForDraggedTypes:ARRAY(NSFilenamesPboardType)];
    [beforeTable registerForDraggedTypes:ARRAY(NSFilenamesPboardType)];
    [beforeTable setTarget:self];
    [beforeTable setDelegate:self];
    [afterTable setTarget:self];
    [afterTable setDelegate:self];
}

-(NSString*)compareStart:(NSString*)cmpMode
               rasterDpi:(int)rasterDpi
              transRatio:(int)transRatio
              kyoukaiNum:(int)kyoukaiNum
                  isAnti:(BOOL)anti
              beforeData:(NSString*)bData
               afterData:(NSString*)aData
                savePath:(NSString*)savePathS
{
    NSString* ret = @"";
    NSDictionary  *asErrDic = nil;
    NSString* resPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/Scripts/"];
    NSString* assOpenModePDF;
    NSString* assOpenModeEPS;
    NSString* assHikakuMode;
    NSString* isAnti = (anti)? @"true":@"false";
    NSString* savFile = [aData lastPathComponent];
    savFile = [savFile stringByReplacingOccurrencesOfString:@".pdf" withString:@".psd"];
    savFile = [@"比較_" stringByAppendingString:savFile];
    
    assOpenModeEPS = [NSString stringWithFormat:@""
                      "open alias bFile with options {class:EPS open options, mode:grayscale, resolution:%d, use antialias:%@, constrain proportions:true}\n"
                      "open alias aFile with options {class:EPS open options, mode:grayscale, resolution:%d, use antialias:%@, constrain proportions:true}\n",
                      rasterDpi,isAnti,
                      rasterDpi,isAnti];
    
    if([cmpMode compare:@"カラー"] == NSOrderedSame)
    {
        assOpenModePDF = [NSString stringWithFormat:@""
                          "open alias bFile with options {class:PDF open options, mode:CMYK, resolution:%d, use antialias:%@, page:1, constrain proportions:true, crop page:media box}\n"
                          "open alias aFile with options {class:PDF open options, mode:CMYK, resolution:%d, use antialias:%@, page:1, constrain proportions:true, crop page:media box}\n",
                          rasterDpi,isAnti,
                          rasterDpi,isAnti];
    }
    else
    {
        assOpenModePDF = [NSString stringWithFormat:@""
                          "open alias bFile with options {class:PDF open options, mode:grayscale, resolution:%d, use antialias:%@, page:1, constrain proportions:true, crop page:media box}\n"
                          "open alias aFile with options {class:PDF open options, mode:grayscale, resolution:%d, use antialias:%@, page:1, constrain proportions:true, crop page:media box}\n",
                          rasterDpi,isAnti,
                          rasterDpi,isAnti];
    }
    
    if([cmpMode compare:@"カラー"] == NSOrderedSame ||
       [cmpMode compare:@"厳しく"] == NSOrderedSame )
    {
        assHikakuMode = [NSString stringWithFormat:@""
                         "set siki to \"%@\"",
                         [resPath stringByAppendingPathComponent:@"sikiiki_action_ill.jsx"]];
    }
    else if([cmpMode compare:@"ゆるく"] == NSOrderedSame)
    {
        assHikakuMode = [NSString stringWithFormat:@""
                         "set siki to \"%@\"",
                         [resPath stringByAppendingPathComponent:@"sikiiki_action_near.jsx"]];
    }
    else if([cmpMode compare:@"標準"] == NSOrderedSame)
    {
        assHikakuMode = [NSString stringWithFormat:@""
                         "set siki to \"%@\"",
                         [resPath stringByAppendingPathComponent:@"sikiiki_action.jsx"]];
    }
    if([usePS state] == NSOnState)
    {
        bData =[acroApp PDF2PS:bData isBeforeData:YES];
        aData =[acroApp PDF2PS:aData isBeforeData:NO];
    }
    
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"%@\"\n"
                     "        set display dialogs to never\n"
                     "        set bFile to \"%@\" as text\n"
                     "        set aFile to \"%@\" as text\n"
                     "        set bexpitem to \"%@\"\n"
                     "        set aexpitem to \"%@\"\n"
                     "        set tif_on to false\n"
                     "        if ((aexpitem is \"tif\") or (aexpitem is \"tiff\")) and ((bexpitem is \"tif\") or (bexpitem is \"tiff\")) then\n"
                     "            open alias bFile as TIFF\n"
                     "            open alias aFile as TIFF\n"
                     "            set tif_on to true\n"
                     "        else if ((aexpitem is \"pdf\") and (bexpitem is \"pdf\")) then\n"
                     "            %@"
                     "        else if ((aexpitem is \"eps\") and (bexpitem is \"eps\")) or ((aexpitem is \"ps\") and (bexpitem is \"ps\")) then\n"
                     "            %@"
                     "        else if ((aexpitem is \"psd\") and (bexpitem is \"psd\")) then\n"
                     "            open alias bFile showing dialogs never\n"
                     "            open alias aFile showing dialogs never\n"
                     "        else if ((aexpitem is \"png\") and (bexpitem is \"png\")) then\n"
                     "            open alias bFile showing dialogs never\n"
                     "            open alias aFile showing dialogs never\n"
                     "        else\n"
                     "            display dialog \"比較ファイルタイプが違います。\"\n"
                     "        end if\n"
                     "        set chg to \"%@\"\n"
                     "        set currentDocument to (a reference to document 2)\n"
                     "        tell currentDocument\n"
                     "            activate\n"
                     "            flatten\n"
                     "            if tif_on then\n"
                     "                resize image resolution 600 resample method bicubic smoother\n"
                     "                do javascript (file chg)\n"
                     "                resize image resolution %d resample method bicubic smoother\n"
                     "            end if\n"
                     "            select all\n"
                     "            copy\n"
                     "            close saving no\n"
                     "        end tell\n"
                     "        set currentDocument to (a reference to document 1)\n"
                     "        tell currentDocument\n"
                     "            activate\n"
                     "            flatten\n"
                     "            if tif_on then\n"
                     "                resize image resolution 600 resample method bicubic smoother\n"
                     "                do javascript (file chg)\n"
                     "                resize image resolution %d resample method bicubic smoother\n"
                     "            end if\n"
                     "            paste\n"
                     "            set imglay1 to background layer\n"
                     "            set name of imglay1 to \"比較元\"\n"
                     "            set imglay2 to layer 1\n"
                     "            set name of imglay2 to \"比較先\"\n"
                     "            set d1 to duplicate imglay1\n"
                     "            set d2 to duplicate imglay2\n"
                     "            move 2nd layer to after 3rd layer\n"
                     "            set blend mode of d2 to difference\n"
                     "            tell layer 1\n"
                     "                merge\n"
                     "            end tell\n"
                     "            set name of d2 to \"比較結果\"\n"
                     "            set visible of 3rd layer to true\n"
                     "            set visible of 2nd layer to false\n"
                     "        end tell\n"
                     "        activate\n"
                     "        %@\n"
                     "        do javascript (file siki)\n"
                     "        tell currentDocument\n"
                     "            activate\n"
                     "            set current layer to 1st layer\n"
                     "            fill selection with contents {class:gray color, gray value:0}\n"
                     "            invert selection\n"
                     "        end tell\n"
                     "        set kyoukai to \"%@\"\n"
                     "        do javascript (file kyoukai) with arguments {%d, 100.0}\n"
                     "        tell currentDocument\n"
                     "            activate\n"
                     "            fill selection with contents {class:gray color, gray value:0}\n"
                     "            invert selection\n"
                     "            deselect\n"
                     "            tell layer 1\n"
                     "                set opacity to %d\n"
                     "            end tell\n"
                     "        end tell\n"
                     "    end tell\n"
                     "    set saveFile to \"%@\"\n"
                     "    tell application \"%@\"\n"
                     "        tell currentDocument\n"
                     "            activate\n"
                     "            set myOptions to {class:Photoshop save options, embed color profile:true, save spot colors:true, save alpha channels:true, save annotations:true, save layers:true}\n"
                     "            save in file saveFile as Photoshop format with options myOptions appending no extension with copying\n"
                     "            close without saving\n"
                     "        end tell\n"
                     "    end tell\n"
                     "end timeout",
                     [set PhotoshopPath],
                     bData,
                     aData,
                     [[bData lastPathComponent] pathExtension],
                     [[aData lastPathComponent] pathExtension],
                     assOpenModePDF,
                     assOpenModeEPS,
                     [resPath stringByAppendingPathComponent:@"chgGray.jsx"],
                     rasterDpi,
                     rasterDpi,
                     assHikakuMode,
                     [resPath stringByAppendingPathComponent:@"kyoukai.jsx"],
                     kyoukaiNum,
                     transRatio,
                     [savePathS stringByAppendingPathComponent:savFile],
                     [set PhotoshopPath]];
    [ass writeToFile:@"/Applications/FACILIS Supremo/OutPDF/test.txt" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:ass];
    [as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        ret = [asErrDic objectForKey:NSAppleScriptErrorMessage];
    }
    return ret;
}

//----------------------------------------------------------------------------//
#pragma mark -
#pragma mark IBActions
//----------------------------------------------------------------------------//

-(IBAction)go:(id)sender
{
    NSAlert* al = [[NSAlert alloc] init];
    NSString* cmpMode = [[mode selectedItem] title];
    int rasterDpi = [dpi intValue];
    int transRatio = [transparent intValue];
    int kyoukaiNum = [kyoukaiLine intValue];
    BOOL isAnti = ([useAnti state] == NSOnState)? YES : NO;
    
    if([beforeData count] != [afterData count])
    {
        [al setMessageText:@"エラー"];
        [al setInformativeText:@"比較PDFの数が合いません"];
        [al runModal];
        return;
    }
    if([[beforeData objectAtIndex:0] compare:[afterData objectAtIndex:0]] == NSOrderedSame)
    {
        [al setMessageText:@"エラー"];
        [al setInformativeText:@"同じファイルです"];
        [al runModal];
        return;
    }
    
    __block NSString* ret;
    if([[savePath stringValue] compare:@""] == NSOrderedSame)
    {
        [savePath setStringValue:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        for(int i = 0; i < [beforeData count]; i++)
        {
            
            ret = [self compareStart:cmpMode
                           rasterDpi:rasterDpi
                          transRatio:transRatio
                          kyoukaiNum:kyoukaiNum
                              isAnti:isAnti
                          beforeData:[beforeData objectAtIndex:i]
                           afterData:[afterData objectAtIndex:i]
                            savePath:[savePath stringValue]];
            if([ret compare:@""]!=NSOrderedSame)
            {
                break;
            }
        }
        if([ret compare:@""]!=NSOrderedSame)
        {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                NSAlert* alt = [[NSAlert alloc] init];
                [alt setInformativeText:ret];
                [alt setMessageText:@"エラー"];
                [alt runModal];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            [self clear:nil];
            [savePath setStringValue:@""];
            
        });
    });
    
    
}

-(IBAction)openSave:(id)sender
{
    NSArray* o = [Macros openFileDialog:@"Title" multiple:NO selectFile:NO selectDir:YES];
    if([o count] == 1)
    {
        [savePath setStringValue:[o objectAtIndex:0]];
    }
    else
    {
        NSAlert* al = [[NSAlert alloc] init];
        [al setMessageText:@"エラー"];
        [al setInformativeText:@"キャンセルされました"];
        [al runModal];
        return;
    }
}


-(IBAction)clear:(id)sender
{
    [afterData removeAllObjects];
    [beforeData removeAllObjects];
    [afterTable reloadData];
    [beforeTable reloadData];
}

-(IBAction)showSetting:(id)sender
{
    [set showSetting];
}
//----------------------------------------------------------------------------//
#pragma mark -
#pragma mark InternalFuncs
//----------------------------------------------------------------------------//
-(void)setDataToTable:(NSArray*)arrfile table:(NSTableView*)aTable
{
    arrfile = [arrfile sortedArrayUsingComparator:^(id o1, id o2){
        return [o1 compare:o2];
    }];
    if(aTable == beforeTable)
    {
        beforeData = [arrfile mutableCopy];
    }
    if(aTable == afterTable)
    {
        afterData = [arrfile mutableCopy];
    }
    [aTable reloadData];
}

#pragma mark -
#pragma mark TableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(aTableView == beforeTable)
    {
        return [beforeData count];
    }
    if(aTableView == afterTable)
    {
        return [afterData count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    if(aTableView == beforeTable)
    {
        return [[beforeData objectAtIndex:rowIndex] lastPathComponent];
    }
    if(aTableView == afterTable)
    {
        return [[afterData objectAtIndex:rowIndex] lastPathComponent];
    }
    
    return nil;
}

- (NSString*)searchType:(NSArray*)types
{
    for(int i = 0; i < [types count]; i++)
    {
        if ([[types objectAtIndex:i] compare:NSFilenamesPboardType] == NSOrderedSame)
        {
            return NSFilenamesPboardType;
        }
    }
    return nil;
}

- (NSDragOperation)tableView:(NSTableView*)tv
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)op
{
    NSDragOperation retOperation = NSDragOperationNone;
    NSArray* dataTypes = [[info draggingPasteboard] types];
    
    if ([[self searchType:dataTypes] compare:NSFilenamesPboardType] == NSOrderedSame)
    {
        // ファイル／フォルダドロップ時
        retOperation = NSDragOperationCopy;
    }
    return retOperation;
}

- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id )info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation
{
    
    NSPasteboard* pboard = [info draggingPasteboard];
    NSArray* dataTypes = [pboard types];
    
    
    if ([[self searchType:dataTypes] compare:NSFilenamesPboardType] == NSOrderedSame)
    {
        // ファイル／フォルダドロップ時
        NSData* data = [pboard dataForType:NSFilenamesPboardType];
        NSError *error;
        NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
        NSArray* theFiles = [NSPropertyListSerialization propertyListWithData:data options:(NSPropertyListReadOptions)NSPropertyListImmutable format:&format error:&error];
        NSMutableArray* setData = [NSMutableArray array];
        
        for(id file in theFiles)
        {
            if(![Macros isDirectory:file])
            {
                //if([[file pathExtension] compare:@"pdf"] == NSOrderedSame)
                //{
                [setData addObject:file];
                //}
            }
            else
            {
                NSArray* arFiles = [Macros getFileList:file deep:NO onlyDir:NO];
                for(id f in arFiles)
                {
                    /*if([[f pathExtension] compare:@"pdf"] == NSOrderedSame)
                     {*/
                    [setData addObject:[file stringByAppendingPathComponent:f]];
                    //}
                }
            }
        }
        [self setDataToTable:[setData copy] table:aTableView];
        return YES;
        
    }
    return NO;
}



#pragma mark -
#pragma mark NSTableView Delegate
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return YES;
}


@end
