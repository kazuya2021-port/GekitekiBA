//
//  ControlAcrobat.m
//  ProjectDB
//
//  Created by uchiyama_Macmini on 2017/06/13.
//  Copyright © 2017年 uchiyama_Macmini. All rights reserved.
//

#import "ControlAcrobat.h"

@implementation ControlAcrobat

- (id) init
{
    self = [super init];
    if (self != nil) {
        app = [SBApplication applicationWithBundleIdentifier:@"com.adobe.Acrobat.Pro"];
        appDist = [SBApplication applicationWithBundleIdentifier:@"com.adobe.distiller"];
    }
    return self;
}

#pragma mark -
#pragma mark Internal Functions

- (void)open:(NSArray*)paths visible:(BOOL)visible
{
    BOOL inv = (visible)?NO:YES;
    [app open:paths invisible:inv options:@""];
}

// すでに指定のファイルを開いているかチェック
- (BOOL)isAlreadyOpen:(NSString*)filename
{
    BOOL isOpened = NO;
    
    id documents = [app documents];
    
    if([documents count] == 0)
    {
        isOpened = NO;
    }
    else
    {
        for(AcrobatProDocument* doc in documents)
        {
            if([[doc name] compare:filename] == NSOrderedSame)
            {
                isOpened = YES;
                break;
            }
        }
    }
    return isOpened;
}

- (AcrobatProDocument*)getTargetDocument:(NSString*)filename
{
    
    id docs = [app documents];
    AcrobatProDocument* target = nil;
    for(AcrobatProDocument* doc in docs)
    {
        if([[doc name] compare:filename] == NSOrderedSame)
        {
            target = doc;
            break;
        }
    }
    return target;
}


#pragma mark -
#pragma mark Outer Functions
- (void)deletePageAt:(NSString*)filepath page:(int)page
{
    filepath = [self changeFolderName:filepath];
    filepath = [self changeFileName:filepath];
    
    if([self isAlreadyOpen:[filepath lastPathComponent]])
    {
        //[app closeAllDocsSaving:AcrobatProSavoNo];
    }
    else
    {
        [self open:ARRAY(filepath) visible:YES];
    }
    
    id documents = [app documents];
    for(AcrobatProDocument* doc in documents)
    {
        if([[doc name] compare:[filepath lastPathComponent]] == NSOrderedSame)
        {
            [doc deletePagesFirst:page last:page];
        }
    }
    //
}
- (void)addPageAt:(NSString*)filepath to:(NSString*)naosiPage page:(int)page
{
    filepath = [self changeFolderName:filepath];
    filepath = [self changeFileName:filepath];
    
    if(![self isAlreadyOpen:[filepath lastPathComponent]])
    {
        if (![self isAlreadyOpen:[naosiPage lastPathComponent]])
            [self open:ARRAY(filepath,naosiPage) visible:YES];
        else
            [self open:ARRAY(filepath) visible:YES];
    }
    else if (![self isAlreadyOpen:[naosiPage lastPathComponent]])
    {
        if (![self isAlreadyOpen:[filepath lastPathComponent]])
            [self open:ARRAY(filepath,naosiPage) visible:YES];
        else
            [self open:ARRAY(naosiPage) visible:YES];
    }
    
    id documents = [app documents];
    AcrobatProDocument* srcDoc;
    AcrobatProDocument* naosiDoc;
    for(AcrobatProDocument* doc in documents)
    {
        if([[doc name] compare:[naosiPage lastPathComponent]] == NSOrderedSame)
        {
            naosiDoc = doc;
        }
        if([[doc name] compare:[filepath lastPathComponent]] == NSOrderedSame)
        {
            srcDoc = doc;
        }
    }
    [srcDoc insertPagesAfter:page-1 from:naosiDoc startingWith:1 numberOfPages:1 insertBookmarks:NO];
    
    [naosiDoc closeSaving:AcrobatProSavoNo linearize:NO];
}
- (void)revertPageOrder:(NSString*)filepath savePath:(NSString*)savePath rangePage:(NSRange)rng isAllPage:(BOOL)isAllPage
{
    // すでに開いているか？
    filepath = [self changeFolderName:filepath];
    filepath = [self changeFileName:filepath];
    
    if([self isAlreadyOpen:[filepath lastPathComponent]])
    {
        [app closeAllDocsSaving:AcrobatProSavoNo];
    }
    NSDictionary  *asErrDic = nil;
    NSInteger endPage = (rng.location + rng.length)-1;
    
    if(!isAllPage)
    {
        endPage =(rng.location + rng.length)+1;
    }
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    set g_cur_path to \"%@\"\n"
                     "    set g_sav_path to \"%@\"\n"
                     "    set startPage to %lu\n"
                     "    set endPage to %lu\n"
                     "    tell application \"%@\"\n"
                     "        do script (\"\n"
                     "        var theDoc = app.openDoc(\" & quoted form of g_cur_path & \");\n"
                     "        var start = \" & startPage & \";\n"
                     "        var end = \" & endPage & \";\n"
                     "        var insertCount = start;\n"
                     "        for(var i = end-1; i >= start; i--)\n"
                     "        {\n"
                     "            theDoc.movePage(end,insertCount-1);\n"
                     "            insertCount++;\n"
                     "        }\n"
                     "        theDoc.saveAs(\" & quoted form of g_sav_path & \");\n"
                     "        theDoc.closeDoc(true);\n"
                     "        \")\n"
                     "    end tell\n"
                     "end timeout",
                     filepath,
                     [savePath stringByAppendingPathComponent:[filepath lastPathComponent]],
                     rng.location,
                     endPage,
                     [set AcrobatPath]];
    //[ass writeToFile:@"/Applications/FACILIS Supremo/OutPDF/test.txt" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:ass];

    [as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        NSLog(@"ASError:%@",[asErrDic objectForKey:NSAppleScriptErrorMessage]);
    }
    /*NSString* cmd1 = [NSString stringWithFormat:@"cd %@; osascript revertPageOrder.scpt \"%@\" %lu %lu",resPath,
                      filepath,
                      rng.location,
                      (rng.location + rng.length)];
    [Macros doShellScript:ARRAY(@"-c", cmd1)];*/
}

