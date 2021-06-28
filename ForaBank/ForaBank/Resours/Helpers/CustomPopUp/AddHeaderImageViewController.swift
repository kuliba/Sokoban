//
//  AddHeaderImageViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.06.2021.
//

import UIKit

class AddHeaderImageViewController: UIViewController, AppHeaderProtocol {
    
    func addHeaderImage() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 80, width: 80, height: 10))
        imageView.image = UIImage(named: "headerView")
        self.view.addSubview(imageView)
        imageView.centerX(inView: self.view, topAnchor: self.view.topAnchor, paddingTop: 8)
//        imageView.center.x = view.center.x
        
    }
}
