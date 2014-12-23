//
//  Summoners.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Summoners : NSObject <NSCoding>

@property (strong, nonatomic) NSString  * summonerName;
@property (strong, nonatomic) NSString  * summonerID;
@property (strong, nonatomic) NSString  * iconID;
@property (strong, nonatomic) UIImage * imageView;
@property (        nonatomic) NSInteger   level;

-(instancetype) initWithSummonerName:(NSString *)name
                          summonerID:(NSString *)summonerID
                       profileIconID:(NSString *)iconID
                            andLevel:(NSInteger)level;

@end
