//
//  NSAttributedString+StyleString.h
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

#import <Foundation/Foundation.h>

/** StyleString category
 * Provides a set of methods that allow for easy construction of
 * NSAttributedString objects.
 */
@interface NSAttributedString (DHStyleString)

#pragma mark - Class Methods

/** Create a styled string 
 *
 * Creates a styled string using a raw string and a style specifier. This method looks for
 * any stylespec file in the project and automatically uses it. Only use this method if you
 * have a single stylespec file in your project.
 *
 * @param inString The raw string you want to style
 * @param style The style name that you want to use from the stylespec
 * @return The styled attributed string
 */
+ (NSAttributedString *)SS_attributedString:(NSString *)inString style:(NSString *)style;

/** Create a styled string using a specific stylespec file
 *
 * Creates a styled string using a raw string, style specifier and a stylespec file name.
 *
 * @param inString The raw string you want to style
 * @param style The style name that you want to use from the stylespec
 * @param stylespec The name of the stylespec file to use that was included in the Bundle (no need to include .stylespec at the end)
 * @return The styled attributed string
 */
+ (NSAttributedString *)SS_attributedString:(NSString *)inString style:(NSString *)style stylespec:(NSString *)stylespec;

/** Create a styled string from an array of strings
 *
 * Creates a styled string using an array of strings and style specifiers. The strings are simply appended
 * to each other to create the final result. This method looks for
 * any stylespec file in the project and automatically uses it. Only use this method if you
 * have a single stylespec file in your project.
 *
 * @param inStrings The array of raw strings you want to style
 * @param styles The array of styles you want to style
 * @return The styled attributed string
 */
+ (NSAttributedString *)SS_attributedStrings:(NSArray *)inStrings styles:(NSArray *)styles;

/** Create a styled string from an array of strings using a specific stylespec file
 *
 * Creates a styled string using an array of strings and style specifiers. The strings are simply appended
 * to each other to create the final result.
 *
 * @param inStrings The array of raw strings you want to style
 * @param styles The array of styles you want to style
 * @param stylespec The name of the stylespec file to use that was included in the Bundle (no need to include .stylespec at the end)
 * @return The styled attributed string
 */
+ (NSAttributedString *)SS_attributedStrings:(NSArray *)inStrings styles:(NSArray *)styles stylespec:(NSString *)stylespec;

@end
