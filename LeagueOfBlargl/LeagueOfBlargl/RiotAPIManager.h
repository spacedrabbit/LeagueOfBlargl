//
//  RiotAPIManager.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

// -- TYPEDEF REFERENCE VALUES -- //
typedef NS_ENUM(NSInteger, LoLRegions) {
    northAmerica = 0,
    global,
    oceanic,
    korea,
    euNordic,
    euWest
};
typedef NS_ENUM(NSInteger, LoLSearchType) {
    LoLSearchTypeSummonerName = 0,
    LoLSearchTypeSummonerID,
    LoLSearchTypeStatic_data,
    LoLSearchTypeSummonerMasteries,
    LoLSearchTypeSummonerRunes
};
typedef NS_ENUM(NSInteger, LoLStatusCodes) {
    lolGood = 200,
    lolLimitExceeded = 429,
    lolServerBusy = 503,
    lolResponseUnmodified = 304,
    lolRequestNotFound = 404
};

typedef NSString* SummonerName, SummonerID, StaticData;

// -- TYPEDEF REFERENCE VALUES -- //


@class Summoners;
@interface RiotAPIManager : NSObject

+(instancetype) sharedManager;

-(void) makeRiotAPIRequest:(NSURL *)requestURL
                completion:(void(^)(BOOL, NSDictionary *))complete;

-(void) beginRequestWithURL:(NSURL *)urlString
                withSuccess:(void(^)(NSDictionary *))success
                    orError:(void(^)(NSDictionary *))error;

-(NSURL *) createURLStringForRegion:(LoLRegions)region
                            apiVersion:(NSString *)version
                             queryType:(LoLSearchType)type
                              andQuery:(NSString *)query;

-(void) searchRiotFor:(LoLSearchType)type
            withQuery:(NSString *)query
            forRegion:(LoLRegions)region
       withCompletion:(void(^)(NSDictionary *))completion;

// -- helpers -- //
-(void) changeRegionTo:(LoLRegions)region;
-(LoLRegions) currentRegion;
-(NSArray *) priorSearches;

// -- Static API Calls - //
-(void) makeProfileIconCallFor:(Summoners *)summoner completion:(void(^)(BOOL))complete;

@end
