//
//  mapPopUpViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 05/11/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import UIKit
 
class MapPopUpViewController: UIViewController {
    
    @IBOutlet weak var mapPopUp: UIView!
    
    @IBOutlet weak var closePopUp: UIButton!
    
    
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
           
           self.showAnimate()
           
           // Do any additional setup after loading the view.
       }

       override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
       
       @IBAction func closePopUp(_ sender: AnyObject) {
           self.removeAnimate()
           //self.view.removeFromSuperview()
       }
       
       func showAnimate()
       {
           self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
           self.view.alpha = 0.0;
           UIView.animate(withDuration: 0.25, animations: {
               self.view.alpha = 1.0
               self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
           });
       }
       
       func removeAnimate()
       {
           UIView.animate(withDuration: 0.25, animations: {
               self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
               self.view.alpha = 0.0;
               }, completion:{(finished : Bool)  in
                   if (finished)
                   {
                       self.view.removeFromSuperview()
                   }
           });
       }

       /*
       // MARK: - Navigation

       // In a storyboard-based application, you will often want to do a little preparation before navigation
       override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
           // Get the new view controller using segue.destinationViewController.
           // Pass the selected object to the new view controller.
       }
       */
}
