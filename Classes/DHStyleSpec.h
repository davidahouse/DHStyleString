//
//  DHStyleSpec.h
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
#import <Foundation/Foundation.h>

@class DHStyleString;

@interface DHStyleSpec : NSObject

#pragma mark - Initializer
/** Initializer
 *
 * Initialize a StyleSpec given a stylespec file name
 * @param stylespecname The name of the stylespec file, not including the .stylespec extension
 * @return The instantiated object
 */
- (instancetype)initWithName:(NSString *)stylespecname;

#pragma mark - Public Methods
/** Create an attributed string
 *
 * Creates an attributed string from a plain string and a style name
 * @param inString The string to convert
 * @param style The style to use when formatting the string
 * @return The attributed string styled using this stylespec
 */
- (NSAttributedString *)attributedString:(NSString *)inString style:(NSString *)style;

/** Create an attributed string from a style string
 * 
 * Creates an attributed string from a style string and given a set of replacement
 * variables.
 * @param inStyleString A DHStyleString object representing the raw data to be converted
 * @param variables A dictionary of replacement variables that will be applied to the style string
 * @return The attributed string styled using this stylespec
 */
- (NSAttributedString *)attributedStringFromStyleString:(DHStyleString *)inStyleString variables:(NSDictionary *)variables;

@end
