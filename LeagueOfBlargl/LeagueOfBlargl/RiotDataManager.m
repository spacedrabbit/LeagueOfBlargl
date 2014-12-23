//
//  RiotDataManager.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotDataManager.h"
#import "Summoners.h"

@implementation RiotDataManager

+(instancetype) sharedManager{

    static RiotDataManager * _sharedManager = nil;
    static dispatch_once_t onceToken;   //creates a token with an 'on' state
    dispatch_once(&onceToken, ^{       //this gets called once, and onceToken
        _sharedManager = [[RiotDataManager alloc] init];  //is set to 'off', never
    });                                //to be instantiated again
 
    return _sharedManager;
 }

-(void)createSummonersFromRawJSON:(NSDictionary *)jsonData{
    
    
    
    
}

@end
