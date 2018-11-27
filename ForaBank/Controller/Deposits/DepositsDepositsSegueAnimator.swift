//
//  DepositsDepositsSegueAnimator.swift
//  ForaBank
//
//  Created by Sergey on 27/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsDepositsSegueAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    // MARK: методы протокола UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: методы протокола UIViewControllerAnimatedTransitioning
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.viewController(forKey: .to) is OneOneViewController {
            animateSegueToDetailsViewController(using: transitionContext)
        } else if transitionContext.viewController(forKey: .from) is OneOneViewController {
            animateUnwindSegue(using: transitionContext)
        } else {
            print("DepositsDepositsSegueAnimator unprovided transition")
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}

extension DepositsDepositsSegueAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //context?.completeTransition(true)
    }
}

// MARK: - Private methods
extension DepositsDepositsSegueAnimator {
    func animateSegueToDetailsViewController(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? UIViewController & CustomTransitionOriginator,
            let toVC = transitionContext.viewController(forKey: .to) as? UIViewController & CustomTransitionDestination
            else {
                print("DepositsDepositsSegueAnimator animateSegueToDetailsViewController guard return")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        let container = transitionContext.containerView
        print(container.subviews)
//        print(fromVC.fromAnimatedSubviews)
//        print(toVC.toAnimatedSubviews)
        let fromSnapshots = fromVC.fromAnimatedSubviews.map { (tuple) -> (String, UIView) in
            let snapshot = tuple.1.snapshotView(afterScreenUpdates: false)!
            // we're putting it in container, so convert original frame into container's coordinate space
            snapshot.frame = container.convert(tuple.1.frame, from: tuple.1.superview)
            return (tuple.0, snapshot)
        }
        print("fromSnapshots \(fromSnapshots)")
//        let toSnapshots = toVC.toAnimatedSubviews.map { (tuple) -> (String, UIView) in
//            let snapshot = tuple.1.snapshotView(afterScreenUpdates: true)!
//            // we're putting it in container, so convert original frame into container's coordinate space
//            snapshot.frame = container.convert(tuple.1.frame, from: tuple.1.superview)
//            return (tuple.0, snapshot)
//        }
//        print("toSnapshots \(toSnapshots)")

//        containerView.addSubview(snapshot)
        fromVC.view.removeFromSuperview()
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = UIScreen.main.bounds
//        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.colors = [
//            UIColor(hexFromString: "ED4F48").cgColor,
//            UIColor(hexFromString: "9F3057").cgColor
//        ]
//
//        containerView.layer.addSublayer(gradientLayer)
        container.addSubview(toVC.view)
        transitionContext.completeTransition(true)
//        toVC.view.alpha = 0
//
//        let mask = CAShapeLayer()
//        gradientLayer.mask = mask
//
//        let pathInitial = UIBezierPath()
//        pathInitial.move(to: CGPoint(x: 0, y: 0))
//        pathInitial.addQuadCurve(to: CGPoint(x: gradientLayer.frame.width, y: 0), controlPoint: CGPoint(x: gradientLayer.frame.width / 2, y: -33))
//        pathInitial.addLine(to: CGPoint(x: gradientLayer.frame.width, y: -33))
//        pathInitial.addLine(to: CGPoint(x: 0, y: -33))
//        pathInitial.close()
//
//        let pathFinal = UIBezierPath()
//        pathFinal.move(to: CGPoint(x: 0, y: gradientLayer.frame.height+33))
//        pathFinal.addQuadCurve(to: CGPoint(x: gradientLayer.frame.width, y: gradientLayer.frame.height+33),
//                               controlPoint: CGPoint(x: gradientLayer.frame.width / 2, y: gradientLayer.frame.height))
//        pathFinal.addLine(to: CGPoint(x: gradientLayer.frame.width, y: 0))
//        pathFinal.addLine(to: CGPoint(x: 0, y: 0))
//        pathFinal.close()
//
//        let dur = transitionDuration(using: transitionContext)
//
//        CATransaction.begin()
//        let a1 = CABasicAnimation(keyPath: "path")
//        a1.fromValue = pathInitial.cgPath
//        a1.toValue = pathFinal.cgPath
//        a1.duration = dur/2
//        a1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//
//        let a2 = CABasicAnimation(keyPath: "opacity")
//        a2.fromValue = 0
//        a2.toValue = 1
//        a2.duration = dur/2
//        a2.beginTime = CACurrentMediaTime() + dur/2 //CACurrentMediaTime() + dur/2
//
//        let a3 = CATransition()
//        a3.type = CATransitionType.moveIn
//        a3.subtype = CATransitionSubtype.fromRight
//        a3.duration = dur/2
//        a3.beginTime = CACurrentMediaTime() + dur/2 //CACurrentMediaTime() + dur/2
//        a3.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//
//        //completition
//        CATransaction.setCompletionBlock {
//            toVC.view.alpha = 1
//            gradientLayer.removeFromSuperlayer()
//            snapshot.removeFromSuperview()
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
//        // add animation
//        mask.add(a1, forKey: "path")
//        toVC.view.layer.add(a2, forKey: "opacity")
//        toVC.infoView.layer.add(a3, forKey: "transition")
//        CATransaction.commit()
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        mask.path = pathFinal.cgPath
//        CATransaction.commit()
    }
    
    func animateUnwindSegue(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
}

