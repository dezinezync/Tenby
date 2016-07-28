//
//  Tenby.m
//  Tenby
//
//  Created by Nikhil Nigade on 5/27/15.
//  Copyright (c) 2015 Dezine Zync Studios LLP. All rights reserved.
//

#import "TenbyiOS.h"

@implementation NSArray (Maps)

- (NSArray *)dz_map:(id (^)(id, NSUInteger, NSArray *))processor
{
    
    NSParameterAssert(processor);
    
    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        
        id result = processor(obj, idx, self);
        
        if (result)
        {
            [mapped addObject:result];
        }
        
    }];
    
    return [mapped copy];
    
}

@end

@implementation NSArray (Dosa)

- (NSDictionary *)dz_flattenToDictionaryWithParentKey:(NSString *)parentKey
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *composedKey = [NSString stringWithFormat:@"%@_%@", parentKey?:@"", @(idx)];
        
        if([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *aDict = [(NSDictionary *)obj dz_flattenWithParent:nil parentKey:[composedKey stringByAppendingString:@"_"]];
            
            [dict addEntriesFromDictionary:aDict];
        }
        else if([obj isKindOfClass:[NSArray class]])
        {
            
            NSDictionary *aDict = [obj dz_flattenToDictionaryWithParentKey:composedKey];
            
            [dict addEntriesFromDictionary:aDict];
            
        }
        else
        {
            [dict setObject:obj forKey:composedKey];
        }
        
    }];
    
    return [dict copy];
    
}

@end

@implementation NSDictionary (Dosa)

- (NSDictionary *)dz_flatten
{
    return [self dz_flattenWithParent:nil parentKey:nil];
}

- (NSDictionary *)dz_flattenWithParent:(NSDictionary *)parent parentKey:(NSString *)parentKey
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *aDict = [(NSDictionary *)obj dz_flattenWithParent:self parentKey:key];
            [dict addEntriesFromDictionary:aDict];
        }
        else if([obj isKindOfClass:[NSArray class]])
        {
            
            NSDictionary *aDict = [(NSArray *)obj dz_flattenToDictionaryWithParentKey:key];
            [dict addEntriesFromDictionary:aDict];
            
        }
        else
        {
            
            NSString *composedKey;
            
            if(parentKey)
            {
                composedKey = [NSString stringWithFormat:@"%@%@", parentKey, [key capitalizedString]];
            }
            else
            {
                composedKey = key;
            }
            
            [dict setValue:obj forKey:composedKey];
            
        }
        
    }];
    
    return [dict copy];
    
}

@end

@implementation Tenby

+ (NSArray *)JSONFromCSVString:(NSString *)csv
{
    return [[self class] JSONFromCSVString:csv delimiter:@"," endOfLine:@"\n"];
}

+ (NSArray *)JSONFromCSVString:(NSString *)csv delimiter:(NSString *)delimiter
{
    return [[self class] JSONFromCSVString:csv delimiter:delimiter endOfLine:@"\n"];
}

