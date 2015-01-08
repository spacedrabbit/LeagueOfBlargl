//
//  RiotStaticRequest.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/8/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"
#import <UIKit/UIKit.h>

@class Summoners;
@interface RiotStaticRequest : RiotAPIManager

-(void) retrieveStaticDataFor:(Summoners *)summoner completion:(void(^)(BOOL , UIImage *))complete;

@end
