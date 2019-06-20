//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/24/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController{
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Stores the currents selected or added pin map coordinates
    var touchMapCoordinate: CLLocationCoordinate2D!
    
    // Editing mode (Delete or Open a pin)
    var isEditingModeOn = false
    
    // Holds an array of map pins
    var pins:[Pin] = []
    
    // Holds the selected pin to be passed to the photo album view controller
    var selectedPin: Pin!
    
    // Holds all the map annotations
    var annotations = [MKPointAnnotation]()
    
    // Data controller injected from the app delegate
    var dataController: DataController!
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the map and loaded saved pins
        SetupMap()
    }
    
    // MARK: Set up map
    fileprivate func SetupMap() {
        // fetch the saved data from the data controller and populate the pins array
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            loadPinsOnMap()
        }
        
        // Set up navigation controls and title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: nil)
        navigationItem.title = "Virtual Tourist"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editMode))
        
        // Set up a long press gesture recognizer and add to the map view
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    // When the edit bar button is pressed , the editing mode is switched on and off
    @objc func editMode() {
        isEditingModeOn = !isEditingModeOn
        if navigationItem.rightBarButtonItem?.title == "Edit" {
            changeTitle(stateTitle: "Done", title: "Tap a pin to delete", color: UIColor.red)
        } else {
            changeTitle(stateTitle: "Edit", title: "Virtual Tourist", color: UIColor.black)
        }
    }
    
    /* A helper method that changes the navigation controller title and
     edit bar text with given text attributes
     */
    func changeTitle(stateTitle: String ,title: String , color: UIColor) {
        navigationItem.rightBarButtonItem?.title = stateTitle
        navigationItem.title = title
        let textAttributes = [NSAttributedString.Key.foregroundColor:color]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    // When user long press any location on the map , creates a pin and save it to the store
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        annotations.append(annotation)
        mapView.addAnnotation(annotation)
        
        // Create a new pin record to save
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = touchMapCoordinate.latitude
        pin.longitude = touchMapCoordinate.longitude
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
        pins.append(pin)
        
        FlickerApi.LocationInfo.lat = touchMapCoordinate.latitude
        FlickerApi.LocationInfo.long = touchMapCoordinate.longitude
        
    }
    
    // A helper method that puts loaded pins form the store on the map
    func loadPinsOnMap() {
        for pin in pins {
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    // Before seguing to the photo album pass the selected pin and the data controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoAlbumSegue" {
            if let vc = segue.destination as? PhotoAlbumViewController{
                vc.pin = selectedPin
                vc.dataController = dataController
            }
        }
    }
    
    // MARK: Map delegate methods
    
    // Handles when a pin is pressed by deleting or opening the pin according to the editing mode
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        // Get the index of the selected pin
        let index = annotations.firstIndex(of: view.annotation! as! MKPointAnnotation)!
        
        if isEditingModeOn {
            mapView.removeAnnotation(view.annotation!)
            mapView.deselectAnnotation(view.annotation, animated: false)
            
            // Delete Pin from presistent store and save changes
            let pinToDelete = pins[index]
            dataController.viewContext.delete(pinToDelete)
            if dataController.viewContext.hasChanges {
                try? dataController.viewContext.save()
            }
        } else {
            selectedPin = pins[index]
            touchMapCoordinate = view.annotation?.coordinate
            performSegue(withIdentifier: "PhotoAlbumSegue", sender: self)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
}