- (void)splitPages:(NSString*)filepath savePath:(NSString*)savePath pages:(NSArray*)pages ofst:(int)ofst usePDFOffset:(BOOL)usePDFOffset
{
    // すでに開いているか？
    if([self isAlreadyOpen:[filepath lastPathComponent]])
    {
        [app closeAllDocsSaving:AcrobatProSavoNo];
    }
    NSString* lastChar = [savePath substringFromIndex:[savePath length]-1];
    
    if([lastChar compare:@"/"] != NSOrderedSame)
    {
        savePath = [savePath stringByAppendingString:@"/"];
    }
    filepath = [self changeFolderName:filepath];
    filepath = [self changeFileName:filepath];
    NSDictionary  *asErrDic = nil;
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    set g_cur_path to \"%@\" as POSIX file\n"
                     "    set g_cur_file to \"%@\" as text\n"
                     "    set g_save_path to \"%@\"\n"
                     "    set extractPages to {%@}\n"
                     "    set saveOfset to %d\n"
                     "    set usePDFOffset to %@\n"
                     "    tell application \"%@\"\n"
                     "        open alias g_cur_path\n"
                     "        set docs to active doc\n"
                     "        set maxPage to count of pages of docs\n"
                     "        set pageStrLen to 3\n"
                     "        if maxPage > 999 then\n"
                     "            set pageStrLen to 4\n"
                     "        end if\n"
                     "        set pageOffset to (label text of item 1 of pages of docs) as integer\n"
                     "        if usePDFOffset then\n"
                     "        else\n"
                     "            if pageOffset is not equal saveOfset then\n"
                     "                do script (\"\n"
                     "                    var d = app.activeDocs;\n"
                     "                    d[0].setPageLabels(0,[\\\"D\\\",\\\"\\\", \" & saveOfset & \"]);\n"
                     "                \")\n"
                     "                set pageOffset to saveOfset\n"
                     "            end if\n"
                     "        end if\n"
                     "        repeat with i from 1 to count of extractPages\n"
                     "            set paddNum to 0\n"
                     "            set sp to item i of extractPages\n"
                     "            set sp to sp - (pageOffset - 1)\n"
                     "            set strSavePage to \"\"\n"
                     "            if sp > 999 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 0\n"
                     "            else if sp > 99 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 1\n"
                     "            else if sp > 99 and pageStrLen is equal to 3 then\n"
                     "                set paddNum to 0\n"
                     "            else if sp > 9 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 2\n"
                     "            else if sp > 9 and pageStrLen is equal to 3 then\n"
                     "                set paddNum to 1\n"
                     "            else if sp ≥ 0 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 3\n"
                     "            else if sp ≥ 0 and pageStrLen is equal to 3 then\n"
                     "                set paddNum to 2\n"
                     "            end if\n"
                     "            repeat with j from 1 to paddNum\n"
                     "                set strSavePage to strSavePage & \"0\"\n"
                     "            end repeat\n"
                     "            if usePDFOffset then\n"
                     "                set strSavePage to strSavePage & (sp + (pageOffset - 1)) as text\n"
                     "            else\n"
                     "                set strSavePage to strSavePage & (sp + (saveOfset - 1)) as text\n"
                     "            end if\n"
                     "            set strSavePage to \"P\" & strSavePage & \".pdf\"\n"
                     "            set savePath to g_save_path & strSavePage\n"
                     "            do script (\"\n"
                     "                var d = app.activeDocs;\n"
                     "                if(d.length == 1){\n"
                     "                    d[0].extractPages({nStart:\" & sp - 1 & \", nEnd:\" & sp - 1 & \", cPath:\" & quoted form of savePath & \"});\n"
                     "                }\n"
                     "                else{\n"
                     "                    var theDoc;\n"
                     "                    for(var i = 0; i < d.length; i++)\n"
                     "                    {\n"
                     "                        if(d[i].documentFileName == \" & quoted form of g_cur_file & \"){\n"
                     "                            theDoc = d[i];\n"
                     "                            break;\n"
                     "                        }\n"
                     "                    }\n"
                     "                    theDoc.extractPages({nStart:\" & sp - 1 & \", nEnd:\" & sp - 1 & \", cPath:\" & quoted form of savePath & \"});\n"
                     "                }\n"
                     "            \")\n"
                     "        end repeat\n"
                     "    end tell\n"
                     "end timeout",
                     filepath,
                     [filepath lastPathComponent],
                     savePath,
                     [pages componentsJoinedByString:@","],
                     ofst,
                     (usePDFOffset)?@"true":@"false",
                     [set AcrobatPath]];
    [ass writeToFile:@"/Applications/FACILIS Supremo/OutPDF/test.txt" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:ass];
    
    [ as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        NSLog(@"ASError:%@",[asErrDic objectForKey:NSAppleScriptErrorMessage]);
    }
    if(usePDFOffset)
        [self closeAll:NO];
    else
        [self closeAll:YES];

}

