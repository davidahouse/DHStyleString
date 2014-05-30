//
//  NSAttributedString+StyleString.m
//
//
//  Created by David House on 5/29/14.
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

#import "NSAttributedString+DHStyleString.h"
#import "DHStyleSpec.h"

@implementation NSAttributedString (DHStyleString)

#pragma mark - Class Methods

+ (NSAttributedString *)SS_attributedString:(NSString *)inString style:(NSString *)style
{
    // Search all the bundles for the file
    for ( NSBundle *bundle in [NSBundle allBundles] ) {
        
        NSArray *specFiles = [bundle pathsForResourcesOfType:@"stylespec" inDirectory:nil];
        if ( specFiles && [specFiles count] > 0 ) {
            return [self SS_attributedString:inString style:style stylespec:[specFiles[0] lastPathComponent] ];
        }
    }
    return [[NSAttributedString alloc] initWithString:inString];
}

+ (NSAttributedString *)SS_attributedString:(NSString *)inString style:(NSString *)style stylespec:(NSString *)stylespec
{
    // Load the style spec
    DHStyleSpec *spec = [[DHStyleSpec alloc] initWithName:stylespec];

    // Calculate the attributes for this style
    NSDictionary *attributes = [spec attributesForStyle:style];
    if ( attributes ) {
        return [[NSAttributedString alloc] initWithString:inString attributes:attributes];
    }
    else {
        return [[NSAttributedString alloc] initWithString:inString];
    }
}

+ (NSAttributedString *)SS_attributedStrings:(NSArray *)inStrings styles:(NSArray *)styles
{
    // Search all the bundles for the file
    for ( NSBundle *bundle in [NSBundle allBundles] ) {
        
        NSArray *specFiles = [bundle pathsForResourcesOfType:@"stylespec" inDirectory:nil];
        if ( specFiles && [specFiles count] > 0 ) {
            return [self SS_attributedStrings:inStrings styles:styles stylespec:[specFiles[0] lastPathComponent] ];
        }
    }
    return nil;
}

+ (NSAttributedString *)SS_attributedStrings:(NSArray *)inStrings styles:(NSArray *)styles stylespec:(NSString *)stylespec
{
    if ( !inStrings || !styles || [inStrings count] != [styles count] ) {
        return nil;
    }
    
    NSMutableAttributedString *totalString = [[NSMutableAttributedString alloc] init];
    
    for ( int i = 0; i < [inStrings count]; i++ ) {
        
        [totalString appendAttributedString:[self SS_attributedString:inStrings[i] style:styles[i] stylespec:stylespec]];
    }
    return totalString;
}

@end
