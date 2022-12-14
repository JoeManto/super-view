//
//  WebKitPreferences.h
//  SuperView
//
//  Created by Joe Manto on 9/22/21.
//
#import <WebKit/WebKit.h>

@interface WebKitPreferences : NSObject
-(WKPreferences *)getPreferences;
@end

@interface WKPreferences ()
-(void)_setFullScreenEnabled:(BOOL)fullScreenEnabled;
@end
