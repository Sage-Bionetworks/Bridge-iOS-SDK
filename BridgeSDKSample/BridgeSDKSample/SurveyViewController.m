//
//  SurveyViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 10/14/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SurveyViewController.h"
@import BridgeSDK;

@interface SurveyViewController ()

@property (nonatomic, strong) SBBSurvey *fetchedSurvey;
@property (nonatomic, strong) NSString *responseGuid;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *versionedOnTextField;
@property (weak, nonatomic) IBOutlet UITextField *guidTextField;
@property (weak, nonatomic) IBOutlet UITextField *numQuestionsTextField;

- (IBAction)didTouchLoadSampleButton:(id)sender;
- (IBAction)didTouchSendSampleAnswersButton:(id)sender;

- (IBAction)didTouchFetchResultsButton:(id)sender;
- (IBAction)didTouchAddSampleAnswersButton:(id)sender;
- (IBAction)didTouchDeleteResultsButton:(id)sender;

@end

@implementation SurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)surveyRef
{
    NSString *surveyRef = nil;
    switch (SBBComponent(SBBNetworkManager).environment) {
        case SBBEnvironmentDev:
            surveyRef = @"/api/v1/surveys/4aad1810-cef9-41bc-b0d9-73bcdf32df07/2014-10-16T21:36:44.386Z";
            break;
            
        case SBBEnvironmentStaging:
//          surveyRef = @"/api/v1/surveys/ecf7e761-c7e9-4bb6-b6e7-d6d15c53b209/2014-09-25T20:07:49.186Z";
            surveyRef = @"/api/v1/surveys/c132f353-9c31-4046-af31-df7e9ff02dba/2014-10-31T22:54:40.415Z";
            break;
            
        default:
            break;
    }
  
  return surveyRef;
}

- (NSString *)guidForQuestion:(NSUInteger)index
{
//  NSArray *stagingGuids =
//  @[
//    @"ebcb8ea2-011e-4c12-b97d-08eca1aa3fb8",
//    @"0698db53-efe5-4530-b703-1e6cd589039b",
//    @"c3702ee5-945c-48c4-b826-b8182edf7fa0",
//    @"3a26741d-5880-4030-bf58-74f58ca57b65"
//    ];
//  
//  NSArray *devGuids =
//  @[
//    @"1460946a-7c80-4c7f-a590-89aba92a657c",
//    @"b73be244-49d9-4418-a13c-93a3801cbb65",
//    @"36726387-8320-49af-a8b2-479c14b17919",
//    @"a29f5a03-70bc-4891-817e-ecc8451b9b80"
//    ];
//  
//  NSString *questionGuid = nil;
//  switch (SBBComponent(SBBNetworkManager).environment) {
//    case SBBEnvironmentDev:
//      questionGuid = devGuids[index];
//      break;
//      
//    case SBBEnvironmentStaging:
//      questionGuid = stagingGuids[index];
//      break;
//      
//    default:
//      break;
//  }
//  
//  return questionGuid;
  return ((SBBSurveyQuestion *)_fetchedSurvey.questions[index]).guid;
}

- (IBAction)didTouchLoadSampleButton:(id)sender {
  [SBBComponent(SBBSurveyManager) getSurveyByRef:[self surveyRef] completion:^(id survey, NSError *error) {
    if (survey) {
      id jsonSurvey = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:survey];
      NSLog(@"Survey (converted back to JSON for dump):\n%@", jsonSurvey);
    }
    if (error) {
      NSLog(@"Error getting sample survey:\n%@", error);
    } else {
      SBBSurvey *sbbSurvey = (SBBSurvey *)survey;
      if ([sbbSurvey isKindOfClass:[SBBSurvey class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          _fetchedSurvey = sbbSurvey;
          _nameTextField.text = sbbSurvey.name;
          _versionedOnTextField.text = [sbbSurvey.versionedOn description];
          _guidTextField.text = sbbSurvey.guid;
          _numQuestionsTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)sbbSurvey.questions.count];
        });
      }
    }
  }];
}

- (NSArray *)someAnswers {
  NSMutableArray *answers = [NSMutableArray array];
  SBBSurveyAnswer *a1 = [SBBSurveyAnswer new];
  a1.questionGuid = [self guidForQuestion:0];
  a1.answer = @3;
  a1.answeredOn = [NSDate date];
  a1.client = @"test";
  a1.declined = @NO;
  [answers addObject:a1];
  SBBSurveyAnswer *a2 = [a1 copy];
  a2.questionGuid = [self guidForQuestion:1];
  a2.answer = @2;
  [answers addObject:a2];
  
  return answers;
}

- (IBAction)didTouchSendSampleAnswersButton:(id)sender {
  [SBBComponent(SBBSurveyManager) submitAnswers:[self someAnswers] toSurveyByRef:[self surveyRef] completion:^(id guidHolder, NSError *error) {
    if (guidHolder) {
      id guidHolderJSON = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:guidHolder];
      NSLog(@"Guid holder for new survey response (converted back to JSON for dump):\n%@", guidHolderJSON);
      if ([guidHolder isKindOfClass:[SBBGuidHolder class]]) {
        self.responseGuid = ((SBBGuidHolder *)guidHolder).guid;
      }
    }
    if (error) {
      NSLog(@"Error:\n%@", error);
    }
  }];
}

- (IBAction)didTouchFetchResultsButton:(id)sender {
  [SBBComponent(SBBSurveyManager) getSurveyResponse:_responseGuid completion:^(id surveyResponse, NSError *error) {
    if (surveyResponse) {
      id surveyResponseJSON = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:surveyResponse];
      NSLog(@"Survey response (converted back to JSON for dump):\n%@", surveyResponseJSON);
    }
    if (error) {
      NSLog(@"Error:\n%@", error);
    }
  }];
}

- (NSArray *)moreAnswers {
  NSMutableArray *answers = [NSMutableArray array];
  SBBSurveyAnswer *a1 = [SBBSurveyAnswer new];
  a1.questionGuid = [self guidForQuestion:2];
  a1.answer = @4;
  a1.answeredOn = [NSDate date];
  a1.client = @"test";
  a1.declined = @NO;
  [answers addObject:a1];
  SBBSurveyAnswer *a2 = [a1 copy];
  a2.questionGuid = [self guidForQuestion:3];
  a2.answer = @1;
  [answers addObject:a2];
  
  return answers;
}

- (IBAction)didTouchAddSampleAnswersButton:(id)sender {
  [SBBComponent(SBBSurveyManager) addAnswers:[self moreAnswers] toSurveyResponse:_responseGuid completion:^(id responseObject, NSError *error) {
    if (responseObject) {
      NSLog(@"Add answers to survey results %@\nAPI response:\n%@", _responseGuid, responseObject);
    }
    if (error) {
      NSLog(@"Error:\n%@", error);
    }
  }];
}

- (IBAction)didTouchDeleteResultsButton:(id)sender {
  [SBBComponent(SBBSurveyManager) deleteSurveyResponse:_responseGuid completion:^(id responseObject, NSError *error) {
    if (responseObject) {
      NSLog(@"Delete survey response %@\nAPI response:\n%@", _responseGuid, responseObject);
    }
    if (error) {
      NSLog(@"Error:\n%@", error);
    } else {
      self.responseGuid = nil;
    }
  }];
}

@end
