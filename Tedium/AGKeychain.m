//
// AGKeychain.m
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


#import "AGKeychain.h"

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

@implementation AGKeychain



+ (BOOL)checkForExistanceOfKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withAddress:(NSString *) address
{
	SecKeychainSearchRef search;
	SecKeychainItemRef item;
	SecKeychainAttributeList list;
	SecKeychainAttribute attributes[4];
    OSErr result;
    int numberOfItemsFound = 0;
	
	attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[username UTF8String];
    attributes[0].length = [[NSNumber numberWithUnsignedLong:[username length]] unsignedIntValue];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [[NSNumber numberWithUnsignedLong:[keychainItemKind length]] unsignedIntValue];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [[NSNumber numberWithUnsignedLong:[keychainItemName length]] unsignedIntValue];
    
    attributes[3].tag = kSecServerItemAttr;
    attributes[3].data = (void *)[address UTF8String];
    attributes[3].length = [[NSNumber numberWithUnsignedLong:[address length]] unsignedIntValue];

    list.count = 4;
    list.attr = attributes;

    result = SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, &list, &search);

    if (result != noErr) {
        NSLog (@"status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }
    
	while (SecKeychainSearchCopyNext (search, &item) == noErr) {
        CFRelease (item);
        numberOfItemsFound++;
    }
	
	NSLog(@"%d items found\n", numberOfItemsFound);
    CFRelease (search);
	return numberOfItemsFound;
}

+ (BOOL)deleteKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withAddress:(NSString *)address
{
	SecKeychainAttribute attributes[3];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
	SecKeychainSearchRef search;
    OSStatus status;
	OSErr result;
	int numberOfItemsFound = 0;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[username UTF8String];
    attributes[0].length = [[NSNumber numberWithUnsignedLong:[username length]] unsignedIntValue];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [[NSNumber numberWithUnsignedLong:[keychainItemKind length]] unsignedIntValue];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [[NSNumber numberWithUnsignedLong:[keychainItemName length]] unsignedIntValue];
    
    attributes[3].tag = kSecServerItemAttr;
    attributes[3].data = (void *)[address UTF8String];
    attributes[3].length = [[NSNumber numberWithUnsignedLong:[address length]] unsignedIntValue];

    list.count = 3;
    list.attr = attributes;
	
	result = SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, &list, &search);
	while (SecKeychainSearchCopyNext (search, &item) == noErr) {
        numberOfItemsFound++;
    }
	if (numberOfItemsFound) {
		status = SecKeychainItemDelete(item);
	}
	
    if (status != 0) {
        NSLog(@"Error deleting item: %d\n", (int)status);
    }
	CFRelease (item);
	CFRelease(search);
	return !status;
}

+ (BOOL)modifyKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withNewPassword:(NSString *)newPassword withAddress:(NSString *)address
{
	SecKeychainAttribute attributes[3];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
	SecKeychainSearchRef search;
    OSStatus status;
	OSErr result;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[username UTF8String];
    attributes[0].length = [[NSNumber numberWithUnsignedLong: [username length]] unsignedIntValue];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [[NSNumber numberWithUnsignedLong:[keychainItemKind length]] unsignedIntValue];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [[NSNumber numberWithUnsignedLong:[keychainItemName length]] unsignedIntValue];
    
    attributes[3].tag = kSecServerItemAttr;
    attributes[3].data = (void *)[address UTF8String];
    attributes[3].length = [[NSNumber numberWithUnsignedLong:[address length]] unsignedIntValue];

    list.count = 3;
    list.attr = attributes;
	
	result = SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, &list, &search);
	SecKeychainSearchCopyNext (search, &item);
    status = SecKeychainItemModifyContent(item, &list, [[NSNumber numberWithUnsignedLong:[newPassword length]] unsignedIntValue], [newPassword UTF8String]);
	
    if (status != 0) {
        NSLog(@"Error modifying item: %d", (int)status);
    }
	CFRelease (item);
	CFRelease(search);
	return !status;
}

+ (BOOL)addKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withPassword:(NSString *)password withAddress:(NSString *)address
{
	SecKeychainAttribute attributes[4];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
    OSStatus status;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[username UTF8String];
    attributes[0].length = [[NSNumber numberWithUnsignedLong:[username length]] unsignedIntValue];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [[NSNumber numberWithUnsignedLong:[keychainItemKind length]] unsignedIntValue];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [[NSNumber numberWithUnsignedLong:[keychainItemName length]] unsignedIntValue];
    
    

    list.count = 4;
    list.attr = attributes;

    status = SecKeychainItemCreateFromContent(kSecInternetPasswordItemClass, &list, [[NSNumber numberWithUnsignedLong:[password length]] unsignedIntValue], [password UTF8String], NULL,NULL,&item);
    if (status != 0) {
        NSLog(@"Error creating new item: %d\n", (int)status);
    }
	return !status;
}

+ (NSString *)getPasswordFromKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withAddress:(NSString *)address
{
    SecKeychainSearchRef search;
    SecKeychainItemRef item;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[4];
    OSErr result;

	attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[username UTF8String];
    attributes[0].length = [[NSNumber numberWithUnsignedLong:[username length]] unsignedIntValue];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [[NSNumber numberWithUnsignedLong:[keychainItemKind length]] unsignedIntValue];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [[NSNumber numberWithUnsignedLong:[keychainItemName length]] unsignedIntValue];
    
    attributes[3].tag = kSecServerItemAttr;
    attributes[3].data = (void *)[address UTF8String];
    attributes[3].length = [[NSNumber numberWithUnsignedLong:[address length]] unsignedIntValue];

    list.count = 4;
    list.attr = attributes;

    result = SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, &list, &search);

    if (result != noErr) {
        NSLog (@"status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }
	
	NSString *password = @"";
    if (SecKeychainSearchCopyNext (search, &item) == noErr) {
		password = [self getPasswordFromSecKeychainItemRef:item];
		if(!password) {
			password = @"";
		}
		CFRelease(item);
		CFRelease (search);
	}
	return password;
}

+ (NSString *)getPasswordFromSecKeychainItemRef:(SecKeychainItemRef)item
{
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
    OSStatus status;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
 
    list.count = 4;
    list.attr = attributes;

    status = SecKeychainItemCopyContent (item, NULL, &list, &length, 
                                         (void **)&password);

    // use this version if you don't really want the password,
    // but just want to peek at the attributes
    //status = SecKeychainItemCopyContent (item, NULL, &list, NULL, NULL);
    
    // make it clear that this is the beginning of a new
    // keychain item
    if (status == noErr) {
        if (password != NULL) {

            // copy the password into a buffer so we can attach a
            // trailing zero byte in order to be able to print
            // it out with printf
            char passwordBuffer[1024];

            if (length > 1023) {
                length = 1023; // save room for trailing \0
            }
            strncpy (passwordBuffer, password, length);

            passwordBuffer[length] = '\0';
			//printf ("passwordBuffer = %s\n", passwordBuffer);
			return [NSString stringWithUTF8String:passwordBuffer];
        }

        SecKeychainItemFreeContent (&list, password);

    } else {
        printf("Error = %d\n", (int)status);
		return @"Error getting password";
    }
    return @"reached end of method and shouldn't have, yay you!";
}



@end
