#import "RNAppAuth.h"
#if __has_include(<AppAuth/AppAuth.h>)
#import <AppAuth/AppAuth.h>
#else
#import "AppAuth.h"
#endif
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import "RNAppAuthAuthorizationFlowManager.h"

@interface RNAppAuth()<RNAppAuthAuthorizationFlowManagerDelegate> {
    id<OIDExternalUserAgentSession> _currentSession;
}
@end

@implementation RNAppAuth

-(BOOL)resumeExternalUserAgentFlowWithURL:(NSURL *)url {
    return [_currentSession resumeExternalUserAgentFlowWithURL:url];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

#if TARGET_OS_IPHONE
  UIBackgroundTaskIdentifier rnAppAuthTaskId;
#endif

/*! @brief Number of random bytes generated for the @ state.
 */
static NSUInteger const kStateSizeBytes = 32;

/*! @brief Number of random bytes generated for the @ codeVerifier.
 */
static NSUInteger const kCodeVerifierBytes = 32;



RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(register,
                 issuer: (NSString *) issuer
                 redirectUrls: (NSArray *) redirectUrls
                 responseTypes: (NSArray *) responseTypes
                 grantTypes: (NSArray *) grantTypes
                 subjectType: (NSString *) subjectType
                 tokenEndpointAuthMethod: (NSString *) tokenEndpointAuthMethod
                 additionalParameters: (NSDictionary *_Nullable) additionalParameters
                 serviceConfiguration: (NSDictionary *_Nullable) serviceConfiguration
                 connectionTimeoutSeconds: (double) connectionTimeoutSeconds
                 additionalHeaders: (NSDictionary *_Nullable) additionalHeaders
                 resolve: (RCTPromiseResolveBlock) resolve
                 reject: (RCTPromiseRejectBlock)  reject)
{
    [self configureUrlSession:additionalHeaders sessionTimeout:connectionTimeoutSeconds];

    // if we have manually provided configuration, we can use it and skip the OIDC well-known discovery endpoint call
    if (serviceConfiguration) {
        OIDServiceConfiguration *configuration = [self createServiceConfiguration:serviceConfiguration];
        [self registerWithConfiguration: configuration
                           redirectUrls: redirectUrls
                          responseTypes: responseTypes
                             grantTypes: grantTypes
                            subjectType: subjectType
                tokenEndpointAuthMethod: tokenEndpointAuthMethod
                   additionalParameters: additionalParameters
                                resolve: resolve
                                 reject: reject];
    } else {
        [OIDAuthorizationService discoverServiceConfigurationForIssuer:[NSURL URLWithString:issuer]
                                                            completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                                if (!configuration) {
                                                                    reject(@"service_configuration_fetch_error", [error localizedDescription], error);
                                                                    return;
                                                                }
                                                                [self registerWithConfiguration: configuration
                                                                                   redirectUrls: redirectUrls
                                                                                  responseTypes: responseTypes
                                                                                     grantTypes: grantTypes
                                                                                    subjectType: subjectType
                                                                        tokenEndpointAuthMethod: tokenEndpointAuthMethod
                                                                           additionalParameters: additionalParameters
                                                                                        resolve: resolve
                                                                                         reject: reject];
                                                            }];
    }
} // end RCT_REMAP_METHOD(register,

