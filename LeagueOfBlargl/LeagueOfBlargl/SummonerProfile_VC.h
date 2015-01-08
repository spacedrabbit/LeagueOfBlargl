//
//  SummonerProfile_VC.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/7/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Summoners;
@interface SummonerProfile_VC : UIViewController <UITableViewDataSource>

-(instancetype) initWithSummoner:(Summoners *)selectedSummoner;
-(void) displayDetailsForSummoner:(Summoners *)selectedSummoner;

@end
