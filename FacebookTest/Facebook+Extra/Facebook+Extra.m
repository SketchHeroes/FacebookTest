//
//  Facebook+Extra.m
//  FacebookTest
//
//  Created by Yaniv Marshaly on 1/28/13.
//  Copyright (c) 2013 SketchHeroes LTD. All rights reserved.
//

#import "Facebook+Extra.h"

static FacebookFailedBlock _facebookDialogFaildBlock;
static FacebookSuccessBlock _facebookDialogSuccessBlock;

@interface Facebook (extra)<FBDialogDelegate>

@end


@implementation Facebook (Extra)

+(id)shared
{
    static id shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class]alloc]init];
    });
    return shared;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.accessToken = FBSession.activeSession.accessToken;
        self.expirationDate = FBSession.activeSession.expirationDate;
    }
    return self;
}

#pragma mark - Class Methods
#pragma mark - Login Methods
+(BOOL)isSessionOpen
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // even though we had a cached token, we need to login to make the session usable
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
            // we recurse here, in order to update buttons and labels
            [FBSession setActiveSession:session];

            [[Facebook shared]setAccessToken:FBSession.activeSession.accessToken];
            [[Facebook shared]setExpirationDate:FBSession.activeSession.expirationDate];
            
        }];
    }
    
    return FBSession.activeSession.isOpen;
}
+(void)logout
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [[Facebook shared]logout];
}

+(void)loginWithPermissions:(NSArray*)permissions
               successBlock:(FacebookSuccessBlock)successBlock
                failedBlock:(FacebookFailedBlock)failedBlock
{
    if (![Facebook isSessionOpen]) {
        
        FBSession *session = [[FBSession alloc]initWithPermissions:permissions];
        
        [FBSession setActiveSession:session];
        
        [session openWithCompletionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             if (error) {
                 failedBlock(error);
             } else {
                 [FBSession setActiveSession:session];
                 [[Facebook shared]sessionStateChanged:session state:state error:error successBlock:successBlock failedBlock:failedBlock];
             }
         }];
       
    }

}
#pragma mark - Open Graph Methods
+(void)startForMeRequestWithSuccessBlock:(FacebookSuccessBlock)successBlock andFailedBlock:(FacebookFailedBlock)failedBlock
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            failedBlock(error);
        }else{
            successBlock(result);
        }
    }];
}

+(void)startGraphRequestWithPath:(NSString*)graphPath andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock
{
    [Facebook startGraphRequestWithPath:graphPath andParameters:nil andSuccessBlock:successBlock andFailedBlock:failedBlock];
}

+(void)startGraphRequestWithPath:(NSString*)graphPath andParameters:(NSDictionary*)parameters andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock
{
    [Facebook startGraphRequestWithPath:graphPath andParameters:parameters andHTTPMethod:nil andSuccessBlock:successBlock andFailedBlock:failedBlock];
}

+(void)startGraphRequestWithPath:(NSString*)graphPath andParameters:(NSDictionary*)parameters andHTTPMethod:(NSString*)httpMethod
                 andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock
{
    [Facebook startGraphRequestWithPath:graphPath andParameters:parameters andHTTPMethod:httpMethod andPermissions:nil permissionsType:kFacebookPremissionTypePublish andSessionAudience:FBSessionDefaultAudienceEveryone andSuccessBlock:successBlock andFailedBlock:failedBlock];
}

+(void)startGraphRequestWithPath:(NSString*)graphPath andParameters:(NSDictionary*)parameters andHTTPMethod:(NSString*)httpMethod andPermissions:(NSArray*)permissions permissionsType:(kFacebookPremissionType)permissionsType
              andSessionAudience:(FBSessionDefaultAudience)sessionAudience
                 andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock
{
    
    
    [Facebook reauthorizePermissions:permissions ofType:permissionsType andSessionAudience:sessionAudience successBlock:^{
        
        [FBRequestConnection startWithGraphPath:graphPath parameters:parameters HTTPMethod:httpMethod completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                failedBlock(error);
            }else{
                successBlock(result);
            }
        }];
        
    } failedBlock:^(NSError *error) {
        failedBlock(error);
    }];
    
}

