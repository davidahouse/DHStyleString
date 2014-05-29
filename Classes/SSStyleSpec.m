//
//  SSStyleSpec.m
//  
//
//  Created by David House on 5/29/14.
//
//

#import "SSStyleSpec.h"

/**
 
 SPEC FILE FORMAT:
 
 
 <name> : <parent> {
    <style attributes>
 }
 
 
 <style attributes>
 
 
    NSForegroundColorAttributeName
    "NSColor": "0xCCCCCC"
 
    NSBackgroundColorAttributeName
    "NSBackgroundColor": "0xCCCCCC"
 
    NSStrokeColorAttributeName
    "NSStrokeColor"
 
    NSStrokeWidthAttributeName
    "NSStrokeWidth"
 
    NSUnderlineColorAttributeName
    "NSUnderlineColor"
 
    NSUnderlineStyleAttributeName
    NSUnderline

    NSStrikethroughColorAttributeName
    NSStrikethroughColor
 
    NSStrikethroughStyleAttributeName
    NSStrikethrough

    NSShadowAttributeName
    NSShadow
        shadowColor
        shadowBlurRadius
        shadowOffsetX
        shadowOffsetY
 
    NSKernAttributeName
    NSKern
 
    NSLigatureAttributeName
    NSLigature
 
    NSTextEffectAttributeName
    NSTextEffect
 
    NSAttachmentAttributeName
    NOT SUPPORTED
 
    NSLinkAttributeName
    NSLink
 
    NSBaselineOffsetAttributeName
    NSBaselineOffset
 
    NSObliquenessAttributeName
    NSObliqueness
 
    NSExpansionAttributeName
    NSExpansion
 
    NSWritingDirectionAttributeName
    NSWritingDirection
    NOT SUPPORTED (HOW TO MAKE IT WORK?)
 
    NSVerticalGlyphFormAttributeName
    NOT SUPPORTED
 
    NSFontAttributeName
    NSFont
        fontName
        fontSize

    NSParagraphStyleAttributeName
 
*/


@interface SSStyleSpec()

#pragma mark - Properties
@property (nonatomic,strong) NSString *specFilePath;
@property (nonatomic,strong) NSDictionary *styles;

@end

@implementation SSStyleSpec

#pragma mark - Initializer
- (instancetype)initWithName:(NSString *)stylespecname
{
    if ( self = [super init] ) {
        
        // Search all the bundles for the file
        for ( NSBundle *bundle in [NSBundle allBundles] ) {
            
            NSString *specFilePath = [bundle pathForResource:stylespecname ofType:@"stylespec"];
            if ( specFilePath ) {
                _specFilePath = specFilePath;
            }
        }
    }
    return self;
}

#pragma mark - Properties
- (NSDictionary *)styles
{
    if ( !_styles ) {
        
        static NSMutableDictionary *staticCachedStyles = nil;
        if ( !staticCachedStyles ) {
            staticCachedStyles = [[NSMutableDictionary alloc] init];
        }
        
        if ( staticCachedStyles[_specFilePath] ) {
            _styles = staticCachedStyles[_specFilePath];
        }
        else {
            [self parse];
            staticCachedStyles[_specFilePath] = _styles;
        }
    }
    return _styles;
}

#pragma mark - Public Methods
- (NSDictionary *)attributesForStyle:(NSString *)style
{
    NSDictionary *attr = [self.styles objectForKey:style];
    if ( attr ) {
        return attr;
    }
    else {
        return nil;
    }
}

