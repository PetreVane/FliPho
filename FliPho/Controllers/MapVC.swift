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


class MapVC: UIViewController {

    
    
    // MARK: - Variables & constants
    
    
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate let authorizationStatus = CLLocationManager.authorizationStatus()
    fileprivate let areaInMeters: Double = 5000
    fileprivate var url: URL?
    fileprivate var photoAlbum: [String : PhotoRecord] = [:]
    let pendingOperations = PendingOperations()
    var pinAnnotations: [FlickrAnnotation] = []
    
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
    
        confirmLocationServicesAreON()
        getLocationCoordinates()
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        centerMapOnUserLocation()
//        getLocationCoordinates()
    }
    
    
    
    // MARK: - Error handling
    
    
    
    enum ErrorMessages: Error {
        
        case locationDisabled
        case allowLocationServices
        case restrictedLocationServices
        
        var description: String {
            
            switch self {
            case .locationDisabled:
                return "Location Services Disabled"
            case .restrictedLocationServices:
                return "Restricted Location Services"
            case .allowLocationServices:
                return "Can FliPho use your Location? "
            }
        }
    }
    
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
        }
    }
    
    // MARK: - Location Services
    
    
    
    func confirmLocationServicesAreON() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            checkAuthorizationStatus()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            
        } else {
            
            showAlert(message: .locationDisabled)
        }
    }
    
    func checkAuthorizationStatus() {
        
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            centerMapOnUserLocation()
        default:
            requestAuthorizationForLocationServices()
            print("request auth for location services called")
        }
    }
}

// MARK: - MapView Delegate methods



extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        
        mapView.showsUserLocation = true
        
        guard let coordinates = locationManager.location?.coordinate else { return }
        print("User coordinates are: Lat \(coordinates.latitude) and lon \(coordinates.longitude)")
        
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: areaInMeters, longitudinalMeters: areaInMeters)
       
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let reuseIdentifier = "flickrAnnotation"
        var view: MKMarkerAnnotationView
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView {
            dequedView.annotation = annotation
            view = dequedView
            view.markerTintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view.canShowCallout = true
            view.markerTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            view.clusteringIdentifier = reuseIdentifier
            
        }
        
//         here annotation refers to annotationPoint declared in dropPin method
            guard let annotationTitle = annotation.title as? String else { print(" Failed casting annotation title as string")
                return nil
            }
         let annotationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
        
            if let record = photoAlbum[annotationTitle] {
    
                DispatchQueue.main.async {
                    annotationImageView.image = record.image
                }
            }
        
        view.leftCalloutAccessoryView = annotationImageView
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Button pressed: trigger segue here")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.pinAnnotations)
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
   
    func requestAuthorizationForLocationServices() {
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(message: .restrictedLocationServices)
        case .denied:
            showAlert(message: .allowLocationServices)
        case .authorizedWhenInUse, .authorizedAlways:
            centerMapOnUserLocation()

        @unknown default:
            print("unknown default case in requestAuthorizationForLocationServices()")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
        print("Auth status changed to: \(status.rawValue)")
        getLocationCoordinates()
        centerMapOnUserLocation()
    }
}

// MARK: - Networking



extension MapVC {
    
    /*
     Tasks accomplished in Networking extension:
     
     1. getting the user geographic coordinates
     2. using geographic coordinates to construct a Flickr URL
     3. using the URL to call Flickr endpoint Api, which returns an encoded json with the urls of images taken around the user location
     The span area containing pictures accounts for 5000 meters.
     4. iterating over each image url, to get the image ID
     5. using each image ID, to call another Flickr endPpoint, which returns the geographic coordinates for that particular imageID
     6. using the returned geoGraphic coordinates, to establish the exact location where the image has been taken.
     7. iterating over each image url, to get the final image
     
     */
    
    func getLocationCoordinates() {
        
        guard let currentLocation = locationManager.location?.coordinate else { print ("Coordinates could not be established")
            showAlert(message: .allowLocationServices)
            return
        }
        
        guard let urlWithLocationCoordinates = FlickrURLs.fetchPhotosFromCoordinates(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            else { print ("Could not construct URL for FlickrURLs.fetchPhotosFromCoordinates method")
            return
        }
       
        fetchImageURLs(from: urlWithLocationCoordinates)
    }
    
    func fetchImageURLs(from url: URL) {
        
        print("fetchImageURLs called")
        
        let jsonDecoder = JSONDecoder()
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { print("Errors while requesting images for MapVC")
                return }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200 else { print("Server responded with unexpected status code")
                    return
            }
            
            guard let receivedData = data else { return }
            
            do {
                let decodedData = try jsonDecoder.decode(EncodedPhotos.self, from: receivedData)
                let decodedPhotos = decodedData.photos.photo
                
                for photo in decodedPhotos {

                    if let photoCoordinatesURL = FlickrURLs.fetchPhotoCoordinates(photoID: photo.id) {

                        self.fetchImageCoordinates(from: photoCoordinatesURL) { (latitude, longitude) in
                            
                            if let photoUrl = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
        
                                let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoUrl)
                                photoRecord.latitude = latitude
                                photoRecord.longitude = longitude
                                self.photoAlbum.updateValue(photoRecord, forKey: photo.title)
                                self.fetchImage(record: photoRecord)
                            }
                        }
                    }
                }
               
            } catch {
                print("Errors while parsing Image json: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    func fetchImageCoordinates(from url: URL, coordinates: @escaping (_ latitude: Double, _ longitude: Double) -> Void) {
        
//        print("fetchImageCoordinates called")
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            
            let decoder = JSONDecoder()
            
            guard error == nil else { print("Errors while requesting image coordinates for MapVC")
                return }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200 else { print("Server responded with unexpected status code")
                    return
            }
            
            guard let receivedData = data else { return }
            
            do {
                
                let geoData = try decoder.decode(Json.EncodedGeoData.self, from: receivedData)
                if let photoCoordinates = try? (latitude: Double(geoData.photo.location.latitude), longitude: Double(geoData.photo.location.longitude)) {
                    coordinates(photoCoordinates.latitude!, photoCoordinates.longitude!)
                    
                } else { print("Failed passing parsed geoData to completionHandler") }
                
                } catch { print("Errors while parsing GeoData: \(error.localizedDescription)") }
        }
        task.resume()
    }
    
    
    func fetchImage(record: PhotoRecord) {
        
//        print("fetchImage(recod:) called")
        let imageFetcher = ImageFetcher(photo: record)
        pendingOperations.downloadQueue.addOperation(imageFetcher)
        
        imageFetcher.completionBlock = {
            DispatchQueue.main.async {
                print("Image named: \(record.name) has been successfully fetched")
                self.dropPin(for: record)
            }
        }
    }
    
    // MARK: - Showing Pins
    
    
    
    func dropPin(for photoRecord: PhotoRecord) {
        print("dropPin(for record:) called")
        
        guard let latitude = photoRecord.latitude,
            let longitude = photoRecord.longitude else {return}
        
        let pointAnnotation = FlickrAnnotation(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude))
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

