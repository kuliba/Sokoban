//
//  ExtensionGKHInputNav.swift
//  ForaBank
//
//  Created by Константин Савялов on 27.08.2021.
//

import UIKit

extension GKHInputViewController {
    
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
        
        return titleView
    }
    
    func setupNavBar() {
        
        navigationItem.titleView = setTitle(title: "Все", subtitle: "0000")
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "qr_Icon") , style: .plain, target: self, action: #selector(onQR))
//
//        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
//            [.foregroundColor: UIColor.black], for: .normal)
//        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
//            [.foregroundColor: UIColor.black], for: .highlighted)
        
    }
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
