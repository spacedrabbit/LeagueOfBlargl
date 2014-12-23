//
//  SearchRiotTVController.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "SearchRiotTVController.h"
#import "RiotAPIManager.h"
#import "Summoners.h"

@interface SearchRiotTVController ()

@property (strong, nonatomic) __block NSMutableArray * searchResults;
@property (strong, nonatomic) __block NSArray * usersFound;

@end

@implementation SearchRiotTVController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchResults = [[NSMutableArray alloc] init];
    
    RiotAPIManager * myManager = [RiotAPIManager sharedManager];
    
    NSString * queryString = @"existinabsurdity,mister strickland,mr dale gribble";
    
    [myManager searchRiotFor:summonerName
                   withQuery:queryString
                   forRegion:northAmerica
              withCompletion:^(NSDictionary * jsonResults)
    {
        self.usersFound = [jsonResults allKeys];
        for (NSString * users in self.usersFound) {
            NSDictionary * searchResults = jsonResults[users];
            
            Summoners * newSummoner = [[Summoners alloc] initWithSummonerName:searchResults[@"name"]
                                                                   summonerID:searchResults[@"id"]
                                                                profileIconID:searchResults[@"profileIconId"]
                                                                     andLevel:[searchResults[@"summonerLevel"] integerValue]];
            
            [self.searchResults addObject:newSummoner];
            
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.tableView reloadData];
        }];

    }];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.usersFound ? [self.usersFound count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];
    
    if (self.usersFound)
    {
        Summoners * currentSummoner = self.searchResults[indexPath.row];
        cell.textLabel.text = currentSummoner.summonerName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Level: %li\t Icon:%@",
                                     currentSummoner.level, currentSummoner.iconID];
    }else{
        cell.textLabel.text = @"No search results";
    }
    
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
    {
        return @"Summoners Found";
    }
    return nil;
}


@end
