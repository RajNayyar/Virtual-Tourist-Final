//
//  imageCollectionViewController.swift
//  virtualTouristApp
//
//  Created by Rajpreet on 05/04/18.
//  Copyright © 2018 Rajpreet. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class imageCollectionViewController: UIViewController, NSFetchedResultsControllerDelegate,  UICollectionViewDelegate, UICollectionViewDataSource  {
    var pageNo : Int = 1
    var obj1 = flickrImageSearch()
    @IBOutlet weak var imgCollection: UICollectionView!
    var totalPages = 0
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollection: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPin()
        
 
        if droppedPin?.image?.count == 0 {
            
            
            self.obj1.getDataFromFlickr(latitude: (droppedPin?.lat)!, longitude: (droppedPin?.long)!) { (pages, numberOfImages) in
                
                
                
                if numberOfImages != nil {
                    if (numberOfImages! == 0 ){
                        DispatchQueue.main.async{
                            let alert = UIAlertController(title: "Alert", message: "No image found!", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.newCollection.isEnabled = false
                        }
                    }
                    else
                    {
                        print("No of pages issue")
                    }
                }
                else
                {
                    print("no of pages issue 2 -- debugger")
                }
                
               
                
                if pages != nil {
                    let randomPageNumber = arc4random_uniform(UInt32(min(pages!,4000/20))) + 1 //this was recommended in the 3rd Udacity review.
                    
                    self.obj1.urlsFromFlickrAPI(latitude: (droppedPin?.lat)!, longitude: (droppedPin?.long)!, page: Int(randomPageNumber))
                        print("this is working compleejhbvsbhkjk")
                }
                else
                {
                   self.obj1.urlsFromFlickrAPI(latitude: (droppedPin?.lat)!, longitude: (droppedPin?.long)!, page:1)
                }
                
                DispatchQueue.main.async{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let managedContext = appDelegate.persistentContainer.viewContext
                    do{
                        try managedContext.save()
                    }catch {
                        print("Error saving")
                    }
                }
            }
        }
        
        
        do {
            print("viewdidload fetch working fine")
            try self.fetchedResultsController.performFetch()
        }catch{
            print("An error occured")
        }
    }
    
    
    
    @IBAction func newImageCollection(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        while((droppedPin?.image?.count)! > 0){
            
           let photo = fetchedResultsController.object(at: [0,0])
            managedContext.delete(photo)
            do{
                try managedContext.save()
            }catch {
                print("Error while saving")
            }
        
        }
         let randomPageNumber = arc4random_uniform(UInt32(20)) + 1// This was recommended in the 2nd Udacity review...
     obj1.urlsFromFlickrAPI(latitude: (droppedPin?.lat)!, longitude: (droppedPin?.long)!, page: Int(randomPageNumber))
        
    }
    
    lazy var fetchedResultsController : NSFetchedResultsController = { () -> NSFetchedResultsController<Image> in
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Image>(entityName: "Image")
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [droppedPin!])
        let frc  = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        print("this is working fine----")
        return frc
    }()

    // CONTROLLERS CONFIG
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath{
                self.imgCollection.insertItems(at: [insertIndexPath])
            }
        case .delete:
            if let deleteIndexpath = indexPath{
                self.imgCollection.deleteItems(at: [deleteIndexpath])
            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.imgCollection.deleteItems(at: [deleteIndexPath])
            }
            if let insertIndexPath = newIndexPath {
                self.imgCollection.insertItems(at: [insertIndexPath])
            }
        default:
            print("NOTHING")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.imgCollection.insertSections(sectionIndexSet as IndexSet)
        case .delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.imgCollection.deleteSections(sectionIndexSet as IndexSet)
        default:
            print("NOTHING")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.imgCollection.numberOfItems(inSection: 0)
    }
    
    //ADD PIN TO SUBMAP IN THIS VIEWCONTROLLER
   func addPin()
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = (droppedPin?.lat)!
        annotation.coordinate.longitude = (droppedPin?.long)!
        mapView.addAnnotation(annotation)
        let point = CLLocationCoordinate2DMake((droppedPin?.lat)!, (droppedPin?.long)!)
        let span = MKCoordinateSpanMake(5, 5)
        let region = MKCoordinateRegion(center: point, span: span)
        mapView.setRegion(region, animated: true)
    }
    

        // COLLECTIONS CONFIG
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            if let sections = fetchedResultsController.sections {
                return sections.count
            }
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let sections = fetchedResultsController.sections {
                let currentSection = sections[section]
                return currentSection.numberOfObjects
            }
            return 0
        }
        
    
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let photo = fetchedResultsController.object(at: indexPath)
            managedContext.delete(photo)
            
            do{
                try managedContext.save()
            }catch {
                print("Error while saving")
            }
        }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        if photo.data == nil {
            cell.activityIndicator.startAnimating()
            obj1.getImageURL(url: photo.url!, completion: { (data) in
                DispatchQueue.main.async{
                    cell.activityIndicator.isHidden = false
                    cell.imageView.image = UIImage(data: data)
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let managedContext = appDelegate.persistentContainer.viewContext
                    photo.data = data as Data
                    
                    do{
                        try managedContext.save()
                    }catch{
                        print("Error saving")
                    }
                }
            })
        }
            
        else {
            cell.imageView.image = UIImage(data: photo.data! as Data)
        }
        
        return cell
        
    }
  
}



