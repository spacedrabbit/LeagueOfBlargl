//
//  RiotAPIManager.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"
#import <AFNetworking/AFNetworking.h>

// ---------------------//
// --    Constants   -- //
static NSString * const kRiotAPIKey = @"e84a851b-a433-46b8-8b3f-8578b78a53e4";
static NSString * const kRiotBaseURL = @"https://<region>.api.pvp.net/api/lol/<region>";

static NSString * const kRegionPlaceholder = @"<region>";


// ---------------------//
// --    Interface   -- //
@interface RiotAPIManager ()

@property (nonatomic) NSInteger selectedRegion;
@property (strong, nonatomic) NSDictionary * searchTypeKey;
@property (strong, nonatomic) AFHTTPSessionManager * httpSessionManager;

@end


// ---------------------//
// -- Implementation -- //
@implementation RiotAPIManager

+(instancetype) sharedManager
{
    static RiotAPIManager * _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[RiotAPIManager alloc] init];
    });
    return _sharedManager;
 }

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectedRegion = northAmerica; // default
        _httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
    }
    return self;
}

-(void)beginRequestUsingString:(NSString *)urlString
                   withSuccess:(void (^)(NSDictionary *))success
                       orError:(void (^)(NSDictionary *))error
{
    
    NSURL * requestURL = [NSURL URLWithString:urlString];
    self.httpSessionManager = [[AFHTTPSessionManager alloc]
                               initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask * summonerTask =  [self.httpSessionManager GET:[requestURL absoluteString]
                                                             parameters:@{ @"api_key" : kRiotAPIKey }
        success:^(NSURLSessionDataTask *task, id responseObject)
        {
            // typecasts so that I can check the status code
            // otherwise task.response return type is NSURLResponse
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                success(responseObject);
            }else{
                NSLog(@"Non 200 Status Code Encountered: %ld", (long)httpResponse.statusCode);
                error(responseObject);
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error)
        {
            NSLog(@"Error Encountered With Request: %@", error);
        }];
    [summonerTask resume];

}


#pragma mark - URL CREATION -
// -- Creates the full URL String -- //
-(NSString *) createURLString:(NSString *)baseURL
                   WithRegion:(LoLRegions)region
                   apiVersion:(NSString *)version
                    queryType:(LoLSearchType)type
                     andQuery:(NSString *)query
{
    
    NSNumber * queryType = [NSNumber numberWithInteger:type];
    NSString * regionString = [self stringFromRegion:region];
    NSString * udpatedBaseURL = [kRiotBaseURL stringByReplacingOccurrencesOfString:kRegionPlaceholder
                                                                        withString:regionString];
    NSString * fullURLString = [NSString stringWithFormat:@"%@/%@/%@/%@",
                                udpatedBaseURL, version, self.searchTypeKey[queryType],query];
    
    return fullURLString;
}
// -- this is a public facing method as the secret key will be internal
// -- to this class
-(NSString *)createURLStringForRegion:(LoLRegions)region
                           apiVersion:(NSString *)version
                            queryType:(LoLSearchType)type
                             andQuery:(NSString *)query{
    return [self createURLString:kRiotBaseURL
                      WithRegion:region
                      apiVersion:version
                       queryType:type
                        andQuery:query];
}

#pragma mark - HELPERS -
// -- helpers -- //
-(void)changeRegionTo:(LoLRegions)region{
    self.selectedRegion = region;
}
-(LoLRegions)currentRegion{
    return self.selectedRegion;
}
-(NSString *) stringFromRegion:(LoLRegions)region
{
    NSString * regionString = @"";
    switch (region)
    {
        case northAmerica:
            regionString = @"na";
            break;
        case global:
            regionString = @"global"; break;
        case oceanic:
            regionString =  @"oce"; break;
        case korea:
            regionString =  @"kr"; break;
        case euNordic:
            regionString =  @"eune"; break;
        case euWest:
            regionString =  @"euw"; break;
        default:
            regionString =  @"none"; break;
    }
    return regionString;
}

-(NSDictionary *)searchTypeKey{
    if (!_searchTypeKey) {
        _searchTypeKey = @{
                           
                           [NSNumber numberWithFloat:summonerName]  :   @"summoner/by-name",
                           [NSNumber numberWithFloat:summonerID]    :   @"summoner"
                           
                           };
    }
    return _searchTypeKey;
}
@end
