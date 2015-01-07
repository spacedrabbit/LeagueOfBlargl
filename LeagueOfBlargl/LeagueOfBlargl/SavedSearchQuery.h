//
//  SavedSearchQuery.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/7/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedSearchQuery : NSObject

@property (strong, nonatomic, readonly) NSString * queryStringToShow;

+(instancetype) createSavedSearch:(NSString *)searchString fullURL:(NSURL *)url ofQueryType:(id)searchType;

@end
