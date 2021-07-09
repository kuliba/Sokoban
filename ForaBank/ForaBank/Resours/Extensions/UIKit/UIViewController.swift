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
            ProgressHUD.animationType = .circleRotateChase
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

extension UIWindow {
    private static let association = ObjectAssociation<UIActivityIndicatorView>()
    
    private static var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var activityIndicator: UIActivityIndicatorView {
        set { UIWindow.association[self] = newValue }
        get {
            if let indicator = UIWindow.association[self] {
                return indicator
            } else {
                UIWindow.association[self] = UIActivityIndicatorView.customIndicator(at: self.center)
                return UIWindow.association[self]!
            }
        }
    }
    
    // MARK: - Activity Indicator
    public func startIndicatingActivity(_ ignoringEvents: Bool? = true) {
        DispatchQueue.main.async {
            self.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            if ignoringEvents! {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        }
    }
    
    public func stopIndicatingActivity() {
        DispatchQueue.main.async {
            self.activityIndicator.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    public func addBlure() {
        DispatchQueue.main.async {
            UIWindow.visualEffectView.alpha = 0.97
            UIWindow.visualEffectView.frame =
                CGRect(x: 0.0, y: 0.0,
                       width: UIScreen.main.bounds.size.width,
                       height: UIScreen.main.bounds.size.height)
            self.addSubview(UIWindow.visualEffectView)
            
        }
    }
    
    public func deleteBlure() {
        DispatchQueue.main.async {
            UIWindow.visualEffectView.removeFromSuperview()
        }
    }
    
    
}

public final class ObjectAssociation<T: AnyObject> {
    
    private let policy: objc_AssociationPolicy
    
    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        self.policy = policy
    }
    
    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}

extension UIActivityIndicatorView {
    public static func customIndicator(at center: CGPoint) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        indicator.layer.cornerRadius = 0
        indicator.color = .white // #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        indicator.center = center
        indicator.backgroundColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.5)
        indicator.hidesWhenStopped = true
        let transfrom = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
        indicator.transform = transfrom
        return indicator
    }
}
