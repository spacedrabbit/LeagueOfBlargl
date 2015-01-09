//
//  SummonerAPIRequests.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//
#import "RiotDataManager.h"
#import "SummonerAPIRequests.h"

@implementation SummonerAPIRequests

-(void)searchForSummonersByName:(NSString *)summonersSearch completion:(void (^)(BOOL, NSArray *))complete{
    
    NSURL * requestURL = [self createURLStringForRegion:self.currentRegion
                                                   apiVersion:@"v1.4"
                                                    queryType:summonerName
                                                     andQuery:summonersSearch];
    [self makeRiotAPIRequest:requestURL
                  completion:^(BOOL success, NSDictionary * jsonResponse)
    {
        if (success) {
            [[RiotDataManager sharedManager] createSummonersFromRawJSON:jsonResponse];
        }
    }];
    
    
    
}

@end