#pragma mark - Private Methods
- (void)parse
{
    NSMutableDictionary *foundStyles = [[NSMutableDictionary alloc] init];
    
    NSLog(@"loading style from: %@",self.specFilePath);
    
    NSError *error = nil;
    NSString *styleFile = [NSString stringWithContentsOfFile:self.specFilePath encoding:NSUTF8StringEncoding error:&error];
    if ( error ) {
        NSLog(@"error parsing file: %@",error);
        _styles = foundStyles;
        return;
    }
    
    NSArray *fileLines = [styleFile componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    BOOL inStyle = NO;
    NSString *currentStyle = @"";
    NSString *currentStyleContent = @"";
    for ( NSString *line in fileLines ) {

        // empty lines are a signal that the style has ended. Also an ending curly brace at the start of the line.
        if ( (line.length > 0 && [line hasPrefix:@"}"]) ) {
            
            inStyle = NO;
            
            NSString *styleName = @"";
            NSString *parentStyleName = @"";
            NSArray *styleComponents = [currentStyle componentsSeparatedByString:@":"];
            styleName = [[styleComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ( styleComponents.count > 1 ) {
                parentStyleName = [[styleComponents objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
            }
            
            currentStyleContent = [currentStyleContent stringByAppendingString:@"}"];
            NSData *jsonData = [currentStyleContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *parseError = nil;
            id parsedJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
            if ( parseError ) {
                NSLog(@"error parsing style: %@",parseError);
                NSLog(@"raw style json: %@",currentStyleContent);
            }
            else {
                [foundStyles setObject:@{@"name":styleName,@"parent":parentStyleName,@"attributes":parsedJSON} forKey:styleName];
            }
            currentStyle = @"";
            currentStyleContent = @"";
        }
        else {
            
            if ( inStyle ) {
                currentStyleContent = [currentStyleContent stringByAppendingString:line];
            }
            else {
                if ( [line rangeOfString:@"{"].location != NSNotFound ) {
                    currentStyle = [line substringToIndex:[line rangeOfString:@"{"].location];
                    inStyle = YES;
                    currentStyleContent = @"{";
                }
            }
        }
    }

    NSLog(@"found styles: %@",foundStyles);
    
    // Now we need to compute the final styles
    [self computeStylesFromRawSpec:foundStyles];
    
    NSLog(@"computed styles: %@",_styles);
}

- (void)computeStylesFromRawSpec:(NSDictionary *)foundStyles
{
    NSMutableDictionary *computedStyles = [[NSMutableDictionary alloc] init];

    for ( NSString *key in [foundStyles allKeys] ) {
    
        NSDictionary *styleAttributes = [self convertAttributeValues:[foundStyles objectForKey:key][@"attributes"]];
        if ( ![[foundStyles objectForKey:key][@"parent"] isEqualToString:@""] ) {
            styleAttributes = [self mergeAttributes:styleAttributes withParent:[foundStyles objectForKey:key][@"parent"] foundStyles:foundStyles];
        }
        [computedStyles setObject:styleAttributes forKey:key];
    }
    _styles = computedStyles;
}

- (NSDictionary *)mergeAttributes:(NSDictionary *)attributes withParent:(NSString *)parent foundStyles:(NSDictionary *)foundStyles
{
    NSDictionary *parentAttributes = [self convertAttributeValues:[foundStyles objectForKey:parent][@"attributes"]];
    if ( ![[foundStyles objectForKey:parent][@"parent"] isEqualToString:@""] ) {
        parentAttributes = [self mergeAttributes:parentAttributes withParent:[foundStyles objectForKey:parent][@"parent"] foundStyles:foundStyles];
    }
    
    if ( !parentAttributes ) {
        return attributes;
    }
    
    NSLog(@"trying to merge attributes: %@",attributes);
    NSLog(@"with: %@",parentAttributes);
    
    NSMutableDictionary *mergedAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes copyItems:YES];
    for ( id key in parentAttributes ) {
        if ( ![mergedAttributes objectForKey:key] ) {
            [mergedAttributes setObject:[parentAttributes objectForKey:key] forKey:key];
        }
    }
    return mergedAttributes;
}

- (NSDictionary *)convertAttributeValues:(NSDictionary *)attributes
{
    NSMutableDictionary *finalAttributes = [[NSMutableDictionary alloc] init];
    
    for ( id key in attributes ) {
        if ( [key isEqualToString:@"NSColor"] || [key isEqualToString:@"NSBackgroundColor"] || [key isEqualToString:@"NSStrokeColor"] || [key isEqualToString:@"NSUnderlineColor"] || [key isEqualToString:@"NSStrikethroughColor"]) {
            
            UIColor *converted = [self colorFromHexString:[attributes objectForKey:key]];
            [finalAttributes setObject:converted forKey:key];
        }
        else if ( [key isEqualToString:@"NSShadow"] ) {
            
            NSShadow *shadow = [[NSShadow alloc] init];
            
            NSDictionary *shadowDetails = [attributes objectForKey:key];
            if ( shadowDetails && shadowDetails[@"shadowColor"] ) {
                shadow.shadowColor = [self colorFromHexString:shadowDetails[@"shadowColor"]];
            }
            if ( shadowDetails && shadowDetails[@"shadowOffsetX"] && shadowDetails[@"shadowOffsetY"] ) {
                shadow.shadowOffset = CGSizeMake([shadowDetails[@"shadowOffsetX"] floatValue], [shadowDetails[@"shadowOffsetY"] floatValue]);
            }
            if ( shadowDetails && shadowDetails[@"shadowBlurRadius"] ) {
                shadow.shadowBlurRadius = [shadowDetails[@"shadowBlurRadius"] floatValue];
            }
            
            [finalAttributes setObject:shadow forKey:key];
        }
        else if ( [key isEqualToString:@"NSFont"] ) {
            
            NSDictionary *fontDetails = [attributes objectForKey:key];
            if ( fontDetails && fontDetails[@"fontName"] && fontDetails[@"fontSize"] ) {
            
                UIFont *font = [UIFont fontWithName:fontDetails[@"fontName"] size:[fontDetails[@"fontSize"] floatValue]];
                [finalAttributes setObject:font forKey:key];
            }
            else if ( fontDetails && fontDetails[@"systemFontOfSize"] ) {
                
                UIFont *font = [UIFont systemFontOfSize:[fontDetails[@"systemFontOfSize"] floatValue]];
                [finalAttributes setObject:font forKey:key];
            }
            else if ( fontDetails && fontDetails[@"boldSystemFontOfSize"] ) {
                
                UIFont *font = [UIFont boldSystemFontOfSize:[fontDetails[@"boldSystemFontOfSize"] floatValue]];
                [finalAttributes setObject:font forKey:key];
            }
            else if ( fontDetails && fontDetails[@"italicSystemFontOfSize"] ) {
                
                UIFont *font = [UIFont italicSystemFontOfSize:[fontDetails[@"italicSystemFontOfSize"] floatValue]];
                [finalAttributes setObject:font forKey:key];
            }
        }
        else if ( [key isEqualToString:@"NSParagraphStyle"] ) {
            
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            NSDictionary *paraDetails = [attributes objectForKey:key];
            
            if ( paraDetails && paraDetails[@"alignment"] ) {
                if ( [paraDetails[@"alignment"] isEqualToString:@"left"] ) {
                    paragraph.alignment = NSTextAlignmentLeft;
                }
                else if ( [paraDetails[@"alignment"] isEqualToString:@"center"] ) {
                    paragraph.alignment = NSTextAlignmentCenter;
                }
                else if ( [paraDetails[@"alignment"] isEqualToString:@"right"] ) {
                    paragraph.alignment = NSTextAlignmentRight;
                }
            }
            else if ( paraDetails && paraDetails[@"firstLineHeadIndent"] ) {
                paragraph.firstLineHeadIndent = [paraDetails[@"firstLineHeadIndent"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"headIndent"] ) {
                paragraph.headIndent = [paraDetails[@"headIndent"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"hyphenationFactor"] ) {
                paragraph.hyphenationFactor = [paraDetails[@"hyphenationFactor"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"lineBreakMode"] ) {
                if ( [paraDetails[@"lineBreakMode"] isEqualToString:@"wordWrapping"] ) {
                    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
                }
                else if ( [paraDetails[@"lineBreakMode"] isEqualToString:@"charWrapping"] ) {
                    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
                }
                else if ( [paraDetails[@"lineBreakMode"] isEqualToString:@"clipping"] ) {
                    paragraph.lineBreakMode = NSLineBreakByClipping;
                }
                else if ( [paraDetails[@"lineBreakMode"] isEqualToString:@"truncatingHead"] ) {
                    paragraph.lineBreakMode = NSLineBreakByTruncatingHead;
                }
                else if ( [paraDetails[@"lineBreakMode"] isEqualToString:@"truncatingTail"] ) {
                    paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
                }
                else if ( [paraDetails[@"lineBreakMode"] isEqualToString:@"truncatingMiddle"] ) {
                    paragraph.lineBreakMode = NSLineBreakByTruncatingMiddle;
                }
            }
            else if ( paraDetails && paraDetails[@"lineHeightMultiple"] ) {
                paragraph.lineHeightMultiple = [paraDetails[@"lineHeightMultiple"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"lineSpacing"] ) {
                paragraph.lineSpacing = [paraDetails[@"lineSpacing"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"maximumLineHeight"] ) {
                paragraph.maximumLineHeight = [paraDetails[@"maximumLineHeight"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"minimumLineHeight"] ) {
                paragraph.minimumLineHeight = [paraDetails[@"minimumLineHeight"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"paragraphSpacing"] ) {
                paragraph.paragraphSpacing = [paraDetails[@"paragraphSpacing"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"paragraphSpacingBefore"] ) {
                paragraph.paragraphSpacing = [paraDetails[@"paragraphSpacingBefore"] floatValue];
            }
            else if ( paraDetails && paraDetails[@"tailIndent"] ) {
                paragraph.tailIndent = [paraDetails[@"tailIndent"] floatValue];
            }

            [finalAttributes setObject:paragraph forKey:key];
        }
        else {
            [finalAttributes setObject:[attributes objectForKey:key] forKey:key];
        }
    }
    
    return finalAttributes;
}

- (UIColor *)colorFromHexString:(NSString *)colorString
{
    unsigned int rgbValue;
    NSScanner* scanner = [NSScanner scannerWithString:colorString];
    [scanner scanHexInt:&rgbValue];
    UIColor *converted = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
    return converted;
}

@end



