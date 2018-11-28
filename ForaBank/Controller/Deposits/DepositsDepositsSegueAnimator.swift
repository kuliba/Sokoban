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
        return 0.6
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
        container.addSubview(toVC.view)
        toVC.view.layoutIfNeeded()

        let fromSnapshots = fromVC.fromAnimatedSubviews.mapValues { view -> UIView in
            let snapshot = view.snapshotView(afterScreenUpdates: false)!
            snapshot.frame = container.convert(view.frame, from: view.superview)
            return snapshot
        }
        fromVC.view.removeFromSuperview()
        
        let toSnapshots = toVC.toAnimatedSubviews/*.mapValues { view -> UIView in
            let snapshot = view.snapshotView(afterScreenUpdates: true)!
            snapshot.frame = container.convert(view.frame, from: view.superview)
            return snapshot
        }*/
//        let toVCsnapshot = toVC.view.snapshotView(afterScreenUpdates: true)!
//        let tableSnapshot = toVC.view.snapshotView(afterScreenUpdates: true)!
        let tableSnapshot = toSnapshots["tableView"]!

        let maskedWhiteBackgroundView = UIView()
        maskedWhiteBackgroundView.frame = tableSnapshot.frame
        maskedWhiteBackgroundView.backgroundColor = .white
        
        
//        container.addSubview(toVCsnapshot)
        container.addSubview(maskedWhiteBackgroundView)
        container.addSubview(fromSnapshots["carousel"]!)
        container.addSubview(fromSnapshots["tableView"]!)
        container.addSubview(tableSnapshot)
        
        
        let roundedMask = CAShapeLayer()
        maskedWhiteBackgroundView.layer.mask = roundedMask

        let pathInitial = UIBezierPath()
        pathInitial.move(to: CGPoint(x: 0, y: 78))
        pathInitial.addQuadCurve(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: 78), controlPoint: CGPoint(x: maskedWhiteBackgroundView.frame.width / 2, y: 45))
        pathInitial.addLine(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: maskedWhiteBackgroundView.frame.height))
        pathInitial.addLine(to: CGPoint(x: 0, y: maskedWhiteBackgroundView.frame.height))
        pathInitial.close()
        

        let pathFinal = UIBezierPath()
        pathFinal.move(to: CGPoint(x: 0, y: 320))
        pathFinal.addQuadCurve(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: 320),
                               controlPoint: CGPoint(x: maskedWhiteBackgroundView.frame.width / 2, y: 287))
        pathFinal.addLine(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: maskedWhiteBackgroundView.frame.height))
        pathFinal.addLine(to: CGPoint(x: 0, y: maskedWhiteBackgroundView.frame.height))
        pathFinal.close()

        roundedMask.path = pathFinal.cgPath
        
        let dur = transitionDuration(using: transitionContext)

        CATransaction.begin()
        let a1 = CAKeyframeAnimation(keyPath: "path")
        a1.keyTimes = [0, 1]
        a1.values = [pathInitial.cgPath, pathFinal.cgPath]
        a1.duration = dur
//        a1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a2 = CAKeyframeAnimation(keyPath: "opacity")
        a2.keyTimes = [0, 0.5, 1]
        a2.values = [1, 0, 0]
        a2.duration = dur
//        a2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a3 = CAKeyframeAnimation(keyPath: "transform.translation.y")
        a3.keyTimes = [0, 1]
        a3.values = [0, (320-78)/2]
        a3.duration = dur
//        a3.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let a4 = CAKeyframeAnimation(keyPath: "transform.translation.y")
        a4.keyTimes = [0, 0.5, 1]
        a4.values = [(320-78)/2, (333-78)/2, 0]
        a4.duration = dur
//        a4.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let a5 = CAKeyframeAnimation(keyPath: "opacity")
        a5.keyTimes = [0, 0.5, 1]
        a5.values = [0, 0, 1]
        a5.duration = dur
