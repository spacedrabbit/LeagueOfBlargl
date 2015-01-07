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
    
    NSArray * summonersNames = [jsonData allKeys]; // keys for this query are the summoner's names
    
    for (NSString * summoner in summonersNames)
    {
        NSDictionary * searchResults = jsonData[summoner];
        Summoners * newSummoner = [[Summoners alloc] initWithSummonerName:searchResults[@"name"]
                                                               summonerID:searchResults[@"id"]
                                                            profileIconID:searchResults[@"profileIconId"]
                                                                 andLevel:[searchResults[@"summonerLevel"] integerValue]];
        
        //needs a check here to see if they already exist
        [self.allSummoners addObject:newSummoner];
        
        if ([self.allSummoners count] > 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.managedTableView reloadData];
            }];
        }
    }
}


/**********************************************************************************
 *
 *      TABLEVIEW DELEGATE METHODS
 *      
 ***********************************************************************************/
#pragma mark - TABLEVIEW DELEGATE METHODS
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allSummoners ? [self.allSummoners count] : 0;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    NSString * headerString = (section == 0) ? @"Summoners" : @"";

    return headerString;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    
    
}

@end