RCT_REMAP_METHOD(authorize,
                 issuer: (NSString *) issuer
                 redirectUrl: (NSString *) redirectUrl
                 clientId: (NSString *) clientId
                 clientSecret: (NSString *) clientSecret
                 scopes: (NSArray *) scopes
                 additionalParameters: (NSDictionary *_Nullable) additionalParameters
                 serviceConfiguration: (NSDictionary *_Nullable) serviceConfiguration
                 skipCodeExchange: (BOOL) skipCodeExchange
                 connectionTimeoutSeconds: (double) connectionTimeoutSeconds
                 additionalHeaders: (NSDictionary *_Nullable) additionalHeaders
                 useNonce: (BOOL) useNonce
                 usePKCE: (BOOL) usePKCE
                 iosCustomBrowser: (NSString *) iosCustomBrowser
                 prefersEphemeralSession: (BOOL) prefersEphemeralSession
                 resolve: (RCTPromiseResolveBlock) resolve
                 reject: (RCTPromiseRejectBlock)  reject)
{
    [self configureUrlSession:additionalHeaders sessionTimeout:connectionTimeoutSeconds];

    // if we have manually provided configuration, we can use it and skip the OIDC well-known discovery endpoint call
    if (serviceConfiguration) {
        OIDServiceConfiguration *configuration = [self createServiceConfiguration:serviceConfiguration];
        [self authorizeWithConfiguration: configuration
                             redirectUrl: redirectUrl
                                clientId: clientId
                            clientSecret: clientSecret
                                  scopes: scopes
                                useNonce: useNonce
                                 usePKCE: usePKCE
                    additionalParameters: additionalParameters
                    skipCodeExchange: skipCodeExchange
                        iosCustomBrowser: iosCustomBrowser
                 prefersEphemeralSession: prefersEphemeralSession
                                 resolve: resolve
                                  reject: reject];
    } else {
        [OIDAuthorizationService discoverServiceConfigurationForIssuer:[NSURL URLWithString:issuer]
                                                            completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                                if (!configuration) {
                                                                    reject(@"service_configuration_fetch_error", [error localizedDescription], error);
                                                                    return;
                                                                }
                                                                [self authorizeWithConfiguration: configuration
                                                                 
                                                                                     redirectUrl: redirectUrl
                                                                                        clientId: clientId
                                                                                    clientSecret: clientSecret
                                                                                          scopes: scopes
                                                                                        useNonce: useNonce
                                                                                         usePKCE: usePKCE
                                                                            additionalParameters: additionalParameters
                                                                                skipCodeExchange: skipCodeExchange
                                                                                iosCustomBrowser: iosCustomBrowser
                                                                         prefersEphemeralSession: prefersEphemeralSession
                                                                                         resolve: resolve
                                                                                          reject: reject];
                                                            }];
    }
} // end RCT_REMAP_METHOD(authorize,

RCT_REMAP_METHOD(refresh,
                 issuer: (NSString *) issuer
                 redirectUrl: (NSString *) redirectUrl
                 clientId: (NSString *) clientId
                 clientSecret: (NSString *) clientSecret
                 refreshToken: (NSString *) refreshToken
                 scopes: (NSArray *) scopes
                 additionalParameters: (NSDictionary *_Nullable) additionalParameters
                 serviceConfiguration: (NSDictionary *_Nullable) serviceConfiguration
                 connectionTimeoutSeconds: (double) connectionTimeoutSeconds
                 additionalHeaders: (NSDictionary *_Nullable) additionalHeaders
                 iosCustomBrowser: (NSString *) iosCustomBrowser
                 resolve:(RCTPromiseResolveBlock) resolve
                 reject: (RCTPromiseRejectBlock)  reject)
{
    [self configureUrlSession:additionalHeaders sessionTimeout:connectionTimeoutSeconds];

    // if we have manually provided configuration, we can use it and skip the OIDC well-known discovery endpoint call
    if (serviceConfiguration) {
        OIDServiceConfiguration *configuration = [self createServiceConfiguration:serviceConfiguration];
        [self refreshWithConfiguration: configuration
                           redirectUrl: redirectUrl
                              clientId: clientId
                          clientSecret: clientSecret
                          refreshToken: refreshToken
                                scopes: scopes
                  additionalParameters: additionalParameters
                               resolve: resolve
                                reject: reject];
    } else {
        // otherwise hit up the discovery endpoint
        [OIDAuthorizationService discoverServiceConfigurationForIssuer:[NSURL URLWithString:issuer]
                                                            completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                                if (!configuration) {
                                                                    reject(@"service_configuration_fetch_error", [error localizedDescription], error);
                                                                    return;
                                                                }
                                                                [self refreshWithConfiguration: configuration
                                                                                   redirectUrl: redirectUrl
                                                                                      clientId: clientId
                                                                                  clientSecret: clientSecret
                                                                                  refreshToken: refreshToken
                                                                                        scopes: scopes
                                                                          additionalParameters: additionalParameters
                                                                                       resolve: resolve
                                                                                        reject: reject];
                                                            }];
    }
} // end RCT_REMAP_METHOD(refresh,

