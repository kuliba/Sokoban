//
//  EventDetailsViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 19.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Alamofire

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var imageFilm: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var descriptionBody: UILabel!
    @IBOutlet weak var ageRestriction: UILabel!
    @IBOutlet weak var back: UIButton!
    var idFilm = ""
    @IBOutlet weak var scrollView: UIScrollView!
    //defining the API URL
    var moviesList = EventDetails()
    
    override func viewDidLoad() {
          super.viewDidLoad()
        scrollView.isScrollEnabled = true
        self.scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height/2) //or what ever size you want to set
        let API_URL = "https://kudago.com/public-api/v1.4/movies/\(idFilm)/"
        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
          Alamofire.request(API_URL).responseJSON { response in
              let json = response.data
              
              do{
                  //created the json decoder
                  let decoder = JSONDecoder()
                  
                  //using the array to put values
                  self.moviesList = try decoder.decode(EventDetails.self, from: json!)
                self.eventName.text = self.moviesList.title
                let string = self.moviesList.bodyText
                let stringEdit = string!.replacingOccurrences(of: "<p>", with: "", options:
                NSString.CompareOptions.literal, range: nil)

                self.descriptionBody.text = stringEdit
                self.rating.text = self.moviesList.imdbRating?.description
                self.ageRestriction.text = self.moviesList.ageRestriction
                self.genres.text = self.moviesList.genres?[0].name
//                imageFilm.image = getDateCurrencys(data: )
                  //printing all the hero names
                print(self.moviesList.images)
                let imageUrl:NSURL = NSURL(string: "\(self.moviesList.images![0].image!)")!
                          DispatchQueue.global(qos: .userInitiated).async {
                                    
                                    let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
                                
                                    DispatchQueue.main.async {
                                        
                                        let image = UIImage(data: imageData as Data)
                                       self.imageFilm.image = image
                                      }

                           }
              }catch let err{
                  print(err)
              }
          }
      }
    @IBAction func dismissViewController(_ sender: Any) {
        //Go back to previous controller
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
