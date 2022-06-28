//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Eyvind on 31/5/22.
//

import UIKit
import CryptoKit
import CommonCrypto
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var currentAnnotation: MKPointAnnotation? = nil

    var dataController: DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    var listPin = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLastPosition()
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        do {
            try fetchedResultsController.performFetch()
            showAllPins()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onPointSelected(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func showAllPins() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        var annotations = [MKPointAnnotation]()
        for fetchedObject in fetchedResultsController.fetchedObjects! {
            annotations.append(generateAnnotation(fetchedObject.lat, fetchedObject.lon))
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func generateAnnotation(_ lat: Double,_ lon: Double) -> MKPointAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(lat), \(lon)"
        return annotation
    }
    
    @objc func onPointSelected(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            debugPrint("LongPress ended")
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            currentAnnotation = generateAnnotation(coordinate.latitude, coordinate.longitude)
            mapView.addAnnotation(currentAnnotation!)
            
            
            let pin = Pin.newInstance(lat: currentAnnotation!.coordinate.latitude, lon: currentAnnotation!.coordinate.longitude, context: dataController.viewContext)
            try? dataController.viewContext.save()
            openDetailController(pin: pin, isNew: true)
        }
    }
    
    private func loadLastPosition() {
        let lastLocation = UserPref.getLastLocation()
        let lastSpanLocation = UserPref.getLastSpanLocation()
        
        if lastLocation != nil && lastSpanLocation != nil {
            let center = CLLocationCoordinate2D(latitude: lastLocation!.latitude, longitude: lastLocation!.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: lastSpanLocation!.latitude, longitudeDelta: lastSpanLocation!.longitude))
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func openDetailController(pin: Pin, isNew: Bool) {

        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailController") as! DetailViewController

        controller.dataController = dataController
        controller.pin = pin
        controller.isNew = isNew
        
        let nav = UINavigationController(rootViewController: controller)
        
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pinSelectedRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let predicate = NSPredicate(format: "lat == %@ AND lon == %@", argumentArray: [view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude])
        pinSelectedRequest.predicate = predicate
        
        do {
            let pins = try dataController.viewContext.fetch(pinSelectedRequest)
            if !pins.isEmpty {
                openDetailController(pin: pins.first!, isNew: false)
            }
        } catch {
            showSingleAlert("Can't load pin")
        }       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear()")
        UserPref.setLastLocation(mapView.region.center.latitude, mapView.region.center.longitude)
        UserPref.setLastSpan(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta)
        
        super.viewWillDisappear(animated)
    }
    
}