RCT_REMAP_METHOD(logout,
                 issuer: (NSString *) issuer
                 idTokenHint: (NSString *) idTokenHint
                 postLogoutRedirectURL: (NSString *) postLogoutRedirectURL
                 serviceConfiguration: (NSDictionary *_Nullable) serviceConfiguration
                 additionalParameters: (NSDictionary *_Nullable) additionalParameters
                 iosCustomBrowser: (NSString *) iosCustomBrowser
                 prefersEphemeralSession: (BOOL) prefersEphemeralSession
                 resolve:(RCTPromiseResolveBlock) resolve
                 reject: (RCTPromiseRejectBlock)  reject)
{
  if (serviceConfiguration) {
    OIDServiceConfiguration *configuration = [self createServiceConfiguration:serviceConfiguration];
    [self endSessionWithConfiguration: configuration
                          idTokenHint: idTokenHint
                postLogoutRedirectURL: postLogoutRedirectURL
                 additionalParameters: additionalParameters
                     iosCustomBrowser: iosCustomBrowser
              prefersEphemeralSession: prefersEphemeralSession
                              resolve: resolve
                               reject: reject];

  } else {
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:[NSURL URLWithString:issuer]
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                                if (!configuration) {
                                                                    reject(@"service_configuration_fetch_error", [error localizedDescription], error);
                                                                    return;
                                                                }
                                                                [self endSessionWithConfiguration: configuration
                                                                                      idTokenHint: idTokenHint
                                                                            postLogoutRedirectURL: postLogoutRedirectURL
                                                                             additionalParameters: additionalParameters
                                                                                 iosCustomBrowser: iosCustomBrowser
                                                                          prefersEphemeralSession: prefersEphemeralSession
                                                                                          resolve: resolve
                                                                                           reject: reject];
                                                        }];
  }
} // end RCT_REMAP_METHOD(logout,

/*
 * Create a OIDServiceConfiguration from passed serviceConfiguration dictionary
 */
- (OIDServiceConfiguration *) createServiceConfiguration: (NSDictionary *) serviceConfiguration {
    NSURL *authorizationEndpoint = [NSURL URLWithString: [serviceConfiguration objectForKey:@"authorizationEndpoint"]];
    NSURL *tokenEndpoint = [NSURL URLWithString: [serviceConfiguration objectForKey:@"tokenEndpoint"]];
    NSURL *registrationEndpoint = [NSURL URLWithString: [serviceConfiguration objectForKey:@"registrationEndpoint"]];
    NSURL *endSessionEndpoint = [NSURL URLWithString: [serviceConfiguration objectForKey:@"endSessionEndpoint"]];

    OIDServiceConfiguration *configuration =
    [[OIDServiceConfiguration alloc]
     initWithAuthorizationEndpoint:authorizationEndpoint
     tokenEndpoint:tokenEndpoint
     issuer:nil
     registrationEndpoint:registrationEndpoint
     endSessionEndpoint:endSessionEndpoint];

    return configuration;
}

+ (nullable NSString *)generateCodeVerifier {
  return [OIDTokenUtilities randomURLSafeStringWithSize:kCodeVerifierBytes];
}

+ (nullable NSString *)generateState {
  return [OIDTokenUtilities randomURLSafeStringWithSize:kStateSizeBytes];
}

+ (nullable NSString *)codeChallengeS256ForVerifier:(NSString *)codeVerifier {
  if (!codeVerifier) {
    return nil;
  }
  // generates the code_challenge per spec https://tools.ietf.org/html/rfc7636#section-4.2
  // code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
  // NB. the ASCII conversion on the code_verifier entropy was done at time of generation.
    NSData *sha256Verifier = [OIDTokenUtilities sha256:codeVerifier];
  return [OIDTokenUtilities encodeBase64urlNoPadding:sha256Verifier];
}


/*
 * Perform dynamic client registration with provided OIDServiceConfiguration
 */
- (void)registerWithConfiguration: (OIDServiceConfiguration *) configuration
                     redirectUrls: (NSArray *) redirectUrlStrings
                    responseTypes: (NSArray *) responseTypes
                       grantTypes: (NSArray *) grantTypes
                      subjectType: (NSString *) subjectType
          tokenEndpointAuthMethod: (NSString *) tokenEndpointAuthMethod
             additionalParameters: (NSDictionary *_Nullable) additionalParameters
                          resolve: (RCTPromiseResolveBlock) resolve
                           reject: (RCTPromiseRejectBlock)  reject
{
    NSMutableArray<NSURL *> *redirectUrls = [NSMutableArray arrayWithCapacity:[redirectUrlStrings count]];
    for (NSString *urlString in redirectUrlStrings) {
        [redirectUrls addObject:[NSURL URLWithString:urlString]];
    }

    OIDRegistrationRequest *request =
    [[OIDRegistrationRequest alloc] initWithConfiguration:configuration
                                             redirectURIs:redirectUrls
                                            responseTypes:responseTypes
                                               grantTypes:grantTypes
                                              subjectType:subjectType
                                  tokenEndpointAuthMethod:tokenEndpointAuthMethod
                                     additionalParameters:additionalParameters];

    [OIDAuthorizationService performRegistrationRequest:request
                                             completion:^(OIDRegistrationResponse *_Nullable response,
                                                          NSError *_Nullable error) {
                                                 if (response) {
                                                     resolve([self formatRegistrationResponse:response]);
                                                 } else {
                                                     reject([self getErrorCode: error defaultCode:@"registration_failed"],
                                                            [self getErrorMessage: error], error);
                                                 }
                                            }];
}

