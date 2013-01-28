//
//  ViewController.m
//  FacebookTest
//
//  Created by Yaniv Marshaly on 1/28/13.
//  Copyright (c) 2013 SketchHeroes LTD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self updateUI];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didPressLogin:(id)sender {
    
    
    
    
    if ([Facebook isSessionOpen]) {
        
        [Facebook logout];
    }else{
        
        [Facebook loginWithPermissions:@[@"publish_stream"] successBlock:^(id result) {
           
            [self updateUI];
            
        } failedBlock:^(NSError *error) {
            
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:error.localizedDescription
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
        }];
    }
    
    
}
-(void)updateUI
{
    if ([Facebook isSessionOpen]) {
        [self.loginLogoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    }else{
        [self.loginLogoutButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}
@end
