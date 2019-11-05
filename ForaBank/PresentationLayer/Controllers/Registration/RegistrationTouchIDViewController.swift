import UIKit
import LocalAuthentication
import BiometricAuthentication

class RegistrationTouchIDViewController: UIViewController {

    @IBOutlet weak var touchIDButton: UIButton!


    @IBAction func backButtonClicked(_ sender: Any) {
        //        dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }

    let touchMe = BiometricIDAuth()
    var segueId: String? = nil

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
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Используйте для входа в приложение") { _ in
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
