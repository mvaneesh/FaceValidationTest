
import UIKit
import AimBrainSDK

class ViewController: UIViewController {

  @IBOutlet weak var lipSyncButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    lipSyncButton.layer.borderWidth = 1
    lipSyncButton.layer.borderColor = UIColor.lightGray.cgColor
  }
  
  @IBAction func onTapLivelinessWithLipSync(_ sender: Any) {
    performLipSyncAuth()
  }
  
  @IBAction func onTapFaceCompare(_ sender: Any) {
  }
  
  private func performLipSyncAuth() {
    let type = AMBNFaceTokenType.auth
    AMBNManager.sharedInstance().createSession(withUserId: UUID().uuidString) { (result, error) in
      if result != nil {
        AMBNManager.sharedInstance()?.enrollFaceImages(self.getTestImage(), completionHandler: { (enrollResult, error) in
          if let _ = enrollResult {
            
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
        })
      }
    }
  }
  
  private func getTestImage() -> [UIImage] {
    var eidPhotoImageArr: [UIImage] = []
    if let faceImage = UIImage(named: "testPhoto") {
      eidPhotoImageArr.append(faceImage)
    }
    return eidPhotoImageArr
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
    
    AMBNManager.sharedInstance()?.authenticateFaceVideo(video, completionHandler: { (result, error) in
      if let result = result {
        let alertController = UIAlertController(title: "",
                                                message: String(format: "Liveliness %d, Score- %d", result.liveliness.boolValue, result.score.boolValue),
                                                preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        faceRecordingViewController.present(alertController, animated: true, completion: nil)
      }
    })
  }
}


