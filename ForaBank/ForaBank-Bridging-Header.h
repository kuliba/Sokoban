//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef ForaBank_Bridging_Header_h
#define ForaBank_Bridging_Header_h

#import "CardIO.h"

#endif /* ForaBank_Bridging_Header_h */
@import UIKit;
@import TOPasscodeViewController;

@interface TOPasscodeViewController(PrivateMethods)

- (void)keypadButtonTapped;
- (void)setUpAccessoryButtons;

@end
