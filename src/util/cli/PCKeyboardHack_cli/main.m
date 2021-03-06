@import Cocoa;
#import "PCKeyboardHackClient.h"

@interface PCKeyboardHackCLI : NSObject

- (void) main;

@end

@implementation PCKeyboardHackCLI

- (void) output:(NSString*)string
{
  NSFileHandle* fh = [NSFileHandle fileHandleWithStandardOutput];
  [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) usage
{
  [self output:@"Usage:\n"];
  [self output:@"  PCKeyboardHack_cli export\n"];
  [self output:@"  PCKeyboardHack_cli relaunch\n"];
  [self output:@"  PCKeyboardHack_cli set IDENTIFIER VALUE\n"];
  [self output:@"\n"];
  [self output:@"Example:\n"];
  [self output:@"  PCKeyboardHack_cli export\n"];
  [self output:@"  PCKeyboardHack_cli relaunch\n"];
  [self output:@"  PCKeyboardHack_cli set keycode_capslock 80\n"];

  [[NSApplication sharedApplication] terminate:nil];
}

- (void) export:(PCKeyboardHackClient*)client
{
  NSArray* arguments = [[NSProcessInfo processInfo] arguments];
  NSDictionary* dict = [[client proxy] allValues];

  [self output:@"#!/bin/sh\n\n"];
  [self output:[NSString stringWithFormat:@"cli=%@\n\n", arguments[0]]];

  for (NSString* key in [dict allKeys]) {
    [self output:[NSString stringWithFormat:@"$cli set %@ %@\n", key, dict[key]]];
    [self output:@"/bin/echo -n .\n"];
  }
}

- (void) main
{
  NSArray* arguments = [[NSProcessInfo processInfo] arguments];

  if ([arguments count] == 1) {
    [self usage];
  } else {
    @try {
      PCKeyboardHackClient* client = [PCKeyboardHackClient new];
      NSString* command = arguments[1];

      /*  */ if ([command isEqualToString:@"export"]) {
        [self export:client];
      } else if ([command isEqualToString:@"relaunch"]) {
        [[client proxy] relaunch];
      } else if ([command isEqualToString:@"set"]) {
        if ([arguments count] != 4) {
          [self usage];
        }
        NSString* identifier = arguments[2];
        NSString* value = arguments[3];
        [[client proxy] setValue:[value intValue] forName:identifier];
      }
    } @catch (NSException* exception) {
      NSLog(@"%@", exception);
    }
  }
}

@end

int
main(int argc, const char* argv[])
{
  [[PCKeyboardHackCLI new] main];
  return 0;
}
