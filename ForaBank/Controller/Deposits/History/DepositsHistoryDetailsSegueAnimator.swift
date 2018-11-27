//
//  DepositsHistoryDetailsSegueAnimator.swift
//  ForaBank
//
//  Created by Sergey on 23/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsHistoryDetailsSegueAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    // MARK: методы протокола UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: методы протокола UIViewControllerAnimatedTransitioning
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.viewController(forKey: .to) is DepositsHistoryDetailsViewController {
            animateSegueToDetailsViewController(using: transitionContext)
        } else if transitionContext.viewController(forKey: .from) is DepositsHistoryDetailsViewController {
            animateUnwindSegue(using: transitionContext)
        } else {
            print("DepositsHistoryDetailsSegueAnimator unprovided transition")
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}

extension DepositsHistoryDetailsSegueAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //context?.completeTransition(true)
    }
}

// MARK: - Private methods
extension DepositsHistoryDetailsSegueAnimator {
    func animateSegueToDetailsViewController(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) as? DepositsHistoryDetailsViewController,
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
            else {
                print("DepositsHistoryDetailsSegueAnimator animateSegueToDetailsViewController guard return")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(snapshot)
        fromVC.view.removeFromSuperview()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            UIColor(hexFromString: "ED4F48").cgColor,
            UIColor(hexFromString: "9F3057").cgColor
        ]
        
        containerView.layer.addSublayer(gradientLayer)
        containerView.addSubview(toVC.view)
        toVC.view.alpha = 0
        
        let mask = CAShapeLayer()
        gradientLayer.mask = mask
        
        let pathInitial = UIBezierPath()
        pathInitial.move(to: CGPoint(x: 0, y: 0))
        pathInitial.addQuadCurve(to: CGPoint(x: gradientLayer.frame.width, y: 0), controlPoint: CGPoint(x: gradientLayer.frame.width / 2, y: -33))
        pathInitial.addLine(to: CGPoint(x: gradientLayer.frame.width, y: -33))
        pathInitial.addLine(to: CGPoint(x: 0, y: -33))
        pathInitial.close()
        
        let pathFinal = UIBezierPath()
        pathFinal.move(to: CGPoint(x: 0, y: gradientLayer.frame.height+33))
        pathFinal.addQuadCurve(to: CGPoint(x: gradientLayer.frame.width, y: gradientLayer.frame.height+33),
                               controlPoint: CGPoint(x: gradientLayer.frame.width / 2, y: gradientLayer.frame.height))
        pathFinal.addLine(to: CGPoint(x: gradientLayer.frame.width, y: 0))
        pathFinal.addLine(to: CGPoint(x: 0, y: 0))
        pathFinal.close()
        
        let dur = transitionDuration(using: transitionContext)
        
        CATransaction.begin()
        let a1 = CABasicAnimation(keyPath: "path")
        a1.fromValue = pathInitial.cgPath
        a1.toValue = pathFinal.cgPath
        a1.duration = dur/2
        a1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let a2 = CABasicAnimation(keyPath: "opacity")
        a2.fromValue = 0
        a2.toValue = 1
        a2.duration = dur/2
        a2.beginTime = CACurrentMediaTime() + dur/2 //CACurrentMediaTime() + dur/2
        
        let a3 = CATransition()
        a3.type = CATransitionType.moveIn
        a3.subtype = CATransitionSubtype.fromRight
        a3.duration = dur/2
        a3.beginTime = CACurrentMediaTime() + dur/2 //CACurrentMediaTime() + dur/2
        a3.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        //completition
        CATransaction.setCompletionBlock {
            toVC.view.alpha = 1
            gradientLayer.removeFromSuperlayer()
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        // add animation
        mask.add(a1, forKey: "path")
        toVC.view.layer.add(a2, forKey: "opacity")
        toVC.infoView.layer.add(a3, forKey: "transition")
        CATransaction.commit()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        mask.path = pathFinal.cgPath
        CATransaction.commit()
    }
    
    func animateUnwindSegue(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) as? DepositsHistoryDetailsViewController
            else {
                print("DepositsHistoryDetailsSegueAnimator animateUnwindSegue guard return")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        let screenRect = UIScreen.main.bounds
        let containerView = transitionContext.containerView
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = screenRect
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            UIColor(hexFromString: "ED4F48").cgColor,
            UIColor(hexFromString: "9F3057").cgColor
            
        ]
        containerView.layer.insertSublayer(gradientLayer, below: fromVC.view.layer)
        containerView.insertSubview(toVC.view, at: 0)
        fromVC.view.layer.opacity=0
        
        let mask = CAShapeLayer()
        gradientLayer.mask = mask

        let pathFinal = UIBezierPath()
        pathFinal.move(to: CGPoint(x: 0, y: 0))
        pathFinal.addQuadCurve(to: CGPoint(x: gradientLayer.frame.width, y: 0), controlPoint: CGPoint(x: gradientLayer.frame.width / 2, y: -33))
        pathFinal.addLine(to: CGPoint(x: gradientLayer.frame.width, y: -33))
        pathFinal.addLine(to: CGPoint(x: 0, y: -33))
        pathFinal.close()

        let pathInitial = UIBezierPath()
        pathInitial.move(to: CGPoint(x: 0, y: gradientLayer.frame.height+33))
        pathInitial.addQuadCurve(to: CGPoint(x: gradientLayer.frame.width, y: gradientLayer.frame.height+33),
                               controlPoint: CGPoint(x: gradientLayer.frame.width / 2, y: gradientLayer.frame.height))
        pathInitial.addLine(to: CGPoint(x: gradientLayer.frame.width, y: 0))
        pathInitial.addLine(to: CGPoint(x: 0, y: 0))
        pathInitial.close()

        mask.path = pathInitial.cgPath
        
        let dur = transitionDuration(using: transitionContext)

        CATransaction.begin()
        
        let a1 = CAKeyframeAnimation(keyPath: "transform.translation.x")
        a1.keyTimes = [0, 0.5, 1]
        a1.values = [0, screenRect.width, screenRect.width]
        a1.duration = dur
        a1.isRemovedOnCompletion = true
        
        let a2 = CAKeyframeAnimation(keyPath: "opacity")
        a2.keyTimes = [0, 0.5, 1]
        a2.values = [1, 0, 0]
        a2.duration = dur
        a2.isRemovedOnCompletion = true

        let a3 = CABasicAnimation(keyPath: "path")
        a3.fromValue = pathInitial.cgPath
        a3.toValue = pathFinal.cgPath
        a3.duration = dur/2
        a3.beginTime =  CACurrentMediaTime() + dur/2
        a3.isRemovedOnCompletion = true
        a3.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        //completition
        CATransaction.setCompletionBlock {
            fromVC.view.removeFromSuperview()
            gradientLayer.removeFromSuperlayer()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        // add animation
        fromVC.infoView.layer.add(a1, forKey: "transform.translation.x")
        fromVC.view.layer.add(a2, forKey: "opacity")
        mask.add(a3, forKey: "path")
        CATransaction.commit()
    }
}
