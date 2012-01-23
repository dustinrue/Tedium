//
// Originally AGKeychain.h
// Based on code from "Core Mac OS X and Unix Programming"
// by Mark Dalrymple and Aaron Hillegass
// http://borkware.com/corebook/source-code
//
// Created by Adam Gerson on 3/6/05.
// agerson@mac.com
//
// Updated 1/22/2012 by Dustin Rue silence compiler warnings
// and work with Tedium
// ruedu@dustinrue.com
//

#import <Cocoa/Cocoa.h>


@interface KeychainServices : NSObject {

}
+ (NSString *)getPasswordFromSecKeychainItemRef:(SecKeychainItemRef)item;
+ (BOOL)checkForExistanceOfKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withAddress:(NSString *) address;
+ (BOOL)modifyKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withNewPassword:(NSString *)newPassword withAddress:(NSString *)address;
+ (BOOL)deleteKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withAddress:(NSString *)address;
+ (BOOL)addKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withPassword:(NSString *)password withAddress:(NSString *)address;
+ (NSString *)getPasswordFromKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withAddress:(NSString *)address;
+ (NSString *)getPasswordFromSecKeychainItemRef:(SecKeychainItemRef)item;
@end
