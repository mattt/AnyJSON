// anyjson.m
//
// Copyright (c) 2012 Cédric Luthi (https://twitter.com/0xced)
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
#import <dlfcn.h>

void ExitWithError(NSString *message, id error) {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    BOOL term = [environment objectForKey:@"TERM"] != nil;
    BOOL xcodeColors = [[environment objectForKey:@"XcodeColors"] boolValue];
    NSString *userInfo = [error isKindOfClass:[NSError class]] ? [@"\n" stringByAppendingString:[[error userInfo] description]] : @"";
    NSLog(term || xcodeColors ? @"\e[1;31m%@:\e[m %@%@" : @"%@: %@%@", message, [error description], userInfo);
    exit(EXIT_FAILURE);
}

void LoadDylib(NSString *dylibPath) {
    if (!dylibPath) {
        return;
    }
    
    NSBundle *dylibBundle = [NSBundle bundleWithPath:dylibPath];
    if (dylibBundle) {
        NSError *loadError = nil;
        BOOL loaded = [dylibBundle loadAndReturnError:&loadError];
        if (!loaded) {
            ExitWithError(@"Load Error", loadError);
        }
    } else {
        void *dylibHandle = dlopen([dylibPath fileSystemRepresentation], RTLD_LAZY);
        if (dylibPath && !dylibHandle) {
            ExitWithError(@"Load Error", @(dlerror()));
        }
    }
}

NSData * JSONRoundTrip(NSData *inputData, NSJSONReadingOptions readingOptions, NSJSONWritingOptions writingOptions) {
    NSError *readingError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:inputData options:readingOptions error:&readingError];
    if (!object) {
        ExitWithError(@"Reading Error", readingError);
    }
    
    NSError *writingError = nil;
    NSData *outputData = [NSJSONSerialization dataWithJSONObject:object options:writingOptions error:&writingError];
    if (!outputData) {
        ExitWithError(@"Writing Error", writingError);
    }
    
    return outputData;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            NSLog(@"Usage: %@ [-dylib dylib_path] [-readingOptions reading_options] [-writingOptions writing_options] JSON_string", [@(argv[0]) lastPathComponent]);
            return EXIT_FAILURE;
        }
        @try {
            LoadDylib([[NSUserDefaults standardUserDefaults] objectForKey:@"dylib"]);
            
            NSString *readingOptions = [[NSUserDefaults standardUserDefaults] objectForKey:@"readingOptions"];
            NSString *writingOptions = [[NSUserDefaults standardUserDefaults] objectForKey:@"writingOptions"];
            
            NSData *inputData = [@(argv[argc - 1]) dataUsingEncoding:NSUTF8StringEncoding];
            NSData *outputData = JSONRoundTrip(inputData, [readingOptions integerValue], [writingOptions integerValue]);
            NSLog(@"%@", [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding]);
        }
        @catch (NSException *exception) {
            ExitWithError(@"Exception", exception);
        }
    }
    
    return EXIT_SUCCESS;
}
