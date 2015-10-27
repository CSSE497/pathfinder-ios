/*
 * GITClient.h
 * Identity Toolkit iOS SDK
 *
 * Copyright (c) 2014 Google Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class GITAccount;
@class GITClient;

/** Provider ID of Google. */
extern NSString * const kGITProviderGoogle;
/** Provider ID of Facebook. */
extern NSString * const kGITProviderFacebook;
/** Provider ID of Yahoo. */
extern NSString * const kGITProviderYahoo;
/** Provider ID of PayPal. */
extern NSString * const kGITProviderPaypal;
/** Provider ID of Microsoft. */
extern NSString * const kGITProviderMicrosoft;
/** Provider ID of AOL. */
extern NSString * const kGITProviderAOL;

/** Error codes in Identity Toolkit error domain. */
typedef enum {
  /** Default error code. */
  kGITErrorCodeUnknown = -1,
  /** User cancels authentication. */
  kGITErrorCodeUserCancellation = -100,
  /** User cannot sign in silently. */
  kGITErrorCodeCannotSignInSilently = -101,
  /** The email asserted by IdP does not match the user input email. */
  kGITErrorCodeEmailMismatch = -200,
  /** The email to sign up already exists. */
  kGITErrorCodeEmailExists = -201,
  /** Unexpected response from Identity Toolkit API. */
  kGITErrorCodeApiUnexpectedResponse = -300,
  /** Insecure (non-HTTPS) request, which cannot be authorized. */
  kGITErrorCodeInsecureRequest = -400,
  /** GetToken failure. */
  kGITErrorCodeGetTokenFailure = -401,
} GITErrorCode;

/**
 * A protocol implemented by the client of |GITClient| to receive signed in account.
 */
@protocol GITClientDelegate

/**
 * The authentication has finished and is successful if |error| is |nil|.
 */
- (void)client:(GITClient *)client
    didFinishSignInWithToken:(NSString *)token
                     account:(GITAccount *)account
                       error:(NSError *)error;

@end

/**
 * A singleton class that works as client for Identity Toolkit.
 */
@interface GITClient : NSObject

/** The API key of the Identity Toolkit project in Google Cloud Console. */
@property(nonatomic, copy) NSString *apiKey;
/** Where the Identity Toolkit Javascript widget is hosted. */
@property(nonatomic, copy) NSString *widgetURL;
/** An array of provider IDs to support on this app. */
@property(nonatomic, strong) NSArray *providers;
/** Whether to request access to social features for Google users. */
@property(nonatomic, assign) BOOL useGooglePlus;
/** The object to be notified at the end of an authentication operation. */
@property(nonatomic, weak) id<GITClientDelegate> delegate;

/** Returns a shared |GITClient| instance. */
+ (GITClient *)sharedInstance;

/** Handles callback from system browser. */
+ (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;

/**
 * Adds additional scopes for an identity provider.
 * Note that this only works for Google and Facebook.
 *
 * @param scopes An NSArray of scopes as NSStrings.
 * @param providerId The ID of the identity provider.
 */
- (void)setAdditionalScopes:(NSArray *)scopes forProvider:(NSString *)providerId;

/**
 * Gets additional scopes for an identity provider, could be |nil|.
 */
- (NSArray *)additionalScopesForProvider:(NSString *)providerId;

@end
