//
//  SBBSurveyManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/13/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "NSDate+SBBAdditions.h"
#import "SBBSurveyManagerInternal.h"
#import "SBBBridgeNetworkManager.h"
#import "SBBBridgeAPIManager.h"

@interface SBBSurveyManagerUnitTests : SBBBridgeAPIUnitTestCase

@property (nonatomic, strong) NSDictionary *sampleSurveyJSON;

@end

@implementation SBBSurveyManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *sampleSurveyJsonString = @"{\n"
    "\"guid\":\"55d9973d-1092-42b0-81e2-bbfb86f483c0\",\n"
    "\"createdOn\":\"2014-10-09T23:30:44.747Z\",\n"
    "\"modifiedOn\":\"2014-10-09T23:30:44.747Z\",\n"
    "\"version\":1,\n"
    "\"name\":\"General Blood Pressure Survey\",\n"
    "\"identifier\":\"bloodpressure\",\n"
    "\"published\":false,\n"
    "\"elements\":[\n"
                 "{\n"
                   "\"guid\":\"not-really-a-guid\",\n"
                   "\"identifier\":\"bp_survey_intro\",\n"
                   "\"image\":{\n"
                     "\"source\":\"http://doctormurray.com/wp-content/uploads/2014/03/highbloodpressure.jpg\",\n"
                     "\"width\":640.5,\n"
                     "\"height\":480.5,\n"
                     "\"type\":\"Image\"\n"
                   "},\n"
                   "\"prompt\":\"Here are some questions about your blood pressure.\",\n"
                   "\"promptDetail\":\"We want to know about your blood pressure.\",\n"
                   "\"title\":\"Blood Pressure Survey\",\n"
                   "\"type\":\"SurveyInfoScreen\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"e872f85a-c157-457b-890f-9e28eeed6efa\",\n"
                   "\"identifier\":\"high_bp\",\n"
                   "\"prompt\":\"Do you have high blood pressure?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                      "\n"
                     "],\n"
                     "\"dataType\":\"boolean\",\n"
                     "\"type\":\"BooleanConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"checkbox\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"c374b293-a060-47c9-bd99-2738837967a8\",\n"
                   "\"identifier\":\"last_checkup\",\n"
                   "\"prompt\":\"When did you last have a medical check-up?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                      "\n"
                     "],\n"
                     "\"dataType\":\"date\",\n"
                     "\"allowFuture\":false,\n"
                     "\"type\":\"DateConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"datepicker\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"854aed00-3d2c-41c2-9b36-17b72287819b\",\n"
                   "\"identifier\":\"last_reading\",\n"
                   "\"prompt\":\"When is your next medical check-up scheduled?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                      "\n"
                     "],\n"
                     "\"dataType\":\"datetime\",\n"
                     "\"allowFuture\":true,\n"
                     "\"type\":\"DateTimeConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"datetimepicker\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"e27a4728-32e7-4066-985a-bee71e2580c3\",\n"
                   "\"identifier\":\"deleuterium_dosage\",\n"
                   "\"prompt\":\"What dosage (in grams) do you take of deleuterium each day?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                      "\n"
                     "],\n"
                     "\"dataType\":\"decimal\",\n"
                     "\"minValue\":0.0,\n"
                     "\"maxValue\":10.0,\n"
                     "\"step\":0.1,\n"
                     "\"type\":\"DecimalConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"slider\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"21987fd2-4846-48a4-aa80-27c3371186c0\",\n"
                   "\"identifier\":\"bp_x_day\",\n"
                   "\"prompt\":\"How many times a day do you take your blood pressure?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                              "{\n"
                                "\"operator\":\"le\",\n"
                                "\"value\":2,\n"
                                "\"goto\":\"name\",\n"
                                "\"type\":\"SurveyRule\"\n"
                              "},\n"
                              "{\n"
                                "\"operator\":\"de\",\n"
                                "\"goto\":\"name\",\n"
                                "\"type\":\"SurveyRule\"\n"
                              "}\n"
                              "],\n"
                     "\"dataType\":\"integer\",\n"
                     "\"minValue\":0,\n"
                     "\"maxValue\":4,\n"
                     "\"step\":null,\n"
                     "\"type\":\"IntegerConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"numberfield\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"db8d54db-c00e-4203-af71-2701253aa9e9\",\n"
                   "\"identifier\":\"time_for_appt\",\n"
                   "\"prompt\":\"How log does your appointment take, on average?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                      "\n"
                     "],\n"
                     "\"dataType\":\"duration\",\n"
                     "\"type\":\"DurationConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"timepicker\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"f841bb48-3d22-4049-ae1f-921c38cd4ebb\",\n"
                   "\"identifier\":\"deleuterium_x_day\",\n"
                   "\"prompt\":\"What times of the day do you take deleuterium?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                      "\n"
                     "],\n"
                     "\"dataType\":\"time\",\n"
                     "\"type\":\"TimeConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"timepicker\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"
                   "\"guid\":\"1992b80e-912c-4b05-b29b-5c35f02688b4\",\n"
                   "\"identifier\":\"feeling\",\n"
                   "\"prompt\":\"How do you feel today?\",\n"
                   "\"constraints\":{\n"
                     "\"rules\":[\n"
                        "\n"
                     "],\n"
                     "\"dataType\":\"integer\",\n"
                     "\"enumeration\":[\n"
                                    "{\n"
                                      "\"label\":\"Terrible\",\n"
                                      "\"value\":1,\n"
                                      "\"type\":\"SurveyQuestionOption\"\n"
                                    "},\n"
                                    "{\n"   
                                      "\"label\":\"Poor\",\n"
                                      "\"value\":2,\n"
                                      "\"type\":\"SurveyQuestionOption\"\n"
                                    "},\n"
                                    "{\n"   
                                      "\"label\":\"OK\",\n"
                                      "\"value\":3,\n"
                                      "\"type\":\"SurveyQuestionOption\"\n"
                                    "},\n"
                                    "{\n"   
                                      "\"label\":\"Good\",\n"
                                      "\"value\":4,\n"
                                      "\"type\":\"SurveyQuestionOption\"\n"
                                    "},\n"
                                    "{\n"   
                                      "\"label\":\"Great\",\n"
                                      "\"value\":5,\n"
                                      "\"type\":\"SurveyQuestionOption\"\n"
                                    "}\n"
                                    "],\n"
                     "\"allowOther\":false,\n"
                     "\"allowMultiple\":true,\n"
                     "\"type\":\"MultiValueConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"list\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "},\n"
                 "{\n"   
                   "\"guid\":\"12fee175-6213-4c0b-89b5-5cac34f7783f\",\n"
                   "\"identifier\":\"name\",\n"
                   "\"prompt\":\"Please enter an emergency phone number (###-###-####)?\",\n"
                   "\"constraints\":{\n"   
                     "\"rules\":[\n"   
                      "\n"
                     "],\n"
                     "\"dataType\":\"string\",\n"
                     "\"minLength\":2,\n"
                     "\"maxLength\":255,\n"
                     "\"pattern\":\"\\\\d{3}-\\\\d{3}-\\\\{d}4\",\n"
                     "\"type\":\"StringConstraints\"\n"
                   "},\n"
                   "\"uiHint\":\"textfield\",\n"
                   "\"type\":\"SurveyQuestion\"\n"
                 "}\n"
                 "],\n"
    "\"type\":\"Survey\"\n"
    "}";
    NSData *jsonData = [sampleSurveyJsonString dataUsingEncoding:NSUTF8StringEncoding];
    _sampleSurveyJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _sampleSurveyJSON = nil;
}

