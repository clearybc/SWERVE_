import Foundation
import CoreLocation
import LyftSDK
import SwiftyJSON
import Alamofire


class Lyft {
    struct LyftRideDetail{
        var type = ""
        var price = 0.0
        var time = 0.0
    }

    
    let lyftDestination = CLLocationCoordinate2D(latitude:42.3359, longitude:-71.1493)

    
    var newResults = LyftRideDetail(type: "", price: 0, time: 0)
    let headers    = [ "Authorization" : "bearer EnaXEcGWR5Yc498LsxxO2KlfZKXupWQIl3wkO3xdce7FcRkIFZtmdfynnTOYZA5fdh7/JVlo/A0vjTHzxGpRiDB2uC18fo28E3SUzzp/PIsQUu4SkI011x4="]
    
    func getAllLyftInfo(latitude: Double, longitude: Double, destinationLatitude: Double, destinationLongitude:Double, completed: @escaping () -> ()){
        getLyftPriceInfo(latitude: latitude, longitude: longitude, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude, completed:{
            self.getLyftETAInfo(latitude: latitude, longitude: longitude, completed:{completed()} )
            
        })
    }
    
    func getLyftPriceInfo(latitude: Double, longitude: Double, destinationLatitude: Double, destinationLongitude:Double, completed: @escaping () -> ()) {
        Alamofire.request("https://api.lyft.com/v1/cost?start_lat=\(latitude)&start_lng=\(longitude)&end_lat=\(destinationLatitude)&end_lng=\(destinationLongitude)", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let LyftCostEstimate = json["cost_estimates"][2]["estimated_cost_cents_min"].double
                let lyftRideType = json["cost_estimates"][2]["ride_type"].stringValue
                self.newResults = LyftRideDetail(type: lyftRideType, price: LyftCostEstimate!, time: 0)
            case .failure( _):
                print("there was an error in getting lyft time info")
            }
            completed()
        }
    }
    
    func getLyftETAInfo(latitude: Double, longitude: Double, completed: @escaping () -> ()) {
        Alamofire.request("https://api.lyft.com/v1/eta?lat=\(latitude)&lng=\(longitude)", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                let lyftETAEstimate = json["eta_estimates"][1]["eta_seconds"].double
                if lyftETAEstimate != nil {
                    self.newResults.time = lyftETAEstimate!}
                print(" :) LYFT API RESULTS \(self.newResults.type), $\((self.newResults.price)/100), \((self.newResults.time)/60)min")
            case .failure( _):
                print("there was an error with getting lyft price info")
            }
            completed()
        }
    }
    
}
