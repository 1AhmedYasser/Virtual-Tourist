//
//  ViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/27/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// An extension that holds functionalty or variables used across all view controllers in the app
extension UIViewController: MKMapViewDelegate{
    
    // A helper method to handle different errors
    func handleErrors(appDelegate: AppDelegate, statusCode: Int,error: Error?) {
        print(error?.localizedDescription ?? "")
        switch statusCode {
        case 100: appDelegate.showError(controller: self, title: "Error", message: "Invalid api key")
        case 105: appDelegate.showError(controller: self, title: "Error", message: "Service currently unavailable")
        case 111: appDelegate.showError(controller: self, title: "Error", message: "Format not found")
        case 112: appDelegate.showError(controller: self, title: "Error", message: "Method not found")
        case 116: appDelegate.showError(controller: self, title: "Error", message: "Bad URL")
        default:  appDelegate.showError(controller: self,title: "Error", message: error?.localizedDescription ?? "")
        }
    }
    
    // A method that setup the map pin properties
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
