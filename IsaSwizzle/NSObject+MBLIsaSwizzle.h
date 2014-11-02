//
//  NSObject+IsaSwizzle.h
//  IsaSwizzle
//
//  Created by Michail Pishchagin on 02.11.14.
//  Copyright (c) 2014 Michail Pishchagin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MBLISASwizzle)
- (void)mbl_setClass:(Class)cls;
- (Class)mbl_originalClass;
- (void)mbl_restoreClass;
- (void)mbl_restoreOriginalClass;
- (BOOL)mbl_hasCustomClass;
@end
