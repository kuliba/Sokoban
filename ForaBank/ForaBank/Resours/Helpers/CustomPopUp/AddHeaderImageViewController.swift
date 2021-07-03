//
//  AddHeaderImageViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.06.2021.
//

import UIKit

class AddHeaderImageViewController: UIViewController, AppHeaderProtocol {
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    func addHeaderImage() {
        let panGesture = UIPanGestureRecognizer(
            target: self, action: #selector(panGestureRecognizerAction))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 80, width: 80, height: 10))
        imageView.image = UIImage(named: "headerView")
        
        view.addSubview(imageView)
        view.addGestureRecognizer(panGesture)
                
        imageView.centerX(inView: view, topAnchor: view.topAnchor, paddingTop: 8)
    }
    
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        guard translation.y >= 0 else { return }
        
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 800 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
}
