// DemoViewController.m
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

#import "DemoViewController.h"

@implementation DemoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
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

- (IBAction)test:(id)sender {
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
    } @catch (NSException *exception) {
        self.outputTextView.text = [NSString stringWithFormat:@"Exception: %@", exception];
    }
}

@end
