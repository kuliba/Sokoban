//
//  ChangePasscodeVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 06.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import TOPasscodeViewController
import ReSwift
//import BiometricAuthentication

class ChangePasscodeVC: UIViewController, StoreSubscriber{

    let passcodeVC = PasscodeViewController(rightTitle: NSLocalizedString("Logout", comment: "Logout"), style: .opaqueLight, passcodeType: .fourDigits)
    typealias SignInState = (passcodeState: PasscodeSignInState, verificationState: VerificationCodeState)
    
    var stateChangePasscode = 0
    var newPasscode = String()
    var oldPassowrd = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeVC.passcodeView.titleLabel.adjustsFontSizeToFitWidth = true
//        passcodeVC.passcodeView.titleLabel.text = "Введите текущий код"
//        passcodeVC.rightAccessoryButton?.titleLabel?.text = "Выход"

        if keychainCredentialsPasscode() == nil{
            passcodeVC.passcodeView.titleLabel.text = "Установите новый код"
            stateChangePasscode = 1
        }else{
            passcodeVC.passcodeView.titleLabel.text = "Введите текущий код"
            passcodeVC.rightAccessoryButton?.titleLabel?.text = "Выход"
        }
        
        passcodeVC.delegate = self
        //passcodeVC.automaticallyPromptForBiometricValidation = true
        //passcodeVC.allowBiometricValidation = true

//        if BioMetricAuthenticator.shared.touchIDAvailable() && SettingsStorage.shared.allowedBiometricSignIn() {
//            passcodeVC.biometryType = .touchID
//        } else if BioMetricAuthenticator.shared.faceIDAvailable() && SettingsStorage.shared.allowedBiometricSignIn() {
//            passcodeVC.biometryType = .faceID
//        } else {
//            passcodeVC.leftAccessoryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//            passcodeVC.allowBiometricValidation = false
//        }

        passcodeVC.willMove(toParent: self)
        self.view.addSubview(passcodeVC.view)
        self.addChild(passcodeVC)
        passcodeVC.didMove(toParent: self)
        
    }
    

    func newState(state: SignInState) {
        guard state.passcodeState.isShown == true else {
            dismiss(animated: true, completion: nil)
            return
        }
        if state.passcodeState.failCounter >= 1 {
            passcodeVC.passcodeView.titleLabel.text = "Осталось \(3 - state.passcodeState.failCounter) попыток"
            passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: false)
        }

        if state.verificationState.isShown == true {
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - TOPasscodeViewControllerDelegate

extension ChangePasscodeVC: TOPasscodeViewControllerDelegate{

    // тут проверяем код который ввел пользователь
    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: false)
        switch stateChangePasscode {
        case 0: //проверка на правильный старый пароль
            guard code == keychainCredentialsPasscode()else{
                passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: true)
                return false
            }
            oldPassowrd = code
            return true
        case 1: //записавыем новый пароль
            newPasscode = code // запоминаем новый код
            return true
        case 2: //проверяем повтор нового пароля
            guard newPasscode == code else {
                passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: true)
                return false
            }
            return true
        default:
            return false
        }
    }

    //если код правильный
    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {
        switch stateChangePasscode {
        case 0: //если пароль правильный
            stateChangePasscode = 1 // переводим на стадию создания нового пароля
            passcodeVC.passcodeView.titleLabel.text = "Установите новый код"
        case 1: // установка нового пароля
            stateChangePasscode = 2 // переводим на стадию повтора нового пароля
            passcodeVC.passcodeView.titleLabel.text = "Повторите новый код"
        case 2:
            // сначала удаляем пароль
            unsafeRemoveEncryptedPasscodeFromKeychain()
            unsafeRemovePasscodeFromKeychain()
            
            //сохраняем новый пароль
            savePasscodeToKeychain(passcode: newPasscode)
            if let encryptedPasscode = encrypt(passcode: newPasscode) {
                saveEncryptedPasscodeToKeychain(passcode: encryptedPasscode)
            }
            
            if let dataUserEncrypt = keychainCredentialsUserData(){ //получаем данные пользователя
                if let dataUser = decryptUserData(userData: dataUserEncrypt, withPossiblePasscode: oldPassowrd){ //расшифровываем данные пользователя
                    if let saveUserData = encrypt(userData: dataUser, withPasscode: newPasscode){ //расшифровываем данные пользователя с новым passcode
                        updateUserData(saveUserData: saveUserData)
                    }
                }else if let dataUser = decryptUserData(userData: dataUserEncrypt, withPossiblePasscode: "passcode"){
                    if let saveUserData = encrypt(userData: dataUser, withPasscode: newPasscode){ //расшифровываем данные пользователя с новым passcode
                        updateUserData(saveUserData: saveUserData)
                    }
                }
            }else{
                self.dismiss(animated: true, completion: nil)
            }
            self.dismiss(animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }

    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        PasscodeService.shared.cancelPasscodeAuth()
    }
}

//MARK: Update User Data
extension ChangePasscodeVC{
    // обновляем UserData
    private func updateUserData( saveUserData: String){
        unsafeRemoveUserDataFromKeychain() //удаляем данные перед записью новых
        saveUserDataToKeychain(userData: saveUserData)
    }

}
