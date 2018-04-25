import UIKit
import CoreLocation
import GooglePlaces
import MapKit
import LyftSDK
import UberRides
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var btnLyft: LyftButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var UberTextBox: UITextView!
    @IBOutlet weak var LyfttextBox: UITextView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    //set up location manager
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //defaults
    //actual values set in the CLLocationManagerDelegate
    var currentLatitude: CLLocationDegrees =  42.340715
    var currentLongitude: CLLocationDegrees = -71.155412
    

    
    //preset destination is MAs unless user determines otherwise
    var destinationName = "MAs"
    var destinationLatitude = 42.3359
    var destinationLongitude = -71.1493
    var destinationAddress = "1937 Beacon St."

    //creates variables for Uber and Lyft classes info
    var uberResults = Uber()
    var lyftResults = Lyft()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.takeAction), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        loadVideo()
 //  takeAction()
}
    
  @objc func takeAction(){
    
        
        UIView.animate(withDuration: 0.25) {
            self.btnLyft.alpha = 1
            self.UberTextBox.alpha = 1
            self.LyfttextBox.alpha = 1
            self.mapView.alpha = 1
            self.toolbar.alpha = 1
        }
        
        
        //format lyft button
        btnLyft.layer.cornerRadius = 5;
        btnLyft.layer.masksToBounds = true;
        
        //location permissions and loading
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //show default MAs textboxes when loaded
        self.updateText()
        
        //CHANGE PRODUCT ID
        //adjust location coordinates
        // communicate an Uber dropoffLocation for Uber and build it into a button
        
        //properly formatted destination and location for Uber
        let uberPickup = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
        let uberDestination = CLLocation(latitude: self.self.destinationLatitude, longitude: self.destinationLongitude)
        
        let builder = RideParametersBuilder()
        builder.pickupLocation = uberPickup
        builder.dropoffLocation = uberDestination
        builder.dropoffNickname = "\(self.destinationName)"
        builder.dropoffAddress = "\(self.destinationAddress)"
        builder.productID = "6d318bcc-22a3-4af6-bddd-b409bfce1546"
        let rideParameters = builder.build()
        let button = RideRequestButton(rideParameters: rideParameters)
        
        //put the Uber button in the view
        self.view.addSubview(button)
        button.center = self.view.center
        
        //adjust location coordinates
        // Lyft button detail adjustments
        
        let lyftPickup = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
        let lyftDestination = CLLocationCoordinate2D(latitude: self.destinationLatitude, longitude: self.destinationLongitude)
        
        
        self.btnLyft.configure(rideKind: LyftSDK.RideKind.Standard, pickup: lyftPickup, destination: lyftDestination)

    }
    
    //add location button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    //basic alert function
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //video function
    //video function
    func loadVideo() {
        
        btnLyft.alpha = 0
        UberTextBox.alpha = 0
        LyfttextBox.alpha = 0
        mapView.alpha = 0
        toolbar.alpha = 0
        
        print("LOAD VIDEO IS WORKING!!!!!")
        
        
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
        
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.takeAction), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        
        player.seek(to: kCMTimeZero)
        player.play()
        
    }
    
    //uppdate the textboxes (called when new location is selected and in viewdidload
    func updateText(){
        
        //every time coordinates change, input the coordinates to update the info
        self.lyftResults.getAllLyftInfo(latitude: currentLatitude, longitude: currentLongitude, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude) {
            self.LyfttextBox.text = "Lyft can pick you up in \((self.lyftResults.newResults.time)/60) min and get you to \(self.destinationName) for $ \((self.lyftResults.newResults.price)/100.0)"
            }
            
        self.uberResults.getUberInfo(latitude: currentLatitude, longitude: currentLongitude, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude){
            self.UberTextBox.text = "Uber can pick you up in \((self.uberResults.newResults.time)/60.0) min and get you to \(self.destinationName) for \(self.uberResults.newResults.price)"
        }
    }
}


//for google places picker
extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        destinationLatitude = place.coordinate.latitude
        destinationLongitude = place.coordinate.longitude
        place.formattedAddress
        destinationName = place.name
        
        updateText()
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

//for user's current location
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

        //set zoom of map
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //amalgimation of region and span
        let region:MKCoordinateRegion = MKCoordinateRegionMake(currentLocation2D, span)
        //set mapview region
        mapView.setRegion(region, animated: true)
        //show location
        self.mapView.showsUserLocation = true
        
    
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}
