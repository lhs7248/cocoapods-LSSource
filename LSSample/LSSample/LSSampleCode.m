//
//  LSSampeCode.m
//  LSSample
//
//  Created by lhs7248 on 2021/1/14.
//

#import "LSSampleCode.h"

@implementation LSSampleCode

-(void)setKey:(NSString *)key value:(NSString *)value
{

    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:value forKey:key];
    
}
@end