+ (NSArray *)JSONFromCSVString:(NSString *)csv delimiter:(NSString *)delimiter endOfLine:(NSString *)eol
{
    
    if(!csv) return nil;
    
    if(!delimiter) delimiter = @",";
    if(!eol) eol = @"\n";
    
    NSString *customDelimiter = @"^";
    NSString *customEOL = @"#";
    
    NSString *expression = [NSString stringWithFormat:@"%@(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))", delimiter];
    
    NSRegularExpression *regEx= [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [regEx matchesInString:csv options:kNilOptions range:NSMakeRange(0, csv.length)];
    
    for(NSTextCheckingResult *result in matches)
    {
        
        csv = [csv stringByReplacingCharactersInRange:result.range withString:customDelimiter];
        
    }
    
    if([eol isEqualToString:@"\n"])
    {
        expression = [NSString stringWithFormat:@"\"[^\"]+\"|(%@)", @"\\n"];
    }
    else
    {
        expression = [NSString stringWithFormat:@"\"[^\"]+\"|(%@)", [@"\\" stringByAppendingString:eol]];
    }
    
    regEx = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    
    matches = [regEx matchesInString:csv options:kNilOptions range:NSMakeRange(0, csv.length)];
    
    for(NSTextCheckingResult *result in matches)
    {
        NSRange range = [result rangeAtIndex:1];
        if(range.location != NSNotFound)
        {
            csv = [csv stringByReplacingCharactersInRange:range withString:customEOL];
        }
    }
    
    NSArray *allRows = [csv componentsSeparatedByString:customEOL];
    
    if(![allRows count]) return nil;
    
    NSOrderedSet *fieldItems = [NSOrderedSet orderedSetWithArray:[[allRows firstObject] componentsSeparatedByString:customDelimiter]];
    
    NSMutableArray *allRowsCopy = [allRows mutableCopy];
    [allRowsCopy removeObjectAtIndex:0];
    allRows = [allRowsCopy copy];
    
    NSArray *rows = [allRows dz_map:^id(NSString *obj, NSUInteger idx, NSArray *array) {
       
        NSArray *items = [obj componentsSeparatedByString:customDelimiter];
        
        items = [items dz_map:^id(NSString *obj, NSUInteger idx, NSArray *array) {
            
            return [obj stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
        }];
        
        NSDictionary *newObj = [NSDictionary dictionaryWithObjects:items forKeys:fieldItems.array];
        
        return newObj;
        
    }];
    
    return rows;
    
}

+ (NSString *)CSVStringFromJSON:(id)aObj
{
    
    return [[self class] CSVStringFromJSON:aObj delimiter:@"," endOfLine:@"\n"];
    
}

+ (NSString *)CSVStringFromJSON:(id)aObj delimiter:(NSString *)delimiter
{
 
    return [[self class] CSVStringFromJSON:aObj delimiter:delimiter endOfLine:@"\n"];
    
}

+ (NSString *)CSVStringFromJSON:(id)aObj delimiter:(NSString *)delimiter endOfLine:(NSString *)eol
{
    
    if(!aObj) return nil;
    if(!delimiter) delimiter = @",";
    if(!eol) eol = @"\n";
    
    NSString *CSV = @"";
    NSArray *fields;
    
    if([aObj isKindOfClass:[NSDictionary class]])
    {
        
        fields = [(NSDictionary *)aObj allKeys];
        
        NSArray *values = [(NSDictionary *)aObj allValues];
        
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
            if([obj isKindOfClass:[NSString class]] && [(NSString *)obj containsString:@","])
            {
                obj = [(NSString *)obj stringByReplacingOccurrencesOfString:@"," withString:@", "];
            }
            
        }];
        
        CSV = [NSString stringWithFormat:@"%@%@%@", [fields componentsJoinedByString:delimiter], eol, [values componentsJoinedByString:delimiter]]; //last line does not get EOL char.
        
    }
    else if([aObj isKindOfClass:[NSArray class]])
    {
        
        aObj = [(NSArray *)aObj dz_map:^id(NSDictionary *obj, NSUInteger idx, NSArray *array) {
           
            return [obj dz_flatten];
            
        }];
        
        NSArray *columns = [[self class] columnTitlesForArray:aObj];
        // sort the column names alphabetically.
        columns = [columns sortedArrayUsingSelector:@selector(localizedCompare:)];
        
        NSArray *rows = [[self class] rowsForColumns:columns fromArray:aObj];
        
        NSArray *serializedRows = [rows dz_map:^id(NSArray *obj, NSUInteger idx, NSArray *array) {
           
            return [obj componentsJoinedByString:delimiter];
            
        }];
        
        CSV = [NSString stringWithFormat:@"%@%@%@", [columns componentsJoinedByString:delimiter], eol, [serializedRows componentsJoinedByString:eol]];
        
    }
    
    return CSV;
    
}

#pragma mark - File Methods

+ (NSURL *)JSONFromCSV:(NSString *)csv
{
    return [[self class] JSONFromCSV:csv delimiter:@"," endOfLine:@"\n"];
}

+ (NSURL *)JSONFromCSV:(NSString *)csv delimiter:(NSString *)delimiter
{
    return [[self class] JSONFromCSV:csv delimiter:delimiter endOfLine:@"\n"];
}

+ (NSURL *)JSONFromCSV:(NSString *)csv delimiter:(NSString *)delimiter endOfLine:(NSString *)eol
{
    
    NSArray *JSON = [[self class] JSONFromCSVString:csv delimiter:delimiter endOfLine:eol];
    
    if(!JSON) return nil;
    
    return [[self class] write:JSON isCSV:NO];
    
}

+ (NSURL *)CSVFromJSON:(id)aObj
{
    return [[self class] CSVFromJSON:aObj delimiter:@"," endOfLine:@"\n"];
}

