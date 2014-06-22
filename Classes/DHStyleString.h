//
//  DHStyleString.h
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

#import <Foundation/Foundation.h>


@interface DHStyleString : NSObject

#pragma mark - Initializer
/** Initialize with the name of a resource file
 *
 * Creates an instance of the DHStyleString class by loading the raw string from
 * a resource included in the bundle. Resource should have a .stylestring extension.
 *
 * @param resourceName The name of the resource, not including the extension.
 * @return The initialized object
 */
- (instancetype)initWithName:(NSString *)resourceName;

/** Initialize with the contents of a string
 *
 * Creates an instance of the DHStyleString class using a raw string.
 *
 * @param inString The raw string
 * @return The initialized object
 */
- (instancetype)initWithString:(NSString *)inString;

#pragma mark - Properties
@property (nonatomic,strong) NSMutableArray *stringFragments;

@end
