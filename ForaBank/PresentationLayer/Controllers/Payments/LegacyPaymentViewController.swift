

import UIKit
import TKFormTextField

class LegacyPaymentViewController: UIViewController {

  @IBOutlet weak var emailTextField: TKFormTextField!
 
  @IBOutlet weak var submitButton: UIButton!
  
  let submitSegueId = "submit"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
   
  }
  
  @objc func onTapBackground() {
    self.view.endEditing(true)
  }
  
  func addTargetForErrorUpdating(_ textField: TKFormTextField) {
    textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
    textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
  }
  
  @objc func updateError(textField: TKFormTextField) {
    textField.error = validationError(textField)
    self.submitButton.isEnabled = isAllTextFieldsValid()
  }
  
  @objc func clearErrorIfNeeded(textField: TKFormTextField) {
    if validationError(textField) == nil {
      textField.error = nil
    }
    self.submitButton.isEnabled = isAllTextFieldsValid()
  }
  
  fileprivate func isAllTextFieldsValid() -> Bool {
    return validationError(emailTextField) == nil
  }
  
  private func validationError(_ textField: TKFormTextField) -> String? {
    if textField == emailTextField {
      return TKDataValidator.email(text: textField.text)
    }
    return nil
  }
  
  @IBAction func submit(_ sender: Any) {
    self.performSegue(withIdentifier: submitSegueId, sender: nil)
  }
  
}

extension LegacyPaymentViewController: UITextFieldDelegate {

}

class TKDataValidator {
  class func email(text: String?) -> String? {
    guard let text = text, !text.isEmpty else {
      return "Email is missing."
    }
    guard text.tk_isValidEmail() else {
      return "Email is invalid."
    }
    return nil
  }
  
  class func password(text: String?) -> String? {
    guard let text = text, text.count >= 6 else {
      return "Password is invalid."
    }
    return nil
  }
}

private extension String {
  func tk_isValidEmail() -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: self)
  }
}
