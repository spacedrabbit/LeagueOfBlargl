//
//  SummonerAPIRequests.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"

@interface SummonerAPIRequests : RiotAPIManager

-(void) searchForSummonersByName:(NSString *) summonersSearch completion:(void(^)(BOOL, NSArray *))complete;

@end
