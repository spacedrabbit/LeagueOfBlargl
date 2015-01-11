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

-(void)searchSummoners:(NSString *)searchQuery byType:(LoLSearchType)searchType {
    
    NSURL * requestURL = [self createURLStringForRegion:self.currentRegion
                                             apiVersion:@"v1.4"
                                              queryType:searchType
                                               andQuery:searchQuery];
    [self makeRiotAPIRequest:requestURL
                  completion:^(BOOL success, NSDictionary * jsonResponse)
     {
         if (success) {
             [[RiotDataManager sharedManager] createSummonersFromRawJSON:jsonResponse];
         }
     }];
  
}
-(void)searchForSummonersByName:(NSString *)summonersSearch completion:(void (^)(void))complete{
    [self searchSummoners:summonersSearch byType:LoLSearchTypeSummonerName];
}
-(void)searchForSummonersByID:(NSString *)summonerIDSearch completion:(void (^)(void))complete{
    [self searchSummoners:summonerIDSearch byType:LoLSearchTypeSummonerID];
}




-(void)searchRunesForSummoner:(NSString *)summonerID completion:(void (^)(void))complete{
    
}
-(void)searchMasteriesForSummoner:(NSString *)summonerID completion:(void (^)(void))complete{
    
}


@end
