//
//  DHStyleString.m
//
//  Created by David House on 6/21/14.
//  Copyright (c) 2014 David House <davidahouse@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "DHStyleString.h"

@implementation DHStyleString

#pragma mark - Initializer
- (instancetype)initWithName:(NSString *)resourceName
{
    if ( self = [super init] ) {
        for ( NSBundle *bundle in [NSBundle allBundles] ) {
            
            NSString *styleStringPath = [bundle pathForResource:resourceName ofType:@"stylestring"];
            if ( styleStringPath ) {
                NSError *error = nil;
                NSString *styleFile = [NSString stringWithContentsOfFile:styleStringPath encoding:NSUTF8StringEncoding error:&error];
                if ( !error ) {
                    [self parseString:styleFile];
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithString:(NSString *)inString
{
    if ( self = [super init] ) {
        [self parseString:inString];
    }
    return self;
}

#pragma mark - Private methods
- (void)parseString:(NSString *)inString
{
    self.stringFragments = [[NSMutableArray alloc] init];
    NSMutableArray *styleStack = [[NSMutableArray alloc] init];
    NSScanner *styleScanner = [[NSScanner alloc] initWithString:inString];
    [styleScanner setCharactersToBeSkipped:nil];
    
    while ( ![styleScanner isAtEnd] ) {
        
        NSString *upTo = @"";
        BOOL foundTag = NO;
        BOOL atTag = NO;
        
        // Peek at the string to see if we are right at a tag. If so, then scanUpToString will
        // fail, so we need to just proceed as if we had a tag.
        if ( [styleScanner scanLocation] < ([inString length] - 2) ) {
            if ( [[inString substringWithRange:NSMakeRange([styleScanner scanLocation], 2)] isEqualToString:@"#{"] ) {
                atTag = YES;
                foundTag = YES;
            }
        }
        
        if ( !atTag ) {
            foundTag = [styleScanner scanUpToString:@"#{" intoString:&upTo];
        }

        if ( upTo && ![upTo isEqualToString:@""] ) {
            // add string to the fragments, applying the styles that are on the stack
            NSDictionary *fragmentDict = @{@"kind":@"string",@"string":upTo,@"styleStack":[styleStack copy]};
            [self.stringFragments addObject:fragmentDict];
        }

        if ( foundTag ) {
            [styleScanner scanString:@"#{" intoString:NULL];
            
            NSString *styleFormat = @"";
            [styleScanner scanUpToString:@"}" intoString:&styleFormat];
            [styleScanner scanString:@"}" intoString:NULL];
            
            if ( styleFormat && ![styleFormat isEqualToString:@""] ) {
                
                if ( [styleFormat rangeOfString:@"+"].location != NSNotFound ) {
                    NSString *style = [styleFormat stringByReplacingOccurrencesOfString:@"+" withString:@""];
                    [styleStack addObject:[style stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
                else if ( [styleFormat rangeOfString:@"-"].location != NSNotFound ) {
                    [styleStack removeLastObject];
                }
                else if ( [styleFormat rangeOfString:@":"].location != NSNotFound ) {
                    NSArray *styleParts = [styleFormat componentsSeparatedByString:@":"];
                    [styleStack addObject:styleParts[1]];
                    NSDictionary *fragmentDict = @{@"kind":@"variable",@"variable":styleParts[0],@"styleStack":[styleStack copy]};
                    [self.stringFragments addObject:fragmentDict];
                    [styleStack removeLastObject];
                }
                else {
                    NSDictionary *fragmentDict = @{@"kind":@"variable",@"variable":styleFormat,@"styleStack":[styleStack copy]};
                    [self.stringFragments addObject:fragmentDict];
                }
            }
        }
    }
}


@end
