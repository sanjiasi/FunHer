//
//  FHSystemActionManager.m
//  FunHer
//
//  Created by GLA on 2023/9/7.
//

#import "FHSystemActionManager.h"

@implementation FHSystemActionManager

+ (void)impactFeedback {
    UIImpactFeedbackGenerator * feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleRigid];
    [feedbackGenerator impactOccurred];
}

@end
