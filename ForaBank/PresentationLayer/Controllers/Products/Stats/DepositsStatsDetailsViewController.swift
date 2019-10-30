/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import DeviceKit

class DepositsStatsDetailsViewController: UIViewController {
    
    // MARK: - Lifecycle
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    weak var currentViewController: UIViewController?
    var lastScrollViewOffset: CGFloat = 0
    var previousOffset: CGFloat = 0
    
    var offset: CGFloat = {
        if Device().isOneOf(Constants.xDevices) {
            return 100 // models: x
        } else {
            return 75 // models 7 7+ se
        }
    }()
    
    // MARK: - Actions
    
    @IBAction func backButtonCLicked(_ sender: Any) {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScroll(_:)), name: NSNotification.Name("TableViewScrolled"), object: nil)
        scrollView.isScrollEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerHeight.constant = -offset
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransitionToSecondViewController" {
            // let secondViewController = segue.destination as! TwoViewController
            // Pass data to secondViewController before the transition
        }
    }
}

// MARK: - Private methods
private extension DepositsStatsDetailsViewController {
    
    @objc func handleScroll(_ notification: Notification?) {
        let tableScrollView = notification?.userInfo?["tableView"] as? UIScrollView
        var currentOffset = tableScrollView?.contentOffset.y
        
        let distanceFromBottom = (tableScrollView?.contentSize.height ?? 0.0) - (currentOffset ?? 0.0)
        
        if previousOffset < (currentOffset ?? 0.0) && distanceFromBottom > (tableScrollView?.frame.size.height ?? 0.0) {
            if (currentOffset ?? 0.0) > header.frame.height - offset {
                currentOffset = header.frame.height - offset
            }
            
            scrollView.contentOffset.y -= previousOffset - (currentOffset ?? 0.0)
            previousOffset = currentOffset ?? 0.0
        } else {
            if previousOffset > (currentOffset ?? 0.0) {
                if (currentOffset ?? 0.0) < 0 {
                    currentOffset = 0
                }
                
                scrollView.contentOffset.y -= previousOffset - (currentOffset ?? 0.0)
                previousOffset = currentOffset ?? 0.0
            }
        }
        
        print(previousOffset, currentOffset!, lastScrollViewOffset)
    }
}
