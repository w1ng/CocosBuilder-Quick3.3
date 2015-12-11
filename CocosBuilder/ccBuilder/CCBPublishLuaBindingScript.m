//
//  CCBPublishLuaBindingScript.m
//  CocosBuilder
//
//  Created by zhengle on 14-11-20.
//
//

#import "CCBPublishLuaBindingScript.h"
#import "CCBReaderInternalV1.h"

enum {
    kCCBTargetTypeNone = 0,
    kCCBTargetTypeDocumentRoot = 1,
    kCCBTargetTypeOwner = 2,
};

@implementation CCBPublishLuaBindingScript

+ (NSString*) getClassName:(NSDictionary*) doc
{
    NSDictionary* nodeGraph = [doc objectForKey:@"nodeGraph"];
    NSString* className = [nodeGraph objectForKey:@"jsController"];
    if ( ! className || ! className.length) {
        return nil;
    }
    
    //get last component of className
    NSRange range = [className rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location != NSNotFound)
    {
        className = [className substringFromIndex:range.location + 1];
    }
    
    return className;
}

+ (NSString*) exportString:(NSDictionary*) doc ccbiName:(NSString*)ccbiName
{
    NSDictionary* nodeGraph = [doc objectForKey:@"nodeGraph"];
    NSString* className = [nodeGraph objectForKey:@"jsController"];
    NSString* ccbiFolder = @"ccb";
    if ( ! className || ! className.length) {
        return nil;
    }
    
    //get last component of className
    NSRange range = [className rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location != NSNotFound)
    {
        ccbiFolder = [NSString stringWithFormat:@"%@/%@", ccbiFolder, [className substringToIndex:range.location]];
        ccbiFolder = [ccbiFolder stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        className = [className substringFromIndex:range.location + 1];
    }
    if ( ! className || ! className.length) {
        return nil;
    }
    
    ccbiName = [NSString stringWithFormat:@"ccb/%@.ccbi", ccbiName];
    
    // load templates
    NSString* classTemplatePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/luaTemplate/class_template.lua"];
    NSString* functionTemplatePath = [[classTemplatePath stringByDeletingLastPathComponent] stringByAppendingString:@"/function_template.lua"];

    NSString* classTemplate = [NSString stringWithContentsOfFile:classTemplatePath encoding:NSUTF8StringEncoding error:nil];
    NSString* functionTemplate = [NSString stringWithContentsOfFile:functionTemplatePath encoding:NSUTF8StringEncoding error:nil];
    
    // load functions & members
    NSMutableArray* funcs = [NSMutableArray array];
    NSMutableArray* members = [NSMutableArray array];
    [CCBPublishLuaBindingScript fillFuncs:nodeGraph funcs:funcs members:members];
    
    // functions
    NSString* funcNameReplacement = @"";
    NSString* funcImplementReplacement = @"";
    NSString* touchFuncImplementReplacement = @"";
    NSString* addTouchFuncReplacement = @"";

    for (NSArray* func in funcs) {
        NSString* funcName = [func objectAtIndex:0];
        NSNumber* target  = [func objectAtIndex:1];
        // build names
        if (funcNameReplacement.length > 0)
        {
            funcNameReplacement = [funcNameReplacement stringByAppendingString:@"\n    "];
        }
        if ([target intValue] == kCCBTargetTypeDocumentRoot) {
            funcNameReplacement = [funcNameReplacement stringByAppendingFormat:@"\"%@\",", funcName];
        }else if ([target intValue] == kCCBMemberVarAssignmentTypeOwner) {
            funcNameReplacement = [funcNameReplacement stringByAppendingFormat:@"-- \"%@\", --[[ Owner ]]", funcName];
        }
        
        // build implements
        if (funcImplementReplacement.length > 0)
        {
            funcImplementReplacement = [funcImplementReplacement stringByAppendingString:@"\n\n"];
        }
        if ([target intValue] == kCCBTargetTypeDocumentRoot) {
            funcImplementReplacement = [funcImplementReplacement stringByAppendingString:[functionTemplate stringByReplacingOccurrencesOfString:@"__FUNC_NAME__" withString:funcName]];
        }else if ([target intValue] == kCCBMemberVarAssignmentTypeOwner) {
            funcImplementReplacement = [funcImplementReplacement stringByAppendingFormat:@"--[[\n-- Owner\n%@\n]]", [functionTemplate stringByReplacingOccurrencesOfString:@"__FUNC_NAME__" withString:funcName]];
        }
    }
    
    //members
    NSString* membersReplacement = @"";
    NSString* singleTouchFuncImp = @"";

    for (NSDictionary* node in members) {
        NSString* assignName = [node objectForKey:@"memberVarAssignmentName"];
        NSNumber* assignType = [node objectForKey:@"memberVarAssignmentType"];
        NSString* baseClass  = [node objectForKey:@"baseClass"];
        NSString* customClass= [node objectForKey:@"customClass"];


        if ([baseClass isEqualToString:@"CCSprite"]) {
            for (NSDictionary* dict in [node objectForKey:@"properties"]) {
                if ([[dict objectForKey:@"name"] isEqualToString:@"tag"]) {
                    int spriteTag = [[dict objectForKey:@"value"] intValue];
                    if (spriteTag >= 500) {
//                    对于tag>=500的精灵   视为按钮   直接在模板中绑定点击事件
                        addTouchFuncReplacement = [addTouchFuncReplacement stringByAppendingFormat:@"    \n--Add touch Event -%@\n    self.%@:setTouchEnabled(true)\n    self.%@:setLocalZOrder(1)\n    self.%@:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:buttonClick(event,self.%@)end)\n",assignName,assignName,assignName,assignName ,assignName];
                        singleTouchFuncImp = [singleTouchFuncImp stringByAppendingFormat:@"\n    if tag == %d then\n        --todo %@ Sprite Click\n        --todo        local state = CMSpriteButton:new(event,{sprite = sender,callback = function () CMClose(self) end})\n\n        return state\n    end",spriteTag,assignName];
                    }
                }
            }
        }
        
        
//        NSData *properties = [[node objectForKey:@"properties"] dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *propDict = [NSJSONSerialization JSONObjectWithData:properties options:NSJSONReadingMutableLeaves error:nil];
//        if (propDict != NULL) {
//            for (NSString *value in [propDict allValues]) {
//                if ([value isEqualToString:@"tag"]) {
//                    NSLog(@"Tag is ===> %d",[[propDict objectForKey:@"value"] intValue]);
//                }
//            }
//        }
//        NSLog(@"customClass:%@,baseClass:%@",baseClass,customClass);
        
        
        
        if (membersReplacement.length > 0) {
            membersReplacement = [membersReplacement stringByAppendingString:@"\n    "];
        }
        
        if ([baseClass isEqualToString:@"CCBFile"]) {
            for (NSDictionary* prop in [node objectForKey:@"properties"]) {
                if ([[prop objectForKey:@"type"] isEqualToString:@"CCBFile"]) {
                    NSString* ccbPath = [prop objectForKey:@"value"];
                    
                    baseClass = [NSString stringWithFormat:@"CCBFile(%@i)", ccbPath];
//                    NSLog([NSString stringWithFormat:@"CCBFile: %@i", ccbPath]);
                }
            }
        }
        
        membersReplacement = [membersReplacement stringByAppendingFormat:@"%@.%@ %@",
                                    [assignType intValue] == kCCBMemberVarAssignmentTypeDocumentRoot ? @"self" : @"owner",
                                    assignName,
                                    customClass.length > 0 ? customClass : baseClass
                              ];
        
        
    }
    if (![singleTouchFuncImp isEqualToString:@""]) {
//        todo namespace
        touchFuncImplementReplacement = [touchFuncImplementReplacement stringByAppendingFormat:@"function %@:buttonClick(event,sender)\n    -- @TODO: all sprite click func\n    local tag = sender:getTag()\n    %@\nend",className,singleTouchFuncImp];
    }
    
    // replace contents
    NSString* content = classTemplate;
    
    content = [content stringByReplacingOccurrencesOfString:@"__CCBI_FILE_PATH__" withString:ccbiName];
    content = [content stringByReplacingOccurrencesOfString:@"__CCBI_FOLDER__" withString:ccbiFolder];
    content = [content stringByReplacingOccurrencesOfString:@"__FUNC_NAMES__" withString:funcNameReplacement];
    content = [content stringByReplacingOccurrencesOfString:@"__FUNC_IMPLEMENTS__" withString:funcImplementReplacement];
    content = [content stringByReplacingOccurrencesOfString:@"__MEMBERS__" withString:membersReplacement];
    content = [content stringByReplacingOccurrencesOfString:@"__CLASS_NAME__" withString:className];
//    add by WuBing  在生成lua 模板时   绑定某些精灵的触摸函数
    content = [content stringByReplacingOccurrencesOfString:@"__TOUCH_FUNC_IMPLEMENTS__" withString:touchFuncImplementReplacement];
    content = [content stringByReplacingOccurrencesOfString:@"__ADD_TOUCH_FUNC__" withString:addTouchFuncReplacement];
    
    return content;
}

+ (void) fillFuncs:(NSDictionary*) node funcs:(NSMutableArray*) funcs members:(NSMutableArray*) members
{
    NSString* className = [node objectForKey:@"baseClass"];
//    NSLog(@"fillFuncs: %@", className);
    
    // push to fields
    NSString* assignName = [node objectForKey:@"memberVarAssignmentName"];
    NSNumber* assignType = [node objectForKey:@"memberVarAssignmentType"];
    if (assignName && assignName.length > 0 && [assignType intValue] != kCCBMemberVarAssignmentTypeNone) {
        [members addObject:node];
    }
    
    // push to funcs
    NSArray* classList = [NSArray arrayWithObjects:@"CCMenuItemImage", @"CCControl", @"CCControlButton", nil];
    if ([classList containsObject:className]) {
        //check property
        for (NSDictionary* prop in [node objectForKey:@"properties"]) {
            NSString* type = [prop objectForKey:@"type"];
            if ( ! [type isEqualToString:@"Block"] && ! [type isEqualToString:@"BlockCCControl"] ) continue;
            
            NSArray* value = (NSArray*)[prop objectForKey:@"value"];
            NSUInteger target = [value objectAtIndex:1];
            if (target != kCCBTargetTypeNone) {
                [funcs addObject:value];
            }
        }
        return;
    }
    
    // find children
    NSArray* children = [node objectForKey:@"children"];
    if ( ! children || ! children.count) {
        return;
    }
    
    for (NSDictionary* n in children) {
        [CCBPublishLuaBindingScript fillFuncs:n funcs:funcs members:members];
    }
}

+ (NSString*) getFolders:(NSDictionary*) doc inDir:(NSString*) luaDir
{
    NSDictionary* nodeGraph = [doc objectForKey:@"nodeGraph"];
    NSString* name = [nodeGraph objectForKey:@"jsController"];
    if ( ! name || ! name.length) {
        return luaDir;
    }
    
    name = [name stringByReplacingOccurrencesOfString:@"." withString:@"/"];
    name = [name stringByDeletingLastPathComponent];
    
    if ( ! name || name.length <= 0) {
        return luaDir;
    }
    
    name = [luaDir stringByAppendingPathComponent:name];
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if( ! [fileManager fileExistsAtPath:name isDirectory:&isDir])
    {
        if( ! [fileManager createDirectoryAtPath:name withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSLog(@"Error: Create folder failed %@", name);
            return luaDir;
        }
    }
    
    return name;
}

@end
