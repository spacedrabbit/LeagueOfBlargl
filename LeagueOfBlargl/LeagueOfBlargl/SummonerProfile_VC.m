//
//  SummonerProfile_VC.m
//  LeagueOfBlargl
//
//  Created by Louis Tur on 1/7/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "SummonerProfile_VC.h"
#import "Summoners.h"

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayDetailsForSummoner:(Summoners *)selectedSummoner{
    self.selectedSummoner = selectedSummoner;
}

@end
