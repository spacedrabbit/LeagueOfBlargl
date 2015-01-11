//
//  Summoners.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "Summoners.h"

static NSString * kSummonerName = @"name";
static NSString * kSummonerID = @"ID";
static NSString * kSummonerIcon = @"icon";
static NSString * kSummonerLevel = @"level";

@implementation Summoners

-(instancetype)initWithSummonerName:(NSString *)name summonerID:(NSString *)summonerID
                      profileIconID:(NSString *)iconID andLevel:(NSInteger)level
{
    self = [super init];
    if (self) {
        _summonerName = name;
        _summonerID = summonerID;
        _iconID = iconID;
        _level = level;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _summonerName   = [coder decodeObjectForKey   :kSummonerName];
        _summonerID     = [coder decodeObjectForKey   :kSummonerID  ];
        _iconID         = [coder decodeObjectForKey   :kSummonerIcon];
        _level          = [[coder decodeObjectForKey  :kSummonerLevel] integerValue];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_summonerName forKey:kSummonerName];
    [aCoder encodeObject:_summonerID forKey:kSummonerID];
    [aCoder encodeObject:_iconID forKey:kSummonerIcon];
    [aCoder encodeObject:[NSNumber numberWithInteger:_level] forKey:kSummonerLevel];
    
}

-(BOOL)isEqual:(Summoners *)summoner{
    return [self.summonerID isEqualToString:summoner.summonerID] ? YES : NO;
}



@end
