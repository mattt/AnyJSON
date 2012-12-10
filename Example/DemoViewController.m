//
//  DemoViewController.m
//  AnyJSON Demo
//
//  Created by Cédric Luthi on 18.11.12.
//

#import "DemoViewController.h"

@implementation DemoViewController

- (void)viewDidLoad
{
    NSString *library = @"None";
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_5_0) {
        library = @"NSJSONSerialization";
    } else if (NSClassFromString(@"JKSerializer")) {
        library = @"JSONKit";
    } else if (NSClassFromString(@"NXJsonSerializer")) {
        library = @"NextiveJson";
    } else if (NSClassFromString(@"SBJsonWriter")) {
        library = @"SBJson";
    } else if (NSClassFromString(@"YAJLGen")) {
        library = @"YAJL";
    }
    self.libraryLabel.text = library;
}

- (IBAction)test:(id)sender
{
    [self.view endEditing:YES];
    
    @try {
        NSError *readingError = nil;
        NSJSONReadingOptions readingOptions = 0;
        id object = [NSJSONSerialization JSONObjectWithData:[self.inputTextView.text dataUsingEncoding:NSUTF8StringEncoding] options:readingOptions error:&readingError];
        if (!object) {
            self.outputTextView.text = [NSString stringWithFormat:@"Reading Error: %@", readingError];
            return;
        }
        
        NSJSONWritingOptions writingOptions = 0;
        NSError *writingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:writingOptions error:&writingError];
        if (!data) {
            self.outputTextView.text = [NSString stringWithFormat:@"Writing Error: %@", writingError];
            return;
        }
        
        self.outputTextView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        self.outputTextView.text = [NSString stringWithFormat:@"Exception: %@", exception];
    }
}

@end