- (void)testGetSurveyByRef {
    NSString *ref = @"/v3/surveys/55d9973d-1092-42b0-81e2-bbfb86f483c0/revisions/2014-10-09T23:30:44.747Z";
    SBBSurveyManager *sMan = [SBBSurveyManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];
    
    // first check for it in cache only--it shouldn't be there yet
    XCTestExpectation *expectNoCachedSurveyYet = [self expectationWithDescription:@"survey not yet in cache"];
    [sMan getSurveyByRef:ref cachingPolicy:SBBCachingPolicyCachedOnly completion:^(id survey, NSError *error) {
        XCTAssert(survey == nil, @"Survey not found in cache");
        XCTAssert(error == nil, @"There was no error, i.e. it didn't try (and fail) to fetch from mock Bridge server");
        [expectNoCachedSurveyYet fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get survey from cache by ref:\n%@", error);
        }
    }];
    
    // now check for it in cache first, and fall back to server if not found (we already know it's not in cache; we want to test that this works in that case)
    [self.mockURLSession setJson:_sampleSurveyJSON andResponseCode:200 forEndpoint:ref andMethod:@"GET"];
    XCTestExpectation *expectGotSurvey = [self expectationWithDescription:@"got survey by ref"];
    [sMan getSurveyByRef:ref completion:^(id survey, NSError *error) {
        XCTAssert([survey isKindOfClass:[SBBSurvey class]], @"Converted incoming json to SBBSurvey");
        SBBSurveyInfoScreen *info0 = ((SBBSurvey *)survey).elements[0];
        XCTAssert([info0 isKindOfClass:[SBBSurveyInfoScreen class]], @"Survey Info Screen converted to SBBSurveyInfoScreen");
        XCTAssert([info0.image isKindOfClass:[SBBImage class]], @"Image converted to SBBImage");
        SBBSurveyQuestion *question0 = ((SBBSurvey *)survey).elements[1];
        XCTAssert([question0 isKindOfClass:[SBBSurveyQuestion class]], @"Questions converted to SBBSurveyQuestion");
        XCTAssert([question0.constraints isKindOfClass:[SBBSurveyConstraints class]], @"Constraints converted to SBBSurveyConstraints");
        [expectGotSurvey fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get survey by ref:\n%@", error);
        }
    }];
    
    // now do that again, making sure this time it comes from the cache and doesn't try to hit the server
    // we do this by setting up a mock survey JSON response with the same ref but a different type for the first element;
    // if we get this modified version of the survey back, we'll know it hit the server
    NSMutableDictionary *differentSurveyJSONWithSameRef = [_sampleSurveyJSON mutableCopy];
    NSArray *elements = _sampleSurveyJSON[@"elements"];
    differentSurveyJSONWithSameRef[@"elements"] = [elements subarrayWithRange:NSMakeRange(1, elements.count - 1)];
    [self.mockURLSession setJson:differentSurveyJSONWithSameRef andResponseCode:200 forEndpoint:ref andMethod:@"GET"];
    XCTestExpectation *expectGotSurveyFromCache = [self expectationWithDescription:@"got survey by ref from cache"];
    [sMan getSurveyByRef:ref completion:^(id survey, NSError *error) {
        XCTAssert([survey isKindOfClass:[SBBSurvey class]], @"Retrieved an SBBSurvey");
        SBBSurveyInfoScreen *info0 = ((SBBSurvey *)survey).elements[0];
        XCTAssert([info0 isKindOfClass:[SBBSurveyInfoScreen class]], @"First element is still SurveyInfoScreen, so it's from cache, not server");
        [expectGotSurveyFromCache fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get survey by ref from cache:\n%@", error);
        }
    }];
    
}

