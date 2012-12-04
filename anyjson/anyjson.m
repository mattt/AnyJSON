//
//  anyjson.m
//  AnyJSON Demo
//
//  Created by Cédric Luthi on 01.12.12.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>

void ExitWithError(NSString *message, id error)
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    BOOL term = [environment objectForKey:@"TERM"] != nil;
    BOOL xcodeColors = [[environment objectForKey:@"XcodeColors"] boolValue];
    NSLog(term || xcodeColors ? @"\e[1;31m%@:\e[m %@" : @"%@: %@", message, [error description]);
    exit(EXIT_FAILURE);
}

void LoadDylib(NSString *dylibPath)
{
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

NSData * JSONRoundTrip(NSData *inputData, NSJSONReadingOptions readingOptions, NSJSONWritingOptions writingOptions)
{
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

int main(int argc, const char * argv[])
{
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
