//
//  RiotAPIManager.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"
#import "RiotDataManager.h"
#import <AFNetworking/AFNetworking.h>

@interface RegionAPIVersionInfo : NSObject

-(instancetype) initWithJSON:(NSDictionary *)jsonData;
@property (strong, nonatomic) NSString * dataDragonVersion;
@property (strong, nonatomic) NSString * currentGameVersion;
@property (strong, nonatomic) NSString * language;
@property (strong, nonatomic) NSString * championDataVersion;
@property (strong, nonatomic) NSString * itemDataVersion;
@property (strong, nonatomic) NSString * languageDataVersion;
@property (strong, nonatomic) NSString * masteryDataVersion;
@property (strong, nonatomic) NSString * profileIconDataVersion;
@property (strong, nonatomic) NSString * runeInfoDataVersion;
@property (strong, nonatomic) NSString * summonerDataVersion;

@end

@implementation RegionAPIVersionInfo

-(instancetype)initWithJSON:(NSDictionary *)jsonData{
    self = [super init];
    if (self) {
        
        _dataDragonVersion = jsonData[@"dd"];
        _currentGameVersion = jsonData[@"v"];
        _language = jsonData[@"l"];
        _championDataVersion = jsonData[@"n"][@"champion"];
        _itemDataVersion = jsonData[@"n"][@"item"];
        _languageDataVersion  = jsonData[@"n"][@"language"];
        _masteryDataVersion = jsonData[@"n"][@"mastery"];
        _profileIconDataVersion = jsonData[@"n"][@"profileicon"];
        _runeInfoDataVersion = jsonData[@"n"][@"rune"];
        _summonerDataVersion = jsonData[@"n"][@"summoner"];
        
        NSLog(@"Region version created! %@", self);
    }
    return self;
}
@end


// ---------------------//
// --    Constants   -- //
static NSString * const kRiotAPIKey = @"e84a851b-a433-46b8-8b3f-8578b78a53e4";
static NSString * const kRiotBaseURL = @"https://<region>.api.pvp.net/api/lol/<region>/<version>";

static NSString * const kRegionPlaceholder = @"<region>";
static NSString * const kVersionPlaceholder = @"<version>";

  // == STATIC DATA == //
static NSString * const kDragonVersionQuery = @"https://<region>.api.pvp.net/api/lol/static-data/<region>/<version>";


// ---------------------//
// --    Interface   -- //
@interface RiotAPIManager ()
@property (nonatomic) NSInteger selectedRegion;

@property (strong, nonatomic) NSDictionary * searchTypeKey;
@property (strong, nonatomic) NSDictionary * regionKey;

@property (strong, nonatomic) AFHTTPSessionManager * httpSessionManager;

@property (strong, nonatomic) RegionAPIVersionInfo * versionInfo;

@end



// ---------------------//
// -- Implementation -- //
@implementation RiotAPIManager

#pragma mark - INITIALIZERS & SINGLETONS
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
        
        [self getRealmDataForCurrentRegion];
    }
    return self;
}


/**********************************************************************************
 *
 *              SEARCH TYPES AND HANDLING
 *
 ***********************************************************************************/
#pragma mark - SEARCH_TYPE-SPECIFIC METHODS

-(void) searchRiotFor:(LoLSearchType)type
            withQuery:(NSString *)query
            forRegion:(LoLRegions)region
       withCompletion:(void(^)(NSDictionary *))completion
{
    
    NSString * requestString = [self createURLStringForRegion:region
                                                   apiVersion:@"v1.4"
                                                    queryType:type
                                                     andQuery:query];
    
    NSString * utf8Query = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * requestURL = [NSURL URLWithString:utf8Query];

    [self beginRequestWithURL:requestURL
                  withSuccess:^(NSDictionary * jsonData)
     {
         NSLog(@"Successful request, bubbling up: %@", jsonData);
         completion(jsonData);
     }
                      orError:^(NSDictionary * jsonData)
     {
         NSLog(@"API Manager has encountered the following problematic JSON data: %@", jsonData);
         NSLog(@"Issue logged in [%@ %@]", NSStringFromClass([RiotAPIManager class]), NSStringFromSelector(@selector(searchRiotFor:withQuery:forRegion:withCompletion:)) );
         completion(nil);
     }];

}

/**********************************************************************************
 *
 *              SEARCH AGNOSTIC METHODS
 *
 ***********************************************************************************/
