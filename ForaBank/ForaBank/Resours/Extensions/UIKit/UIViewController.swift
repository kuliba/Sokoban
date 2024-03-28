//
//  UIViewController.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

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
    
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: U, for indexPath: IndexPath, getUImage: @escaping (Md5hash) -> UIImage?) -> T {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellType.reuseId,
                for: indexPath) as? T
        else {
            fatalError("Unable to dequeue \(cellType)")
        }

        cell.configure(with: value, getUImage: getUImage)
        return cell
    }
    
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = { }) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                completion()
            }
            alertController.addAction(okAction)
            alertController.view.tintColor = .black
            alertController.view.center = self.view.center
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertWithCancel(with title: String, and message: String, buttonTitle: String = "OK", completion: @escaping () -> Void = { }) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonTitle, style: .default) { (_) in
                completion()
            }
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancel)
            alertController.addAction(okAction)
            alertController.view.tintColor = .black
            alertController.view.center = self.view.center
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Добавить",
                         cancelTitle:String? = "Отмена",
                         inputText:String? = nil,
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.text = inputText
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        alert.modalPresentationCapturesStatusBarAppearance = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActivity() {
        DispatchQueue.main.async {
            
            UIApplication.shared.keyWindow?.startIndicatingActivity()
        }
    }

    func dismissActivity() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.stopIndicatingActivity()
        }
    }
    
    func addCloseButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onClose))
        button.tintColor = .black
        navigationItem.leftBarButtonItem = button
    }
    
    func addCloseButton_setting() {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onClose))
        button.tintColor = .black
        navigationItem.leftBarButtonItem = button

        let imageViewRight = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        imageViewRight.contentMode = .scaleAspectFit
        imageViewRight.image = UIImage(named: "Right Actionable")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageViewRight)
    }
    
    func addCloseButton_1() {
        let button = UIBarButtonItem(image: UIImage(systemName: "barcode"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onClose))
        navigationItem.leftBarButtonItem = button
    }
    
    func addCloseButton_2() {
        let button = UIBarButtonItem(image: UIImage(systemName: "qrIcon"),
                                     landscapeImagePhone: nil,
                                     style: .plain,
                                     target: self,
                                     action: #selector(onClose))
        navigationItem.rightBarButtonItem = button
    }
    func addCloseButton_3() {
        let button = UIBarButtonItem(image: UIImage(named: "back_button"),
                                     landscapeImagePhone: nil,
                                     style: .plain,
                                     target: self,
                                     action: #selector(onClose))
        navigationItem.rightBarButtonItem = button
    }
    
    func addCloseButton_xMark() {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onClose))
        button.tintColor = .black
        navigationItem.rightBarButtonItem = button
    }
    
    func addBackButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onBack))
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func onBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onClose(){
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        return instantiateFromNib()
    }
    
    class func loadFromStoryboard<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("Error: No initial view controller in \(name) storyboard!")
        }
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
        indicator.color = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        indicator.center = center
        indicator.backgroundColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.2)
        indicator.hidesWhenStopped = true
        let transfrom = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
        indicator.transform = transfrom
        return indicator
    }
}
