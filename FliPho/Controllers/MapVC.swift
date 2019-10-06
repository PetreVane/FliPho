//
//  MapVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

   // MARK: - Variables & constants


class MapVC: UIViewController {
    
    fileprivate var location = CLLocationManager()
    fileprivate let authorizationStatus = CLLocationManager.authorizationStatus()
    fileprivate let areaInMeters: Double = 5000
    fileprivate var photoAlbum: [String : PhotoRecord] = [:]
    fileprivate let pendingOperations = PendingOperations()
    fileprivate var pinAnnotations: [FlickrAnnotation] = []
    fileprivate let networkManager = NetworkManager()
    
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        location.delegate = self
    
        confirmLocationServicesAreON()
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        centerMapOnUser(location)
//        getLocationCoordinates()
    }
    
    
    
    // MARK: - Error handling
    
    
    enum ErrorMessages: Error {
        
        case locationDisabled
        case allowLocationServices
        case restrictedLocationServices
        case failedCastingType
        case errorParsingJSON
        
        var description: String {
            
            switch self {
            case .locationDisabled:
                return "Location Services Disabled"
            case .restrictedLocationServices:
                return "Restricted Location Services"
            case .allowLocationServices:
                return "Can FliPho use your Location? "
            case .failedCastingType:
                return "Errors while casting String as Double"
            case .errorParsingJSON:
                return "Errors while trying to decode JSON data"
            }
        }
    }
    
    
    //MARK: - Alert
    
    
    func showAlert(message: ErrorMessages) {
        
        let alert: UIAlertController
        
        switch message {
            
        case .allowLocationServices:
            alert = UIAlertController(title: "Allow Location Access", message: message.description, preferredStyle: .alert)
            let openSettingsAction = UIAlertAction(title: "Allow", style: .default) { (action) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "Not now", style: .cancel, handler: nil)
            alert.addAction(openSettingsAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        case .locationDisabled:
            alert = UIAlertController(title: "Error", message: message.description, preferredStyle: .alert)
            let guideAction = UIAlertAction(title: "Go to Settings -> Privacy -> Location Services", style: .default, handler: nil)
            let laterAction = UIAlertAction(title: "Maybe later", style: .cancel, handler: nil)
            alert.addAction(laterAction)
            alert.addAction(guideAction)
            present(alert, animated: true, completion: nil)
        
        case .restrictedLocationServices:
            
            alert = UIAlertController(title: "Error", message: message.description, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok, I Understand", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            present(alert, animated: true, completion: nil)
            
        case .failedCastingType:
            print("Error casting String to Double in DecodeImageGeoData method")
            
        case .errorParsingJSON:
            print("Errors Parsing JSON in DecodeImageGeoData method")
        }
    }
    
    // MARK: - Location Services
    
    
    func confirmLocationServicesAreON() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            checkLocation(authorizationStatus)
            location.desiredAccuracy = kCLLocationAccuracyKilometer
            
        } else {
            
            showAlert(message: .locationDisabled)
        }
    }
    
    func checkLocation(_ authorizationStatus: CLAuthorizationStatus) {
        
        switch authorizationStatus {
            
        case .authorizedAlways, .authorizedWhenInUse:
            getUserCoordinatesFrom(location)
            centerMapOnUser(location)
            
        default:
            requestAuthorizationForLocationServices()
//            print("request auth for location services called")
        }
    }
}

// MARK: - MapView Delegate methods


extension MapVC: MKMapViewDelegate {
    

    
    /// Centers the map on user location
    /// - Parameter location: Reference to location object that you use to start and stop the delivery of location-related events.
    
    func centerMapOnUser(_ location: CLLocationManager) {
        
        guard let coordinates = location.location?.coordinate else { return }
        
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: areaInMeters, longitudinalMeters: areaInMeters)
       
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
    }
    
    /// Shows objects on map
    /// - Parameter mapView: Reference to an embeddable map interface, similar to the one provided by the Maps application.
    /// - Parameter annotation: Reference to an interface for associating your content with a specific map location.
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        guard !annotation.isKind(of: MKUserLocation.self) else {
//            return nil
//        }
//
//        let reuseIdentifier = "flickrAnnotation"
//        var view: MKMarkerAnnotationView
//
//        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView {
//            dequedView.annotation = annotation
//            view = dequedView
//            view.markerTintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//            view.canShowCallout = true
//            view.markerTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//            view.clusteringIdentifier = reuseIdentifier
//
//        }
//
////         here annotation refers to annotationPoint declared in dropPin method
//            guard let annotationTitle = annotation.title as? String else { print(" Failed casting annotation title as string")
//                return nil
//            }
//         let annotationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
//
//            if let record = photoAlbum[annotationTitle] {
//
//                DispatchQueue.main.async {
//                    annotationImageView.image = record.image
//                }
//            }
//
//        view.leftCalloutAccessoryView = annotationImageView
//        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//
//        return view
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("Button pressed: trigger segue here")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        getLocationCoordinates()
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.pinAnnotations)
        }
    }
}

