//
//  RiotDataManager.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Summoners;

@interface RiotDataManager : NSObject <UITableViewDataSource>

@property (strong, nonatomic) UITableView * managedTableView;
@property (strong, nonatomic) NSMutableArray * searchHistory;
@property (strong, nonatomic) NSMutableArray * allSummoners;

+(instancetype) sharedManager;

-(void)createSummonersFromRawJSON:(NSDictionary *)jsonData;


@end
