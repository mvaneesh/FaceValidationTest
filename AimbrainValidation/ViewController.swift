
import UIKit
import AimBrainSDK

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  @IBAction func onTapLivelinessWithLipSync(_ sender: Any) {
    performLipSyncAuth()
  }
  
  @IBAction func onTapFaceCompare(_ sender: Any) {
    performFaceCompare()
  }
  
  private func performLipSyncAuth() {
    let type = AMBNFaceTokenType.enroll1
    AMBNManager.sharedInstance().createSession(withUserId: UUID().uuidString) { (result, error) in
      if result != nil {
        //        AMBNManager.sharedInstance()?.enrollFaceImages(self.getEIDImage(), completionHandler: { (enrollResult, error) in
        //          if let result = enrollResult {
        
        AMBNManager.sharedInstance().getFaceToken(with: type) { (result, error) in
          if let token = result {
            let tokenText = token.tokenText
            
            
            let stringToken = String(format: "Please read: %@", tokenText ?? "")
            let viewController = AMBNManager.sharedInstance()?.instantiateFaceRecordingViewController(withTopHint: "Position your face fully within the outline and read the number shown below.", bottomHint: stringToken, tokenText: stringToken, videoLength: 2)
            viewController?.delegate = self
            if let videoController = viewController {
              self.present(videoController, animated: true, completion: nil)
            }
          }
        }
      }
      //})
      //}
    }
  }
  
  private func getTestImage() -> UIImage? {
    return UIImage(named: "testPhoto")
  }
  
  private func performFaceCompare() {
    guard let testPhoto = getTestImage() else {
      return
    }
    let eidPhotoImageArr: [UIImage] = [testPhoto]
    AMBNManager.sharedInstance().openFaceImagesCapture(
      withTopHint: "To authenticate please face the camera directly and press 'camera' button",
      bottomHint: "Position your face fully within the outline with eyes between the lines.",
      batchSize: 3,
      delay: 0.3,
      from: self) { (images, error) in
        AMBNManager.sharedInstance().createSession(withUserId: UUID().uuidString) { (result, error) in
          if result != nil {
            AMBNManager.sharedInstance().compareFaceImages(eidPhotoImageArr, toFaceImages: images, completionHandler: { (result, error) in
              DispatchQueue.main.async {
                if let compareResult = result {
                  self.showAlert(with: String(format: "Success : %d", compareResult.secondLiveliness.intValue))
                } else {
                  self.showAlert(with: "Error")
                }
              }
            })
          }
        }
    }
  }
  
  private func getEIDImagetoEnroll() -> UIImage {
    return UIImage()
  }
  
  private func showAlert(with message: String) {
    let alertController = UIAlertController(title: "",
                                            message: message,
                                            preferredStyle: .alert)
    
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    present(alertController, animated: true, completion: nil)
  }
}

extension ViewController: AMBNFaceRecordingViewControllerDelegate {
  func faceRecordingViewController(_ faceRecordingViewController: AMBNFaceRecordingViewController!, recordingResult video: URL!, error: Error!) {
    
    AMBNManager.sharedInstance()?.enrollFaceVideo(video, completionHandler: { (result, error) in
      if let result = result {
        print(result.success)
      } else {
        self.showAlert(with: "failed")
      }
    })
  }
}


