//
//  SearchRiotTVController.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 12/21/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "RiotDataManager.h"
#import "SearchRiotTVController.h"
#import "RiotAPIManager.h"
#import "RiotDataManager.h"
#import "Summoners.h"
#import "SavedSearchQuery.h"
#import "SummonerProfile_VC.h"


@interface SearchRiotTVController () <UISearchControllerDelegate, UISearchBarDelegate,
UISearchResultsUpdating, UIScrollViewDelegate>

@property (nonatomic) CGRect originalSearchBarRect;

@property (strong, nonatomic) __block NSMutableArray * searchResults;
@property (strong, nonatomic) __block NSArray * usersFound;

@property (strong, nonatomic) UISearchController * searchController;
@property (strong, nonatomic) UISearchBar * searchBar;

@property (strong, nonatomic) UITableViewController * filteredResultsTableViewController;
@property (strong, nonatomic) UITableViewCell * searchResultsCells;

@property (strong, nonatomic) RiotAPIManager * sharedAPIManager;
@property (strong, nonatomic) RiotDataManager * sharedDataManager;


@end

@implementation SearchRiotTVController

-(RiotDataManager *)sharedDataManager{
    if (!_sharedDataManager) {
        _sharedDataManager = [RiotDataManager sharedManager];
    }
    return _sharedDataManager;
}
-(RiotAPIManager *)sharedAPIManager{
    if (!_sharedAPIManager) {
        _sharedAPIManager = [RiotAPIManager sharedManager];
    }
    return _sharedAPIManager;
}
-(NSMutableArray *)searchResults{
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return _searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor * riotMediumWellBlue = [UIColor colorWithRed:0.167 green:0.289 blue:0.430 alpha:1.000];
    UIColor * riotMediumBlue = [UIColor colorWithRed:0.610 green:0.735 blue:0.854 alpha:1.000];
    [self.tableView setBackgroundColor:riotMediumBlue];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.navigationItem setTitle:@"League of Blargl"];
    
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
    
    [self.filteredResultsTableViewController.tableView setDelegate:         self];
    [self.filteredResultsTableViewController.tableView setDataSource:       self];
    
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
    [self.searchBar setBarStyle:UIBarStyleDefault];
    
    // IT EVEN HANDLES THE SHOW/HIDE FOR YOU!!!
    // Cmon.. easy mode Apple. Make something challenging.
    //[self.searchBar setScopeButtonTitles:@[@"SUMR",@"CHMP",@"ITM",@"RUNE"]];
    
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView setDataSource:self.sharedDataManager];
    self.sharedDataManager.managedTableView = self.tableView;
 
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, 44)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**********************************************************************************
 *
 *      TABLEVIEW METHODS
 *      Side note: move this into DataManager since the data is managed there
 ***********************************************************************************/
#pragma mark - TABLEVIEW DATA METHODS (Search Table)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sharedAPIManager priorSearches].count ? : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:0.502 green:0.000 blue:0.251 alpha:1.000];
    
    if ([self.sharedAPIManager priorSearches].count > 0) {
        SavedSearchQuery * currentSavedQuery = [self.sharedAPIManager priorSearches][indexPath.row];
        cell.textLabel.text = currentSavedQuery.queryStringToShow;
    }

    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Recent Searches";
}
-(BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - TABLEVIEW DELEGATE METHODS
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Summoners * selectedSummoner = self.sharedDataManager.allSummoners[indexPath.row];
    SummonerProfile_VC * dstvc = [[SummonerProfile_VC alloc] initWithSummoner:selectedSummoner];
    
    [self.navigationController pushViewController:dstvc animated:YES];
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
    //load prior searches here
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString * searchQuery = searchBar.text;
    if ([searchQuery length]) {
        
        //this method needs to be re-written since the JSON results for a 404 will not work here
        [self.sharedAPIManager searchRiotFor:summonerName
                       withQuery:searchQuery
                       forRegion:northAmerica
                  withCompletion:^(NSDictionary * jsonResults)
         {
             [self.sharedDataManager createSummonersFromRawJSON:jsonResults];
         }];
    }
    [self.searchController setActive:NO];
}

/**********************************************************************************
 *
 *      UISEARCH RESULTS UPDATING DELEGATE METHODS
 *
 ***********************************************************************************/
#pragma mark - SEARCH RESULTS DELEGATE
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    // implement NSPredicate search here
    NSLog(@"Update search results for search controller");
}


@end
