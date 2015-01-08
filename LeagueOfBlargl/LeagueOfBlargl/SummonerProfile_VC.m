//
//  SummonerProfile_VC.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/7/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "SummonerProfile_VC.h"
#import "Summoners.h"


// -- Summoner Table Header View -- //
@interface SummonerHeaderView : UIView

@property (strong, nonatomic) UIImageView * profileIcon;
@property (strong, nonatomic) NSString * summonerName;

@end

@implementation SummonerHeaderView



@end


// -- Rest of the VC -- //

@interface SummonerProfile_VC ()

@property (strong, nonatomic) Summoners * selectedSummoner;

@end

@implementation SummonerProfile_VC

-(instancetype)initWithSummoner:(Summoners *)selectedSummoner{
    self = [super init];
    if (self) {
        _selectedSummoner = selectedSummoner;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView * summonerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
    [self.view addSubview:summonerIcon];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayDetailsForSummoner:(Summoners *)selectedSummoner{
    self.selectedSummoner = selectedSummoner;
}

#pragma mark - TABLEVIEW DATA SOURCE
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * headerTitle = (section == 0) ? @"Summoner Data" : @"At a Glance";
    return headerTitle;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = self.selectedSummoner.summonerName;
    
    return cell;
}

@end
