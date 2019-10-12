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
    
    fileprivate let location = CLLocationManager()
    fileprivate let authorizationStatus = CLLocationManager.authorizationStatus()
    fileprivate let areaInMeters: Double = 5000
    fileprivate var photoAlbum: [String : PhotoRecord] = [:]
    fileprivate let pendingOperations = PendingOperations()
    fileprivate var annotationsList: [MKAnnotation] = []
    fileprivate let networkManager = NetworkManager()
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        location.delegate = self
    
        confirmLocationServicesAreON()
        getUserCoordinatesFrom(location)

    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        centerMapOnUser(location)
    }
    
    
    
    // MARK: - Error handling
    
    
    enum ErrorMessages: Error {
        
        case locationDisabled
        case allowLocationServices
        case restrictedLocationServices
        case failedCastingType
        case errorParsingJSON
        case failedAcquiringUserLocation
        
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
            case .failedAcquiringUserLocation:
                return "The app cannot establish your location. Please try again later"
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
            
        case .failedAcquiringUserLocation:
             alert = UIAlertController(title: "Error", message: message.description, preferredStyle: .alert)
             let dismissAction = UIAlertAction(title: "Ok, I'll try later", style: .cancel, handler: nil)
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
            centerMapOnUser(location)
            
        default:
            requestAuthorizationForLocationServices()
        }
    }
}

// MARK: - MapView Delegate methods


extension MapVC: MKMapViewDelegate {
    
    
    /// Centers the map on user location
    /// - Parameter location: Reference to location object that you use to start and stop the delivery of location-related events.
    