- (void)testGetSurveyByGuidCreatedOn {
    NSString *guid = @"55d9973d-1092-42b0-81e2-bbfb86f483c0";
    NSString *createdOnISO8601 = @"2014-10-09T23:30:44.747Z";
    NSDate *createdOn = [NSDate dateWithISO8601String:createdOnISO8601];
    NSString *endpoint = [NSString stringWithFormat:kSBBSurveyAPIFormat, guid, createdOnISO8601];
    SBBSurveyManager *sMan = [SBBSurveyManager managerWithAuthManager:SBBComponent(SBBAuthManager) networkManager:SBBComponent(SBBBridgeNetworkManager) objectManager:self.objectManager];

    // first check for it in cache only--it shouldn't be there yet
    XCTestExpectation *expectNoCachedSurveyYet = [self expectationWithDescription:@"survey not yet in cache"];
    [sMan getSurveyByGuid:guid createdOn:createdOn cachingPolicy:SBBCachingPolicyCachedOnly completion:^(id survey, NSError *error) {
        XCTAssert(survey == nil, @"Survey not found in cache");
        XCTAssert(error == nil, @"There was no error, i.e. it didn't try (and fail) to fetch from mock Bridge server");
        [expectNoCachedSurveyYet fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get survey from cache by guid/createdOn:\n%@", error);
        }
    }];
    
    // now check for it in cache first, and fall back to server if not found (we already know it's not in cache; we want to test that this works in that case)
    [self.mockURLSession setJson:_sampleSurveyJSON andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    XCTestExpectation *expectGotSurvey = [self expectationWithDescription:@"got survey by guid/createdOn"];
    [sMan getSurveyByGuid:guid createdOn:createdOn completion:^(id survey, NSError *error) {
        XCTAssert([survey isKindOfClass:[SBBSurvey class]], @"Converted incoming json to SBBSurvey");
        SBBSurveyInfoScreen *info0 = ((SBBSurvey *)survey).elements[0];
        XCTAssert([info0 isKindOfClass:[SBBSurveyInfoScreen class]], @"Survey Info Screen converted to SBBSurveyInfoScreen");
        XCTAssert([info0.image isKindOfClass:[SBBImage class]], @"Image converted to SBBImage");
        SBBSurveyQuestion *question0 = ((SBBSurvey *)survey).elements[1];
        XCTAssert([question0 isKindOfClass:[SBBSurveyQuestion class]], @"Questions converted to SBBSurveyQuestion");
        XCTAssert([question0.constraints isKindOfClass:[SBBSurveyConstraints class]], @"Constraints converted to SBBSurveyConstraints");
        [expectGotSurvey fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get survey by guid/createdOn:\n%@", error);
        }
    }];

    // now do that again, making sure this time it comes from the cache and doesn't try to hit the server
    // we do this by setting up a mock survey JSON response with the same ref but a different type for the first element;
    // if we get this modified version of the survey back, we'll know it hit the server
    NSMutableDictionary *differentSurveyJSONWithSameRef = [_sampleSurveyJSON mutableCopy];
    NSArray *elements = _sampleSurveyJSON[@"elements"];
    differentSurveyJSONWithSameRef[@"elements"] = [elements subarrayWithRange:NSMakeRange(1, elements.count - 1)];
    [self.mockURLSession setJson:differentSurveyJSONWithSameRef andResponseCode:200 forEndpoint:endpoint andMethod:@"GET"];
    XCTestExpectation *expectGotSurveyFromCache = [self expectationWithDescription:@"got survey by guid/createdOn from cache"];
    [sMan getSurveyByGuid:guid createdOn:createdOn completion:^(id survey, NSError *error) {
        XCTAssert([survey isKindOfClass:[SBBSurvey class]], @"Retrieved an SBBSurvey");
        SBBSurveyInfoScreen *info0 = ((SBBSurvey *)survey).elements[0];
        XCTAssert([info0 isKindOfClass:[SBBSurveyInfoScreen class]], @"First element is still SurveyInfoScreen, so it's from cache, not server");
        [expectGotSurveyFromCache fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Time out error trying to get survey by guid/createdOn from cache:\n%@", error);
        }
    }];
}

@end
