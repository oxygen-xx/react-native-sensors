// Inspired by https://github.com/pwmckenna/react-native-motion-manager

#import "DeviceMotion.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

@implementation DeviceMotion

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"DeviceMotion");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
        //DeviceMotion
        if([self->_motionManager isDeviceMotionAvailable])
        {
            NSLog(@"DeviceMotion available");
            /* Start the accelerometer if it is not active already */
            if([self->_motionManager isDeviceMotionActive] == NO)
            {
                NSLog(@"DeviceMotion active");
            } else {
                NSLog(@"DeviceMotion not active");
            }
        }
        else
        {
            NSLog(@"DeviceMotion not available!");
        }
    }
    return self;
}

RCT_EXPORT_METHOD(setUpdateInterval:(double) interval) {
    NSLog(@"setDiviceMotionUpdateInterval: %f", interval);
    double intervalInSeconds = interval / 1000;

    [self->_motionManager setDeviceMotionUpdateInterval:intervalInSeconds];
}

RCT_EXPORT_METHOD(getUpdateInterval:(RCTResponseSenderBlock) cb) {
    double interval = self->_motionManager.deviceMotionUpdateInterval;
    NSLog(@"getUpdateInterval: %f", interval);
    cb(@[[NSNull null], [NSNumber numberWithDouble:interval]]);
}

RCT_EXPORT_METHOD(getData:(RCTResponseSenderBlock) cb) {

    cb(@[[NSNull null], @{
                                                                                     @"gravity": @{
                                                                                     	@"x": [NSNumber numberWithDouble:self->_motionManager.deviceMotion.gravity.x],
                                                                                     	@"y": [NSNumber numberWithDouble:self->_motionManager.deviceMotion.gravity.y],
                                                                                     	@"z": [NSNumber numberWithDouble:self->_motionManager.deviceMotion.gravity.z]
																							 },
																					@"attitude": @{
                                                                                     	@"yaw": [NSNumber numberWithDouble:self->_motionManager.deviceMotion.attitude.yaw],
                                                                                     	@"pitch": [NSNumber numberWithDouble:self->_motionManager.deviceMotion.attitude.pitch],
                                                                                     	@"roll": [NSNumber numberWithDouble:self->_motionManager.deviceMotion.attitude.roll]
																							 }
																					 
                                                                                 }]
       );
}

RCT_EXPORT_METHOD(startUpdates) {
    NSLog(@"startUpdates");
    [self->_motionManager startDeviceMotionUpdates];

    /* Receive the gyroscope data on this block */
    [self->_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                      withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
        //  double x = gyroData.rotationRate.x;
        //  double y = gyroData.rotationRate.y;
        //  double z = gyroData.rotationRate.z;
        //  double timestamp = gyroData.timestamp;
        //  NSLog(@"startUpdates: %f, %f, %f, %f", x, y, z, timestamp);
		 CMAttitude *attitude =  motion.attitude;
		 NSLog(@"startUpdates: %f, %f, %f", attitude.yaw, attitude.pitch, attitude.roll);
         [self.bridge.eventDispatcher sendDeviceEventWithName:@"DeviceMotion" body:@{
                                                                                     @"gravity": @{
                                                                                     	@"x": [NSNumber numberWithDouble:motion.gravity.x],
                                                                                     	@"y": [NSNumber numberWithDouble:motion.gravity.y],
                                                                                     	@"z": [NSNumber numberWithDouble:motion.gravity.z]
																							 },
																					@"attitude": @{
                                                                                     	@"yaw": [NSNumber numberWithDouble:attitude.yaw],
                                                                                     	@"pitch": [NSNumber numberWithDouble:attitude.pitch],
                                                                                     	@"roll": [NSNumber numberWithDouble:attitude.roll]
																							 }
                                                                                     
                                                                                 }];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    NSLog(@"stopUpdates");
    [self->_motionManager stopDeviceMotionUpdates];
}

@end
