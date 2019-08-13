/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class DepositsHistoryDetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var topView: UIView!
    
    let transitionAnimator = DepositsHistoryDetailsSegueAnimator()
    lazy var panRecognizer =  UIPanGestureRecognizer()
    var defaultTopViewOffset: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(scrollView.gestureRecognizers)
        scrollView.delegate = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepare ofr segue \(segue.identifier ?? "nil")")
        if segue.identifier == "TabBarViewController" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = transitionAnimator
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        defaultTopViewOffset = topView.frame.size.height + topView.frame.origin.y
    }
}

extension DepositsHistoryDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll")
//        print(defaultTopViewOffset)
//        print(scrollView.contentOffset.y)
        let offset = scrollView.contentOffset.y > defaultTopViewOffset ? defaultTopViewOffset : scrollView.contentOffset.y
        let percent = offset/defaultTopViewOffset
        let zoomScale = 1 - percent/4
        let alphaScale = 1 - percent/2
        UIView.animate(withDuration: 0.1) {
            self.topView.transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
            self.topView.alpha = alphaScale>1 ? 1 : alphaScale
        }
    }
}
