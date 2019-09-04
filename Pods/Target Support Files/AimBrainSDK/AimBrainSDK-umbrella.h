#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AimBrainSDK.h"
#import "AMBNGlobal.h"
#import "AMBNLogConstants.h"
#import "AMBNManager.h"
#import "AMBNAcceleration.h"
#import "AMBNAccelerometerCollector.h"
#import "AMBNBaseEvent.h"
#import "AMBNEventBuffer.h"
#import "AMBNTextEvent.h"
#import "AMBNTextEventBuffer.h"
#import "AMBNTextInputCollector.h"
#import "AMBNTextInputCollectorDelegate.h"
#import "AMBNTouch.h"
#import "AMBNTouchCollector.h"
#import "AMBNTouchCollectorDelegate.h"
#import "AMBNCameraOverlay.h"
#import "AMBNCameraOverlayDelegate.h"
#import "AMBNCameraPreview.h"
#import "AMBNCaptureSessionConfigurator.h"
#import "AMBNFaceCaptureManager.h"
#import "AMBNFaceRecordingViewController.h"
#import "AMBNFaceRecordingViewControllerDelegate.h"
#import "AMBNImageAdapter.h"
#import "AMBNImagePickerController.h"
#import "AMBNRecordingOverlay.h"
#import "AMBNRecordingOverlayView.h"
#import "AMBNHashGenerator.h"
#import "AMBNTimeTools.h"
#import "AMBNViewIdChainExtractor.h"
#import "UIApplication+Swizzle.h"
#import "AMBNPrivacyGuard.h"
#import "AMBNNetworkClient.h"
#import "AMBNServer.h"
#import "AMBNAuthenticateResult.h"
#import "AMBNBehaviouralResult.h"
#import "AMBNCallResult.h"
#import "AMBNCompareFaceResult.h"
#import "AMBNEnrollFaceResult.h"
#import "AMBNEnrollVoiceResult.h"
#import "AMBNResult.h"
#import "AMBNSerializedRequest.h"
#import "AMBNSessionCreateResult.h"
#import "AMBNTextResult.h"
#import "AMBNVoiceTextResult.h"
#import "AMBNCircleButton.h"
#import "AMBNAudioRecorderConfigurator.h"
#import "AMBNCircularProgressView.h"
#import "AMBNVoiceRecordingManager.h"
#import "AMBNVoiceRecordingViewController.h"
#import "AMBNVoiceRecordingViewControllerDelegate.h"

FOUNDATION_EXPORT double AimBrainSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char AimBrainSDKVersionString[];