/*
 * Authorize a user in exchange for a token with provided OIDServiceConfiguration
 */
- (void)authorizeWithConfiguration: (OIDServiceConfiguration *) configuration
                       redirectUrl: (NSString *) redirectUrl
                          clientId: (NSString *) clientId
                      clientSecret: (NSString *) clientSecret
                            scopes: (NSArray *) scopes
                          useNonce: (BOOL) useNonce
                           usePKCE: (BOOL) usePKCE
              additionalParameters: (NSDictionary *_Nullable) additionalParameters
              skipCodeExchange: (BOOL) skipCodeExchange
                  iosCustomBrowser: (NSString *) iosCustomBrowser
           prefersEphemeralSession: (BOOL) prefersEphemeralSession
                           resolve: (RCTPromiseResolveBlock) resolve
                            reject: (RCTPromiseRejectBlock)  reject
{

    NSString *codeVerifier = usePKCE ? [[self class] generateCodeVerifier] : nil;
    NSString *codeChallenge = usePKCE ? [[self class] codeChallengeS256ForVerifier:codeVerifier] : nil;
    NSString *nonce =  useNonce ? additionalParameters[@"nonce"]? additionalParameters[@"nonce"]:  [[self class] generateState] : nil ;

    // builds authentication request
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:clientId
     
                                              clientSecret:clientSecret
                                                     scope:[OIDScopeUtilities scopesWithArray:scopes]
                                               redirectURL:[NSURL URLWithString:redirectUrl]
                                              responseType:OIDResponseTypeCode
                                                     state: additionalParameters[@"state"] ? additionalParameters[@"state"] : [[self class] generateState]
                                                     nonce:nonce
                                              codeVerifier:codeVerifier
                                             codeChallenge:codeChallenge
                                      codeChallengeMethod: usePKCE ? OIDOAuthorizationRequestCodeChallengeMethodS256 : nil
                                      additionalParameters:additionalParameters];

    // performs authentication request
#if TARGET_OS_IPHONE
    id<UIApplicationDelegate, RNAppAuthAuthorizationFlowManager> appDelegate = (id<UIApplicationDelegate, RNAppAuthAuthorizationFlowManager>)[UIApplication sharedApplication].delegate;
#elif TARGET_OS_OSX
    id<NSApplicationDelegate, RNAppAuthAuthorizationFlowManager> appDelegate = (id<NSApplicationDelegate, RNAppAuthAuthorizationFlowManager>)[NSApplication sharedApplication].delegate;
#endif
    if (![[appDelegate class] conformsToProtocol:@protocol(RNAppAuthAuthorizationFlowManager)]) {
        [NSException raise:@"RNAppAuth Missing protocol conformance"
                    format:@"%@ does not conform to RNAppAuthAuthorizationFlowManager", appDelegate];
    }
    appDelegate.authorizationFlowManagerDelegate = self;
    __weak typeof(self) weakSelf = self;

#if TARGET_OS_IPHONE
    rnAppAuthTaskId = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        [UIApplication.sharedApplication endBackgroundTask:rnAppAuthTaskId];
        rnAppAuthTaskId = UIBackgroundTaskInvalid;
    }];

    UIViewController *presentingViewController = appDelegate.window.rootViewController.view.window ? appDelegate.window.rootViewController : appDelegate.window.rootViewController.presentedViewController;
#elif TARGET_OS_OSX
    NSWindow *presentingWindow = [NSApplication sharedApplication].mainWindow;
    if(!presentingWindow){
        reject(@"authentication_failed", @"Unable to get the main window to present an authorization request. Try authenticating again with the main window open.", nil);
        return;
    }
#endif

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    id<OIDExternalUserAgent> externalUserAgent = iosCustomBrowser != nil ? [self getCustomBrowser: iosCustomBrowser] : nil;
#elif TARGET_OS_IPHONE || TARGET_OS_OSX
    id<OIDExternalUserAgent> externalUserAgent = nil;
#endif
    
    OIDAuthorizationCallback callback = ^(OIDAuthorizationResponse *_Nullable authorizationResponse, NSError *_Nullable error) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   strongSelf->_currentSession = nil;
#if TARGET_OS_IPHONE
                                                   [UIApplication.sharedApplication endBackgroundTask:rnAppAuthTaskId];
                                                   rnAppAuthTaskId = UIBackgroundTaskInvalid;
#elif TARGET_OS_OSX
                                                   // Brings this app to the foreground.
                                                   [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows)];
