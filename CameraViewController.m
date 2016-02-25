#import "CameraViewController.h"
#import "TakeSelfieViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoCaptureController.h"
#import <ImageIO/ImageIO.h>


@interface CameraViewController ()  {
    UIImage *selfieImage;
    NSDictionary* capturedPhotoExif;
}

@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;

@end


@implementation CameraViewController {
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.btnTakePhoto.layer.cornerRadius = 30.0;
    self.btnTakePhoto.layer.borderWidth = 1.0;
    self.btnTakePhoto.layer.borderColor = [UIColor blackColor].CGColor;
    self.btnTakePhoto.backgroundColor = [UIColor colorWithRed:178.0/255.0 green:135.0/255.0 blue:247.0/255.0 alpha:0.5];
    
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in devices) {
        if([camera position] == AVCaptureDevicePositionFront) { // is front camera
            inputDevice = camera;
            break;
        }
    }
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = self.view.layer;
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session startRunning];
    });
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LookAtSelfieSegue"]) {
        
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in stillImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                    videoConnection = connection;
                    break;
                }
            }
        }
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^ (CMSampleBufferRef imageDataSampleBuffer, NSError *error){
            if (imageDataSampleBuffer != NULL) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                selfieImage = [[UIImage alloc] initWithData:imageData];
                TakeSelfieViewController *vc = [segue destinationViewController];
                selfieImage = [UIImage imageWithCGImage:selfieImage.CGImage scale:selfieImage.scale orientation:UIImageOrientationLeftMirrored];
                vc.selfie = selfieImage;
                vc.roleColor = self.roleColor;
                vc.roleType = self.roleType;
                
            }
        }];
    }

}

- (IBAction)unwindToCameraViewController:(UIStoryboardSegue *)unwindSegue {
    
}

@end


