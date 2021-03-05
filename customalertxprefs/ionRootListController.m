#import "ionRootListController.h"

@implementation ionRootListController


- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}


- (void)followButtonPress {
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"twitter://user?screen_name=_justincarlson"]];
}

@end
