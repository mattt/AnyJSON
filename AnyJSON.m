// AnyJSON.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static void AnyJSONUnimplemented(id self, SEL _cmd) {
    NSString *reason = [NSString stringWithFormat:@"%@[%@ %@] is not implemented", class_isMetaClass(object_getClass(self)) ? @"+" : @"-", self, NSStringFromSelector(_cmd)];
    [[NSException exceptionWithName:@"AnyJSONUnimplementedException" reason:reason userInfo:nil] raise];
}

BOOL AnyJSONIsValidObject(id self, SEL _cmd, id object) {
    AnyJSONUnimplemented(self, _cmd);
    return NO;
}

NSData * AnyJSONEncodeData(id self, SEL _cmd, id object, NSJSONWritingOptions options, NSError **error) {
    if (!object) {
        return nil;
    }

    NSData *data = nil;
    
    SEL _JSONKitSelector = NSSelectorFromString(@"JSONDataWithOptions:error:"); 
    
    SEL _YAJLSelector = NSSelectorFromString(@"yajl_JSONStringWithOptions:indentString:");
    
    id _SBJsonWriterClass = NSClassFromString(@"SBJsonWriter");
    SEL _SBJsonWriterSelector = NSSelectorFromString(@"dataWithObject:");
    SEL _SBJsonWriterSetHumanReadableSelector = NSSelectorFromString(@"setHumanReadable:");
    
    id _NXJsonSerializerClass = NSClassFromString(@"NXJsonSerializer");
    SEL _NXJsonSerializerSelector = NSSelectorFromString(@"serialize:");
    
    if (_JSONKitSelector && [object respondsToSelector:_JSONKitSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:_JSONKitSelector]];
        invocation.target = object;
        invocation.selector = _JSONKitSelector;
        
        NSUInteger serializeOptionFlags = 0;
        if ((options & NSJSONWritingPrettyPrinted) == NSJSONWritingPrettyPrinted) {
            serializeOptionFlags = 1 << 0; // JKSerializeOptionPretty
        }
        [invocation setArgument:&serializeOptionFlags atIndex:2];
        if (error != NULL) {
            [invocation setArgument:error atIndex:3];
        }
        
        [invocation invoke];
        [invocation getReturnValue:&data];
    } else if (_SBJsonWriterClass && [_SBJsonWriterClass instancesRespondToSelector:_SBJsonWriterSelector]) {
        id writer = [[_SBJsonWriterClass alloc] init];
        if ((options & NSJSONWritingPrettyPrinted) == NSJSONWritingPrettyPrinted && [writer respondsToSelector:_SBJsonWriterSetHumanReadableSelector]) {
            NSInvocation *humanReadableInvocation = [NSInvocation invocationWithMethodSignature:[writer methodSignatureForSelector:_SBJsonWriterSetHumanReadableSelector]];
            humanReadableInvocation.target = writer;
            humanReadableInvocation.selector = _SBJsonWriterSetHumanReadableSelector;
            [humanReadableInvocation setArgument:&(BOOL){YES} atIndex:2];
            [humanReadableInvocation invoke];
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[writer methodSignatureForSelector:_SBJsonWriterSelector]];
        invocation.target = writer;
        invocation.selector = _SBJsonWriterSelector;
        
        [invocation setArgument:&object atIndex:2];
        
        [invocation invoke];
        [invocation getReturnValue:&data];
        
        if (!data && error && [writer respondsToSelector:@selector(error)]) {
            id writerError = [writer performSelector:@selector(error)];
            if ([writerError isKindOfClass:[NSError class]]) {
                *error = writerError;
            } else if ([writerError isKindOfClass:[NSString class]]) {
                *error = [NSError errorWithDomain:@"org.brautaset.SBJsonWriter.ErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey : writerError}];
            }
        }
        [writer release];
    } else if (_YAJLSelector && [object respondsToSelector:_YAJLSelector]) {
        @try {
            NSString *JSONString = nil;
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:_YAJLSelector]];
            invocation.target = object;
            invocation.selector = _YAJLSelector;
            
            NSUInteger genOptions = 0;
            if ((options & NSJSONWritingPrettyPrinted) == NSJSONWritingPrettyPrinted) {
                genOptions = 1 << 0; // YAJLGenOptionsBeautify
            }
            [invocation setArgument:&genOptions atIndex:2];
            NSString *indent = @"  ";
            [invocation setArgument:&indent atIndex:3];
            
            [invocation invoke];
            [invocation getReturnValue:&JSONString];
            
            data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            *error = [[[NSError alloc] initWithDomain:NSStringFromClass([exception class]) code:0 userInfo:[exception userInfo]] autorelease];
        }
    } else if (_NXJsonSerializerClass && [_NXJsonSerializerClass respondsToSelector:_NXJsonSerializerSelector]) {
        NSString *JSONString = nil;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_NXJsonSerializerClass methodSignatureForSelector:_NXJsonSerializerSelector]];
        invocation.target = _NXJsonSerializerClass;
        invocation.selector = _NXJsonSerializerSelector;
        
        [invocation setArgument:&object atIndex:2];
        
        [invocation invoke];
        [invocation getReturnValue:&JSONString];
        data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Please add one of the following libraries to your project: JSONKit, SBJSON, YAJL or Nextive JSON", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"No JSON generation functionality available", nil) userInfo:userInfo] raise];
    }

    return data;
}

