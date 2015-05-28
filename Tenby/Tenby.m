//
//  Tenby.m
//  Tenby
//
//  Created by Nikhil Nigade on 5/27/15.
//  Copyright (c) 2015 Dezine Zync Studios LLP. All rights reserved.
//

#import "Tenby.h"

@interface NSArray (Maps)

- (NSArray *)dz_map:(id(^)(id obj, NSUInteger idx, NSArray *array))processor;

@end

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
    
    NSArray *allRows = [csv componentsSeparatedByString:eol];
    
    if(![allRows count]) return nil;
    
    NSOrderedSet *fieldItems = [NSOrderedSet orderedSetWithArray:[[allRows firstObject] componentsSeparatedByString:delimiter]];
    
    NSMutableArray *allRowsCopy = [allRows mutableCopy];
    [allRowsCopy removeObjectAtIndex:0];
    allRows = [allRowsCopy copy];
    
    NSArray *rows = [allRows dz_map:^id(NSString *obj, NSUInteger idx, NSArray *array) {
       
        NSArray *items = [obj componentsSeparatedByString:delimiter];
        
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
    
    //Cleanse the incoming json object
    aObj = [NSJSONSerialization JSONObjectWithData:[NSJSONSerialization dataWithJSONObject:aObj options:kNilOptions error:nil] options:kNilOptions error:nil];
    
    NSString *CSV = @"";
    NSArray *fields;
    
    if([aObj isKindOfClass:[NSDictionary class]])
    {
        
        fields = [(NSDictionary *)aObj allKeys];
        
        NSArray *values = [(NSDictionary *)aObj allValues];
        
        CSV = [NSString stringWithFormat:@"%@%@%@", [fields componentsJoinedByString:delimiter], eol, [values componentsJoinedByString:delimiter]]; //last line does not get EOL char.
        
    }
    else if([aObj isKindOfClass:[NSArray class]])
    {
        
        NSArray *columns = [[self class] columnTitlesForArray:aObj];
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
    
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:[arr count]];
    
    // loop over all items and create a formatted row
    for(NSDictionary *obj in arr)
    {
        
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:[columns count]];
        
        // Loop over all column titles and fetch the individual values.
        for(NSString *key in columns)
        {
            // sometimes, a particular object may not have a key. We need to subtitute with a blank value.
            [row addObject:[obj valueForKey:key]?:@""];
            
        }
        
        [rows addObject:[row copy]];
        
    }
    
    return [rows copy];
    
}

@end