// savePath はフォルダ
- (void)splitAllPage:(NSString*)filepath savePath:(NSString*)savePath ofst:(int)ofst usePDFOffset:(BOOL)usePDFOffset
{
    // すでに開いているか？
    if([self isAlreadyOpen:[filepath lastPathComponent]])
    {
        [app closeAllDocsSaving:AcrobatProSavoNo];
    }
    NSString* lastChar = [savePath substringFromIndex:[savePath length]-1];
    
    if([lastChar compare:@"/"] != NSOrderedSame)
    {
        savePath = [savePath stringByAppendingString:@"/"];
    }
    filepath = [self changeFolderName:filepath];
    filepath = [self changeFileName:filepath];
    
    NSDictionary  *asErrDic = nil;
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    set g_cur_path to \"%@\" as POSIX file\n"
                     "    set g_cur_file to \"%@\" as text\n"
                     "    set g_save_path to \"%@\"\n"
                     "    set saveOfset to %d\n"
                     "    set usePDFOffset to %@\n"
                     "    tell application \"%@\"\n"
                     "        open alias g_cur_path\n"
                     "        set docs to active doc\n"
                     "        set maxPage to count of pages of docs\n"
                     "        set pageStrLen to 3\n"
                     "        if maxPage > 999 then\n"
                     "            set pageStrLen to 4\n"
                     "        end if\n"
                     "        set pageOffset to (label text of item 1 of pages of docs) as integer\n"
                     "        if usePDFOffset then\n"
                     "        else\n"
                     "            if pageOffset is not equal saveOfset then\n"
                     "                do script (\"\n"
                     "                var d = app.activeDocs;\n"
                     "                var theDoc;\n"
                     "                for(var i = 0; i < d.length; i++)\n"
                     "                {\n"
                     "                    if(d[i].documentFileName == \" & quoted form of g_cur_file & \"){\n"
                     "                        theDoc = d[i];\n"
                     "                        break;\n"
                     "                    }\n"
                     "                }\n"
                     "                theDoc.setPageLabels(0,[\\\"D\\\",\\\"\\\", \" & saveOfset & \"]);\n"
                     "                \")\n"
                     "                set pageOffset to saveOfset\n"
                     "            end if\n"
                     "        end if\n"
                     "        repeat with i from 1 to maxPage\n"
                     "            set paddNum to 0\n"
                     "            set sp to i\n"
                     "            set strSavePage to \"\"\n"
                     "            set chkPage to 0\n"
                     "            if usePDFOffset then\n"
                     "                set chkPage to (label text of item i of pages of docs) as integer\n"
                     "            else\n"
                     "                set chkPage to sp + (pageOffset - 1)\n"
                     "            end if\n"
                     "            if chkPage > 999 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 0\n"
                     "            else if chkPage > 99 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 1\n"
                     "            else if chkPage > 99 and pageStrLen is equal to 3 then\n"
                     "                set paddNum to 0\n"
                     "            else if chkPage > 9 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 2\n"
                     "            else if chkPage > 9 and pageStrLen is equal to 3 then\n"
                     "                set paddNum to 1\n"
                     "            else if chkPage ≥ 0 and pageStrLen is equal to 4 then\n"
                     "                set paddNum to 3\n"
                     "            else if chkPage ≥ 0 and pageStrLen is equal to 3 then\n"
                     "                set paddNum to 2\n"
                     "            end if\n"
                     "            repeat with j from 1 to paddNum\n"
                     "                set strSavePage to strSavePage & \"0\"\n"
                     "            end repeat\n"
                     "            set strSavePage to strSavePage & (chkPage) as text\n"
                     "            set strSavePage to \"P\" & strSavePage & \".pdf\"\n"
                     "            set savePath to g_save_path & strSavePage\n"
                     "            do script (\"\n"
                     "                var d = app.activeDocs;\n"
                     "                if(d.length == 1){\n"
                     "                    d[0].extractPages({nStart:\" & sp - 1 & \", nEnd:\" & sp - 1 & \", cPath:\" & quoted form of savePath & \"});\n"
                     "                }\n"
                     "                else{\n"
                     "                    var theDoc;\n"
                     "                    for(var i = 0; i < d.length; i++)\n"
                     "                    {\n"
                     "                        if(d[i].documentFileName == \" & quoted form of g_cur_file & \"){\n"
                     "                            theDoc = d[i];\n"
                     "                            break;\n"
                     "                        }\n"
                     "                    }\n"
                     "                    theDoc.extractPages({nStart:\" & sp - 1 & \", nEnd:\" & sp - 1 & \", cPath:\" & quoted form of savePath & \"});\n"
                     "                }\n"
                     "            \")\n"
                     "        end repeat\n"
                     "    end tell\n"
                     "end timeout",
                     filepath,
                     [filepath lastPathComponent],
                     savePath,
                     ofst,
                     (usePDFOffset)?@"true":@"false",
                     [set AcrobatPath]];
    
    [ass writeToFile:@"/Applications/FACILIS Supremo/OutPDF/test.txt" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:ass];
    
    [ as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        NSLog(@"ASError:%@",[asErrDic objectForKey:NSAppleScriptErrorMessage]);
    }
    if(usePDFOffset)
        [self closeAll:NO];
    else
        [self closeAll:YES];
}

