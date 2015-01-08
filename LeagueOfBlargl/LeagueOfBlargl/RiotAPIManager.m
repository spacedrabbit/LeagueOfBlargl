//
//  RiotAPIManager.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotAPIManager.h"
#import "RiotDataManager.h"
#import "SavedSearchQuery.h"
#import <AFNetworking/AFNetworking.h>

// -- Regin API Info Calls -- //

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
static NSString * const kRiotAPIKey = @"fb86d5e2-b14f-4de8-aec8-3089280f971b";
static NSString * const kRiotBaseURL = @"https://<region>.api.pvp.net/api/lol/<region>/<version>";

static NSString * const kRegionPlaceholder = @"<region>";
static NSString * const kVersionPlaceholder = @"<version>";

  // == STATIC DATA == //
static NSString * const kDragonVersionQuery = @"https://<region>.api.pvp.net/api/lol/static-data/<region>/<version>";
static NSString * const kProfileIconsURL = @"http://ddragon.leagueoflegends.com/cdn/<version>/img/profileicon/";
static NSString * const kCurrentDragonVersion = @"4.20.1";

typedef NSCachedURLResponse * (^CacheResponse)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);

// ---------------------//
// --    Interface   -- //
@interface RiotAPIManager ()

@property (nonatomic) NSInteger selectedRegion;
@property (strong, nonatomic) NSMutableArray * savedSearches;

@property (strong, nonatomic) NSDictionary * searchTypeKey;
@property (strong, nonatomic) NSDictionary * regionKey;

@property (strong, nonatomic) AFHTTPSessionManager * httpSessionManager;

@property (strong, nonatomic) RegionAPIVersionInfo * versionInfo;

@property (copy) CacheResponse DelegateCacheResponseBlock;

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
-(NSMutableArray *)savedSearches{
    if (!_savedSearches) {
        _savedSearches = [[NSMutableArray alloc] init];
    }
    return _savedSearches;
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

    [self.savedSearches addObject:[SavedSearchQuery createSavedSearch:query
                                                              fullURL:requestURL
                                                          ofQueryType:@(type)]];
    
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

-(void) retrieveStaticDataFor:(Summoners *)summoner{
    
    NSString * urlString = [kProfileIconsURL stringByReplacingOccurrencesOfString:kVersionPlaceholder
                                                                       withString:kCurrentDragonVersion];
    [self beginRequestWithURL:[NSURL URLWithString:urlString]
                  withSuccess:^(NSDictionary * jsonData)
    {
        
    }
                      orError:^(NSDictionary * jsonData)
    {
        
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

    [self.httpSessionManager setDataTaskWillCacheResponseBlock:self.DelegateCacheResponseBlock];

    NSURLSessionDataTask * summonerTask =  [self.httpSessionManager GET:[url absoluteString]
                                                             parameters:@{ @"api_key" : kRiotAPIKey }
                                                                success:^(NSURLSessionDataTask *task, id responseObject)
                                            {
                                                // typecasts so that I can check the status code
                                                // otherwise task.response return type is NSURLResponse
                                                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)task.response;
                                                if (httpResponse.statusCode == 200) //good
                                                {
                                                    success(responseObject);
                                                }
                                                else if(httpResponse.statusCode == 429) //rate limit exceeded
                                                {
                                                    NSLog(@"Too many requests have been made using this key. Please wait and try again later");
                                                    error(responseObject);
                                                }
                                                else if(httpResponse.statusCode == 503) //server busy/unavailable
                                                {
                                                    NSLog(@"Server either too busy or unavailable. Try again later");
                                                    error(responseObject);
                                                }
                                                else if (httpResponse.statusCode == 304) //response not modified
                                                {
                                                    NSLog(@"No change since last refresh");
                                                    success(responseObject);
                                                }else if (httpResponse.statusCode == 404){
                                                    NSLog(@"No summoner data found for request");
                                                    error(responseObject);
                                                }
                                                else{
                                                    NSLog(@"Unknown error occurred, likely network issues: %ld", (long)httpResponse.statusCode);
                                                    error(responseObject);
                                                }
                                            }
                                                                failure:^(NSURLSessionDataTask *task, NSError *error)
                                            {
                                                NSLog(@"Error Encountered With Request: %@", error);
                                            }];
    [summonerTask resume];
    
}


// -- BLOCK PROPERTY SETTERS -- //

#pragma mark - Block Property Setter/Getters
// I'm not entirely sure this is best practices when it comes to modern iOS architecture..
// I do make the block property (copy) as indicated... but something about this feels wrong
// I mean, the returned typedef has the same block signature as the block property would indicate
// But, the setter seems off.. even though everything *seems* to be working the same
-(void)setDelegateCacheResponseBlock:(CacheResponse)delegateCacheResponse
{
    self.DelegateCacheResponseBlock = delegateCacheResponse;
}
-(CacheResponse)DelegateCacheResponseBlock{
    
    CacheResponse internaleCacheBlock;
    return internaleCacheBlock = ^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse){
            
            NSCachedURLResponse * responseCached;
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)[proposedResponse response];
            
            //checks to see if NSURLRequestUseProtocolCachePolicy is in place
            //the protocol determines if a request should be cached based on it's headers
            if (dataTask.originalRequest.cachePolicy == NSURLRequestUseProtocolCachePolicy)
            {
                NSDictionary *headers = httpResponse.allHeaderFields;
                NSString * cacheControl = [headers valueForKey:@"Cache-Control"];
                NSString * expires = [headers valueForKey:@"Expires"];
                
                //if the headers for this protocol don't exist, then we will take care of the caching manually
                //outlined in blog post on NSURLCache
                if (cacheControl == nil && expires == nil)
                {
                    NSLog(@"Server does not provide expiration information and use are using NSURLRequestUseProtocolCachePolicy");
                    responseCached = [[NSCachedURLResponse alloc] initWithResponse:dataTask.response
                                                                              data:proposedResponse.data
                                                                          userInfo:@{ @"response" : dataTask.response, @"proposed" : proposedResponse.data }
                                                                     storagePolicy:NSURLCacheStorageAllowed];
                    
                }
            }
            
            return responseCached;
        };
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
-(NSArray *) priorSearches{
    return self.savedSearches;
}
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