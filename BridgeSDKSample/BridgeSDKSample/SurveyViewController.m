//
//  SurveyViewController.m
//  BridgeSDKSample
//
//  Created by Erin Mounts on 10/14/14.
//
//	Copyright (c) 2014, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SurveyViewController.h"
@import BridgeSDK;

@interface SurveyViewController ()

@property (nonatomic, strong) SBBSurvey *fetchedSurvey;
@property (nonatomic, strong) NSString *responseIdentifier;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *createdOnTextField;
@property (weak, nonatomic) IBOutlet UITextField *guidTextField;
@property (weak, nonatomic) IBOutlet UITextField *numElementsTextField;
@property (weak, nonatomic) IBOutlet UITextField *sampleRefTextField;
@property (weak, nonatomic) IBOutlet UITextField *responseIdentifierTextField;

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
  NSString *surveyRef = self.sampleRefTextField.text;
  
//  switch (SBBComponent(SBBNetworkManager).environment) {
//    case SBBEnvironmentDev:
//      surveyRef = @"/api/v1/surveys/9e948494-491d-48c5-b465-7398c727da5e/2014-11-26T21:40:52.183Z";
//      break;
//      
//    case SBBEnvironmentStaging:
//      surveyRef = @"/api/v1/surveys/9e948494-491d-48c5-b465-7398c727da5e/2014-11-26T21:40:52.183Z";
//      break;
//      
//    default:
//      break;
//  }

  return surveyRef;
}

- (id)answer_s_ForQuestion:(SBBSurveyQuestion *)question
{
  id answer_s_ = nil;
  SBBSurveyConstraints *constraints = question.constraints;
  if ([constraints isKindOfClass:[SBBMultiValueConstraints class]]) {
    SBBMultiValueConstraints *mvc = (SBBMultiValueConstraints *)constraints;
    NSArray *enumeration = mvc.enumeration;
    NSUInteger enumIndex = arc4random_uniform((int)enumeration.count);
    SBBSurveyQuestionOption *option = enumeration[enumIndex];
    answer_s_ = option.value;
    if (mvc.allowMultipleValue) {
      answer_s_ = @[answer_s_];
    }
  } else if ([constraints isKindOfClass:[SBBIntegerConstraints class]]) {
      SBBIntegerConstraints *intc = (SBBIntegerConstraints *)constraints;
      int32_t min = INT32_MIN;
      int32_t max = INT32_MAX;
      if (intc.minValue) {
          min = [intc.minValue intValue];
      }
      if (intc.maxValue) {
          max = [intc.maxValue intValue];
      }
      u_int32_t range = max - min;
      int32_t val = arc4random_uniform(range) + min;
      answer_s_ = @(val).stringValue;
  }
  // TODO: Make this work for other constraint types
  
  return answer_s_;
}

- (IBAction)didTouchLoadSampleButton:(id)sender {
  NSString *surveyRef = [self surveyRef];
  if (!surveyRef.length) {
    return;
  }
  
  [SBBComponent(SBBSurveyManager) getSurveyByRef:surveyRef completion:^(id survey, NSError *error) {
    if (survey) {
      id jsonSurvey = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:survey];
      NSLog(@"Survey (converted back to JSON for dump):\n%@", jsonSurvey);
    }
    if (error) {
      NSLog(@"Error getting survey %@:\n%@", surveyRef, error);
    } else {
      SBBSurvey *sbbSurvey = (SBBSurvey *)survey;
      if ([sbbSurvey isKindOfClass:[SBBSurvey class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          _fetchedSurvey = sbbSurvey;
          _nameTextField.text = sbbSurvey.name;
          _createdOnTextField.text = [sbbSurvey.createdOn description];
          _guidTextField.text = sbbSurvey.guid;
          _numElementsTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)sbbSurvey.elements.count];
        });
      }
    }
  }];
}

