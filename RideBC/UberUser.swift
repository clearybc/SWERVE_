import Foundation
import CoreLocation
import UberCore
import UberRides
import SwiftyJSON
import Alamofire

class NewUserUber {
    struct UserUberRideDetail {
        var type: String
        var price: String
        var time: Double
        var product_id: String
    }

var currentType = "--"
var currentPrice = ""
var currentTime = 0.0
var currentProductID = ""


var newResults = UserUberRideDetail(type: "*****", price: "*****", time: 999, product_id: "")


    func UserSpecificInfo(latitude: Double, longitude: Double, destinationLatitude: Double, destinationLongitude: Double,completed: @escaping () -> ())  {self.User(latitude: latitude, longitude: longitude, destinationLatitude: destinationLatitude, destinationLongitude: longitude, completed: {completed()} )}

let token = "KA.eyJ2ZXJzaW9uIjoyLCJpZCI6IjMrdmpSVUllUzVLNW5KaDl4ZmNMOGc9PSIsImV4cGlyZXNfYXQiOjE1Mjc0ODM1MTMsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0.r4C39FDRoJtZ9W94YIaNBZLlhydPY4n9VCToR9Rv3CI"

let headers = [ "Bearer" : "KA.eyJ2ZXJzaW9uIjoyLCJpZCI6IjMrdmpSVUllUzVLNW5KaDl4ZmNMOGc9PSIsImV4cGlyZXNfYXQiOjE1Mjc0ODM1MTMsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0.r4C39FDRoJtZ9W94YIaNBZLlhydPY4n9VCToR9Rv3CI"]
    
    
    func User (latitude: Double, longitude: Double, destinationLatitude: Double, destinationLongitude: Double,completed: @escaping () -> ()){
        
        let parameters: Parameters = [
            "start_latitude": "\(latitude)",
            "start_longitude": "\(longitude)",
            "end_latitude": "\(destinationLatitude)",
            "end_longitude": "\(destinationLongitude)"]
        
        
        Alamofire.request("https://api.uber.com/v1.2/requests/estimate", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(" 😊😊😊😊😊THIS IS THE USER SPEFIFIC JSON \(json)")
            case .failure( _):
                print("there was an error in getting uber time info")
            }
            completed()
        }
    }

    

//func UserSpecific(latitude: Double, longitude: Double, completed: @escaping () -> ()){
//    Alamofire.request("https://api.uber.com/v1.2/products?latitude=\(latitude)&longitude=\(longitude)&access_token=\(token)", headers: headers).responseJSON { response in
//        switch response.result {
//        case .success(let value):
//            let json = JSON(value)
//            print("THIS IS THE NEW JSON \(json)")
////            print("###GET INFO 1 \(json)")
////            let uberTimeEstimate = json["times"][1]["estimate"].double
////            self.newResults.time = uberTimeEstimate!
////            print(" 1 UBER API RESULTS \(self.newResults.type), $\(self.newResults.price), \(self.newResults.time)min, \(self.newResults.product_id)")
//        case .failure( _):
//            print("there was an error in getting uber time info")
//        }
//        completed()
//    }
//}
}






//let token = "KA.eyJ2ZXJzaW9uIjoyLCJpZCI6ImkweTFJdStOUmJ5OElacE5hUHM3cXc9PSIsImV4cGlyZXNfYXQiOjE1Mjc0NzYyNzQsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0.pqlfk50zSZMr_Qv3YPy7w8ELsRvgOCT_HUnVGh207HM"
//
//let headers = [ "Authorization" : "Token OJIQQfoxM5LhYgS6qeWxHowU49kRHnGzueZeNuLe"
//    "client_id" : "7bvwa1OLRndxpWYdqrtxGJ_5nvLctYGL",
//    "client_secret" : "u07O2AXzjrhZJYclNfEMPs2NGiD51CYc2OltMj9R" ,
//    "grant_type" : "authorization_code",
//    "redirect_uri" : "Barbara.RideBC://oauth/consumer",
//    "code": "=<AUTHORIZATION_CODE>' \"]
//
//func getInfo1(latitude: Double, longitude: Double, completed: @escaping () -> ()){
//    Alamofire.request("https://login.uber.com/oauth/v2/\(token)", headers: headers).responseJSON { response in
//        switch response.result {
//        case .success(let value):
//            let json = JSON(value)
//            print("###GET INFO 1 \(json)")
//            let uberTimeEstimate = json["times"][1]["estimate"].double
//            self.newResults.time = uberTimeEstimate!
//            print(" 1 UBER API RESULTS \(self.newResults.type), $\(self.newResults.price), \(self.newResults.time)min, \(self.newResults.product_id)")
//        case .failure( _):
//            print("there was an error in getting uber time info")
//        }
//        completed()
//    }
//}
