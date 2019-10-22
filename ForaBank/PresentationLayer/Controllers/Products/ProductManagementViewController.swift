/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero

class ProductManagementViewController: UITableViewController {

    var actions: Array<Dictionary<String, String>> = []
    var actionsType = ""
    var product: IProduct?
    var color2: UIColor = .black

    override func viewDidLoad() {
        super.viewDidLoad()

        actions = arrayWith(key: actionsType, fromPlist: "productsData")

        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 35
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = .white


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        hero.isEnabled = true
        hero.modalAnimationType = .none
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollUserInfo = ["tableView": tableView]
        NotificationCenter.default.post(name: NSNotification.Name("TableViewScrolled"), object: nil, userInfo: scrollUserInfo as [AnyHashable: Any])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hero.modifiers = [
            HeroModifier.beginWith([HeroModifier.opacity(1),
                                    HeroModifier.zPosition(5)]),
            HeroModifier.duration(0.3),
            HeroModifier.delay(0.5),
            HeroModifier.opacity(0)
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.hero.modifiers = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.hero.modifiers = [
            HeroModifier.beginWith([HeroModifier.opacity(1),
                                    HeroModifier.zPosition(5)]),
            HeroModifier.duration(0.3),
            HeroModifier.opacity(0)
        ]
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.hero.modifiers = nil

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.white
        cell.tintColor = UIColor.white
        cell.textLabel?.text = actions[indexPath.item]["text"]
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont(name: "Roboto-Light", size: 16.0)
        cell.imageView?.image = UIImage(named: actions[indexPath.item]["image"] ?? "")

        return cell
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 1 {
            guard let product = self.product else {
                return
            }
            let paymentOption = PaymentOption(product: product)
            store.dispatch(startPayment(sourceOption: paymentOption, destionationOption: nil))
            return
        } else if indexPath.item == 6 {
            guard let product = self.product else {
                return
            }
            showShareScreen(textToShare: product.number)
            return
        }
        let alertVC = UIAlertController(title: "Функционал недоступен", message: "Функционал временно недоступен", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        show(alertVC, sender: self)
    }
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