- (NSArray *)surveyAnswersForQuestionsFromIndex:(NSUInteger)start toIndex:(NSUInteger)end
{
    NSMutableArray *answers = [NSMutableArray array];
    for (NSUInteger i = start; i <= end; ++i) {
        SBBSurveyQuestion *question = _fetchedSurvey.elements[i];
        if (![question isKindOfClass:[SBBSurveyQuestion class]]) {
            continue;
        }
        SBBSurveyAnswer *a1 = [SBBSurveyAnswer new];
        a1.questionGuid = question.guid;
        id answer_s_ = [self answer_s_ForQuestion:question];
        if ([answer_s_ isKindOfClass:[NSString class]]) {
            a1.answers = @[answer_s_];
        } else if ([answer_s_ isKindOfClass:[NSArray class]]) {
            a1.answers = answer_s_;
        }
        a1.answeredOn = [NSDate date];
        a1.client = @"test";
        a1.declined = @NO;
        [answers addObject:a1];
    }
    
    return answers;
}

- (NSArray *)someAnswers {
    return [self surveyAnswersForQuestionsFromIndex:0 toIndex:1];
}

- (IBAction)didTouchSendSampleAnswersButton:(id)sender {
    SBBSurveyManagerSubmitAnswersCompletionBlock submitCompletionBlock = [^(id identifierHolder, NSError *error){
        if (identifierHolder) {
            id identifierHolderJSON = [SBBComponent(SBBObjectManager) bridgeJSONFromObject:identifierHolder];
            NSLog(@"Identifier holder for new survey response (converted back to JSON for dump):\n%@", identifierHolderJSON);
            if ([identifierHolder isKindOfClass:[SBBIdentifierHolder class]]) {
                self.responseIdentifier = ((SBBIdentifierHolder *)identifierHolder).identifier;
            }
        }
        if (error) {
            NSLog(@"Error:\n%@", error);
        }
    } copy];
    
    if (_fetchedSurvey) {
        [SBBComponent(SBBSurveyManager) submitAnswers:[self someAnswers] toSurvey:_fetchedSurvey withResponseIdentifier:self.responseIdentifierTextField.text completion:submitCompletionBlock];
    } else {
        [SBBComponent(SBBSurveyManager) submitAnswers:[self someAnswers] toSurveyByRef:[self surveyRef] withResponseIdentifier:self.responseIdentifierTextField.text completion:submitCompletionBlock];
    }
}

- (IBAction)didTouchFetchResultsButton:(id)sender {
    NSString *responseId = self.responseIdentifierTextField.text;
    if (!responseId.length) {
        // if not filled in, use the one we got back from the most recently sent sample answers
        responseId = _responseIdentifier;
    }
    
    [SBBComponent(SBBSurveyManager) getSurveyResponse:responseId completion:^(id surveyResponse, NSError *error) {
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
    return [self surveyAnswersForQuestionsFromIndex:2 toIndex:3];
}

- (IBAction)didTouchAddSampleAnswersButton:(id)sender {
    NSString *responseId = self.responseIdentifierTextField.text;
    if (!responseId.length) {
        // if not filled in, use the one we got back from the most recently sent sample answers
        responseId = _responseIdentifier;
    }
    [SBBComponent(SBBSurveyManager) addAnswers:[self moreAnswers] toSurveyResponse:responseId completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            NSLog(@"Add answers to survey results %@\nAPI response:\n%@", responseId, responseObject);
        }
        if (error) {
            NSLog(@"Error:\n%@", error);
        }
    }];
}

- (IBAction)didTouchDeleteResultsButton:(id)sender {
    NSString *responseId = self.responseIdentifierTextField.text;
    if (!responseId.length) {
        // if not filled in, use the one we got back from the most recently sent sample answers
        responseId = _responseIdentifier;
    }
    [SBBComponent(SBBSurveyManager) deleteSurveyResponse:responseId completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            NSLog(@"Delete survey response %@\nAPI response:\n%@", responseId, responseObject);
        }
        if (error) {
            NSLog(@"Error:\n%@", error);
        } else {
            self.responseIdentifier = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.responseIdentifierTextField.text = nil;
            });
        }
    }];
}

@end
