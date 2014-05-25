//
//  MEViewController.m
//  MyBeacon
//
//  Created by Ingo Wiederoder on 12.10.13.
//  Copyright (c) 2013 Ingo Wiederoder. All rights reserved.
//


#import "MEViewController.h"

NSString *const kUUUIDString = @"F2C0D44D-6C90-4B38-B37D-65D223DB19C0";
NSString *const kBeaconID = @"com.media-engineering.MyBeacon";

@interface MEViewController ()

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (weak, nonatomic) IBOutlet UILabel *monitorLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *serviceButton;

@end

@implementation MEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *options = @{CBPeripheralManagerOptionShowPowerAlertKey:@YES };
    //wichtig: Manager muss Property sein
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:options];
    CALayer *indicatorLayer = self.indicatorBackground.layer;
    [indicatorLayer setCornerRadius:6.0f];
    [self.indicatorBackground clipsToBounds];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.serviceButton.enabled = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)startBTService:(id)sender {
    static BOOL isRunnig = NO;
    if (isRunnig == NO) {
        [self adverticeBeaconRegion];
        isRunnig = YES;
    }
    else {
        [self.peripheralManager stopAdvertising];
        [self.activityIndicator stopAnimating];
        self.indicatorBackground.hidden = YES;
        self.monitorLabel.text = @"Service stopped";
        isRunnig = NO;
    }
}

- (void)adverticeBeaconRegion
{
    /*
     Vier Schritte:
     1. BeaconRegion erzeugen
     2. NSDictionary mit peripheralData erzeugen
     3. CBPeripheralManager starten
     */
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kUUUIDString];
    uint16_t majorValue = 10;
    uint16_t minorValue = 42;
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:majorValue minor:minorValue identifier:kBeaconID];
    NSDictionary *beaconRegionData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconRegionData];
}


#pragma mark peripheralManagerDelegate


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) NSLog(@"AdvertisingError: %@",error);
    if (peripheral.isAdvertising) {
        self.monitorLabel.text = @"Advertising beacon service";
        self.indicatorBackground.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    else {
        self.monitorLabel.text = @"No beacon service";
    }
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *stateString;
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            stateString = @"No power";
            self.serviceButton.enabled = NO;
            [self.peripheralManager stopAdvertising];
            break;
        case CBPeripheralManagerStatePoweredOn:
            stateString = @"Bluetooth is ready";
            self.serviceButton.enabled = YES;
            break;
        case CBPeripheralManagerStateUnsupported:
            stateString = @"Bluetooth not supported";
            self.serviceButton.enabled = NO;
            break;
        default:
            break;
    }
    self.monitorLabel.text = stateString;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}


@end
