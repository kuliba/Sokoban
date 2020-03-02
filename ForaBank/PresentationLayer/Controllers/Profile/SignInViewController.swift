/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero
import RMMapper

class SignInViewController: UIViewController, ContactsPickerDelegate {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var contentView: RoundedEdgeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var centralView: UIView!


    var segueId: String? = nil
    var backSegueId: String? = nil


    @IBAction func contactList(_ sender: Any) {
        let contactPickerScene = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.email)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.present(navigationController, animated: true, completion: nil)

    }
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error \(error.description)")
    }

    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) {
        print("Contact \(contact.displayName) has been selected")
    }

    func contactPickerDidCancel(_ picker: ContactsPicker) {
        picker.dismiss(animated: true, completion: nil)
        print("User canceled the selection")
    }

    func contactPicker(_ picker: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        guard !contacts.isEmpty else { return }
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)")
        }

    }


    // MARK: - Actions
    @IBAction func backButtonClicked() {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
    }
    @IBAction func tappedButton(sender: UIButton!) {
    }

    @IBAction func signInButtonClicked() {
        NetworkManager.shared().login(login: self.loginTextField.text ?? "",
                                      password: self.passwordTextField.text ?? "",
                                      completionHandler: { [unowned self] success, errorMessage in
                                          if success {
                                              self.performSegue(withIdentifier: "smsVerification", sender: self)
                                              store.dispatch(createCredentials(login: self.loginTextField.text ?? "", pwd: self.passwordTextField.text ?? ""))
                                        

                                            
                                          } else {
                                              AlertService.shared.show(title: "Неудача", message: errorMessage, cancelButtonTitle: "Ок", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
                                          }
                                      })
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = loginTextField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignIn" {
            contentView.hero.id = "content"
            contentView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.beginWith([HeroModifier.opacity(1)]),
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "smsVerification" {
            contentView.hero.id = "content"
            view.hero.id = "view"
            view.hero.modifiers = [
                HeroModifier.duration(0.5)
            ]
            centralView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.forceAnimate,
                HeroModifier.delay(0),
                HeroModifier.zPosition(1),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.hero.modifiers = nil
        contentView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView.hero.modifiers = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "SignIn" {
            contentView.hero.id = "content"
            contentView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "smsVerification" {
            contentView.hero.id = "content"
            view.hero.id = "view"
            view.hero.modifiers = [
                HeroModifier.duration(0.5)
            ]
            centralView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0)),
                HeroModifier.forceNonFade
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.hero.modifiers = nil
        contentView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView.hero.modifiers = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
        segueId = nil
        if let vc = segue.destination as? RegistrationCodeVerificationViewController {
            segueId = segue.identifier
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
    }
}


extension SignInViewController{
    private func saveLoginAndPassword(_ login: String, _ password:String){
        
    }
}
