//
//  NSObject+Tracing.h
//  IsaSwizzle
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MBLTracing)
- (void)mbl_startTracing;
- (void)mbl_endTracing;
@end