// MARK: - Location Delegate methods


extension MapVC: CLLocationManagerDelegate {
   
    func requestAuthorizationForLocationServices() {
        
        switch authorizationStatus {
            
        case .notDetermined:
            location.requestWhenInUseAuthorization()
            
        case .restricted:
            showAlert(message: .restrictedLocationServices)
            
        case .denied:
            showAlert(message: .allowLocationServices)
            
        case .authorizedWhenInUse, .authorizedAlways:
            centerMapOnUser(location)

        @unknown default:
            print("unknown default case in requestAuthorizationForLocationServices()")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
        getUserCoordinatesFrom(location)
        centerMapOnUser(location)
    }
}

// MARK: - Networking


extension MapVC: JSONDecoding {
    
    /*
     Steps performed in Networking extension:
     
     1. getting the user geographic coordinates
     2. using geographic coordinates to construct a Flickr URL
     3. using the URL to call Flickr endpoint Api, which returns an encoded json with the urls of images taken around the user location
     The span area containing pictures accounts for 5000 meters.
     4. decoding the JSON object returned by the network request
     5. parsing the decoded data & iterating over each image url, to get the image ID
     6. using each image ID, to call another Flickr endPpoint, which returns the geographic coordinates for that particular imageID
     7. using the returned geoGraphic coordinates, to establish the exact location where the image has been taken.
     8. iterating over each image url, to get the final image
     
     */
    
   // step 1: getting the user geographic coordinates
    func getUserCoordinatesFrom(_ location: CLLocationManager){
        
        guard let userLocation = location.location?.coordinate else { checkLocation(authorizationStatus); return }
        makeURL(with: userLocation)
    }
    
    // step 2: using geographic coordinates to construct a Flickr URL
    func makeURL(with userCoordinates: CLLocationCoordinate2D?) {
        
        guard let userLocation = userCoordinates else { return }
        guard let urlWithCoordinates = FlickrURLs.fetchPhotosFromCoordinates(latitude: userLocation.latitude, longitude: userLocation.longitude) else { return }
        
        fetchImageURLs(from: urlWithCoordinates)
    }
    
    // step 3: using the URL to call Flickr endpoint Api, which returns an encoded json with the urls of images taken around the user location
    func fetchImageURLs(from url: URL) {
                
        networkManager.fetchData(from: url) { result in
            
            switch result {
                
            case .failure(let error):
                print("You've got some errors: \(error.localizedDescription)")
                
            case .success(let data):
                // see implementation in step 4
                let decodedData = self.decodeJSON(model: DecodedPhotos.self, from: data)
                // see implementation in step 5
                self.parseImageData(from: decodedData)
            }
        }
    }
    
    // step 4:  decoding the JSON object returned by the network request
    func decodeJSON<T>(model: T.Type, from data: Data) -> Result<T, Error> where T : Decodable {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(model.self, from: data)
            return .success(decodedData)
            
        } catch let error {
            return .failure(error)
        }
    }
    
