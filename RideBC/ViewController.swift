import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import MapKit
import LyftSDK
import UberRides
import MediaPlayer

//to do: add correct info to buttons
//make sure all locations are accurate
//maybe add uber and lyft authorization?
//add map to where you are going

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var btnLyft: LyftButton!
    @IBOutlet weak var directionsView: MKMapView!
    @IBOutlet weak var btnUber: UIButton!
    @IBOutlet weak var btnLyftt: UIButton!
    
    @IBOutlet weak var UberTextBox: UITextView!
    @IBOutlet weak var LyfttextBox: UITextView!
    @IBOutlet weak var UberTimeTextBox: UITextView!
    @IBOutlet weak var LyftTimeTextBox: UITextView!
    @IBOutlet weak var DestinationLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    
    //shows pin on map
    var annotation = MKPointAnnotation()
    
    //set up location manager
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //actual values set in the CLLocationManagerDelegate
    var currentLatitude: CLLocationDegrees =  42.3355
    var currentLongitude: CLLocationDegrees = -71.1685
    
    //default destination is MAs
    var destinationName = "MAs"
    var destinationLatitude = 42.3359
    var destinationLongitude = -71.1493
    var destinationAddress = "1937 Beacon St."

    //creates variables for Uber and Lyft API info
    var uberResults = Uber()
    var lyftResults = Lyft()
    //trying
    var userSpecific = NewUserUber()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //play into video
         loadVideo()
        
        //sets up observer for video ending so that takeaction() will occur after video stops
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.takeAction), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
}
    
    //the part of viewdidload that happens after the vide plays
  @objc func takeAction(){
    
 self.directionsView.removeOverlays(self.directionsView.overlays)
directions()
    
    //location permissions and loading
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
    

        //this should animate the textboxes to appear, but they load when API loads for now
        UIView.animate(withDuration: 0.25) {
            self.btnLyftt.alpha = 1
            self.UberTextBox.alpha = 1
            self.LyfttextBox.alpha = 1
            self.directionsView.alpha = 1
            self.toolbar.alpha = 1
            self.btnUber.alpha = 1
            self.DestinationLabel.alpha = 1
            self.LyftTimeTextBox.alpha = 1
            self.UberTimeTextBox.alpha = 1
        }
    
        //format lyft button so there is no white space on the corners
        btnLyftt.layer.cornerRadius = 6;
        btnLyftt.layer.masksToBounds = true;
    
        //format Uber button to curve corners 
        btnUber.layer.cornerRadius = 6
    
        
        //show default MAs textboxes when loaded
        self.updateText()
    
    }
    

        //when uber button is pressed, send user to uber deeplink
        @IBAction func UberButtonPressed(_ sender: UIButton) {
        let uberPickup = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
        let uberDestination = CLLocation(latitude: self.self.destinationLatitude, longitude: self.destinationLongitude)
        
        //build a ride from current info
        let builder = RideParametersBuilder()
        builder.pickupLocation = uberPickup
        builder.dropoffLocation = uberDestination
        builder.dropoffNickname = "\(self.destinationName)"
        builder.dropoffAddress = "\(self.destinationAddress)"
        builder.productID = "55c66225-fbe7-4fd5-9072-eab1ece5e23e"
        let rideParameters = builder.build()
        let deeplink = RequestDeeplink(rideParameters: rideParameters)
        deeplink.execute()
    }
    
    
    @IBAction func LyftButtonPressed(_ sender: UIButton) {
        
        let lyftPickup = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
        let lyftDestination = CLLocationCoordinate2D(latitude: self.destinationLatitude, longitude: self.destinationLongitude)
         LyftDeepLink.requestRide(kind: .Standard, from: lyftPickup, to: lyftDestination)
    }
    

    
    func directions() {
        //load the map
        directionsView.delegate = self
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.directionsView.add(route.polyline)
                self.directionsView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsetsMake(100, 100, 100, 100), animated: true)
                self.directionsView.showsUserLocation = true
                
                self.annotation.coordinate = CLLocationCoordinate2D(latitude: self.destinationLatitude, longitude: self.destinationLongitude)
                self.directionsView.addAnnotation(self.annotation)
                
            }
        }
    }
    
    //map maker function
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(red:0.05, green:0.53, blue:0.59, alpha:1.0)
        polylineRenderer.fillColor = UIColor.red
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    //add location button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //if user refreshes, update everything again 
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        takeAction()
        self.directionsView.removeOverlays(self.directionsView.overlays)
    }
    

    //MARK: ALERT FUNCTION
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: LOADVIDEO, runs in viewdidload
    func loadVideo() {
        
        btnLyftt.alpha = 0
        UberTextBox.alpha = 0
        LyfttextBox.alpha = 0
        directionsView.alpha = 0
        toolbar.alpha = 0
        self.btnUber.alpha = 0
        self.DestinationLabel.alpha = 0
        self.LyftTimeTextBox.alpha = 0
        self.UberTimeTextBox.alpha = 0
        
        print("LOAD VIDEO IS RUNING!!!!!")
        
        //this line is important to prevent background music stop
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "RICKY", ofType:"mp4")
        
        let filePathURL = NSURL.fileURL(withPath: path!)
        let player = AVPlayer(url: filePathURL)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1
        
        self.view.layer.addSublayer(playerLayer)
        
        //sends notification when done
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.takeAction), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        
        player.seek(to: kCMTimeZero)
        player.play()
        
    }
    
    //MARK: UPDATE textboxes (called when new location is selected and in viewdidload
    func updateText(){
        
        //every time coordinates change, input the coordinates to update the info
        self.lyftResults.getAllLyftInfo(latitude: currentLatitude, longitude: currentLongitude, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude) {
            self.LyfttextBox.text = String(format: "$%.02f",self.lyftResults.newResults.price/100.0)
//            "$ \((self.lyftResults.newResults.price)/100.0) "
            self.LyftTimeTextBox.text = "\(Int((self.lyftResults.newResults.time)/60)) min "
            }
            
        self.uberResults.getUberInfo(latitude: currentLatitude, longitude: currentLongitude, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude){
            self.UberTextBox.text = "\(self.uberResults.newResults.price)"
            self.UberTimeTextBox.text = "\(Int((self.uberResults.newResults.time)/60.0)) min "
        }
        
    }
    
    
}


//MARK: PLACEPICKER EXTENSION
extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        destinationLatitude = place.coordinate.latitude
        destinationLongitude = place.coordinate.longitude
        destinationAddress = place.formattedAddress ?? " "
        destinationName = place.name
        DestinationLabel.text = "Destination: \(destinationName)"
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
        directionsView.addAnnotation(annotation)
        
        
        //if place is changed, update UI
        updateText()
        self.directionsView.removeOverlays(self.directionsView.overlays)
        directions()
//        self.lyftButtonChange()
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

//MARK: LOCATION MANAGER EXTENSION

extension ViewController: CLLocationManagerDelegate {
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .restricted:
            showAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            print("Something went wrong getting the UIApplicationOpenSettingsURLString")
            return
        }
        let settingsActions = UIAlertAction(title: "Settings", style: .default) { value in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsActions)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        //get current location coordinates
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        
        
        //make my location 2d for mkcoordinateregion
        let currentLocation2D = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        

        

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.fillColor = UIColor.red
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}
}
