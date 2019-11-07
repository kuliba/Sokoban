import UIKit
import LocalAuthentication
import BiometricAuthentication


protocol RegistrationTouchIDViewControllerDelegate: class {
    func passcodeFinished(success: Bool)
}

class RegistrationTouchIDViewController: UIViewController {

    @IBOutlet weak var touchIDButton: UIButton!


    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    let touchMe = BiometricIDAuth()
    var segueId: String? = nil
    weak var biometricDelegate: RegistrationTouchIDViewControllerDelegate?

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
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Используйте для входа в приложение") { [weak self](result) in
            switch result {
            case .success(_):
                self?.biometricDelegate?.passcodeFinished(success: true)
                self?.backButtonClicked(NSObject())
            case .failure(_):
                self?.biometricDelegate?.passcodeFinished(success: false)
                AlertService.shared.show(title: "Неудача", message: "Повторите попытку", cancelButtonTitle: nil, okButtonTitle: "Понятно", cancelCompletion: nil, okCompletion: nil)
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
