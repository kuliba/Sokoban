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
        ProgressHUD.show()
    }

    func dismissActivity() {
        ProgressHUD.dismiss()
    }
    
}
