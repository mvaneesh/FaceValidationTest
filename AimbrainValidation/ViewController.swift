
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
        self.showAlert(with: String(format: "Success %d", result.success))
      } else {
        self.showAlert(with: "failed")
      }
    })
  }
}


