//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/24/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var emptyCollectionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionButton: UIButton!
    
    // The pin whose photos are being displayed , passed from travel location view controller
    var pin: Pin!
    
    // Data controller passed from travel location view controller
    var dataController: DataController!
    
    // An array that holds indexes of cells to remove from the collection view
    var indexesToRemove = [Int]()
    
    // Holds an array of Photos loaded from the store
    var LoadedPhotos:[Photos] = []
    
    // Holds an array of Photo structs downloaded
    var downloadedPhotos:[Photo] = []
    
    // The number of elements in the collection view
    var CollectionViewSize = 0
    
    // A refrence to the app delegate , used to share data between different controllers
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the collection button and label visibility
        collectionButton.isEnabled = false
        emptyCollectionLabel.isHidden = true
        
        // Loades saved images from store
        LoadSavedImagesFromStore()
        
        // set up the map for the passed pin
        setupMapForSelectedPin()
        
        // set up the collection view
        SetupCollectionView()
    }
    
    // MARK: View will appear
    // Loads the collection view data
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    // A helper method that loades the saved images from store
    func LoadSavedImagesFromStore() {
        if let result = try? dataController.viewContext.fetch(setupAFetchRequest()) {
            LoadedPhotos = result
            CollectionViewSize = LoadedPhotos.count
        }
        if LoadedPhotos.count == 0 {
            FlickerApi.LocationInfo.lat = pin.latitude
            FlickerApi.LocationInfo.long = pin.longitude
            FlickerApi.getPhotosForCoordinates(desiredPage: 1, completionHandler: handleGetPhotosForCoordinatesResponse(photos:statusCode:error:))
        } else {
            collectionButton.isEnabled = true
        }
    }
    
    // A helper method that set up the map for the passed pin
    func setupMapForSelectedPin() {
        let span = MKCoordinateSpan(latitudeDelta: 0.020, longitudeDelta: 0.020)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), span: span)
        mapView.setRegion(region, animated: true)
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    // A helper method that set up the collection View
    fileprivate func SetupCollectionView() {
        collectionView.allowsMultipleSelection = true
        // Set Collection Spacing
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // Handles when the new collection button is tapped (Search for new images/ delete selected images)
    @IBAction func newCollectionTapped(_ sender: Any) {
        downloadedPhotos.removeAll()
        // Get a new collection
        if indexesToRemove.count == 0 {
            // Empty saved photos from store
            if let result = try? dataController.viewContext.fetch(setupAFetchRequest()) {
                for photo in result {
                    dataController.viewContext.delete(photo)
                }
                try? dataController.viewContext.save()
            }
            // Empty the loaded photos array
            LoadedPhotos.removeAll()
            collectionButton.isEnabled = false
            
            // Generate a random page and request a new collection of photos and refresh the collection view
            var number:Int = 1
            if FlickerApi.LocationInfo.totalPages > 1 {
                number = Int.random(in: 1..<FlickerApi.LocationInfo.totalPages)
            }
            FlickerApi.LocationInfo.lat = pin.latitude
            FlickerApi.LocationInfo.long = pin.longitude
            FlickerApi.getPhotosForCoordinates(desiredPage: number,completionHandler: handleGetPhotosForCoordinatesResponse(photos:statusCode:error:))
            collectionView.reloadData()
        } else { // Remove selected photos
            
            // remove selected photos from store
            for index in indexesToRemove {
                let photoToDelete = LoadedPhotos[index]
                dataController.viewContext.delete(photoToDelete)
            }
            
            // remove selected photos from loaded photos array
            LoadedPhotos = LoadedPhotos
                .enumerated()
                .filter { !indexesToRemove.contains($0.offset) }
                .map { $0.element }
            
            // update the collection size and save and refresh the collection view
            CollectionViewSize = LoadedPhotos.count
            try? dataController.viewContext.save()
            indexesToRemove.removeAll()
            collectionButton.setTitle("New Collection", for: UIControl.State.normal)
            collectionView.reloadData()
        }
    }
    
    // A helper function that creates a fetch request of photos that belongs to the selected pin
    func setupAFetchRequest() -> NSFetchRequest<Photos> {
        let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate  = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        return fetchRequest
    }
    
    // MARK: Response handlers
    
    // Handle photo search response , download the actual images for the array of photo structs
    func handleGetPhotosForCoordinatesResponse(photos: [Photo] ,statusCode:Int,error: Error?) {
        if error != nil {
            handleErrors(appDelegate: appDelegate, statusCode: statusCode, error: error)
            collectionButton.isEnabled = true
            return
        }
        if photos.count > 0 {
            downloadedPhotos = photos
            CollectionViewSize = downloadedPhotos.count
            collectionView.reloadData()
            collectionButton.isEnabled = true
            for photo in photos {
                FlickerApi.getActualPhoto(photo: photo, completionHandler: handleGetActualPhotoResponse(image:error:))
            }
        } else {
            emptyCollectionLabel.isHidden = false
            collectionButton.isEnabled = false
        }
    }
    
    // Handle image download response , saves the photo to the model and append it to the collection view
    func handleGetActualPhotoResponse(image: UIImage? ,error: Error?) {
        if error != nil {
            handleErrors(appDelegate: appDelegate, statusCode: 0, error: error)
            return
        }
        // save the downloaded photo to the store with the associated pin
        let photos = Photos(context: dataController.viewContext)
        photos.photo = image?.pngData()
        photos.pin = pin
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
        LoadedPhotos.append(photos)
        self.collectionView.reloadData()
    }
}

// Enxtention to the photo album class that handles the images collection view
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Number of collections sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Mark: Number of collection items in sections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return CollectionViewSize
        
    }
    
    // Asks the data source object for the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for:indexPath) as! PhotoCell
        CollectionCell.imageView.image = UIImage(named: "photoPlaceholder")
        CollectionCell.activityIndicator.startAnimating()
        CollectionCell.layer.borderWidth = 0
        CollectionCell.layer.borderColor = UIColor.green.cgColor
        if LoadedPhotos.count > indexPath.row {
            CollectionCell.imageView.image = UIImage(data: LoadedPhotos[indexPath.row].photo!)
            CollectionCell.activityIndicator.stopAnimating()
        }
        return CollectionCell
    }
    
    // MARK: Collection item selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.isSelected == true {
            cell?.layer.borderWidth = 2.0
            indexesToRemove.append(indexPath.row)
            collectionButtonCheck()
        }
    }
    
    // MARK: Collection item deselected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        let index = indexesToRemove.firstIndex(of: indexPath.row)
        indexesToRemove.remove(at: index!)
        collectionButtonCheck()
    }
    
    // A helper method that change button text according to items selected
    func collectionButtonCheck() {
        if indexesToRemove.count > 0 {
            collectionButton.setTitle("Remove Selected Photos", for: UIControl.State.normal)
        } else {
            collectionButton.setTitle("New Collection", for: UIControl.State.normal)
        }
    }
}
