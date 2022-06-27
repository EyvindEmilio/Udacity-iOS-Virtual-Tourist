//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Eyvind on 2/6/22.
//

import Foundation
import UIKit
import CoreData

class DetailViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    final let ITEMS_PER_ROW = 3.0
    final let CELL_SPACES = 5.0
    
    var dataController: DataController!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var loaderIdicator: UIActivityIndicatorView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var btnNewCollection: UIButton!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var searchPhotosTask: URLSessionDataTask? = nil
    var pin: Pin!
    var isNew: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        applyFlowLayoutSpaces()
        loadLocalData()
        handleEmptyView()
        
        if isNew {
            loadPhotos()
        }
    }
    
    func loadLocalData() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: pin))-photos")
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        handleEmptyView()
        if fetchedResultsController.fetchedObjects!.isEmpty {
            noImagesStatus()
        } else {
            imagesFoundStatus()
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        if pin.photos?.count == RestClient.Endpoints.PAGE_SIZE { // because if the number of the current loaded photos is less than the page means that there are no more photos to load
            pin.newCollection()
            debugPrint("newCollection()")
        } else {
            pin.newInitialCollection()
            debugPrint("newInitialCollection()")
        }
        removeCurrentPhotos()
        try? self.dataController.viewContext.save()
        self.loadPhotos()
    }
    
    private func noImagesStatus(){
        loaderIdicator.isHidden = true
        loaderIdicator.stopAnimating()
        noImagesLabel.isHidden = false
        flowLayout.collectionView?.isHidden = true
    }
    
    private func loadingStatus(){
        loaderIdicator.isHidden = false
        loaderIdicator.startAnimating()
        noImagesLabel.isHidden = true
        flowLayout.collectionView?.isHidden = true
    }
    
    private func imagesFoundStatus(){
        loaderIdicator.isHidden = true
        loaderIdicator.stopAnimating()
        noImagesLabel.isHidden = true
        flowLayout.collectionView?.isHidden = false
    }
    
    func loadPhotos() {
        debugPrint("loadPhotos()")
        loadingStatus()
        
        searchPhotosTask?.cancel()
        
        removeCurrentPhotos()
        
        self.btnNewCollection.isEnabled = false

        searchPhotosTask = RestClient.searchByLocation(pin.lat, pin.lon, Int(pin.attempt)) { photos, error in
            if error != nil {
                self.noImagesStatus()
                self.showSingleAlert("Can't load images")
                return
            }
            
            debugPrint("PhotosLoaded=\(photos.count)")
            
            for photo in photos {
                let _photo = Photo(context: self.dataController.viewContext)
                _photo.photoId = photo.id
                _photo.server = photo.server
                _photo.secret = photo.secret
                _photo.title = photo.title
                
                self.pin.addToPhotos(_photo)
            }

            try? self.dataController.viewContext.save()
            
            self.downloadPhotos()
            
            self.loadLocalData()
        }
    }
    
    func downloadPhotos(){
        debugPrint("downloadPhotos()")
        self.btnNewCollection.isEnabled = false
        RestClient.downloadAllPhotos(photos: fetchedResultsController.fetchedObjects!) { photo, data in
            debugPrint("Downloaded image=\(photo.id)")
            photo.image = data
            try? self.dataController.viewContext.save()
        } completion: { allSuccess in
            debugPrint("Downloaded All images success=\(allSuccess)")
            self.btnNewCollection.isEnabled = true
        }
    }
    
    func removeCurrentPhotos() {
        debugPrint("removeCurrentPhotos()")
        fetchedResultsController.fetchedObjects?.forEach({ photo in
            pin.removeFromPhotos(photo)
        })
        
        try? fetchedResultsController.managedObjectContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.startLoading()
        
        if photo.image != nil {
            cell.stopLoading()
            let image = UIImage(data: photo.image!)
            cell.ivPhoto?.image = image
            cell.setNeedsLayout()
        }
        
        return cell
    }
    
    private func handleEmptyView() {
        debugPrint("handleEmptyView() count=\(fetchedResultsController.fetchedObjects!.count)")
        if fetchedResultsController.fetchedObjects!.isEmpty {
            noImagesStatus()
        } else {
            imagesFoundStatus()
        }
    }
}


extension DetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.flowLayout.collectionView?.insertItems(at: [newIndexPath!])
            break
        case .delete:
            break
        case .update:
            self.flowLayout.collectionView?.reloadItems(at: [indexPath!])
            break
        case .move:
            self.flowLayout.collectionView?.moveItem(at: indexPath!, to: newIndexPath!)
            break
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleEmptyView()
    }
   
}

