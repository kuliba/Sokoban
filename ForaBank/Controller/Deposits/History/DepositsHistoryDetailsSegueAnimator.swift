//
//  DepositsHistoryDetailsSegueAnimator.swift
//  ForaBank
//
//  Created by Sergey on 23/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsHistoryDetailsSegueAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) as? DepositsHistoryDetailsViewController,
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        else {
                return
        }
        let containerView = transitionContext.containerView
        print("animateTransition")
        print(containerView.subviews)
        print(fromVC)
        print(toVC)
        print(fromVC.children)
        print(transitionContext.view(forKey: .from) as Any)
        print(transitionContext.view(forKey: .to) as Any)
        print(transitionContext.view(forKey: .from)?.subviews as Any)
        //containerView.addSubview(snapshot)
        //fromVC.view.removeFromSuperview()
        
        let gradientView = GradientView()
        gradientView.color1 = UIColor(hexFromString: "ED4F48")
        gradientView.color2 = UIColor(hexFromString: "9F3057")
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+33)
        print(rect)
        gradientView.frame = rect
        
        containerView.addSubview(gradientView)
        containerView.addSubview(toVC.view)
        //toVC.view.alpha = 0
        
        let popDown = CGAffineTransform(translationX: 0, y: -gradientView.frame.height)
        
        //toVC.view.transform = popDown
        toVC.view.alpha = 0
        
        
        
        let gradientViewMask = CAShapeLayer()
        gradientViewMask.frame = rect
        let y: CGFloat = rect.height
        let curveTo: CGFloat = 0

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: y))
        bezierPath.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        bezierPath.addLine(to: CGPoint(x: rect.width, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
//        let context = UIGraphicsGetCurrentContext()
//        context!.setLineWidth(4.0)
//        UIColor.white.setFill()
//        bezierPath.fill()

        gradientViewMask.path = bezierPath.cgPath
        gradientViewMask.fillRule = CAShapeLayerFillRule.evenOdd
        //gradientView.layer.mask = gradientViewMask
        
        //print(gradientViewMask.frame)
        gradientView.transform = popDown
        
        let duration = self.transitionDuration(using: transitionContext)
        //gradientView.frame.origin.y = -gradientView.frame.height
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                //snapshot.transform = snapshotDown
                //fromVC.view.transform = snapshotDown
                //toVC.view.transform = CGAffineTransform.identity
                gradientView.transform = CGAffineTransform.identity
                //gradientView.frame.origin.y = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                toVC.view.alpha = 1
            })
            
            
        }, completion: { (_) in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
//        UIView.animate(withDuration: duration, animations: {
//            snapshot.transform = snapshotDown
//            //toViewController.view.alpha = 1
//        }, completion: { _ in
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
    }

}