id AnyJSONDecodeData(id self, SEL _cmd, NSData *data, NSJSONReadingOptions options, NSError **error) {
    if (!data || [data length] == 0) {
        return nil;
    }

    id JSON = nil;
    
    SEL _JSONKitSelector = NSSelectorFromString(@"objectFromJSONDataWithParseOptions:error:");
    SEL _JSONKitMutableContainersSelector = NSSelectorFromString(@"mutableObjectFromJSONDataWithParseOptions:error:");
    
    SEL _YAJLSelector = NSSelectorFromString(@"yajl_JSONWithOptions:error:");
    
    id _SBJSONParserClass = NSClassFromString(@"SBJsonParser");
    SEL _SBJSONParserSelector = NSSelectorFromString(@"objectWithData:");
    
    id _NXJsonParserClass = NSClassFromString(@"NXJsonParser");
    SEL _NXJsonParserSelector = NSSelectorFromString(@"parseData:error:ignoreNulls:");

    if (_JSONKitSelector && [data respondsToSelector:_JSONKitSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[data methodSignatureForSelector:_JSONKitSelector]];
        invocation.target = data;
        invocation.selector = _JSONKitSelector;
        if ((options & NSJSONReadingMutableContainers) == NSJSONReadingMutableContainers && [data respondsToSelector:_JSONKitMutableContainersSelector]) {
            invocation.selector = _JSONKitMutableContainersSelector;
        }
        
        NSUInteger parseOptionFlags = 0;
        [invocation setArgument:&parseOptionFlags atIndex:2];
        if (error != NULL) {
            [invocation setArgument:&error atIndex:3];
        }
        
        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else if (_SBJSONParserClass && [_SBJSONParserClass instancesRespondToSelector:_SBJSONParserSelector]) {
        id parser = [[_SBJSONParserClass alloc] init];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[parser methodSignatureForSelector:_SBJSONParserSelector]];
        invocation.target = parser;
        invocation.selector = _SBJSONParserSelector;
        
        [invocation setArgument:&data atIndex:2];

        [invocation invoke];
        [invocation getReturnValue:&JSON];
        
        if (!JSON && error && [parser respondsToSelector:@selector(error)]) {
            id parserError = [parser performSelector:@selector(error)];
            if ([parserError isKindOfClass:[NSError class]]) {
                *error = parserError;
            } else if ([parserError isKindOfClass:[NSString class]]) {
                *error = [NSError errorWithDomain:@"org.brautaset.SBJsonParser.ErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey : parserError}];
            }
        }
        [parser release];
    } else if (_YAJLSelector && [data respondsToSelector:_YAJLSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[data methodSignatureForSelector:_YAJLSelector]];
        invocation.target = data;
        invocation.selector = _YAJLSelector;
        
        NSUInteger yajlParserOptions = 0;
        [invocation setArgument:&yajlParserOptions atIndex:2];
        if (error != NULL) {
            [invocation setArgument:&error atIndex:3];
        }
        
        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else if (_NXJsonParserClass && [_NXJsonParserClass respondsToSelector:_NXJsonParserSelector]) {
        NSNumber *nullOption = [NSNumber numberWithBool:YES];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_NXJsonParserClass methodSignatureForSelector:_NXJsonParserSelector]];
        invocation.target = _NXJsonParserClass;
        invocation.selector = _NXJsonParserSelector;
        
        [invocation setArgument:&data atIndex:2];
        if (error != NULL) {
            [invocation setArgument:&error atIndex:3];
        }
        [invocation setArgument:&nullOption atIndex:4];
        
        [invocation invoke];
        [invocation getReturnValue:&JSON];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Please add one of the following libraries to your project: JSONKit, SBJSON, YAJL or Nextive JSON", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"No JSON parsing functionality available", nil) userInfo:userInfo] raise];
    }
        
    return JSON;
}

