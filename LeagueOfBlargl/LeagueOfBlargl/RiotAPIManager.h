//
//  RiotAPIManager.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RiotAPIManager : NSObject

+(instancetype) sharedManager;
-(void) makeTestRequest;

@end