- (NSArray*)getPageSize:(NSArray*)paths
{
    NSMutableArray* sizes = [NSMutableArray array];
    
    // すでに開いているか？
    NSMutableArray* filenames = [NSMutableArray array];
    BOOL isOpened = NO;
    
    for(id file in paths)
    {
        NSString* newfile = [self changeFolderName:file];
        newfile = [self changeFileName:newfile];
        if([[[newfile lastPathComponent] pathExtension] compare:@"pdf"] == NSOrderedSame)
            [filenames addObject:[newfile lastPathComponent]];
    }
    
    NSMutableArray* noFounds = [[NSMutableArray alloc] initWithArray:filenames copyItems:YES];
    
    for(id file in filenames)
    {
        if([self isAlreadyOpen:file])
        {
            [noFounds removeObject:file];
        }
    }
    if([noFounds count] == 0) isOpened = YES;
    
    if(!isOpened)
    {
        NSMutableArray* openDocs = [NSMutableArray array];
        for(id file in paths)
        {
            NSString* fName = [file lastPathComponent];
            if([noFounds containsObject:fName])
            {
                [openDocs addObject:[NSURL fileURLWithPath:file]];
            }
        }
        [self open:openDocs visible:NO];
    }
    
    id documents = [app documents];
    for(AcrobatProDocument* doc in documents)
    {
        for(id file in filenames)
        {
            NSString* docname =[doc name];
            if([docname compare:file] == NSOrderedSame)
            {
                // 先頭のページサイズを測る
                AcrobatProPage* p = [[doc pages] objectAtIndex:0];
                
                NSArray* size = [p trimBox]; //(left, top, right, bottom)
                
                NSSize s = NSMakeSize([[size objectAtIndex:2] doubleValue] - [[size objectAtIndex:0] doubleValue],
                                      [[size objectAtIndex:1] doubleValue] - [[size objectAtIndex:3] doubleValue]);
                
                s.height = round([Macros pixcelToMm:s.height dpi:72.0]);
                s.width = round([Macros pixcelToMm:s.width dpi:72.0]);
                NSMutableDictionary* dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSString stringWithFormat:@"%dx%d",(int)s.width,(int)s.height] forKey:@"size"];
                [dic setObject:file forKey:@"name"];
                [sizes addObject:dic];
            }
        }
    }
    [app closeAllDocsSaving:AcrobatProSavoNo];
    
    return [sizes copy];
}

