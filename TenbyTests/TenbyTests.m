//
//  TenbyTests.m
//  TenbyTests
//
//  Created by Nikhil Nigade on 5/27/15.
//  Copyright (c) 2015 Dezine Zync Studios LLP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Tenby.h"

@interface TenbyTests : XCTestCase {
    
    NSArray *_jsonArray;
    NSDictionary *_jsonObject;
    NSString *_csv;
    NSString *_csvSingle;
    
}

@end

@implementation TenbyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _jsonArray = @[@{@"car":@"Audi",@"price":@40000,@"color":@"blue"},
                   @{@"car":@"BMW",@"price":@[@{@"showroom": @41000, @"onroad" : @43250}, @{@"showroom": @35000, @"onroad" : @42000}],@"color":@"black"},
                   @{@"car":@"Porsche",@"price": @{@"showroom": @41000, @"onroad" : @43250},@"color":@"green"}];
    
    _jsonObject = @{@"car":@"Porsche",@"price":@60000,@"color":@"green"};
    
    _csv = @"car,price,color\nAudi,40000,blue\nBMW,35000,black\nPorsche,,green";
    _csvSingle = @"car,price,color\nAudi,40000,blue";
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJSONToCSV
{
    
    NSString *objCSV = [Tenby CSVStringFromJSON:_jsonObject];
    NSString *arrCSV = [Tenby CSVStringFromJSON:_jsonArray];
    
    NSString *expectedObjOutput = @"car,price,color\nPorsche,60000,green";
    NSString *expectedArrOutput = @"car,color,price,price_0_Onroad,price_0_Showroom,price_1_Onroad,price_1_Showroom,priceOnroad,priceShowroom\nAudi,blue,40000,,,,,,\nBMW,black,,43250,41000,42000,35000,,\nPorsche,green,,,,,,43250,41000";
    
    XCTAssert([objCSV isEqualToString:expectedObjOutput]);
    XCTAssert([arrCSV isEqualToString:expectedArrOutput]);
    
}

- (void)testJSONToCSVWithDelimiter
{
    
    NSString *objCSV = [Tenby CSVStringFromJSON:_jsonObject delimiter:@"\t"];
    NSString *arrCSV = [Tenby CSVStringFromJSON:_jsonArray delimiter:@"\t"];
    
    NSString *expectedObjOutput = @"car\tprice\tcolor\nPorsche\t60000\tgreen";
    NSString *expectedArrOutput = @"car\tcolor\tprice\tprice_0_Onroad\tprice_0_Showroom\tprice_1_Onroad\tprice_1_Showroom\tpriceOnroad\tpriceShowroom\nAudi\tblue\t40000\t\t\t\t\t\t\nBMW\tblack\t\t43250\t41000\t42000\t35000\t\t\nPorsche\tgreen\t\t\t\t\t\t43250\t41000";
    
    XCTAssert([objCSV isEqualToString:expectedObjOutput]);
    XCTAssert([arrCSV isEqualToString:expectedArrOutput]);
    
}

- (void)testJSONToCSVWithDelimiterAndEOL
{
    
    NSString *objCSV = [Tenby CSVStringFromJSON:_jsonObject delimiter:@"\t" endOfLine:@"\n\n"];
    NSString *arrCSV = [Tenby CSVStringFromJSON:_jsonArray delimiter:@"\t" endOfLine:@"\n\n"];
    
    NSString *expectedObjOutput = @"car\tprice\tcolor\n\nPorsche\t60000\tgreen";
    NSString *expectedArrOutput = @"car\tcolor\tprice\tprice_0_Onroad\tprice_0_Showroom\tprice_1_Onroad\tprice_1_Showroom\tpriceOnroad\tpriceShowroom\n\nAudi\tblue\t40000\t\t\t\t\t\t\n\nBMW\tblack\t\t43250\t41000\t42000\t35000\t\t\n\nPorsche\tgreen\t\t\t\t\t\t43250\t41000";
    
    XCTAssert([objCSV isEqualToString:expectedObjOutput]);
    XCTAssert([arrCSV isEqualToString:expectedArrOutput]);
    
}

- (void)testCSVToJSON
{
    
    NSArray *JSON = [Tenby JSONFromCSVString:_csv];
    NSArray *JSONSingle = [Tenby JSONFromCSVString:_csvSingle];
    
    XCTAssert([JSON count] == 3);
    XCTAssert([JSONSingle count] == 1);
    
}

- (void)testCSVToJSONWithDelimiter
{
    
    _csv = [_csv stringByReplacingOccurrencesOfString:@"," withString:@"\\s"];
    _csvSingle = [_csvSingle stringByReplacingOccurrencesOfString:@"," withString:@"\\s"];
    
    NSArray *JSON = [Tenby JSONFromCSVString:_csv delimiter:@"\\s"];
    NSArray *JSONSingle = [Tenby JSONFromCSVString:_csvSingle delimiter:@"\\s"];
    
    XCTAssert([JSON count] == 3);
    XCTAssert([JSONSingle count] == 1);
    
}

- (void)testCSVToJSONWithDelimiterAndEOL
{
    
    _csv = [_csv stringByReplacingOccurrencesOfString:@"," withString:@"\\s"];
    _csv = [_csv stringByReplacingOccurrencesOfString:@"\n" withString:@"\t"];
    _csvSingle = [_csvSingle stringByReplacingOccurrencesOfString:@"," withString:@"\\s"];
    _csvSingle = [_csvSingle stringByReplacingOccurrencesOfString:@"\n" withString:@"\t"];
    
    NSArray *JSON = [Tenby JSONFromCSVString:_csv delimiter:@"\\s" endOfLine:@"\t"];
    NSArray *JSONSingle = [Tenby JSONFromCSVString:_csvSingle delimiter:@"\\s" endOfLine:@"\t"];
    
    XCTAssert([JSON count] == 3);
    XCTAssert([JSONSingle count] == 1);
    
}

- (void)testWritingForJSON
{
    
    NSURL *normal = [Tenby CSVFromJSON:_jsonArray];
    NSURL *normalDelimited = [Tenby CSVFromJSON:_jsonArray delimiter:@"\t"];
    NSURL *normalDelimitedAndEOL = [Tenby CSVFromJSON:_jsonArray delimiter:@"\t" endOfLine:@"\n\n"];
    
    XCTAssert(normal && normalDelimited && normalDelimitedAndEOL);
    
}

- (void)testWritingForCSV
{
    
    NSURL *normal = [Tenby JSONFromCSV:_csv];
    NSURL *normalDelimited = [Tenby JSONFromCSV:_csv delimiter:@"\t"];
    NSURL *normalDelimitedAndEOL = [Tenby JSONFromCSV:_csv delimiter:@"\t" endOfLine:@"\n\n"];
    
    XCTAssert(normal && normalDelimited && normalDelimitedAndEOL);
    
}

- (void)testPerformanceCSVToJSON
{
    
    [self measureBlock:^{
       
        __unused NSString *arrCSV = [Tenby CSVStringFromJSON:_jsonArray delimiter:@"\t" endOfLine:@"\n\n"];
        
    }];
    
}

- (void)testPerformanceJSONToCSV
{
 
    [self measureBlock:^{
       
        __unused NSArray *JSON = [Tenby JSONFromCSVString:_csv];
        
    }];
    
}

@end