+(void)reauthorizePermissions:(NSArray*)permissions ofType:(kFacebookPremissionType)type
                          andSessionAudience:(FBSessionDefaultAudience)sessionAudience
                 successBlock:(void(^)())successBlock
                  failedBlock:(FacebookFailedBlock)failedBlock;
{

    if (!permissions) {
        successBlock();
    }
    __block BOOL shouldReuthorize = NO;
    
    [permissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        if ([FBSession.activeSession.permissions
             indexOfObject:obj] == NSNotFound) {
            shouldReuthorize = YES;
            *stop = YES;
        }
        
    }];
    
    if (shouldReuthorize) {
        
        switch (type) {
            case kFacebookPremissionTypePublish:
            {
                [FBSession.activeSession
                 reauthorizeWithPublishPermissions:permissions
                 defaultAudience:sessionAudience
                 completionHandler:^(FBSession *session, NSError *error) {
                     if (!error) {
                         successBlock();
                         // re-call assuming we now have the permission
                         
                     }else{
                         failedBlock(error);
                     }
                 }];
            }
                break;
                
            case kFacebookPremissionTypeRead:
            {
                [FBSession.activeSession
                 reauthorizeWithReadPermissions:permissions completionHandler:^(FBSession *session, NSError *error) {
                     if (!error) {
                            // re-call assuming we now have the permission
                         successBlock();
                     }else{
                         failedBlock(error);
                     }
                 }];
            }
                break;
          
        }
        
    } else {
        successBlock();
    }
}
#pragma mark - Share Methods
+(void)shareToUserFeedWithMessage:(NSString*)message
                               andURL:(NSURL*)linkURL
                             andImage:(UIImage*)image
                      andSuccessBlock:(FacebookSuccessBlock)successBlock
                       andFailedBlock:(FacebookFailedBlock)failedBlock
{
    [Facebook shareToUserFeedWithParameteres:nil andMessage:message andURL:linkURL andImage:image andSuccessBlock:successBlock andFailedBlock:failedBlock];
}
+(void)shareToUserFeedWithParameteres:(NSMutableDictionary*)params
                          andMessage:(NSString*)message
                              andURL:(NSURL*)linkURL
                            andImage:(UIImage*)image
                     andSuccessBlock:(FacebookSuccessBlock)successBlock
                      andFailedBlock:(FacebookFailedBlock)failedBlock
{
    [Facebook shareToUserFeedWithDialogPath:@"me/feed" useNativeDialog:YES Parameteres:params andMessage:message andURL:linkURL andImage:image andSuccessBlock:successBlock andFailedBlock:failedBlock];
}
+(void)shareToUserFeedWithDialogPath:(NSString*)dialogPath
                     useNativeDialog:(BOOL)useNativeDialog
                         Parameteres:(NSMutableDictionary*)params
                           andMessage:(NSString*)message
                               andURL:(NSURL*)linkURL
                             andImage:(UIImage*)image
                      andSuccessBlock:(FacebookSuccessBlock)successBlock
                      andFailedBlock:(FacebookFailedBlock)failedBlock
{

    _facebookDialogFaildBlock = nil;
    _facebookDialogSuccessBlock = nil;

    
    UIViewController * rootViewController = [[UIApplication sharedApplication]keyWindow].rootViewController;
        
    if (useNativeDialog && [FBNativeDialogs canPresentShareDialogWithSession:FBSession.activeSession]) {
        
        [FBNativeDialogs
         presentShareDialogModallyFrom:rootViewController
         initialText:message
         image:image
         url:linkURL
         handler:^(FBNativeDialogResult result, NSError *error) {
             
             // Only show the error if it is not due to the dialog
             // not being supporte, i.e. code = 7, otherwise ignore
             // because our fallback will show the share view controller.
             if (error && [error code] == 7) {
                 failedBlock(error);
             }else if (result == FBNativeDialogResultSucceeded) {
                 successBlock(nil);
             }else{
                 failedBlock(error);
             }
             
         }];

        
        
    }else{
        
        if (!params && (message || linkURL )) {
            params = [NSMutableDictionary dictionary];
        }
        
        if (message) {
            [params setValue:message forKey:@"message"];
        }
        if (linkURL) {
            [params setValue:linkURL.absoluteString forKey:@"link"];
        }

        
        _facebookDialogFaildBlock = [failedBlock copy];
        _facebookDialogSuccessBlock = [successBlock copy];
        
        [[Facebook shared]dialog:dialogPath andParams:params andDelegate:[Facebook shared]];
    }

}
#pragma mark - Private Methods

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
               successBlock:(FacebookSuccessBlock)successBlock
                failedBlock:(FacebookFailedBlock)failedBlock
{
    switch (state) {
        case FBSessionStateOpen: {
          
            successBlock(session);
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            failedBlock(error);
            break;
        default:
            failedBlock(error);
            break;
    }
    
    if (error) {
        failedBlock(error);
    }    
}


#pragma mark - FBDialogDelegate
/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog
{
    if (_facebookDialogSuccessBlock) {
        _facebookDialogSuccessBlock(dialog);
    }
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url
{
    if (_facebookDialogSuccessBlock) {
        _facebookDialogSuccessBlock(url);
    }
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
    if (_facebookDialogFaildBlock) {
        _facebookDialogFaildBlock([NSError errorWithDomain:@"com.facebook" code:403 userInfo:@{@"url" : url}]);
    }
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog
{
    if (_facebookDialogFaildBlock) {
        _facebookDialogFaildBlock([NSError errorWithDomain:@"com.facebook" code:403 userInfo:@{@"dialog" : dialog}]);
    }
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    if (_facebookDialogFaildBlock) {
        _facebookDialogFaildBlock(error);
    }
}

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser,
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url
{
    return NO;
}
@end
