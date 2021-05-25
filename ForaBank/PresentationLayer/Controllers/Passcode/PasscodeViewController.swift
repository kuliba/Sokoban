

import Foundation
import TOPasscodeViewController

class PasscodeViewController: TOPasscodeViewController {

    let rightTitle: String

    init(rightTitle: String, style: TOPasscodeViewStyle, passcodeType: TOPasscodeType) {
        self.rightTitle = rightTitle
        super.init(style: style, passcodeType: passcodeType)
        self.backgroundView.backgroundColor = UIColor(hexFromString: "#EA4442")
        self.passcodeView.backgroundColor = UIColor(hexFromString: "#EA4442")
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keypadButtonTapped() {
        let count = self.passcodeView.passcode?.count ?? 0
        let title = (count > 0) ? "Delete" : rightTitle

        UIView.performWithoutAnimation {
            self.cancelButton.setTitle(NSLocalizedString(title, comment: title), for: .normal)
            self.cancelButton.sizeToFit()
        }
    }

    func removeCancelButton() {
        cancelButton.setTitle("", for: .normal)
    }

    override func setUpAccessoryButtons() {
        super.setUpAccessoryButtons()
        UIView.performWithoutAnimation {
            self.cancelButton.setTitle(NSLocalizedString(rightTitle, comment: rightTitle), for: .normal)
            self.cancelButton.sizeToFit()
        }
        
    }
}