#endif
                                                   if (authorizationResponse) {
                                                       resolve([self formatAuthorizationResponse:authorizationResponse withCodeVerifier:codeVerifier]);
                                                   } else {
                                                       reject([self getErrorCode: error defaultCode:@"authentication_failed"],
                                                              [self getErrorMessage: error], error);
                                                   }
                                               };

    if (skipCodeExchange) {
        
        if(externalUserAgent != nil) {
            _currentSession = [OIDAuthorizationService presentAuthorizationRequest:request
                                                                 externalUserAgent:externalUserAgent
                                                                          callback:callback];
        } else {
#if TARGET_OS_IPHONE
            if (@available(iOS 13, *)) {
                _currentSession = [OIDAuthorizationService presentAuthorizationRequest:request
                                                          presentingViewController:presentingViewController
                                                           prefersEphemeralSession:prefersEphemeralSession
                                                                          callback:callback];
            } else {
                _currentSession = [OIDAuthorizationService presentAuthorizationRequest:request
                                                          presentingViewController:presentingViewController
                                                                          callback:callback];
            }
#elif TARGET_OS_OSX
                _currentSession = [OIDAuthorizationService presentAuthorizationRequest:request
                                                           presentingWindow:presentingWindow
                                                           prefersEphemeralSession:prefersEphemeralSession
                                                           callback:callback];
#endif
        }
    } else {
        OIDAuthStateAuthorizationCallback callback = ^(
                                                       OIDAuthState *_Nullable authState,
                                                       NSError *_Nullable error
                                                       ) {
                                                           typeof(self) strongSelf = weakSelf;
                                                           strongSelf->_currentSession = nil;
#if TARGET_OS_IPHONE
                                                           [UIApplication.sharedApplication endBackgroundTask:rnAppAuthTaskId];
                                                           rnAppAuthTaskId = UIBackgroundTaskInvalid;
#elif TARGET_OS_OSX
                                                           // Brings this app to the foreground.
                                                           [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows)];
#endif
                                                           if (authState) {
                                                               resolve([self formatResponse:authState.lastTokenResponse
                                                                           withAuthResponse:authState.lastAuthorizationResponse]);
                                                           } else {
                                                               reject([self getErrorCode: error defaultCode:@"authentication_failed"],
                                                                      [self getErrorMessage: error], error);
                                                           }
                                                       };
        
        if(externalUserAgent != nil) {
            _currentSession = [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                    externalUserAgent:externalUserAgent
                                                                             callback:callback];
        } else {
            
            
#if TARGET_OS_IPHONE
            if (@available(iOS 13, *)) {
                _currentSession = [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                 presentingViewController:presentingViewController
                                                                  prefersEphemeralSession:prefersEphemeralSession
                                                                                 callback:callback];
            } else {
                _currentSession = [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                 presentingViewController:presentingViewController
                                                                                 callback:callback];
            }
#elif TARGET_OS_OSX
                _currentSession = [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                         presentingWindow:presentingWindow
                                                                                 callback:callback];
#endif
        }
    }
}

/*
 * Refresh a token with provided OIDServiceConfiguration
 */
- (void)refreshWithConfiguration: (OIDServiceConfiguration *)configuration
                     redirectUrl: (NSString *) redirectUrl
                        clientId: (NSString *) clientId
                    clientSecret: (NSString *) clientSecret
                    refreshToken: (NSString *) refreshToken
                          scopes: (NSArray *) scopes
            additionalParameters: (NSDictionary *_Nullable) additionalParameters
                         resolve:(RCTPromiseResolveBlock) resolve
                          reject: (RCTPromiseRejectBlock)  reject {

    OIDTokenRequest *tokenRefreshRequest =
    [[OIDTokenRequest alloc] initWithConfiguration:configuration
                                         grantType:@"refresh_token"
                                 authorizationCode:nil
                                       redirectURL:[NSURL URLWithString:redirectUrl]
                                          clientID:clientId
                                      clientSecret:clientSecret
                                            scopes:scopes
                                      refreshToken:refreshToken
                                      codeVerifier:nil
                              additionalParameters:additionalParameters];

    [OIDAuthorizationService performTokenRequest:tokenRefreshRequest
                                        callback:^(OIDTokenResponse *_Nullable response,
                                                   NSError *_Nullable error) {
                                            if (response) {
                                                resolve([self formatResponse:response]);
                                            } else {
                                                reject([self getErrorCode: error defaultCode:@"token_refresh_failed"],
                                                       [self getErrorMessage: error], error);
                                            }
                                        }];
}

