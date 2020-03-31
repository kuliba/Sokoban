/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class DepositsCardsDetailsStatementDetailsViewController: UIViewController {

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
    var sortedTransactionsStatement: DatedCardTransactionsStatement?
     var transaction: TransactionCardStatement?
    

      // MARK: - Actions
      @IBAction func backButtonCLicked(_ sender: Any) {
          view.endEditing(true)
          self.navigationController?.popViewController(animated: true)
          if navigationController == nil {
              dismiss(animated: true, completion: nil)
          }
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(scrollView.gestureRecognizers)
       // recipient.text = "\((transaction?.comment)!)"
        nameTransaction.text = "\((transaction?.comment) ?? "1")"
        datetransaction.text = "\((transaction?.date)!)"
        amountPaT.text = "\(maskSum(sum:transaction?.amount ?? 11))" + "\("₽")"
        if let data = transaction?.operationType {
            if data == "CREDIT"{
                amountPaT.text = "\("+")" + "\(maskSum(sum:(transaction?.amount)!))" + "\("₽")"
            } else {
                view.backgroundColor = .red
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

extension DepositsCardsDetailsStatementDetailsViewController: UIScrollViewDelegate {
    
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
