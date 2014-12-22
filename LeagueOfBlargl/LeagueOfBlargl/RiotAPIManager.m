//
//  RiotAPIManager.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const kRiotAPIKey = @"e84a851b-a433-46b8-8b3f-8578b78a53e4";

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
        
    }
    return self;
}

-(void) makeTestRequest{
    
    NSURL * baseURL = [NSURL URLWithString:@"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/existinabsurdity?"];
    
    AFHTTPSessionManager * httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask * summonerTask =  [httpSessionManager GET:[baseURL absoluteString]
                                                        parameters:@{ @"api_key" : kRiotAPIKey }
                                                           success:^(NSURLSessionDataTask *task, id responseObject)
    {
        
        NSLog(@"Success: %@", responseObject);
    }
                                                           failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"Error: %@", error);
    }];
    [summonerTask resume];
    
    
}

@end
