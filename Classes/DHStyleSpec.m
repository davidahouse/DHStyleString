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
#import "DHStyleSpec.h"
#import "DHStyleString.h"

/**
 TODO: Improve the spec file format documentation
 
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


@interface DHStyleSpec()

#pragma mark - Properties
@property (nonatomic,strong) NSString *specFilePath;
@property (nonatomic,strong) NSDictionary *styles;

@end

@implementation DHStyleSpec

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
        [self parse];
    }
    return self;
}

#pragma mark - Properties
- (NSDictionary *)styles
{
    if ( !_styles ) {
        _styles = [[NSMutableDictionary alloc] init];
    }
    return _styles;
}

#pragma mark - Public Methods

- (NSAttributedString *)attributedString:(NSString *)inString style:(NSString *)style
{
    NSDictionary *attributes = [self.styles objectForKey:style];
    if ( attributes ) {
        return [[NSAttributedString alloc] initWithString:inString attributes:attributes];
    }
    else {
        return [[NSAttributedString alloc] initWithString:inString];
    }
}

- (NSAttributedString *)attributedStringFromStyleString:(DHStyleString *)inStyleString variables:(NSDictionary *)variables
{
    NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] init];
    
    for ( NSDictionary *fragment in inStyleString.stringFragments ) {
    
        NSDictionary *attributes = @{};
        for ( NSString *style in fragment[@"styleStack"] ) {
            
            if ( self.styles[style] ) {
                attributes = [self combineAttributes:attributes with:self.styles[style]];
            }
        }
    
        if ( [fragment[@"kind"] isEqualToString:@"string"] ) {
            NSAttributedString *partial = [[NSAttributedString alloc] initWithString:fragment[@"string"] attributes:attributes];
            [fullString appendAttributedString:partial];
        }
        else if ( [fragment[@"kind"] isEqualToString:@"variable"] ) {
            if ( variables[fragment[@"variable"]] ) {
                NSAttributedString *partial = [[NSAttributedString alloc] initWithString:variables[fragment[@"variable"]] attributes:attributes];
                [fullString appendAttributedString:partial];
            }
        }
    }
    return fullString;
}

#pragma mark - Private Methods
- (void)parse
{
    NSMutableDictionary *foundStyles = [[NSMutableDictionary alloc] init];
    
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

    // Now we need to compute the final styles
    [self computeStylesFromRawSpec:foundStyles];
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
    // if no parent, just return unmerged
    if ( ![foundStyles objectForKey:parent] ) {
        return attributes;
    }
    
    NSDictionary *parentAttributes = [self convertAttributeValues:[foundStyles objectForKey:parent][@"attributes"]];
    if ( ![[foundStyles objectForKey:parent][@"parent"] isEqualToString:@""] ) {
        parentAttributes = [self mergeAttributes:parentAttributes withParent:[foundStyles objectForKey:parent][@"parent"] foundStyles:foundStyles];
    }
    
    if ( !parentAttributes ) {
        return attributes;
    }
    
    return [self combineAttributes:attributes with:parentAttributes];
}

- (NSDictionary *)combineAttributes:(NSDictionary *)attributes with:(NSDictionary *)otherAttributes
{
    NSMutableDictionary *mergedAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes copyItems:YES];
    for ( id key in otherAttributes ) {
        if ( ![mergedAttributes objectForKey:key] ) {
            [mergedAttributes setObject:[otherAttributes objectForKey:key] forKey:key];
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
            else if ( fontDetails && fontDetails[@"preferredFontForTextStyle"] ) {

                UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                if ( [fontDetails[@"preferredFontForTextStyle"] isEqualToString:@"Headline"] ) {
                    font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
                }
                else if ( [fontDetails[@"preferredFontForTextStyle"] isEqualToString:@"SubheadLine"] ) {
                    font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
                }
                else if ( [fontDetails[@"preferredFontForTextStyle"] isEqualToString:@"Body"] ) {
                    font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                }
                else if ( [fontDetails[@"preferredFontForTextStyle"] isEqualToString:@"Footnote"] ) {
                    font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                }
                else if ( [fontDetails[@"preferredFontForTextStyle"] isEqualToString:@"Caption1"] ) {
                    font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
                }
                else if ( [fontDetails[@"preferredFontForTextStyle"] isEqualToString:@"Caption2"] ) {
                    font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                }
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