// -- SEARCH TYPE AGNOSTIC, WILL JUST GET JSON!! -- //
#pragma mark - API CALLS
-(void)beginRequestWithURL:(NSURL *)url
               withSuccess:(void (^)(NSDictionary *))success
                   orError:(void (^)(NSDictionary *))error
{
    
    self.httpSessionManager = [[AFHTTPSessionManager alloc]
                               initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask * summonerTask =  [self.httpSessionManager GET:[url absoluteString]
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

#pragma mark - URL CREATION
// -- Creates the full URL String -- //
-(NSString *) createURLString:(NSString *)baseURL
                   WithRegion:(LoLRegions)region
                   apiVersion:(NSString *)version
                    queryType:(LoLSearchType)type
                     andQuery:(NSString *)query
{
    /* these two calls need refactoring  */
    
    // get strings from dictionary
    NSString * queryType = self.searchTypeKey[[NSNumber numberWithInteger:type]];
    NSString * regionString = self.regionKey[[NSNumber numberWithInteger:region]];
    
    //replace <placeholder> strings with correct info
    NSString * updatedRegionURL = [baseURL stringByReplacingOccurrencesOfString:kRegionPlaceholder
                                                                        withString:regionString];
    NSString * updatedVersionURL = [updatedRegionURL stringByReplacingOccurrencesOfString:kVersionPlaceholder
                                                                               withString:version];
    
    return [NSString stringWithFormat:@"%@/%@%@", updatedVersionURL, queryType, query];
    
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


/**********************************************************************************
 *
 *      STATIC API CALLS
 *
 ***********************************************************************************/
-(void) getRealmDataForCurrentRegion{
    
    NSURL *realmQuery = [NSURL URLWithString:[self createURLString:kDragonVersionQuery
                                                       WithRegion:self.currentRegion
                                                       apiVersion:@"v1.2"
                                                        queryType:static_data
                                                         andQuery:@""]];
    
    // does this cause a retain cycle? or does __block fix that?
    /* 
     answer: No doesn't cause retain, yes __block prevents it
     
     In ARC this(marking a variable as a __block) causes the variable to be automatically retained, so that it can be safely referenced within the block implementation. In the previous example, then, aString is sent a retain message when captured in the block context.
     
     In the Objective-C and Objective-C++ languages, we allow the __weak specifier for __block variables of object type. [...] This qualifier causes these variables to be kept without retain messages being sent. This knowingly leads to dangling pointers if the Block (or a copy) outlives the lifetime of this object.
     
     see: http://stackoverflow.com/questions/19227982/using-block-and-weak (awesome explanantion)
     
     */
    __block RegionAPIVersionInfo * weakVersionInfo = self.versionInfo;
    [self beginRequestWithURL:realmQuery
                  withSuccess:^(NSDictionary * json)
            {
                NSLog(@"Realm data collected");
                
                weakVersionInfo = [[RegionAPIVersionInfo alloc] initWithJSON:json];
                
            }
                      orError:^(NSDictionary * jsonError)
            {
                NSLog(@"Realm data from DataDragon not found: %@", jsonError);
            }];
    
}


/**********************************************************************************
 *
 *              RANDO HELPER METHODS & CUSTOM SETTERS -- SELF EXPLANATORY
 *
 ***********************************************************************************/
#pragma mark - HELPERS
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

// Getters for enum keys
-(NSDictionary *)searchTypeKey{
    if (!_searchTypeKey) {
        _searchTypeKey = @{
                           
                           [NSNumber numberWithFloat:summonerName]  :   @"summoner/by-name/",
                           [NSNumber numberWithFloat:summonerID]    :   @"summoner/",
                           [NSNumber numberWithFloat:static_data]   :   @"realm"
                           
                           };
    }
    return _searchTypeKey;
}
-(NSDictionary *)regionKey{
    if (!_regionKey) {
        _regionKey = @{
                       
                        [NSNumber numberWithInteger:    northAmerica]   : @"na",
                        [NSNumber numberWithInteger:    euNordic]       : @"eune",
                        [NSNumber numberWithInteger:    euWest]         : @"euw",
                        [NSNumber numberWithInteger:    global]         : @"global",
                        [NSNumber numberWithInteger:    korea]          : @"kr",
                        [NSNumber numberWithInteger:    oceanic]        : @"oce"
                      };
    }
    return _regionKey;
}

@end