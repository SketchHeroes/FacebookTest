//
//  Facebook+Extra.h
//  FacebookTest
//
//  Created by Yaniv Marshaly on 1/28/13.
//  Copyright (c) 2013 SketchHeroes LTD. All rights reserved.
//


typedef NS_ENUM(NSInteger, kFacebookPremissionType)
{
    kFacebookPremissionTypeRead = 0,
    kFacebookPremissionTypePublish
};

typedef void (^FacebookSuccessBlock)(id result);

typedef void (^FacebookFailedBlock)(NSError* error);

@interface Facebook (Extra)

#pragma mark - Login Methods
/*
 checking if the current session is open
 if not, the user needs to login.
 */
+(BOOL)isSessionOpen;

/*
 Login with any basic permissions
 */
+(void)loginWithPermissions:(NSArray*)permissions
               successBlock:(FacebookSuccessBlock)successBlock
                failedBlock:(FacebookFailedBlock)failedBlock;

/*
 Logout and delete all cookies
 */
+(void)logout;

#pragma mark - Open Graph Methods

/*
 this method will retrive the user basic informations
 return id<FBGraphUser> .
 */
+(void)startForMeRequestWithSuccessBlock:(FacebookSuccessBlock)successBlock
                          andFailedBlock:(FacebookFailedBlock)failedBlock;

/*
 Simple graph request of type GET,
 just needs the path
 */
+(void)startGraphRequestWithPath:(NSString*)graphPath andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock;
/*
 Graph request of type GET,
  needs  the path , the parametes can be nil.
 */
+(void)startGraphRequestWithPath:(NSString*)graphPath andParameters:(NSDictionary*)parameters andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock;

/*
 Graph request that requesries the definition
 for the request type, if the request type is nil
 the request be GET type,
 needs  the path , the parametes can be nil.
 */
+(void)startGraphRequestWithPath:(NSString*)graphPath andParameters:(NSDictionary*)parameters andHTTPMethod:(NSString*)httpMethod andSuccessBlock:(FacebookSuccessBlock)successBlock andFailedBlock:(FacebookFailedBlock)failedBlock;


/*
 Graph request that requesries the definition
 for the request type, if the request type is nil
 the request be GET type,
 you can add special permissions ,read or publish, if nil 
 it will ignore the parameters of the sessionAudience
 and the permissionsType parameter
 needs  the path , the parametes can be nil.
 */

+(void)startGraphRequestWithPath:(NSString*)graphPath
                   andParameters:(NSDictionary*)parameters
                   andHTTPMethod:(NSString*)httpMethod
                  andPermissions:(NSArray*)permissions
                 permissionsType:(kFacebookPremissionType)permissionsType
              andSessionAudience:(FBSessionDefaultAudience)sessionAudience
                 andSuccessBlock:(FacebookSuccessBlock)successBlock
                  andFailedBlock:(FacebookFailedBlock)failedBlock;

#pragma mark - Share Methods
/*
 the dialog path is me/feed
 and if it can uses Native Dialog(set to YES)
 if its not the native dialog the message and the 
 link will be added automatically to the sending
 params.
 */
+(void)openDialogWithMessage:(NSString*)message
                           andURL:(NSURL*)linkURL
                         andImage:(UIImage*)image
                  andSuccessBlock:(FacebookSuccessBlock)successBlock
                   andFailedBlock:(FacebookFailedBlock)failedBlock;




/*
 the dialog path is me/feed
 and if it can uses Native Dialog(set to YES)
 */
+(void)openDialogWithParameteres:(NSMutableDictionary*)params
                           andMessage:(NSString*)message
                               andURL:(NSURL*)linkURL
                             andImage:(UIImage*)image
                      andSuccessBlock:(FacebookSuccessBlock)successBlock
                       andFailedBlock:(FacebookFailedBlock)failedBlock;

/*
 pass the dialog path ,
 like me/feed , me/links , etc...
 ask if should use the native Dialog
 
 */
+(void)openDialogWithDialogPath:(NSString*)dialogPath
                     useNativeDialog:(BOOL)useNativeDialog
                         Parameteres:(NSMutableDictionary*)params
                          andMessage:(NSString*)message
                              andURL:(NSURL*)linkURL
                            andImage:(UIImage*)image
                     andSuccessBlock:(FacebookSuccessBlock)successBlock
                      andFailedBlock:(FacebookFailedBlock)failedBlock;

@end
