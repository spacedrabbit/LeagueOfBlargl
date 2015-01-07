//
//  SavedSearchQuery.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/7/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "SavedSearchQuery.h"

@interface SavedSearchQuery ()

@property (strong, nonatomic) NSString * queryString;
@property (strong, nonatomic) NSURL * queriedURL;
@property (strong, nonatomic) id searchType;

@end

@implementation SavedSearchQuery

+(instancetype)createSavedSearch:(NSString *)searchString fullURL:(NSURL *)url ofQueryType:(id)searchType{
    
    SavedSearchQuery * boilerPlatedSearch = [[SavedSearchQuery alloc] initWithQuery:searchString
                                                                             andURL:url
                                                                            andType:searchType];
    
    return boilerPlatedSearch;
    
}

-(instancetype)initWithQuery:(NSString *)query andURL:(NSURL *)url andType:(id)type{
    
    self = [super init];
    if (self) {
        _queryString = query;
        _queriedURL = url;
        _searchType = type;
        
        _queryStringToShow = query;
    }
    
    return self;
}

@end