// パスはフルパスで指定
- (NSMutableArray*)getPageCount:(NSArray*)paths
{
    NSMutableArray* ret = [NSMutableArray array];
    
    // すでに開いているか？
    NSMutableArray* filenames = [NSMutableArray array];
    BOOL isOpened = NO;
    
    for(id file in paths)
    {
        NSString* newfile = [self changeFolderName:file];
        newfile = [self changeFileName:newfile];
        if([[[newfile lastPathComponent] pathExtension] compare:@"pdf"] == NSOrderedSame)
            [filenames addObject:[newfile lastPathComponent]];
    }
    
    NSMutableArray* noFounds = [[NSMutableArray alloc] initWithArray:filenames copyItems:YES];
    
    for(NSString* file in filenames)
    {
        if([self isAlreadyOpen:file])
        {
            [noFounds removeObject:file];
        }
    }
    if([noFounds count] == 0) isOpened = YES;
    
    if(!isOpened)
    {
        NSMutableArray* openDocs = [NSMutableArray array];
        for(id file in paths)
        {
            NSString* fName = [file lastPathComponent];
            if([noFounds containsObject:fName])
            {
                [openDocs addObject:[NSURL fileURLWithPath:file]];
            }
        }
        [self open:openDocs visible:NO];
    }
    
    id documents = [app documents];
    for(AcrobatProDocument* doc in documents)
    {
        for(id file in filenames)
        {
            NSString* docname =[doc name];
            if([docname compare:file] == NSOrderedSame)
            {
                NSMutableDictionary* dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSString stringWithFormat:@"%lu",[[doc pages] count]] forKey:@"pageNum"];
                [dic setObject:file forKey:@"name"];
                [ret addObject: dic];
            }
        }
    }
    
    [app closeAllDocsSaving:AcrobatProSavoNo];
    return ret;
}

- (NSString*)getText:(NSString*)filepath pageNum:(NSInteger)num
{
    filepath = [self changeFolderName:filepath];
    filepath = [self changeFileName:filepath];
    NSDictionary  *asErrDic = nil;
    NSString* resPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources"];
    NSString* ass = [NSString stringWithFormat:@""
     "with timeout of (1 * 60 * 60) seconds\n"
     "    set g_cur_path to \"%@\"\n"
     "    set g_tmp_path to \"%@\"\n"
     "    set g_txt_path to \"%@\"\n"
     "    set pageNum to %lu\n"
     "    tell application \"%@\"\n"
     "        do script (\"\n"
     "        var theDoc = app.openDoc(\" & quoted form of g_cur_path & \");\n"
     "        theDoc.extractPages({nStart: \"& pageNum &\", nEnd:\" & pageNum & \", cPath:\" & quoted form of g_tmp_path & \"});\n"
     "        theDoc.closeDoc(false);\n"
     "        var thePage = app.openDoc(\" & quoted form of g_tmp_path & \");\n"
     "        thePage.saveAs(\" & quoted form of g_txt_path & \", \\\"com.adobe.acrobat.plain-text\\\");\n"
     "        thePage.closeDoc(true);\n"
     "        \")\n"
     "    end tell\n"
     "end timeout",
     filepath,
     [resPath stringByAppendingPathComponent:@"tmp.pdf"],
     [resPath stringByAppendingPathComponent:@"tmp.txt"],
     num,
     [set AcrobatPath]];
    //[ass writeToFile:@"/Applications/FACILIS Supremo/OutPDF/test.txt" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:ass];
    
    [ as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        NSLog(@"ASError:%@",[asErrDic objectForKey:NSAppleScriptErrorMessage]);
    }
    NSError* er;
    NSString* strTxt = [NSString stringWithContentsOfFile:[resPath stringByAppendingPathComponent:@"tmp.txt"] encoding:NSShiftJISStringEncoding error:&er];
    return strTxt;
}

