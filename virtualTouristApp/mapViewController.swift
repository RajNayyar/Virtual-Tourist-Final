//
//  mapViewController.swift
//  virtualTouristApp
//
//  Created by Rajpreet on 03/04/18.
//  Copyright © 2018 Rajpreet. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class mapViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var edit: UIBarButtonItem!
    @IBOutlet weak var done: UIBarButtonItem!
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(getCoordinates(gestureRecognizer:)))
        longGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longGesture)
        print("working")
        done.isEnabled = false
        fetchPins()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName : "Pin")
        do{
            let pins = try managedContext.fetch(fetchRequest)
            for pin in pins {
                if pin.lat == view.annotation?.coordinate.latitude && pin.long == view.annotation?.coordinate.longitude {
                    droppedPin=pin
                }
            }
        }catch{
            print("Error fetching Pins from core")
        }
        if(edit.isEnabled == true)
        { performSegue(withIdentifier: "segue", sender: view.annotation)}
        if(edit.isEnabled == false)
        {
            mapView.removeAnnotation(view.annotation!)
            deletePinFromCore(latitude: (droppedPin?.lat)!, longitude: (droppedPin?.long)!)
        }
        
        
    }
    
    @IBAction func doneAction(_ sender: Any) {
        done.isEnabled = false
        edit.isEnabled = true
    }
    @IBAction func editAction(_ sender: Any) {
        edit.isEnabled = false
        done.isEnabled = true
    }
    func fetchPins(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        print("working too")
        let fetchRequest = NSFetchRequest<Pin>(entityName : "Pin")
        
        do{
            pins = try managedContext.fetch(fetchRequest)
        }catch {
            print("Error fetching all pins from Core")
        }
        for pin in pins {
            createPin(latitude: pin.lat, longitude: pin.long)
        }
        
    }
    
    func deletePinFromCore(latitude : CLLocationDegrees, longitude : CLLocationDegrees){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        do{
            let pins = try managedContext.fetch(fetchRequest)
            for pin in pins {
                if pin.lat == latitude && pin.long == longitude {
                    managedContext.delete(pin)
                }
            }
        }catch{
            print("Error fetching pins from Core")
        }
        
        do{
            try managedContext.save()
        }catch{
            print("Error saving after deleting Pin")
        }
    }

    
    @objc func getCoordinates(gestureRecognizer : UILongPressGestureRecognizer){
        
        print("working")
        
        if gestureRecognizer.state == .began {
            
            //SAVING COORDINATES TO COREDATA HERE
            
            let location = gestureRecognizer.location(in: mapView)
            
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)
            let pin = NSManagedObject(entity: entity!, insertInto: managedContext)
            pin.setValue(coordinates.latitude, forKey: "lat")
            pin.setValue(coordinates.longitude, forKey: "long")
            do {
                try managedContext.save()
            }catch {
                print("error saving latitude and longitude")
            } // UNTIL HERE
            
            createPin(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
    }
    
    
    func createPin(latitude : CLLocationDegrees, longitude: CLLocationDegrees){
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        mapView.addAnnotation(annotation)
    }
    
}
