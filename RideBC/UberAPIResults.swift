import Foundation
import CoreLocation
import UberCore
import UberRides
import SwiftyJSON
import Alamofire

class Uber {
    struct UberRideDetail {
        var type: String
        var price: String
        var time: Double
        var product_id: String
    }
    

    var currentType = "--"
    var currentPrice = ""
    var currentTime = 0.0
    var currentProductID = ""


    var newResults = UberRideDetail(type: "*****", price: "*****", time: 999, product_id: "")
    

    func getUberInfo(latitude: Double, longitude: Double, destinationLatitude: Double, destinationLongitude: Double,completed: @escaping () -> ()) {
        self.getInfo1(latitude: latitude, longitude: longitude, completed:
        {self.getInfo2(latitude: latitude, longitude: longitude, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude, completed:
            {self.getInfo3(latitude: latitude, longitude: longitude, completed:
                {completed()} )})})}
   
    
let headers = [ "Authorization" : "Token OJIQQfoxM5LhYgS6qeWxHowU49kRHnGzueZeNuLe"]
    
    func getInfo1(latitude: Double, longitude: Double, completed: @escaping () -> ()){
        Alamofire.request("https://api.uber.com/v1.2/estimates/time?start_latitude=\(latitude)&start_longitude=\(longitude)", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let uberTimeEstimate = json["times"][1]["estimate"].double
                self.newResults.time = uberTimeEstimate!
                print(" 1 UBER API RESULTS \(self.newResults.type), $\(self.newResults.price), \(self.newResults.time)min, \(self.newResults.product_id)")
            case .failure(let error):
                print("there was an error in getting uber time info")
            }
            completed()
        }
    }
    
    func getInfo2(latitude: Double, longitude: Double, destinationLatitude: Double, destinationLongitude: Double,completed: @escaping () -> ()){
        print("https://api.uber.com/v1.2/estimates/price?start_latitude=\(latitude)&start_longitude=\(longitude)&end_latitude=\(destinationLatitude)&end_longitude=\(destinationLongitude)")
        
        Alamofire.request("https://api.uber.com/v1.2/estimates/price?start_latitude=\(latitude)&start_longitude=\(longitude)&end_latitude=\(destinationLatitude)&end_longitude=\(destinationLongitude)", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let uberPriceEstimate = json["prices"][0]["estimate"].stringValue
                self.newResults.price = uberPriceEstimate
                let uberType = json["prices"][0]["localized_display_name"].stringValue
                self.newResults.type = uberType
                   print(" 2 UBER API RESULTS \(self.newResults.type), $\(self.newResults.price), \(self.newResults.time)sec, \(self.newResults.product_id)")
            case .failure(let error):
                print("there was an error with getting uber price info")
            }
            completed()
        }
    }
    
    func getInfo3(latitude: Double, longitude: Double, completed: @escaping () -> ()){
        Alamofire.request("https://api.uber.com/v1.2/products?latitude=\(latitude)&longitude=\(longitude)", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let uberProductID = json["products"][1]["product_id"].stringValue
                self.newResults.product_id = uberProductID
                  print(" 3 UBER API RESULTS \(self.newResults.type), $\(self.newResults.price), \(self.newResults.time)min, \(self.newResults.product_id)")
            case .failure(let error):
                print("there was an error with getting uber price info")
            }
              completed()
        }
    }
}




//import Foundation
//import Alamofire
//import SwiftyJSON
//import GooglePlaces
//import MapKit
//
//class UberResults {
//    struct Results {
//        var type: String
//        var price: Int
//        var time: Int
//        var product_id: String
//    }
//
//       var latitude = 42.340715
//       var longitude = -71.155412
//       var destinationLatitude = 42.3359
//       var destinationLongitude = 71.1493
//
//    var newResults = Results(type: "", price: 0, time: 0, product_id: "")
//
//    //add completion handler
//
//    func getAllUberInfo(){
//        getUberTimeInfo()
//        getUberPriceInfo()
//        getUberTypeInfo()
//    }
//
//    //Mark: API CALLS
//
//    let headers = [ "Authorization" : "Token OJIQQfoxM5LhYgS6qeWxHowU49kRHnGzueZeNuLe"]
//
//    let UberTimeURL = "https://api.uber.com/v1.2/estimates/time?start_latitude=\(latitude)&start_longitude=\(longitude)"
//
//    let uberPriceURL = "https://api.uber.com/v1.2/estimates/price?start_latitude=\(latitude)&start_longitude=\(longitude)&end_latitude=\(destinationLatitude)&end_longitude=\(destinationLongitude)"
//
//    let uberProductURL = "https://api.uber.com/v1.2/products?latitude=\(latitude)&longitude=\(longitude)"
//
//    func getUberTimeInfo() {
//        Alamofire.request("\(UberTimeURL)", headers: headers).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                let uberTimeEstimate = json["times"][1]["estimate"].int
//                self.newResults.time = uberTimeEstimate!
//            case .failure(let error):
//                print("there was an error in getting uber time info")
//            }
//        }
//    }
//
//   func getUberPriceInfo() {
//    Alamofire.request("\(uberPriceURL)", headers: headers).responseJSON { response in
//    switch response.result {
//    case .success(let value):
//    let json = JSON(value)
//    let uberPriceEstimate = json["prices"][1]["high_estimate"].int
//    let uberType = json["prices"][1]["localized_display_name"].stringValue
//    self.newResults.price = uberPriceEstimate!
//    self.newResults.type = uberType
//    case .failure(let error):
//    print("there was an error with getting uber price info")
//    }
//        }
//    }
//
//    func getUberTypeInfo() {
//        Alamofire.request("\(uberProductURL)", headers: headers).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                let uberProductID = json["products"][2]["product_id"].stringValue
//                self.newResults.product_id = uberProductID
//            case .failure(let error):
//                print("there was an error with getting uber price info")
//            }
//        }
//    }
//
//}




//RECENTLY OLD