- (void)endSessionWithConfiguration: (OIDServiceConfiguration *) configuration
                        idTokenHint: (NSString *) idTokenHint
              postLogoutRedirectURL: (NSString *) postLogoutRedirectURL
               additionalParameters: (NSDictionary *_Nullable) additionalParameters
                   iosCustomBrowser: (NSString *) iosCustomBrowser
            prefersEphemeralSession: (BOOL) prefersEphemeralSession
                            resolve: (RCTPromiseResolveBlock) resolve
                             reject: (RCTPromiseRejectBlock) reject {

    OIDEndSessionRequest *endSessionRequest =
      [[OIDEndSessionRequest alloc] initWithConfiguration: configuration
                                              idTokenHint: idTokenHint
                                    postLogoutRedirectURL: [NSURL URLWithString:postLogoutRedirectURL]
                                     additionalParameters: additionalParameters];

#if TARGET_OS_IPHONE
    id<UIApplicationDelegate, RNAppAuthAuthorizationFlowManager> appDelegate = (id<UIApplicationDelegate, RNAppAuthAuthorizationFlowManager>)[UIApplication sharedApplication].delegate;
#elif TARGET_OS_OSX
    id<NSApplicationDelegate, RNAppAuthAuthorizationFlowManager> appDelegate = (id<NSApplicationDelegate, RNAppAuthAuthorizationFlowManager>)[NSApplication sharedApplication].delegate;
#endif
    if (![[appDelegate class] conformsToProtocol:@protocol(RNAppAuthAuthorizationFlowManager)]) {
        [NSException raise:@"RNAppAuth Missing protocol conformance"
                    format:@"%@ does not conform to RNAppAuthAuthorizationFlowManager", appDelegate];
    }
    appDelegate.authorizationFlowManagerDelegate = self;
    __weak typeof(self) weakSelf = self;

#if TARGET_OS_IPHONE
    rnAppAuthTaskId = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        [UIApplication.sharedApplication endBackgroundTask:rnAppAuthTaskId];
        rnAppAuthTaskId = UIBackgroundTaskInvalid;
    }];

    UIViewController *presentingViewController = appDelegate.window.rootViewController.view.window ? appDelegate.window.rootViewController : appDelegate.window.rootViewController.presentedViewController;
#elif TARGET_OS_OSX
    NSWindow *presentingWindow = [NSApplication sharedApplication].mainWindow;
    if(!presentingWindow){
        reject(@"authentication_failed", @"Unable to get the main window to present an authorization request. Try authenticating again with the main window open.", nil);
        return;
    }
#endif

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    id<OIDExternalUserAgent> externalUserAgent = iosCustomBrowser != nil ? [self getCustomBrowser: iosCustomBrowser] : [self getExternalUserAgentWithPresentingViewController:presentingViewController
                                                                                                                                    prefersEphemeralSession:prefersEphemeralSession];
#elif TARGET_OS_OSX
    id<OIDExternalUserAgent> externalUserAgent = nil;
#endif
    
    _currentSession = [OIDAuthorizationService presentEndSessionRequest: endSessionRequest
                                                      externalUserAgent: externalUserAgent
                                             callback: ^(OIDEndSessionResponse *_Nullable response, NSError *_Nullable error) {
                                                          typeof(self) strongSelf = weakSelf;
                                                          strongSelf->_currentSession = nil;
#if TARGET_OS_IPHONE
                                                          [UIApplication.sharedApplication endBackgroundTask:rnAppAuthTaskId];
                                                          rnAppAuthTaskId = UIBackgroundTaskInvalid;
#elif TARGET_OS_OSX
                                                          // Brings this app to the foreground.
                                                          [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows)];
#endif
                                                          if (response) {
                                                              resolve([self formatEndSessionResponse:response]);
                                                          } else {
                                                            reject([self getErrorCode: error defaultCode:@"end_session_failed"],
                                                                   [self getErrorMessage: error], error);
                                                          }
                                                        }];
}

- (void)configureUrlSession: (NSDictionary*) headers sessionTimeout: (double) sessionTimeout{
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (headers != nil) {
        configuration.HTTPAdditionalHeaders = headers;
    }

    configuration.timeoutIntervalForRequest = sessionTimeout;

    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    [OIDURLSessionProvider setSession:session];
}

/*
 * Take raw OIDAuthorizationResponse and turn it to response format to pass to JavaScript caller
 */
