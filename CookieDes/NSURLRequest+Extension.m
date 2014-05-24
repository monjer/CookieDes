//
//  NSURLRequest+Extension.m
//  IOSWebClient
//
//  Created by manjun.han on 24/05/2014.
//  Copyright (c) 2014 manjun.han. All rights reserved.
//

#import "NSURLRequest+Extension.h"

@implementation NSURLRequest (Extension)

+ (NSURLRequest*)requestWithURLString:(NSString*)url
{
	return [NSURLRequest requestWithURL:[NSURL URLWithString:url] ];
}

@end
