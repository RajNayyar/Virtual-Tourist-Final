//
//  flickrImageSearch.swift
//  virtualTouristApp
//
//  Created by Rajpreet on 25/03/18.
//  Copyright © 2018 Rajpreet. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class flickrImageSearch: UIViewController {
       func getImageURL(url : String, completion : @escaping (_ data : Data) -> Void){
        
        let url = NSURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        let task = session.dataTask(with: url as URLRequest) { (data, response, error) in
            guard error == nil else{
                 self.Alert(error: "error while requesting data")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                     self.Alert(error: "error getting the photos")
                return
            }
            guard let data = data else {
                 self.Alert(error: "error getting the data")
                return
            }
            completion(data)
            
        }
        task.resume()
    }
    
    func saveURLToCore(url : String){
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Image", in: managedContext)!
            let photo = NSManagedObject(entity: entity, insertInto: managedContext) as! Image
            
            photo.url = url
            photo.pin = droppedPin
            
            do{
                try managedContext.save()
                print("saved to Core")
            }catch {
                self.Alert(error: "Error saving image URL to Core")
            }
        }
    }
    
       func getDataFromFlickr(latitude : CLLocationDegrees, longitude : CLLocationDegrees, completion : @escaping (_ pages: Int?, _ numberOfImages: Int?)->Void){
        
        let url = NSMutableURLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=75ea49e1098e20b626cf636f50f692db&lat=\(latitude)&lon=\(longitude)&extras=url_m&per_page=20&format=json&nojsoncallback=1")!)
        print(url)
        let session = URLSession.shared
        let task = session.dataTask(with: url as URLRequest) { (data, response, error) in
            guard error == nil else{
              print("error while requesting data")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("status code was other than 2xx")
                return
            }
            guard let data = data else {
                print("request for data failed")
                return
            }
            
            let parsedResult : [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }catch {
                print("error parsing data")
                return
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("error getting the photos")
                return
            }
            
            AllPages = (min((photos["pages"])! as! Int,4000/20))
            completion(AllPages, nil)
            
            guard let photo = photos["photo"] as? [[String:AnyObject]] else {
                print("error getting the list of photos")
                return
            }
            TotalImagesInPage = (photo.count)
            completion(nil,TotalImagesInPage)
        }
        task.resume()
    }
    
    func urlsFromFlickrAPI(latitude: CLLocationDegrees, longitude: CLLocationDegrees, page : Int){
        
        let request = NSMutableURLRequest(url: URL(string:"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apikey)&lat=\(latitude)&lon=\(longitude)&radius=\(radius)&extras=url_m&page=\(page)&format=json&nojsoncallback=1&per_page=20")!)
        
        print("")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else{
                self.Alert(error: "error while requesting data")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.self.Alert(error: "status code was other than 2xx")
                return
            }
            guard let data = data else {
                self.Alert(error: "request for data failed")
                return
            }
            
            let parsedResult : [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }catch {
                self.Alert(error: "error parsing data")
                return
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                self.Alert(error: "error getting the photos")
                return
            }
            guard let photoALBUM = photos["photo"] as? [[String:AnyObject]] else{
                self.Alert(error: "error getting the photos")
                return
            }
            
            for photo in photoALBUM {
                if let url = photo["url_m"] {
                    self.saveURLToCore(url : url as! String)
                }
            }
            
        }
        task.resume()
    }
    
    func Alert(error: String)
    {
        let alert = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