NSInteger AnyJSONEncodeStream(id self, SEL _cmd, id object, NSOutputStream *stream, NSJSONWritingOptions options, NSError **error) {
    AnyJSONUnimplemented(self, _cmd);
    return 0;
}

id AnyJSONDecodeStream(id self, SEL _cmd, NSInputStream *stream, NSJSONReadingOptions options, NSError **error) {
    AnyJSONUnimplemented(self, _cmd);
    return nil;
}

@protocol AnyJSONSerialization
@required
+ (BOOL)isValidJSONObject:(id)obj;
+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error;
@end

__attribute__((constructor)) void AnyJSONInitialize(void) {
    Class NSJSONSerializationClass = objc_allocateClassPair(objc_getClass("NSObject"), "NSJSONSerialization", 0);
    if (!NSJSONSerializationClass) {
        return;
    }
    
    Class NSJSONSerializationMetaClass = object_getClass(NSJSONSerializationClass);
    class_addMethod(NSJSONSerializationMetaClass, @selector(isValidJSONObject:),                      (IMP)AnyJSONIsValidObject, protocol_getMethodDescription(@protocol(AnyJSONSerialization), @selector(isValidJSONObject:), YES, NO).types);
    class_addMethod(NSJSONSerializationMetaClass, @selector(dataWithJSONObject:options:error:),       (IMP)AnyJSONEncodeData,    protocol_getMethodDescription(@protocol(AnyJSONSerialization), @selector(dataWithJSONObject:options:error:), YES, NO).types);
    class_addMethod(NSJSONSerializationMetaClass, @selector(JSONObjectWithData:options:error:),       (IMP)AnyJSONDecodeData,    protocol_getMethodDescription(@protocol(AnyJSONSerialization), @selector(JSONObjectWithData:options:error:), YES, NO).types);
    class_addMethod(NSJSONSerializationMetaClass, @selector(writeJSONObject:toStream:options:error:), (IMP)AnyJSONEncodeStream,  protocol_getMethodDescription(@protocol(AnyJSONSerialization), @selector(writeJSONObject:toStream:options:error:), YES, NO).types);
    class_addMethod(NSJSONSerializationMetaClass, @selector(JSONObjectWithStream:options:error:),     (IMP)AnyJSONDecodeStream,  protocol_getMethodDescription(@protocol(AnyJSONSerialization), @selector(JSONObjectWithStream:options:error:), YES, NO).types);
    objc_registerClassPair(NSJSONSerializationClass);
    
    Class *NSJSONSerializationClassRef = NULL;
#if TARGET_CPU_ARM
    asm(
    "movw %0, :lower16:(L_OBJC_CLASS_NSJSONSerialization-(LPC0+4))\n"
    "movt %0, :upper16:(L_OBJC_CLASS_NSJSONSerialization-(LPC0+4))\n"
    "LPC0: add %0, pc" : "=r"(NSJSONSerializationClassRef)
    );
#else
    asm("mov $L_OBJC_CLASS_NSJSONSerialization, %0" : "=r"(NSJSONSerializationClassRef));
#endif
    if (NSJSONSerializationClassRef) {
        *NSJSONSerializationClassRef = NSJSONSerializationClass;
    }
}

asm(
#if TARGET_CPU_X86 && !TARGET_IPHONE_SIMULATOR
".section        __TEXT,__cstring,cstring_literals\n"
"L_OBJC_CLASS_NAME_NSJSONSerialization:\n"
".asciz          \"NSJSONSerialization\"\n"
".section        __OBJC,__cls_refs,literal_pointers,no_dead_strip\n"
".align          2\n"
"L_OBJC_CLASS_NSJSONSerialization:\n"
".long           L_OBJC_CLASS_NAME_NSJSONSerialization\n"
#else
".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
".align          2\n"
"L_OBJC_CLASS_NSJSONSerialization:\n"
".long           _OBJC_CLASS_$_NSJSONSerialization\n"
".weak_reference _OBJC_CLASS_$_NSJSONSerialization\n"
#endif
);

// This dummy category ensures that all the AnyJSON functions are not stripped by the linker if the -ObjC linker flag is used.
@implementation NSObject (AnyJSON) @end
