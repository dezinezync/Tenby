//
//  Tenby.h
//  Tenby
//
//  Created by Nikhil Nigade on 5/27/15.
//  Copyright (c) 2015 Dezine Zync Studios LLP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Maps)

- (NSArray *)dz_map:(id(^)(id obj, NSUInteger idx, NSArray *array))processor;

@end

@interface NSArray (Dosa)

- (NSDictionary *)dz_flattenToDictionaryWithParentKey:(NSString *)parentKey;

@end

@interface NSDictionary (Dosa)

- (NSDictionary *)dz_flatten;
- (NSDictionary *)dz_flattenWithParent:(NSDictionary *)parent parentKey:(NSString *)parentKey;

@end

/**
 *  Tenby is a JSON to CSV convertor and back. It boasts a very simple and straightforward API allowing you to deal directly with objects or files.
 *  @abstract All methods returning an NSURL* are paths to files inside the app's temporary directory. These files may be deleted by the OS at any time. It's your app's job to move these files to a favorable location.
 */
@interface Tenby : NSObject

/**
 *  Generate a CSV file from a JSON object. Includes the .csv path extension.
 *  @abstract This method uses the standard "," delimiter and the "\n" end of line character.
 *
 *  @param aObj A JSON object. Will be sanitized before processing.
 *
 *  @return NSURL* if all processing and writing succeded. Returns nil if either the CSV generation or file writing fails.
 */
+ (NSURL *)CSVFromJSON:(id)aObj;

/**
 *  Generate a JSON object plist file from the given CSV.
 *  @abstract This method uses the standard "," delimiter and the "\n" end of line character.
 *
 *  @param csv A CSV string.
 *
 *  @return NSURL* if all processing and writing succeded. Returns nil if either the JSON generation or file writing fails.
 */
+ (NSURL *)JSONFromCSV:(NSString *)csv;

/**
 *  Generate a CSV String from a given JSON Object.
 *  @abstract This method uses the standard "," delimiter and the "\n" end of line character.
 *
 *  @param aObj a JSON object, santized before processing.
 *
 *  @return NSString* if processing succeeds, nil if it doesn't.
 */
+ (NSString *)CSVStringFromJSON:(id)aObj;

/**
 *  Generate a JSON Object from a given CSV String
 *  @abstract This method uses the standard "," delimiter and the "\n" end of line character.
 *
 *  @param csv CSV string
 *
 *  @return NSarray* if processing succeeds, nil if it doesn't.
 */
+ (NSArray *)JSONFromCSVString:(NSString *)csv;


/**
 *  Generate a JSON object from a CSV file
 *
 *  @param file local file path
 *
 *  @return NSarry* the parsed JSON object.
 */
+ (NSArray *)JSONFromCSVFile:(NSURL *)file;

@end