- (NSDictionary *)formatAuthorizationResponse: (OIDAuthorizationResponse *) response withCodeVerifier: (NSString *) codeVerifier {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    if (codeVerifier == nil) {
      return @{@"authorizationCode": response.authorizationCode ? response.authorizationCode : @"",
              @"state": response.state ? response.state : @"",
              @"accessToken": response.accessToken ? response.accessToken : @"",
              @"accessTokenExpirationDate": response.accessTokenExpirationDate ? [dateFormat stringFromDate:response.accessTokenExpirationDate] : @"",
              @"tokenType": response.tokenType ? response.tokenType : @"",
              @"idToken": response.idToken ? response.idToken : @"",
              @"scopes": response.scope ? [response.scope componentsSeparatedByString:@" "] : [NSArray new],
              @"additionalParameters": response.additionalParameters,
              };
    } else {
      return @{@"authorizationCode": response.authorizationCode ? response.authorizationCode : @"",
            @"state": response.state ? response.state : @"",
            @"accessToken": response.accessToken ? response.accessToken : @"",
            @"accessTokenExpirationDate": response.accessTokenExpirationDate ? [dateFormat stringFromDate:response.accessTokenExpirationDate] : @"",
            @"tokenType": response.tokenType ? response.tokenType : @"",
            @"idToken": response.idToken ? response.idToken : @"",
            @"scopes": response.scope ? [response.scope componentsSeparatedByString:@" "] : [NSArray new],
            @"additionalParameters": response.additionalParameters,
            @"codeVerifier": codeVerifier
            };
    }
}

/*
 * Take raw OIDTokenResponse and turn it to a token response format to pass to JavaScript caller
 */
- (NSDictionary*)formatResponse: (OIDTokenResponse*) response {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    return @{@"accessToken": response.accessToken ? response.accessToken : @"",
             @"accessTokenExpirationDate": response.accessTokenExpirationDate ? [dateFormat stringFromDate:response.accessTokenExpirationDate] : @"",
             @"additionalParameters": response.additionalParameters,
             @"idToken": response.idToken ? response.idToken : @"",
             @"refreshToken": response.refreshToken ? response.refreshToken : @"",
             @"tokenType": response.tokenType ? response.tokenType : @"",
             };
}

/*
 * Take raw OIDTokenResponse and additional paramaeters from an OIDAuthorizationResponse
 *  and turn them into an extended token response format to pass to JavaScript caller
 */
- (NSDictionary*)formatResponse: (OIDTokenResponse*) response
       withAuthResponse:(OIDAuthorizationResponse*) authResponse {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    return @{@"accessToken": response.accessToken ? response.accessToken : @"",
             @"accessTokenExpirationDate": response.accessTokenExpirationDate ? [dateFormat stringFromDate:response.accessTokenExpirationDate] : @"",
             @"authorizeAdditionalParameters": authResponse.additionalParameters,
             @"tokenAdditionalParameters": response.additionalParameters,
             @"idToken": response.idToken ? response.idToken : @"",
             @"refreshToken": response.refreshToken ? response.refreshToken : @"",
             @"tokenType": response.tokenType ? response.tokenType : @"",
             @"scopes": authResponse.scope ? [authResponse.scope componentsSeparatedByString:@" "] : [NSArray new],
             };
}

- (NSDictionary*)formatRegistrationResponse: (OIDRegistrationResponse*) response {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    return @{@"clientId": response.clientID,
             @"additionalParameters": response.additionalParameters,
             @"clientIdIssuedAt": response.clientIDIssuedAt ? [dateFormat stringFromDate:response.clientIDIssuedAt] : @"",
             @"clientSecret": response.clientSecret ? response.clientSecret : @"",
             @"clientSecretExpiresAt": response.clientSecretExpiresAt ? [dateFormat stringFromDate:response.clientSecretExpiresAt] : @"",
             @"registrationAccessToken": response.registrationAccessToken ? response.registrationAccessToken : @"",
             @"registrationClientUri": response.registrationClientURI ? response.registrationClientURI : @"",
             @"tokenEndpointAuthMethod": response.tokenEndpointAuthenticationMethod ? response.tokenEndpointAuthenticationMethod : @"",
             };
}

- (NSDictionary*)formatEndSessionResponse: (OIDEndSessionResponse*)response
{
    return @{@"state": response.state ? response.state : @"",
             @"idTokenHint": response.request.idTokenHint,
             @"postLogoutRedirectUri": response.request.postLogoutRedirectURL.absoluteString
             };
}

