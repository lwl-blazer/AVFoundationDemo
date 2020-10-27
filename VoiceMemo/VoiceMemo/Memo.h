//
//  Memo.h
//  VoiceMemo
//
//  Created by luowailin on 2020/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Memo : NSObject<NSCoding>

@property(nonatomic, copy, readonly) NSString *title;
@property(nonatomic, strong, readonly) NSURL *url;
@property(nonatomic, copy, readonly) NSString *dateString;
@property(nonatomic, copy, readonly) NSString *timeString;

+ (instancetype)memoWithTitle:(NSString *)title url:(NSURL *)url;
- (BOOL)deleteMemo;

@end

NS_ASSUME_NONNULL_END
