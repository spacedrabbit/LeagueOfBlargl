//
//  RiotDataManager.h
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RiotDataManager : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView * managedTableView;
@property (strong, nonatomic) NSMutableArray * searchHistory;

+(instancetype) sharedManager;

-(void)createSummonersFromRawJSON:(NSDictionary *)jsonData;


@end
