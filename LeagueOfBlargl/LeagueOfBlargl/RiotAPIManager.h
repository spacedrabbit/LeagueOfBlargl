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
    summonerName = 0,
    summonerID
};
// -- TYPEDEF REFERENCE VALUES -- //



@interface RiotAPIManager : NSObject

+(instancetype) sharedManager;

-(void) beginRequestUsingString:(NSString *)urlString
                    withSuccess:(void(^)(NSDictionary *))success
                        orError:(void(^)(NSDictionary *))error;

-(NSString *) createURLStringForRegion:(LoLRegions)region
                            apiVersion:(NSString *)version
                             queryType:(LoLSearchType)type
                              andQuery:(NSString *)query;
// -- helpers -- //
-(void) changeRegionTo:(LoLRegions)region;
-(LoLRegions) currentRegion;


@end