+ (NSURL *)CSVFromJSON:(id)aObj delimiter:(NSString *)delimiter
{
    return [[self class] CSVFromJSON:aObj delimiter:delimiter endOfLine:@"\n"];
}

+ (NSURL *)CSVFromJSON:(id)aObj delimiter:(NSString *)delimiter endOfLine:(NSString *)eol
{
    
    NSString *CSV = [[self class] CSVStringFromJSON:aObj delimiter:delimiter endOfLine:eol];
    
    if(!CSV) return nil;
    
    return [[self class] write:CSV isCSV:YES];
    
}

+ (NSArray *)JSONFromCSVFile:(NSURL *)file
{
    
    if(!file || ![[file path] length])
    {
        return nil;
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[file path]])
    {
        return nil;
    }
    
    NSError *error = nil;
    NSString *CSV = [NSString stringWithContentsOfFile:[file path] encoding:NSUTF8StringEncoding error:&error];
    
    if(error || !CSV || ![CSV length])
    {
        if(error) NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    NSArray *JSON = [[self class] JSONFromCSVString:CSV delimiter:nil endOfLine:nil];
    
    return JSON;
    
}

#pragma mark - Helpers

+ (NSURL *)write:(id)obj isCSV:(BOOL)isCSV
{
 
    NSString *UUID = [[NSUUID UUID] UUIDString];
    
    NSString *temporaryDirectory = NSTemporaryDirectory();
    
    NSString *path = [temporaryDirectory stringByAppendingPathComponent:UUID];
    
    if(isCSV)
    {
        path = [path stringByAppendingPathExtension:@"csv"];
    }
    
    NSURL *URL = [NSURL URLWithString:path];
    
    NSError *error = nil;
    
    if(isCSV)
    {
        
        if([obj writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
        {
            return URL;
        }
        else
        {
            NSLog(@"Error while writing to Path:%@ :: %@", path, error.localizedDescription);
            return nil;
        }
        
    }
    else
    {
        
        if([(NSArray *)obj writeToFile:path atomically:YES])
        {
            return URL;
        }
        else
        {
            return nil;
        }
        
    }
    
}

+ (NSArray *)columnTitlesForArray:(NSArray *)arr
{
    
    NSMutableOrderedSet *fields = [NSMutableOrderedSet orderedSet];
    
    for(NSDictionary *obj in arr)
    {
        
        if(![obj isKindOfClass:[NSDictionary class]]) continue; //only accept a Dictionary.
        
        NSArray *keys = [obj allKeys];
        
        // create an ordered copy of the keys.
        NSMutableOrderedSet *newFields = [NSMutableOrderedSet orderedSetWithArray:keys];
        
        if(!fields.array || ![fields.array count])
        {
            // we don't have any keys for comparison, so simply use the current set we have.
            fields = [newFields mutableCopy];
            
        }
        else
        {
            // we have a pre-existing set. We'll take a union of the two.
            [fields unionSet:newFields.set];
            
        }
        
    }
    
    return [fields array];
    
}

+ (NSArray *)rowsForColumns:(NSArray *)columns fromArray:(NSArray *)arr
{
    
    if(!columns || ![columns count]) return nil;
    if(!arr || ![arr count]) return nil;
    
    NSMutableOrderedSet *rows = [NSMutableOrderedSet orderedSetWithCapacity:[arr count]];
    
    NSString *extraneousCharacters = @",\\/\\,";
    
    NSMutableCharacterSet *set = [NSMutableCharacterSet newlineCharacterSet];
    [set formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    [set formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:extraneousCharacters]];
    
    // loop over all items and create a formatted row
    for(NSDictionary *obj in arr)
    {
        
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:[columns count]];
        
        // Loop over all column titles and fetch the individual values.
        for(NSString *key in columns)
        {
            
            NSString *val = [obj valueForKey:key]?:@"";
            
            if([val isKindOfClass:[NSDate class]])
            {
                val = [NSDateFormatter localizedStringFromDate:(NSDate *)val dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle];
            }
            if([val isKindOfClass:[NSNumber class]])
            {
                val = [(NSNumber *)val stringValue];
            }
            
            if([val rangeOfCharacterFromSet:set].location != NSNotFound)
            {
                val = [NSString stringWithFormat:@"\"%@\"",val];
            }
            
            [row addObject:val];
            
        }
        
        [rows addObject:[row copy]];
        
    }
    
    return [rows array];
    
}

@end
