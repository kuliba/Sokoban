//
//  ExtensionGKHMain.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.08.2021.
//

import UIKit

extension GKHMainViewController {
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "chevron.down")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        completeText.append(attachmentString)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.frame.size.width, height: 15))
        titleView.addSubview(titleLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.titleDidTaped))
        titleView.addGestureRecognizer(gesture)
        
        return titleView
    }
    
    @objc func titleDidTaped() {
        performSegue(withIdentifier: "citySearch", sender: self)
    }
    
    func setupNavBar() {
        
        navigationItem.titleView = setTitle(title: "Все регионы", subtitle: "")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "qr_Icon") , style: .plain, target: self, action: #selector(onQR))
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
        
    }
    @objc func backAction(){
        //self.delegate?.goToBack()
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func onQR(){
        checkCameraAccess(isAllowed: {
            if $0 {
                // self.delegate?.goToQRController()
                DispatchQueue.main.async {
                    self.navigationController?.isNavigationBarHidden = true
                    self.performSegue(withIdentifier: "qr", sender: nil)
                }
            } else {
                guard self.alertController == nil else {
                        return
                    }
                self.alertController = UIAlertController(title: "Внимание", message: "Для сканирования QR кода, необходим доступ к камере", preferredStyle: .alert)
                    guard let alert = self.alertController else {
                        return
                    }
                alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: { (action) in
                        self.alertController = nil
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        })
    }
}

