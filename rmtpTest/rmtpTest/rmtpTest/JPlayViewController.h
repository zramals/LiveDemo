//
//  JPlayViewController.h
//  rmtpTest
//
//  Created by 荆博zramals on 2019/12/23.
//  Copyright © 2019 LAP0332180314. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface JPlayViewController : UIViewController

@property(atomic,strong) NSURL *url;
@property(atomic, retain) id<IJKMediaPlayback> player;

- (id)initWithURL:(NSURL *)url;
@end