- (void)distillEPS:(NSString*)filePath
{
    [appDist open:[NSURL fileURLWithPath:filePath]];
}

- (void)closeAll:(BOOL)isSave
{
    if(isSave)
        [app closeAllDocsSaving:AcrobatProSavoYes];
    else
        [app closeAllDocsSaving:AcrobatProSavoNo];
}

// フォルダパスを受け取りその配下のPDFを対象に処理を行う
// isBならResourcesにBeforeのフォルダ作成,それ以外ならAfterのフォルダを作成して比較用のPSファイルを作成する
- (NSString*)PDF2PS:(NSString*)filePath isBeforeData:(BOOL)isB
{
    NSString* retPath = @"";
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary  *asErrDic = nil;
    NSString* resPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources"];
    if(isB)
        resPath = [resPath stringByAppendingPathComponent:@"Before"];
    else
        resPath = [resPath stringByAppendingPathComponent:@"After"];
    
    resPath = [resPath stringByAppendingString:@"/"];
    [fm removeItemAtPath:resPath error:nil];
    [fm createDirectoryAtPath:resPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString* scptRena1 = @"\"n=\" & currentFile's quoted form & \";echo \\\"${n##*/}\\\"\"";
    NSString* scptRena2 = @"\"n=\" & currentFileName's quoted form & \";echo \\\"${n%.*}\\\"\"";
    NSString* ass = [NSString stringWithFormat:@""
                     "set currentFile to \"%@\"\n"
                     "set outPath to \"%@\"\n"
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    set currentFileName to do shell script %@\n"
                     "    set currentFileShortName to do shell script %@\n"
                     "    set PSFileName to (currentFileShortName & \".eps\") as string\n"
                     "    set PSFilePath to (outPath & PSFileName) as string\n"
                     "    tell application \"%@\"\n"
                     "        do script (\"\n"
                     "              var theDoc = app.openDoc(\" & quoted form of currentFile & \");\n"
                     "              var myPath = \" & quoted form of PSFilePath & \";\n"
                     "              theDoc.saveAs(myPath,\\\"com.adobe.acrobat.eps\\\");\n"
                     "              theDoc.closeDoc(true);\n"
                     "        \")\n"
                     "    end tell\n"
                     "end timeout\n",
                     filePath,
                     resPath,
                     scptRena1,
                     scptRena2,
                     [set AcrobatPath]];
    [ass writeToFile:@"/Applications/FACILIS Supremo/OutPDF/test.txt" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:ass];
    
    [ as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        NSLog(@"ASError:%@",[asErrDic objectForKey:NSAppleScriptErrorMessage]);
    }
    NSError* er;
    NSString* strTxt = [NSString stringWithContentsOfFile:[resPath stringByAppendingPathComponent:@"tmp.txt"] encoding:NSShiftJISStringEncoding error:&er];
    NSString* fileName = [[filePath lastPathComponent] stringByReplacingOccurrencesOfString:@"pdf" withString:@"eps"];
    retPath = [resPath stringByAppendingPathComponent:fileName];
    return retPath;
}

- (NSString*)changeFolderName:(NSString*)path
{
    NSString* cur = [path stringByDeletingLastPathComponent];
    NSString* tmp = [cur lastPathComponent];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"・" withString:@""];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"～" withString:@""];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* toPath = [[cur stringByDeletingLastPathComponent] stringByAppendingPathComponent:tmp];
    if([fm fileExistsAtPath:cur])
    {
        [fm moveItemAtPath:cur toPath:toPath error:nil];
        return [toPath stringByAppendingPathComponent:[path lastPathComponent]];
    }
    return nil;
}

- (NSString*)changeFileName:(NSString*)path
{
    NSString* tmp = [path lastPathComponent];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"・" withString:@""];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"～" withString:@""];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* toPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:tmp];
    if([fm fileExistsAtPath:path])
    {
        [fm moveItemAtPath:path toPath:toPath error:nil];
        return toPath;
    }
    return nil;
}
@end
