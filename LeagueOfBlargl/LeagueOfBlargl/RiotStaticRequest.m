//
//  RiotStaticRequest.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/8/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "RiotStaticRequest.h"
#import "RiotDataManager.h"
#import "Summoners.h"

#import <AFNetworking/AFNetworking.h>

// -- Placeholders -- //
static NSString * const kRegionPlaceholder = @"<region>";
static NSString * const kVersionPlaceholder = @"<version>";

// -- Riot API Key  -- //
static NSString * const kRiotAPIKey = @"fb86d5e2-b14f-4de8-aec8-3089280f971b";
static NSString * const kRiotBaseURL = @"https://<region>.api.pvp.net/api/lol/<region>/<version>";

// -- Dragon Data URL -- //
static NSString * const kProfileIconsURL = @"http://ddragon.leagueoflegends.com/cdn/<version>/img/profileicon/";
static NSString * const kCurrentDragonVersion = @"4.20.1";

// -- Call back block typedefs -- //
typedef void (^IconCallBackBlock)(UIImage * image);

@interface RiotStaticRequest()

@property (copy) IconCallBackBlock iconRequestBlock;
@property (weak, nonatomic) id APIManger;

@end

@implementation RiotStaticRequest

// currently requests the profile icon for a summoner
// will be made more generic later
-(void) retrieveStaticDataFor:(Summoners *)summoner completion:(void(^)(BOOL success, UIImage * icon))complete{
    
    NSString * urlString = [kProfileIconsURL stringByReplacingOccurrencesOfString:kVersionPlaceholder
                                                                       withString:kCurrentDragonVersion];
    NSString * stringWithSummonerInfo = [urlString stringByAppendingFormat:@"%@.png", summoner.iconID];
    
    [self requestSummonerIcon:[NSURL URLWithString:stringWithSummonerInfo]
                   completion:^(UIImage *image)
    {
        if (image)
        {
            complete(YES, image);
        }else{
            complete(NO, nil);
        }
    }];
    
    
}

-(void) requestSummonerIcon:(NSURL *)requestURL completion:(IconCallBackBlock)imageBlock{
    
    AFHTTPSessionManager * sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:requestURL
                                                                     sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
    
    NSMutableURLRequest * imageURLRequest = [sessionManager.requestSerializer requestWithMethod:@"GET"
                                                                                   URLString:requestURL.absoluteString
                                                                                  parameters:nil
                                                                                       error:nil];
    
    NSURLSessionDataTask * dataTask = [sessionManager dataTaskWithRequest:imageURLRequest
                                                        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                       {
                                           NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                                           if (error)
                                           {
                                               NSLog(@"There is an error in %@.\n%@",
                                                     NSStringFromSelector(@selector(requestSummonerIcon:completion:)),
                                                     error);
                                           }
                                           else
                                           {
                                               if (httpResponse.statusCode == 200)
                                               {
                                                   NSLog(@"200 status received, returning image");
                                                   imageBlock(responseObject);
                                               }
                                               else
                                               {
                                                   NSLog(@"Non-200 Response: %li", httpResponse.statusCode);
                                               }
                                           }
                                           imageBlock(nil); //not found
                                       }];
    [dataTask resume];
    
    
    
}

@end