- (NSString*)getErrorCode: (NSError*) error defaultCode: (NSString *) defaultCode {
    if ([[error domain] isEqualToString:OIDOAuthAuthorizationErrorDomain]) {
        switch ([error code]) {
            case OIDErrorCodeOAuthAuthorizationInvalidRequest:
              return @"invalid_request";
            case OIDErrorCodeOAuthAuthorizationUnauthorizedClient:
              return @"unauthorized_client";
            case OIDErrorCodeOAuthAuthorizationAccessDenied:
              return @"access_denied";
            case OIDErrorCodeOAuthAuthorizationUnsupportedResponseType:
              return @"unsupported_response_type";
            case OIDErrorCodeOAuthAuthorizationAuthorizationInvalidScope:
              return @"invalid_scope";
            case OIDErrorCodeOAuthAuthorizationServerError:
              return @"server_error";
            case OIDErrorCodeOAuthAuthorizationTemporarilyUnavailable:
              return @"temporarily_unavailable";
        }
    } else if ([[error domain] isEqualToString:OIDOAuthTokenErrorDomain]) {
        switch ([error code]) {
            case OIDErrorCodeOAuthTokenInvalidRequest:
              return @"invalid_request";
            case OIDErrorCodeOAuthTokenInvalidClient:
              return @"invalid_client";
            case OIDErrorCodeOAuthTokenInvalidGrant:
              return @"invalid_grant";
            case OIDErrorCodeOAuthTokenUnauthorizedClient:
              return @"unauthorized_client";
            case OIDErrorCodeOAuthTokenUnsupportedGrantType:
              return @"unsupported_grant_type";
            case OIDErrorCodeOAuthTokenInvalidScope:
              return @"invalid_scope";
        }
    } else if ([[error domain] isEqualToString:OIDOAuthRegistrationErrorDomain]) {
        switch ([error code]) {
            case OIDErrorCodeOAuthRegistrationInvalidRequest:
              return @"invalid_request";
            case OIDErrorCodeOAuthRegistrationInvalidRedirectURI:
              return @"invalid_redirect_uri";
            case OIDErrorCodeOAuthRegistrationInvalidClientMetadata:
              return @"invalid_client_metadata";
        }
    }

    return defaultCode;
}

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
- (id<OIDExternalUserAgent>)getCustomBrowser: (NSString *) browserType {
    typedef id<OIDExternalUserAgent> (^BrowserBlock)(void);

    NSDictionary *browsers = @{
        @"safari":
            ^{
                return [OIDExternalUserAgentIOSCustomBrowser CustomBrowserSafari];
            },
        @"chrome":
            ^{
                return [OIDExternalUserAgentIOSCustomBrowser CustomBrowserChrome];
            },
        @"opera":
            ^{
                return [OIDExternalUserAgentIOSCustomBrowser CustomBrowserOpera];
            },
        @"firefox":
            ^{
                return [OIDExternalUserAgentIOSCustomBrowser CustomBrowserFirefox];
            }
    };
    BrowserBlock browser = browsers[browserType];
    return browser();
}
#endif

- (NSString*)getErrorMessage: (NSError*) error {
    NSDictionary * userInfo = [error userInfo];

    if (userInfo &&
        userInfo[OIDOAuthErrorResponseErrorKey] &&
        userInfo[OIDOAuthErrorResponseErrorKey][OIDOAuthErrorFieldErrorDescription]) {
        return userInfo[OIDOAuthErrorResponseErrorKey][OIDOAuthErrorFieldErrorDescription];
    } else {
        return [error localizedDescription];
    }
}

#if TARGET_OS_IPHONE
- (id<OIDExternalUserAgent>)getExternalUserAgentWithPresentingViewController: (UIViewController *)presentingViewController
                                                     prefersEphemeralSession: (BOOL) prefersEphemeralSession
#elif TARGET_OS_OSX
- (id<OIDExternalUserAgent>)getExternalUserAgentWithPresentingWindow: (NSWindow *)presentingWindow
                                             prefersEphemeralSession: (BOOL) prefersEphemeralSession
#endif
{
  id<OIDExternalUserAgent> externalUserAgent;
  #if TARGET_OS_MACCATALYST
    externalUserAgent = [[OIDExternalUserAgentCatalyst alloc] initWithPresentingViewController:presentingViewController];
  #elif TARGET_OS_IPHONE
    if (@available(iOS 13, *)) {
        externalUserAgent = [[OIDExternalUserAgentIOS alloc] initWithPresentingViewController:
                             presentingViewController
                             prefersEphemeralSession:prefersEphemeralSession];
    } else {
        externalUserAgent = [[OIDExternalUserAgentIOS alloc] initWithPresentingViewController:
                             presentingViewController];
    }
  #elif TARGET_OS_OSX
    if (@available(macOS 10.15, *)) {
        externalUserAgent = [[OIDExternalUserAgentMac alloc] initWithPresentingWindow:presentingWindow];
    } else {
        externalUserAgent = [[OIDExternalUserAgentMac alloc] init];
    }
  #endif
  return externalUserAgent;
}

@end
