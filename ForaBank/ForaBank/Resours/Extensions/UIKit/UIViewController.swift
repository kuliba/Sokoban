//
//  UIViewController.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit
import ProgressHUD

extension UIViewController {
    
    /// скрывает активную клавиатуру по нажатию на экран
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: U, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellType.reuseId,
                for: indexPath) as? T
        else {
            fatalError("Unable to dequeue \(cellType)")
        }
        cell.configure(with: value)
        return cell
    }
    
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = { }) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                completion()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showActivity() {
        DispatchQueue.main.async {
            ProgressHUD.colorAnimation = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
            ProgressHUD.show()
        }
    }

    func dismissActivity() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
    
    func addCloseButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onClose))
            navigationItem.leftBarButtonItem = button
        }

        @objc func onClose(){
            self.dismiss(animated: true, completion: nil)
        }
    
}
