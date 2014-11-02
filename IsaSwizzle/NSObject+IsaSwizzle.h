//
//  NSObject+IsaSwizzle.h
//  IsaSwizzle
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ISASwizzle)
- (void)setClass:(Class)cls;
- (Class)originalClass;
- (void)restoreClass;
- (void)restoreOriginalClass;
- (BOOL)hasCustomClass;
@end