//        a5.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let a6 = CAKeyframeAnimation(keyPath: "opacity")
        a6.keyTimes = [0, 1]
        a6.values = [1,1]
        a6.duration = dur
        
        //completition
        CATransaction.setCompletionBlock {
//            toVC.view.alpha = 1
//            gradientLayer.removeFromSuperlayer()
//            snapshot.removeFromSuperview()
            fromSnapshots.forEach({ (tuple) in
                
                tuple.1.removeFromSuperview()
            })
//            toVCsnapshot.removeFromSuperview()
            maskedWhiteBackgroundView.removeFromSuperview()
            tableSnapshot.removeFromSuperview()
            print("animateSegueToDetailsViewController after \(container.subviews)")
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        // add animation
        roundedMask.add(a1, forKey: "path")
        fromSnapshots["carousel"]?.layer.add(a2, forKey: "opacity")
        fromSnapshots["tableView"]?.layer.add(a2, forKey: "opacity")
        fromSnapshots["tableView"]?.layer.add(a3, forKey: "pos")
        tableSnapshot.layer.add(a4, forKey: "pos")
        tableSnapshot.layer.add(a5, forKey: "opacity")
        maskedWhiteBackgroundView.layer.add(a6, forKey: "opacity")
        CATransaction.commit()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tableSnapshot.layer.opacity = 0
        fromSnapshots["tableView"]?.layer.opacity = 0
        fromSnapshots["carousel"]?.layer.opacity = 0
        maskedWhiteBackgroundView.layer.opacity = 0
        CATransaction.commit()
    }
    
    func animateUnwindSegue(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? UIViewController & CustomTransitionOriginator,
            let toVC = transitionContext.viewController(forKey: .to) as? UIViewController & CustomTransitionDestination
            else {
                print("DepositsDepositsSegueAnimator animateUnwindSegue guard return")
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        let container = transitionContext.containerView
        container.addSubview(toVC.view)
//        toVC.view.layer.opacity = 0
        toVC.view.layoutIfNeeded()

        let fromSnapshots = fromVC.fromAnimatedSubviews
        let fromVCsnapshot = fromVC.view.snapshotView(afterScreenUpdates: false)!
        fromVC.view.removeFromSuperview()
        
        let toSnapshots = toVC.toAnimatedSubviews.mapValues { view -> UIView in
            let snapshot = view.snapshotView(afterScreenUpdates: true)!
            snapshot.frame = container.convert(view.frame, from: view.superview)
            return snapshot
        }

        let tableSnapshot = fromSnapshots["tableView"]!
        
//        let toVCsnapshot = toVC.view.snapshotView(afterScreenUpdates: true)!

        let maskedWhiteBackgroundView = UIView()
        maskedWhiteBackgroundView.frame = tableSnapshot.frame
        maskedWhiteBackgroundView.backgroundColor = .white
        
        tableSnapshot.layer.opacity = 0
        toSnapshots["tableView"]?.layer.opacity = 0
        toSnapshots["carousel"]?.layer.opacity = 0
        maskedWhiteBackgroundView.layer.opacity = 0
        fromVCsnapshot.layer.opacity = 0
        
        container.addSubview(fromVCsnapshot)
//        container.addSubview(toVCsnapshot)
        container.addSubview(maskedWhiteBackgroundView)
        container.addSubview(toSnapshots["carousel"]!)
        container.addSubview(toSnapshots["tableView"]!)
        container.addSubview(tableSnapshot)
        
        let roundedMask = CAShapeLayer()
        maskedWhiteBackgroundView.layer.mask = roundedMask

        let pathInitial = UIBezierPath()
        pathInitial.move(to: CGPoint(x: 0, y: 78))
        pathInitial.addQuadCurve(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: 78), controlPoint: CGPoint(x: maskedWhiteBackgroundView.frame.width / 2, y: 45))
        pathInitial.addLine(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: maskedWhiteBackgroundView.frame.height))
        pathInitial.addLine(to: CGPoint(x: 0, y: maskedWhiteBackgroundView.frame.height))
        pathInitial.close()


        let pathFinal = UIBezierPath()
        pathFinal.move(to: CGPoint(x: 0, y: 320))
        pathFinal.addQuadCurve(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: 320),
                               controlPoint: CGPoint(x: maskedWhiteBackgroundView.frame.width / 2, y: 287))
        pathFinal.addLine(to: CGPoint(x: maskedWhiteBackgroundView.frame.width, y: maskedWhiteBackgroundView.frame.height))
        pathFinal.addLine(to: CGPoint(x: 0, y: maskedWhiteBackgroundView.frame.height))
        pathFinal.close()

        roundedMask.path = pathFinal.cgPath

        let dur = transitionDuration(using: transitionContext)
        
        CATransaction.begin()
        let a1 = CAKeyframeAnimation(keyPath: "path")
        a1.keyTimes = [0, 1]
        a1.values = [pathInitial.cgPath, pathFinal.cgPath].reversed()
        a1.duration = dur
//        a1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a2 = CAKeyframeAnimation(keyPath: "opacity")
        a2.keyTimes = [0, 0.5, 1]
        a2.values = [0, 0, 1]
        a2.duration = dur
//        a2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a3 = CAKeyframeAnimation(keyPath: "transform.translation.y")
        a3.keyTimes = [0, 1]
        a3.values = [0, (320-78)/2].reversed()
        a3.duration = dur
//        a3.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a4 = CAKeyframeAnimation(keyPath: "transform.translation.y")
        a4.keyTimes = [0, 0.5, 1]
        a4.values = [(320-78)/2, (333-78)/2, 0].reversed()
        a4.duration = dur
//        a4.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a5 = CAKeyframeAnimation(keyPath: "opacity")
        a5.keyTimes = [0, 0.5, 1]
        a5.values = [0, 0, 1].reversed()
        a5.duration = dur
//        a5.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let a6 = CAKeyframeAnimation(keyPath: "opacity")
        a6.keyTimes = [0, 1]
        a6.values = [1,1]
        a6.duration = dur

        let a7 = CAKeyframeAnimation(keyPath: "opacity")
        a7.keyTimes = [0, 0.9, 1]
        a7.values = [1, 1, 0]
        a7.duration = dur
        
        //completition
        CATransaction.setCompletionBlock {
            toSnapshots.forEach({ (tuple) in
                tuple.1.removeFromSuperview()
            })
            fromVCsnapshot.removeFromSuperview()
            maskedWhiteBackgroundView.removeFromSuperview()
            tableSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        // add animation
        fromVCsnapshot.layer.add(a7, forKey: "opacity")
        roundedMask.add(a1, forKey: "path")
        toSnapshots["carousel"]?.layer.add(a2, forKey: "opacity")
        toSnapshots["tableView"]?.layer.add(a2, forKey: "opacity")
        toSnapshots["tableView"]?.layer.add(a3, forKey: "pos")
        tableSnapshot.layer.add(a4, forKey: "pos")
        tableSnapshot.layer.add(a5, forKey: "opacity")
        maskedWhiteBackgroundView.layer.add(a6, forKey: "opacity")
        CATransaction.commit()
    }
}

