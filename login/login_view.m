//
//  login_view.m
//  login
//
//  Created by Vincenzo on 21/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "login_view.h"
#import "MACRO.h"
@interface login_view ()

@end

@interface login_view ()
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end

@implementation login_view

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(loginUrl == NULL || spotsUrl == NULL) return NULL;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        images = [[NSMutableArray alloc] init];
        urls = [[NSMutableArray alloc]init];
        index = 0;
        mask = NULL;
        bundle = nibBundleOrNil;
        
    }
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSpotsUrl:(NSString*)urlSpots andLoginUrl:(NSString*)urlLogin
{
    
    if([NSURL URLWithString:urlLogin] == NULL) return NULL; //Se non è stato passato un url corretto per il loginritorna un oggetto NULL;
    
    else
    {
        loginUrl = urlLogin;
        spotsUrl = urlSpots;
        
        return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    
}



- (IBAction)showingLogin
{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if([mask superview] == NULL){
            [self.view addSubview:mask];
            [self.view addSubview:loginView];
        }
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            [mask setAlpha:1.0];
            [loginView setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Inizializzazione della maschera per il modale
    mask = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    [mask setBackgroundColor:[UIColor grayColor]];
    
    //Inizializzazione per la finestra di login
    loginView.frame = CGRectMake((self.view.frame.size.width/2) - (loginView.frame.size.width/2), (self.view.frame.size.height/2) - (loginView.frame.size.height/2) - 50, loginView.frame.size.width, loginView.frame.size.height);
    
    CALayer * loginBorder = [loginView layer];
    [loginBorder setMasksToBounds:YES];
    [loginBorder setCornerRadius:10];
    [loginBorder setBorderWidth:1.0];
    [loginBorder setBorderColor:[[UIColor whiteColor]CGColor]];
    [mask setAlpha:0.0];
    [loginView setAlpha:0.0];
    
    
    //Inizializzazione della notification view
    
    CALayer *notificationLayer = [notificationView layer];
    [notificationLayer setMasksToBounds:YES];
    [notificationLayer setCornerRadius:10.0];
    
    [notificationView setBackgroundColor:NORMALSTATUS];
    [notificationText setText:NSLocalizedString(@"INSERT CREDENTIALS", NULL)];
    
    
    NSURL *url = [NSURL URLWithString:spotsUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        number_images = [responseObject count];
        if([responseObject count]>0){
            [scroll setContentSize:CGSizeMake((scroll.frame.size.width) * [responseObject count], scroll.frame.size.height)];
            
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [urls insertObject:obj atIndex:idx];
                
                NSURL *ul = [[NSURL alloc] initWithString:[urls objectAtIndex:idx]];
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((scroll.frame.size.width ) * idx, 0, scroll.frame.size.width  , scroll.frame.size.height )];
                
                [images insertObject:img atIndex:idx];
                
                
                

                
                
                UIImage *imageFromMyLibraryBundle = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:@"placeholder.png"]];

                
                [img setImageWithURL:ul placeholderImage:imageFromMyLibraryBundle];
                imageFromMyLibraryBundle = NULL;
                
                //Bordi arrotondati
                CALayer * l = [img layer];
                [l setMasksToBounds:YES];
                [l setCornerRadius:10];
                
                
                
                scroll.center = framePicture.center;
                
                [scroll addSubview:img];
                
                
                
                
                
            }];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error	);
    }];
    [operation start];
    
    
    
}


-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	const CGFloat currPos = scrollView.contentOffset.x;
	const NSInteger selectedPage = lroundf(currPos / scroll.frame.size.width);
    
}


#pragma -- Keyboard Hidding

//Metodi per scorrere la view quando appare la tastiera


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(IBAction) slideFrameUp
{
    [self slideFrame:YES];
}

-(IBAction) slideFrameDown
{
    [self slideFrame:NO];
}

-(void) slideFrame:(BOOL) up
{
    const int movementDistance = 70; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma closing loginview

-(IBAction)dismissingLoginView
{
    
    
    [UIView animateWithDuration:1.0 animations:^{
        
        [mask setAlpha:0];
        [loginView setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        
        
    }];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma login authentication


-(IBAction)signIn:(id)sender
{
    //Controllo su entrambi i campi (user e pwd)
    NSString *us = [[username text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *pwd =[[password text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if([us length]>0 &&
       [pwd length]>0)
    {
        //Prova la connessione
        
        
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"username": us,
                                     @"password": pwd
                                     };
        [manager POST:loginUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if([responseObject objectForKey:@"RETURNCODE"] != Nil && [[responseObject objectForKey:@"RETURNCODE"]  isEqual: @"0"]){
                
                if(self.delegate != Nil &&
                   [delegate respondsToSelector:@selector(loginSuccess:)]){
                    
                    [self.delegate loginSuccess:responseObject];
                }
                
            }
            else{
                
                if([responseObject objectForKey:@"RETURNCODE"] != Nil && [[responseObject objectForKey:@"RETURNCODE"]  isEqual: @"-1"])
                {
                    //credenziali errate
                    UIAlertView *errorMessage = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"WRONG CREDENTIALS", NULL) message:NSLocalizedString(@"WRONG CREDENTIALS", NULL) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                    
                    [errorMessage show];
                }
                else{
                    //Generico errore
                    if(self.delegate != Nil &&
                       [delegate respondsToSelector:@selector(loginError:)]){
                        
                        [self.delegate loginError:responseObject];
                    }
                }
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *errorMessage = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NETWORK ERROR", NULL) message:NSLocalizedString(@"NETWORK ERROR MESSAGE", NULL) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [errorMessage show];
        }];
        
        
        
        
    }
    else{
        UIAlertView *errorMessage = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"CREDENTIALS VOID", NULL) message:NSLocalizedString(@"CREDENTIALS REQUIRED", NULL) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        
        [errorMessage show];
    }
    
    
    
}
@end