    func centerMapOnUser(_ location: CLLocationManager) {
        
//        guard let coordinates = location.location?.coordinate else { return }
        if let coordinates = location.location?.coordinate {
            
             let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: areaInMeters, longitudinalMeters: areaInMeters)
            
             mapView.setRegion(region, animated: true)
             mapView.showsUserLocation = true
        } else {
            
            showAlert(message: .failedAcquiringUserLocation)
        }

    }
    
    /// Sets annotations on map
    /// - Parameter mapView: Reference to an embeddable map interface, similar to the one provided by the Maps application.
    /// - Parameter annotation: Reference to an interface for associating your content with a specific map location.
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }

        let reuseIdentifier = "flickrAnnotation"
        var markerAnnotation: MKMarkerAnnotationView
        
        if let dequedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView {
            dequedAnnotation.annotation = annotation
            markerAnnotation = dequedAnnotation

        } else {
            
            markerAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            markerAnnotation.markerTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            markerAnnotation.clusteringIdentifier = reuseIdentifier
            markerAnnotation.canShowCallout = true
    
        }

        markerAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        

        return markerAnnotation
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("Button pressed: trigger segue here")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let customAnnotation = view.annotation as? FlickrAnnotation else { print("Failed casting view as Flickr Annotation (line 225)"); return }
        
        view.canShowCallout = true

        guard let recordIdentifier = customAnnotation.identifier else { print("Failed getting annotation id for record"); return }
        guard let photoRecord = photoAlbum[recordIdentifier] else { print("Failed getting photoRecord from dictionary"); return }
        
        fetchImage(for: photoRecord) { (image) in

            DispatchQueue.main.async {
                let annotationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
                annotationImageView.image = image
                view.leftCalloutAccessoryView = annotationImageView
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {

        view.leftCalloutAccessoryView = nil
        view.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
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
     2. using geographic coordinates to construct a Flickr URL, which is used to fetch images urls, relevant for user location
     3. using the URL from step 2 to call the Flickr endpoint Api(flickr.photos.search api method), which returns an encoded json with the urls of images taken around the user location
     The span area containing pictures accounts for 5000 meters.
     3.1. decoding the JSON object returned by the network request
     3.2. parsing the decoded data & iterating over each image url, to get the imageID
     4. then each imageID is used to construct an url for another Flickr endPoint(flickr.photos.geo.getLocation api method)
     5. using the flickr.photos.geo.getLocation url for another network request, which returns a json object containing the geographic coordinates for imageID
     5.1  decoding json object returned by flickr.photos.geo.getLocation api method
     5.2. parsing the json object; this method returns a tuple containing location coordinates casted as Double type
     6. using the returned geoGraphic coordinates, to establish the exact location where the image has been taken.
     7. iterating over each image url, to get the final image
     
     */
    
   // step 1: getting the user geographic coordinates
    func getUserCoordinatesFrom(_ location: CLLocationManager) {
        
        if let userLocation = location.location?.coordinate {
            // see implementation in step 2
            makeURL(with: userLocation)
        } else {
            showAlert(message: .failedAcquiringUserLocation)
        }
        
    }
    
    // step 2: passes user geographic coordinates as arguments to Flickr URL constructor
    func makeURL(with userCoordinates: CLLocationCoordinate2D?) {
        
        guard let userLocation = userCoordinates else { return }
        guard let urlWithCoordinates = FlickrURLs.fetchPhotosFromCoordinates(latitude: userLocation.latitude, longitude: userLocation.longitude) else { return }
        // see implementation in step 3
        fetchImageURLs(from: urlWithCoordinates)
    }
    
    // step 3: using the URL to call Flickr endpoint Api, which returns an encoded json with the urls of images taken around the user location
    func fetchImageURLs(from url: URL) {
                
        networkManager.fetchData(from: url) { [weak self] (result) in
            
            switch result {
                
            case .failure(let error):
                print("You've got some errors: \(error.localizedDescription)")
                
            case .success(let data):
                // see implementation in step 3.1
                if  let decodedData = self?.decodeJSON(model: DecodedPhotos.self, from: data) {
                    // see implementation in step 3.2
                    self?.parseImageData(from: decodedData)
                }
            }
        }
    }
    
    // step 3.1:  decoding the JSON object returned by the network request
    func decodeJSON<T>(model: T.Type, from data: Data) -> Result<T, Error> where T : Decodable {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(model.self, from: data)
            return .success(decodedData)
            
        } catch let error {
            return .failure(error)
        }
    }
    
  // step 3.2: parsing the decoded data & iterating over each image url, to get the image ID
    func parseImageData<T>(from data: Result<T, Error>) {
        
        switch data {
            
        case .failure(let error):
            print("Decoding ImageURLs in MapVC returned with errors: \(error.localizedDescription)")
            
        case .success(let decodedPhotos as DecodedPhotos):
            
            let album = decodedPhotos.photos.photo
            
            _ = album.compactMap { [weak self] photo in
                                
                if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_s.jpg") {
                    let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                    
                    // step 4: here, each image ID is used to construct an url for another Flickr endPoint(flickr.photos.geo.getLocation api method)
                    if let photoCoordinatesURL = FlickrURLs.fetchPhotoCoordinates(photoID: photo.id) {
                        
                        // step 5: using the url for flickr.photos.geo.getLocation api method, for another network request which returns a json object containing the geographic coordinates for that particular imageID; see method declaration at line 387
                        fetchImageCoordinates(from: photoCoordinatesURL) { [weak self] (latitude, longitude) in
                            photoRecord.latitude = latitude
                            photoRecord.longitude = longitude
                            self?.addMapAnnotation(for: photoRecord)
                        }
                    }
                }
            }
        default:
            print("Default case reached")
        }
    }
    
    func fetchImageCoordinates(from url: URL, coordinates: @escaping (_ latitude: Double?, _ longitude: Double?) -> Void) {
        
        networkManager.fetchData(from: url) {[weak self] (result) in
            
            switch result {
                
            case .failure(let error):
                print("Decoding ImageGeoData in MapVC returned with error: \(error.localizedDescription)")
            
            case .success(let data):
                // step 5.1: decoding json object;
                if let decodedData = self?.decodeJSON(model: DecodedGeoData.self, from: data) {
                    // step 5.2: parsing the json and passing the coordinates to completion handler; see implementation below, at line 408
                    self?.parseImageCoordinates(from: decodedData) { (latitude, longitude) in
                        coordinates(latitude, longitude)
                    }
                }
            }
        }
    }
    
    func parseImageCoordinates(from data: Result<DecodedGeoData, Error>, completion: @escaping (_ latitude: Double?, _ longitude: Double?) -> Void) {
        
        switch data {
            
        case .failure(let error):
            print("Error parsing GeoData of images: \(error.localizedDescription)")
            
        case .success(let data):
            let imageLocation = data.photo.location
            let coordinates = (latitude: Double(imageLocation.latitude), longitude: Double(imageLocation.longitude))
            completion(coordinates.latitude, coordinates.longitude)
        }
    }

    
    func fetchImage(for photoRecord: PhotoRecord, completion: @escaping (_ image: UIImage?) -> Void) {
        
        var recordImage: UIImage?
        
        let imageFetcher = ImageFetcher(photo: photoRecord)
        pendingOperations.downloadQueue.addOperation(imageFetcher)
        
        imageFetcher.completionBlock = {
            
            DispatchQueue.main.async {
                recordImage = photoRecord.image
                completion(recordImage)
            }
        }
    }
    
    // MARK: - Showing Pins
    
        
    func addMapAnnotation(for photoRecord: PhotoRecord) {
        
        // annotation coordinates
        guard let photoLatitude = photoRecord.latitude,
            let photoLongitude = photoRecord.longitude else {return}
                
        let customAnnotation = FlickrAnnotation(coordinate: CLLocationCoordinate2D.init(latitude: photoLatitude, longitude: photoLongitude))
        customAnnotation.title = photoRecord.name
        customAnnotation.identifier = photoRecord.imageUrl.absoluteString
        photoAlbum.updateValue(photoRecord, forKey: customAnnotation.identifier ?? "randomID")
    // showing annotation
        DispatchQueue.main.async {
            self.mapView.addAnnotation(customAnnotation)
        }
        
        

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

