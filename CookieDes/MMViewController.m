//
//  MMViewController.m
//  CookieDes
//
//  Created by manjun.han on 24/05/2014.
//  Copyright (c) 2014 manjun.han. All rights reserved.
//

/**
 * ref : 
 *
 * https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/Classes/NSHTTPCookieStorage_Class/Reference/Reference.html
 *
 * https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/Classes/NSHTTPCookie_Class/Reference/Reference.html#//apple_ref/occ/cl/NSHTTPCookie
 *
 * https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/URLLoadingSystem/CookiesandCustomProtocols/CookiesandCustomProtocols.html#//apple_ref/doc/uid/10000165i-CH10-SW3
 *
 * https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 *
 */


#import "MMViewController.h"
#import "NSURLRequest+Extension.h"

#define HTTPCookieStorage [NSHTTPCookieStorage sharedHTTPCookieStorage]
#define DefaultNotificationCenter [NSNotificationCenter defaultCenter]

@interface MMViewController ()

@property (weak, nonatomic) IBOutlet UITextField *requestPageTextField;

@property (weak, nonatomic) IBOutlet UITextField *printCookieURLTextField;

@property (weak, nonatomic) IBOutlet UITextField *cookieNewNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *cookieNewValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *cookieNewDomainTextField;
@property (weak, nonatomic) IBOutlet UITextField *cookieNewPathTextField;
@property (weak, nonatomic) IBOutlet UITextField *cookiNewPortTextField;

@property (weak, nonatomic) IBOutlet UITextField *deleteCookieNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *deleteCookieDomainTextField;
@property (weak, nonatomic) IBOutlet UITextField *deleteCookiePathTextField;
@property (weak, nonatomic) IBOutlet UITextField *deleteCookiePortTextField;
@property (weak, nonatomic) IBOutlet UITextField *clearCookieURLTextField;

@end

@implementation MMViewController

#pragma mark UIVewController生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[DefaultNotificationCenter addObserver:self 
				      selector:@selector(keyBoardShownHandler:)
					  name:UIKeyboardWillShowNotification
					object:nil];
	
	[DefaultNotificationCenter addObserver:self 
				      selector:@selector(keyBoardHiddenHandler:)
				  	  name:UIKeyboardWillHideNotification
					object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[DefaultNotificationCenter removeObserver:self];
}

#pragma mark View Action

- (IBAction)postHttpRequest:(UIButton *)sender
{
	NSString *urlString = self.requestPageTextField.text ;
	
	NSURLRequest *request = [NSURLRequest requestWithURLString:urlString];
	
	[NSURLConnection sendAsynchronousRequest:request
					   queue:[NSOperationQueue mainQueue]
			       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
							   
							   NSLog(@"%@",connectionError);
							   
							  [self showAlertWithTitle:@"加载完毕" message:@"可以打印Cookie信息了"];
						   }];
}

- (IBAction)printCookieMessage:(id)sender
{
	NSArray *cookies = NULL ;
	
	NSString *cookieURL = self.printCookieURLTextField.text  ;
	
	if(cookieURL!= NULL && ![cookieURL isEqualToString:@""]){
		
		cookies = [HTTPCookieStorage cookiesForURL:[NSURL URLWithString:cookieURL]];
		
	}else{
		
		cookies = [HTTPCookieStorage cookies];
	}
	
	NSHTTPCookie *curCookie = NULL ;
	
	NSMutableString *string = [[NSMutableString alloc]init];
	
	for (int i = 0 ; i < cookies.count; i++) {
		curCookie = (NSHTTPCookie*)cookies[i];
		[string appendString:@"[ "];
		[string appendString:[curCookie name]];
		[string appendString:@"="];
		[string appendString:[curCookie value]];
		[string appendString:@" ]\n"];
	}
	
	if(cookies.count == 0){
		[string appendString:@"App中尚未写入cookie" ];
	}
	
	[self showAlertWithTitle:@"Cookies" message:string];
}

- (IBAction)createNewCookie:(id)sender
{
	NSMutableDictionary *attr = [NSMutableDictionary new];

	[attr setObject:self.cookieNewNameTextField.text forKey:NSHTTPCookieName];
	[attr setObject:self.cookieNewDomainTextField.text forKey:NSHTTPCookieDomain];
	[attr setObject:self.cookieNewValueTextField.text forKey:NSHTTPCookieValue];
	[attr setObject:self.cookieNewPathTextField.text forKey:NSHTTPCookiePath];
	[attr setObject:self.cookiNewPortTextField.text forKey:NSHTTPCookiePort];
	
	NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:attr];
	
	[HTTPCookieStorage setCookie:newCookie];
	
	[self showAlertWithTitle:@"添加完毕" message:@""];
}

- (IBAction)deleteCookie:(id)sender
{
	NSMutableDictionary *attr = [NSMutableDictionary new];
	
	[attr setObject:self.deleteCookieNameTextField forKey:NSHTTPCookieName];
	[attr setObject:self.deleteCookieDomainTextField forKey:NSHTTPCookieDomain];
	[attr setObject:self.deleteCookiePathTextField forKey:NSHTTPCookiePath];
	[attr setObject:self.deleteCookiePortTextField.text forKey:NSHTTPCookiePort];
	
	NSHTTPCookie *deleteCookie = [NSHTTPCookie cookieWithProperties:attr];
	
	[HTTPCookieStorage deleteCookie:deleteCookie];

	[self showAlertWithTitle:@"删除完毕" message:@""];
}


- (IBAction)clearAllCookiesForURL:(id)sender
{
	NSArray *cookies = NULL ;
	
	if([self.clearCookieURLTextField.text isEqualToString:@""]){
		cookies = [HTTPCookieStorage cookies];
	}else{
		cookies = [HTTPCookieStorage cookiesForURL:[NSURL URLWithString:self.clearCookieURLTextField.text]];
	}
	
	for (int i = 0 ; i < cookies.count; i++) {
		[HTTPCookieStorage deleteCookie:cookies[i]];
	}
	[self showAlertWithTitle:@"清空完毕" message:@""];
}

#pragma mark 消息响应处理

- (void)keyBoardShownHandler:(NSNotification*)notification
{
	if(![self.deleteCookiePathTextField isFirstResponder]   &&
	   ![self.deleteCookieNameTextField isFirstResponder]   &&
	   ![self.deleteCookieDomainTextField isFirstResponder] &&
	   ![self.deleteCookiePortTextField isFirstResponder]   &&
   	   ![self.clearCookieURLTextField isFirstResponder])
	{
		return ;
	}
		
	NSDictionary* info = [notification userInfo];
    
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	CGRect frame = self.view.frame ;
	
	frame.origin.y -= kbSize.height ;
	
	[UIView animateWithDuration:1.0 animations:^{
		self.view.frame = frame ;
	}];
		
}

-(void)keyBoardHiddenHandler:(NSNotification*)notification
{
	CGRect frame = self.view.frame ;
	
	frame.origin.y = 0;
	
	[UIView animateWithDuration:1.0 animations:^{
		self.view.frame = frame ;
	}];
}

#pragma mark touch事件处理

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.view endEditing:NO];
	[super touchesEnded:touches withEvent:event];
}

#pragma mark 自定义方法

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
							   message:message
							  delegate:nil
						 cancelButtonTitle:@"确认" otherButtonTitles:nil];
	
	[alertView show];
}

@end
