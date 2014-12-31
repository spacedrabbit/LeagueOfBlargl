//
//  RiotDataManager.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/22/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotDataManager.h"
#import "Summoners.h"

@interface RiotDataManager ()

@property (strong, nonatomic) NSMutableArray * allSummoners;

@end

@implementation RiotDataManager

+(instancetype) sharedManager{

    static RiotDataManager * _sharedManager = nil;
    static dispatch_once_t onceToken;   //creates a token with an 'on' state
    dispatch_once(&onceToken, ^{       //this gets called once, and onceToken
        _sharedManager = [[RiotDataManager alloc] init];  //is set to 'off', never
    });                                //to be instantiated again
 
    return _sharedManager;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        _allSummoners = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)createSummonersFromRawJSON:(NSDictionary *)jsonData{
    
    NSArray * usersFound = [jsonData allKeys];
    for (NSString * users in usersFound) {
        NSDictionary * searchResults = jsonData[users];
        
        Summoners * newSummoner = [[Summoners alloc] initWithSummonerName:searchResults[@"name"]
                                                               summonerID:searchResults[@"id"]
                                                            profileIconID:searchResults[@"profileIconId"]
                                                                 andLevel:[searchResults[@"summonerLevel"] integerValue]];
        
        [self.allSummoners addObject:newSummoner];
    }
    
}


/**********************************************************************************
 *
 *      TABLEVIEW DELEGATE METHODS
 *      
 ***********************************************************************************/
#pragma mark - TABLEVIEW DELEGATE METHODS

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allSummoners ? [self.allSummoners count] : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];
    cell.backgroundColor = [UIColor colorWithRed:0.411 green:0.723 blue:1.000 alpha:1.000];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.849 green:0.801 blue:0.532 alpha:1.000];
    
    if (self.allSummoners)
    {
        Summoners * currentSummoner = self.allSummoners[indexPath.row];
        cell.textLabel.text = currentSummoner.summonerName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Level: %li\t Icon:%@",
                                     currentSummoner.level, currentSummoner.iconID];
    }else
    {
        cell.textLabel.text = @"No search results";
    }
    
    return cell;

}

@end
