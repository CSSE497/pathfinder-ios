/*
 * GITAuth.h
 * Identity Toolkit iOS SDK
 *
 * Copyright (c) 2014 Google Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class GITAccount;
@protocol GITAuthDelegate;

/**
 * A singleton class that handles authentication with IdPs and Identity Toolkit server.
 */
@interface GITAuth : NSObject

/** Delegate for handling user interface and receiving sign in result. */
@property(nonatomic, weak) id<GITAuthDelegate> delegate;
/** Email address to be verified by another IdP in account linking flow. */
@property(nonatomic, copy) NSString *pendingEmail;
/** The pending id token to be verified by another IdP in account linking flow. */
@property(nonatomic, copy) NSString *pendingIDToken;

/**
 * Returns a shared |GITAuth| instance.
 */
+ (GITAuth *)sharedInstance;

/**
 * Signs user in using saved account as hint.
 */
- (void)signInWithSavedAccount;

/**
 * Signs user in using an email address as hint.
 *
 * @param email User's email address, should not be |nil|.
 */
- (void)signInWithEmail:(NSString *)email;

/**
 * Signs user in with the given identity provider, allowing the login UI to show.
 *
 * @param providerID The ID of the provider, ex. google.com, facebook.com.
 */
- (void)signInWithProviderID:(NSString *)providerID;

/**
 * Signs user in with the given identity provider with the login UI to show controlled by the flag
 * |interactively|.
 *
 * @param providerID The ID of the provider, ex. google.com, facebook.com.
 * @param interactively YES if the login UI is allowed to show, NO otherwise.
 */
- (void)signInWithProviderID:(NSString *)providerID interactively:(BOOL)interactively;

/**
 * Signs the user out of cached IdP sessions. Currently only Google and Facebook support cached
 * sessions.
 */
- (void)signOut;

/**
 * Calls Identity Toolkit server to verify user's password.
 *
 * @param password User's password, should not be |nil|.
 * @param email User's email address, should not be |nil|.
 * @param invalidCallback Block called when the password is invalid.
 */
- (void)verifyPassword:(NSString *)password
              forEmail:(NSString *)email
       invalidCallback:(void (^)())invalidCallback;

/**
 * Calls Identity Toolkit server to sign up a password user.
 *
 * @param email User's email address, should not be |nil|.
 * @param displayName User's display name, should not be |nil|.
 * @param password User's password, should not be |nil|.
 */
- (void)signUpWithEmail:(NSString *)email
            displayName:(NSString *)displayName
               password:(NSString *)password;

/**
 * Starts account linking for a federated account. The user will be send to system browser to
 * finish the linking process.
 *
 * @param toProvider The provider ID of an IdP to be verified.
 * @param fromProvider The provider ID of an IdP the user has previously signed in with.
 */
- (void)linkAccountToProviderID:(NSString *)toProvider fromProviderID:(NSString *)fromProvider;

/**
 * Starts account linking for a password account. The password should have been collected from the
 * user before calling this method.
 *
 * @param password The password collect from the user, which is to be verified.
 * @param invalidCallback Block called when the password is invalid.
 */
- (void)linkAccountWithPassword:(NSString *)password invalidCallback:(void (^)())invalidCallback;

@end
