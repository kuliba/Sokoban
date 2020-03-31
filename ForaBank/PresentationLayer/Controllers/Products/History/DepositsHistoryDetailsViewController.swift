/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class DepositsHistoryDetailsViewController: UIViewController {

    @IBOutlet weak var purposeOfPayment: UILabel!
    @IBOutlet weak var nameTransaction: UILabel!
    @IBOutlet weak var recipient: UILabel!
    @IBOutlet weak var datetransaction: UILabel!
    @IBOutlet weak var amountPaT: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var topView: UIView!
    var historyArray: String = "12"
    let transitionAnimator = DepositsHistoryDetailsSegueAnimator()
    lazy var panRecognizer =  UIPanGestureRecognizer()
    var defaultTopViewOffset: CGFloat = 0
    var product: DatedTransactions?
    var sortedTransactionsStatement: DatedTransactionsStatement?
     var transaction: TransactionStatement?
    
    
    let colorSucces = UIColor(red: CGFloat(48)/CGFloat(255),
    green: CGFloat(198)/CGFloat(255),
    blue: CGFloat(164)/CGFloat(255),
    alpha: 1)
    let colorFail = UIColor(red: CGFloat(239)/CGFloat(255),
    green: CGFloat(65)/CGFloat(255),
    blue: CGFloat(54)/CGFloat(255),
    alpha: 1)
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(scrollView.gestureRecognizers)
        scrollView.delegate = self
        purposeOfPayment.text = "\((transaction?.comment)!)"
       // recipient.text = "\((transaction?.comment)!)"
        nameTransaction.text = "\((transaction?.comment)!)"
        datetransaction.text = "\((transaction?.operationDate)!)"
        amountPaT.text = "\((transaction?.amount)!)" + "\("₽")"
        if let data = transaction?.operationType {
            if data == "CREDIT"{
                view.backgroundColor = colorSucces
                amountPaT.text = "\("+")" + "\(maskSum(sum:(transaction?.amount)!))" + "\("₽")"
            } else {
                view.backgroundColor = colorFail
                amountPaT.text = "\("-")" + "\(maskSum(sum:(transaction?.amount)!))" + "\("₽")"
            }
        }
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
      
    }
}

extension DepositsHistoryDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll")
//        print(defaultTopViewOffset)
//        print(scrollView.contentOffset.y)
        let offset = scrollView.contentOffset.y > defaultTopViewOffset ? defaultTopViewOffset : scrollView.contentOffset.y
        let percent = offset/defaultTopViewOffset
        _ = 1 - percent/4
        _ = 1 - percent/2
      
    }
}
