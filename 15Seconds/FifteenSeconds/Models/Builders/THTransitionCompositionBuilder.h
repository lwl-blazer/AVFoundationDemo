//
//  THTransitionCompositionBuilder.h
//  FifteenSeconds
//
//  Created by luowailin on 2020/12/1.
//  Copyright © 2020 TapHarmonic, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THCompositionBuilder.h"
#import "THTimeline.h"

NS_ASSUME_NONNULL_BEGIN

@interface THTransitionCompositionBuilder : NSObject<THCompositionBuilder>

- (instancetype)initWithTimeline:(THTimeline *)timeline;

@end

NS_ASSUME_NONNULL_END
