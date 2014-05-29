//
//  SSStyleSpec.h
//  
//
//  Created by David House on 5/29/14.
//
//

#import <Foundation/Foundation.h>

@interface SSStyleSpec : NSObject

#pragma mark - Initializer
- (instancetype)initWithName:(NSString *)stylespecname;

#pragma mark - Public Methods
- (NSDictionary *)attributesForStyle:(NSString *)style;

@end