  // step 5:  parsing the decoded data & iterating over each image url, to get the image ID
    func parseImageData<T>(from data: Result<T, Error>) {
        
        switch data {
            
        case .failure(let error):
            print("Decoding returned with errors: \(error.localizedDescription)")
            
        case .success(let decodedPhotos as DecodedPhotos):
            //print("Here are your photos: \(de.photos.photo)")
            let album = decodedPhotos.photos.photo
            _ = album.compactMap { photo in
                
                if let photoCoordinatesURL = FlickrURLs.fetchPhotoCoordinates(photoID: photo.id) {
                    guard let coordinates = try? Data(contentsOf: photoCoordinatesURL) else { print("Failed getting coordinates for id: \(photo.id)"); return }
                    
                }
                
//                if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
//                    let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
//                    photoAlbum[photo.id] = photoRecord
//                }
            }
            //print("You've got \(photoAlbum.count) photorecords")
        default:
            print("Default case reached")
        }
    }
    
//    func getLocationCoordinates() {
//
//        guard let currentLocation = locationManager.location?.coordinate else { print ("Coordinates could not be established")
//            showAlert(message: .allowLocationServices)
//            return
//        }
//
//        guard let urlWithLocationCoordinates = FlickrURLs.fetchPhotosFromCoordinates(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
//            else { print ("Could not construct URL for FlickrURLs.fetchPhotosFromCoordinates method")
//            return
//        }
//
////        fetchImageURLs(from: urlWithLocationCoordinates)
//        fetchImageURLsWhithNetworkManager(from: urlWithLocationCoordinates)
//    }
    
//    func fetchImageURLsWhithNetworkManager(from url: URL) {
//
//        networkManager.fetchData(from: url) { result in
//
//            switch result {
//            case .failure(let error):
//                print("Network request completed with error: \(error.localizedDescription)")
//
//            case .success(let receivedData):
//                guard let decodedData = self.decodeImageData(from: receivedData, as: JSON.self) else { return }
//                self.parseImageData(from: decodedData)
//            }
//        }
//    }
    
//    func decodeImageData(from data: Data, as contained: JSON.Type) -> JSON.EncodedPhotos? {
//
//        let decoder = JSONDecoder()
//        guard let decodedData = try? decoder.decode(contained.EncodedPhotos.self, from: data) else { print("Parsing JSON returned errors"); return nil }
//
//        return decodedData
//    }
        
//    func parseImageData(from data: EncodedPhotos) {
//
//        let decodedPhotos = data.photos.photo
//
//        for photo in decodedPhotos {
//
//            guard let photoCoordinatesURL = FlickrURLs.fetchPhotoCoordinates(photoID: photo.id) else { print("Failed constructing photoCoordinates URL"); return }
//            self.fetchImageCoordinates(from: photoCoordinatesURL) { (latitude, longitude) in
//
////                guard self != nil else { return }
//
//                guard let photoRecordURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") else { return }
//                let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoRecordURL)
//                photoRecord.latitude = latitude
//                photoRecord.longitude = longitude
//                self.photoAlbum.updateValue(photoRecord, forKey: photo.title)
//                self.fetchImage(record: photoRecord)
//            }
//        }
//    }

//    func fetchImageCoordinates(from url: URL, coordinates: @escaping (_ latitude: Double, _ longitude: Double) -> Void) {
//
//        networkManager.fetchData(from: url) { [weak self] result in
//
//            guard self != nil else { return }
//
//            switch result {
//            case .failure(let error):
//                print("FetchImageCoordinates completed with error: \(error.localizedDescription)")
//
//            case .success(let imageData):
//
//                do {
//                      try self?.decodeImageGeoData(from: imageData) { [weak self] (latitude, longitude) in
//
//                          guard self != nil else { return }
//                              coordinates(latitude, longitude)
//                            }
//                  } catch {
//                      print("Errors: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    
//    func decodeImageGeoData(from data: Data, coordinates: @escaping (_ latitude: Double, _ longitude: Double) -> Void) throws {
//
//        let decoder = JSONDecoder()
//
//        guard let geoData = try? decoder.decode(DecodedGeoData.self, from: data) else { throw ErrorMessages.errorParsingJSON }
////        let photoCoordinates = try (latitude: Double(geoData.photo.location.latitude), longitude: Double(geoData.photo.location.longitude))
//        guard let photoCoordinates = try? (latitude: Double(geoData.photo.location.latitude), longitude: Double(geoData.photo.location.longitude)) else { throw ErrorMessages.failedCastingType }
//        coordinates(photoCoordinates.latitude!, photoCoordinates.longitude!)
//    }
    
    
    func fetchImage(record: PhotoRecord) {
        
//        print("fetchImage(recod:) called")
        let imageFetcher = ImageFetcher(photo: record)
        pendingOperations.downloadQueue.addOperation(imageFetcher)
        
        imageFetcher.completionBlock = {
            DispatchQueue.main.async {
//                print("Image named: \(record.name) has been successfully fetched")
                self.dropPin(for: record)
            }
        }
    }
    
    // MARK: - Showing Pins
    
        
    func dropPin(for photoRecord: PhotoRecord) {
//        print("dropPin(for record:) called")
        
        guard let photoLatitude = photoRecord.latitude,
            let photoLongitude = photoRecord.longitude else {return}
        
        let pointAnnotation = FlickrAnnotation(coordinate: CLLocationCoordinate2D.init(latitude: photoLatitude, longitude: photoLongitude))
        pointAnnotation.title = photoRecord.name
        pinAnnotations.append(pointAnnotation)        
    }
}



    
     // MARK: - Navigation
    
    
extension MapVC {
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     
    
}

