import UIKit
import LocalAuthentication

class RegistrationTouchIDViewController: UIViewController {

    let touchMe = BiometricIDAuth()
    let context = LAContext()
    var segueId: String? = nil
    @IBOutlet weak var touchIDButton: UIButton!

    @IBAction func backButtonClicked(_ sender: Any) {
        //        dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()

        switch touchMe.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "FaceIcon"), for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "touchid"), for: .normal)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            self.touchIDLoginAction()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    @IBAction func touchIDLoginAction() {
        touchMe.authenticateUser() { [weak self] message in
            DispatchQueue.main.async {
                if let message = message {
                    // if the completion is not nil show an alert
                    let alertView = UIAlertController(title: "Error",
                                                      message: message,
                                                      preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Повторите попытку!", style: .default)
                    alertView.addAction(okAction)
                    self?.present(alertView, animated: true)

                } else {
                    self?.performSegue(withIdentifier: "finish", sender: self)
                }
            }
        }
    }

}
