//
//  SummonerAPIRequests.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"

@interface SummonerAPIRequests : RiotAPIManager

//update this to include id calls
-(void) searchForSummonersByName:   (NSString *) summonersSearch    completion:(void(^)(void))complete;
-(void) searchForSummonersByID:     (NSString *) summonerIDSearch   completion:(void(^)(void))complete;
-(void) searchMasteriesForSummoner: (NSString *) summonerID         completion:(void(^)(void))complete;
-(void) searchRunesForSummoner:     (NSString *) summonerID         completion:(void(^)(void))complete;

@end
