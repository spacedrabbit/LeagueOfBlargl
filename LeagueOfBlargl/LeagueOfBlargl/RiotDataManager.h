//
//  RiotDataManager.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RiotDataManager : NSObject

+(instancetype) sharedManager;
-(void) createSummonersFromRawJSON:(NSDictionary *)jsonData;

@end
