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


@interface SearchRiotTVController () <UISearchControllerDelegate, UISearchBarDelegate,
UISearchResultsUpdating, UIScrollViewDelegate>

@property (nonatomic) CGRect originalSearchBarRect;

@property (strong, nonatomic) __block NSMutableArray * searchResults;
@property (strong, nonatomic) __block NSArray * usersFound;

@property (strong, nonatomic) UISearchController * searchController;
@property (strong, nonatomic) UISearchBar * searchBar;

@property (strong, nonatomic) UITableViewController * filteredResultsTableViewController;

@property (strong, nonatomic) UITableViewCell * searchResultsCells;


@end

@implementation SearchRiotTVController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor * riotMediumWellBlue = [UIColor colorWithRed:0.167 green:0.289 blue:0.430 alpha:1.000];
    UIColor * riotMediumBlue = [UIColor colorWithRed:0.610 green:0.735 blue:0.854 alpha:1.000];
    [self.tableView setBackgroundColor:riotMediumWellBlue];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    // -- PRESENTATION CONTEXTS -- //
    // needed so that a presenting view will restrict the bounds of a
    // presented view to the visible area of the presenting view
    // in this case, the tableviewcontroller tells the filteredresults controller, what portion
    // of the screen it can occupy (default is no, so the presented view keeps asking for a context
    // up through the VC heirarchy until it reaches one that does, or it his the UIWindow .. which is
    // why if this value is not set, then the filtered results table takes up the entire screen)
    [self setDefinesPresentationContext:YES];
    
    // -- SEARCH BAR -- //
    // The searchbar controller's job is to manage a searchbar and the uitableviewcontroller that it will
    // present results on. The the SBC owns a search bar already, but you have to create it a TVC for it
    // to manage the presentation of the results
    //
    self.filteredResultsTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.filteredResultsTableViewController];
    self.searchBar = self.searchController.searchBar;
    
    [self.searchBar         setDelegate:            self];
    [self.searchController  setDelegate:            self];
    [self.searchController  setSearchResultsUpdater:self];
    
    [self.filteredResultsTableViewController.tableView setDelegate:self];
    [self.filteredResultsTableViewController.tableView setDataSource:self];
    
    // -- SIZETOFIT -- //
    // Ugh, this was a special breed of headache.. so I wanted to place the searchbar into a nav
    // controller much the same way that the contact app does.. but in actuallity it seems as though
    // the searchbar is placed into the tableHeaderView and then told not to scroll with the content
    // of the table. Anyhow, to do this, you call "sizeToFit" on the searchbar. What does this do?
    //
    /*  Well according to apple docs:
     
             Call this method when you want to resize the current
             view so that it uses the most appropriate amount of space. 
             Specific UIKit views resize themselves according to their 
             own internal needs.
     */
    // So from the sounds of it, the searchBar knows it's own size.. otherwise the headerview default
    // size determines it. not sure though.
    [self.searchBar sizeToFit];
    [self.searchBar setBarStyle:UIBarStyleBlack];
    
    // IT EVEN HANDLES THE SHOW/HIDE FOR YOU!!!
    // Cmon.. easy mode Apple. Make something challenging.
    [self.searchBar setScopeButtonTitles:@[@"SUMR",@"CHMP",@"ITM",@"RUNE"]];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    [self.navigationItem setTitle:@"League of Blargl"];
    
    RiotAPIManager * myManager = [RiotAPIManager sharedManager];
    NSString * queryString = @"existinabsurdity,mister strickland,mr dale gribble";
    
    self.searchResults = [[NSMutableArray alloc] init];

    [myManager searchRiotFor:summonerName
                   withQuery:queryString
                   forRegion:northAmerica
              withCompletion:^(NSDictionary * jsonResults)
    {
        //this will eventually be handled by the data manager
        self.usersFound = [jsonResults allKeys];
        for (NSString * users in self.usersFound) {
            NSDictionary * searchResults = jsonResults[users];
            
            Summoners * newSummoner = [[Summoners alloc] initWithSummonerName:searchResults[@"name"]
                                                                   summonerID:searchResults[@"id"]
                                                                profileIconID:searchResults[@"profileIconId"]
                                                                     andLevel:[searchResults[@"summonerLevel"] integerValue]];
            
            [self.searchResults addObject:newSummoner];
            // returning 503 errors occasionally. = took a while for them up update this, but
            // the problem was their API, even though the status tracker said it was working >_<
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.tableView reloadData];
        }];

    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, 44)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //CGPoint offset = scrollView.contentOffset;  //changes based on scroll
    //UIEdgeInsets inset = scrollView.contentInset;//always the same, set at the start
    
    //NSLog(@"Offset| X: %f   Y: %f", offset.x, offset.y );
    //NSLog(@"Inset | Top: %f  Bottom: %f", inset.top, inset.bottom);

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.usersFound ? [self.usersFound count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];
    cell.backgroundColor = [UIColor colorWithRed:0.411 green:0.723 blue:1.000 alpha:1.000];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.849 green:0.801 blue:0.532 alpha:1.000];
    
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
        return @"SUMMONERS";
    }
    return @"SUMMONERS";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIFont *hevNeu = [UIFont fontWithName:@"HelveticaNeue-BlackCondensed" size:14.0];
    
    UIView * headerView = [[UIView alloc] init];
    [headerView sizeToFit];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.477 green:0.612 blue:0.773 alpha:1.000]];
//    
//    UILabel * aLabel = [[UILabel alloc] initWithFrame:headerView.frame];
//    [aLabel setBackgroundColor:[UIColor redColor]];
//    
//    [headerView addSubview:aLabel];
//    
//    [aLabel sizeToFit];
//    
//    
//    aLabel.textAlignment = NSTextAlignmentCenter;
//    aLabel.font = hevNeu;
//    aLabel.textColor = [UIColor lightGrayColor];
//    aLabel.text = @"Summoners";
    
    return headerView;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}


/**********************************************************************************
 *
 *      SEARCH CONTROLLER DELEGATE METHODS
 *
 ***********************************************************************************/
#pragma mark - SEARCH CONTROLLER DELEGATE
-(void)didDismissSearchController:(UISearchController *)searchController{
    NSLog(@"did dismiss search controller");
}
-(void)didPresentSearchController:(UISearchController *)searchController{
    NSLog(@"did present search controller");
}
-(void)willPresentSearchController:(UISearchController *)searchController{
    NSLog(@"Will present search controller");
}
-(void)willDismissSearchController:(UISearchController *)searchController{
    NSLog(@"will dismiss search controller");
}

/**********************************************************************************
 *
 *      SEARCH BAR DELEGATE METHODS
 *
 ***********************************************************************************/
#pragma mark - SEARCH BAR DELEGATE
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Search bar text did change");
}
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"Search bar should change text in range: %lu, %lu, replacementText: %@", range.length, range.location, text);
   return YES;
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"Search bar should begin editing");
    return YES;
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"Search bar did begin editing");
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    NSLog(@"Search bar should end editing");
    return YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"Search bar did end editing");
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Cancel button clicked");
}
-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Results list button clicked");
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Search button clicked");
}

/**********************************************************************************
 *
 *      UISEARCH RESULTS UPDATING DELEGATE METHODS
 *
 ***********************************************************************************/
#pragma mark - SEARCH RESULTS DELEGATE
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSLog(@"Update search results for search controller");
}


@end
