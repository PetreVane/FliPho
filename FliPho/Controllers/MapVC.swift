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

    fileprivate var locationManager = CLLocationManager()
    fileprivate let authorizationStatus = CLLocationManager.authorizationStatus()
    fileprivate let areaInMeters: Double = 5000
    fileprivate var url: URL?
    fileprivate var defaults = UserDefaults()
    fileprivate var photoDetails: [String: URL] = [:]
    fileprivate var listOfGeoDataURLs: [URL] = []
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        
        confirmLocationServicesAreON()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard let currentLocationCoordinates = locationManager.location?.coordinate else { print("Coordinates could not be established")
            return
        }
        url = FlickrURLs.fetchPhotosFromCoordinates(apiKey: consumerKey, latitude: currentLocationCoordinates.latitude, longitude: currentLocationCoordinates.longitude)
//        print("Final url: \(url)")
        fetchLocalImages(from: url!)
    }
    
    // MARK: - Alerting the user
    enum ErrorMessages {
        
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
            alert = UIAlertController(title: "Error", message: message.description, preferredStyle: .alert)
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
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {

        centerMapOnUserLocation()
    }
    
    
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        
        mapView.showsUserLocation = true
        
        guard let coordinates = locationManager.location?.coordinate else { return }
        print("User coordinates are: Lat \(coordinates.latitude) and lon \(coordinates.longitude)")
        
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: areaInMeters, longitudinalMeters: areaInMeters)
       
        mapView.setRegion(region, animated: true)
        
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
    
        centerMapOnUserLocation()
    }
}

extension MapVC {
    
    // MARK: - Networking
    
    func fetchLocalImages(from url: URL) {
        
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
                    if let photoUrl = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
                        
                        self.photoDetails.updateValue(photoUrl, forKey: photo.id)
                        
                    }
                }
                
               
                for (key, _) in self.photoDetails {
                    let imageGeoDataURL = FlickrURLs.fetchPhotosCoordinates(apiKey: consumerKey, photoID: key)
                    self.listOfGeoDataURLs.append(imageGeoDataURL!)
//                    if let imageData = try? Data(contentsOf: imageGeoDataURL!) {
//                        let decodedData = try jsonDecoder.decode(EncodedGeoData.self, from: imageData)
//                        print("Your GeoData: \(imageData.base64EncodedString())")
//                    }
                    self.fetchLocalImages(from: imageGeoDataURL!)
                    
                }
                
                
            } catch {
                print("Errors while parsing Image json: \(error.localizedDescription)")
            }
            
        }
        task.resume()
        
    }

    func fetchFotoCoordinates(from url: URL) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            
            let decoder = JSONDecoder()
            
            guard error == nil else { print("Errors while requesting image coordinates for MapVC")
                return }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200 else { print("Server responded with unexpected status code")
                    return
            }
            
            guard let receivedData = data else {return}
            print("Your data: \(receivedData.description)")
            
//            do {
//                let geoData = try decoder.decode(EncodedGeoData.self, from: receivedData)
//                let city = geoData.location.latitude
//                print("Image taken in : \(geoData.self)")
//
//
//            } catch {
//                print("Errors while parsing GeoData: \(error.localizedDescription)")
//            }
            
            
        }
        task.resume()
    }

}
