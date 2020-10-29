import HealthKit
import CoreLocation

@objc(Healthkit)
class Healthkit: NSObject {
    
    var healthStore = HKHealthStore()
    
    /// Requests permission
    @objc(requestPermissions:withRejecter:)
    func requestPermissions(resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            reject("Health Data Unavailable", "Health Data Unavailable", nil)
            return
        }
        
        var permissions = Set<HKObjectType>([HKObjectType.workoutType()])
        
        // If iOS version is 11 or greater, request permission for accessing workout routes
        if #available(iOS 11.0, *) {
            permissions.insert(HKSeriesType.workoutRoute())
        }
        
        healthStore.requestAuthorization(toShare: [], read: permissions, completion: { (success, error) in
            if let error = error {
                reject("Authorizarion failed", error.localizedDescription, error)
                return
            }
            resolve(true)
        })
    }
    
    /// Fetches the workouts for a given set of input parameters.
    @objc(getWorkouts:withResolver:withRejecter:)
    func getWorkouts(input:Dictionary<String, Any>, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        var start = Date()
        if let startDate = input["startDate"] as? Double {
            start = Date(timeIntervalSince1970: startDate / 1000)
        }
        
        var end = Date()
        if let endDate = input["endDate"] as? Double {
            end = Date(timeIntervalSince1970: endDate / 1000)
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        
        let query = HKSampleQuery(sampleType: .workoutType(),
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: nil)
        { (query, results, error) in
            
            if let error = error { return reject("Query Failed", error.localizedDescription, error) }
            
            guard let workouts = results as? [HKWorkout] else { return reject("Unexpected results", "The query returned unexpected results", nil) }
            
            var workoutItems = [Dictionary<String, Any>]()
            
            // Convert each workout into a JSON serializable form and attach associated routes and locations
            workouts.forEach({ (workout) in
                self.processWorkout(workout) { (workoutData) in
                    workoutItems.append(workoutData)
                    
                    // If all workouts have been process, return the result
                    if (workoutItems.count == workouts.count) {
                        return resolve(workoutItems)
                    }
                }
            })
        }
        
        healthStore.execute(query)
    }
    
    /// Converts a `HKWorkout` to JSON serializable form, then fetches and attaches any associated routes and locations.
    func processWorkout(_ workout:HKWorkout, resultsHandler: @escaping (Dictionary<String, Any>) -> Void) {
        // Convert workout to JSON serializable form
        var workoutData = workout.toJSONDictionary()
        
        // If iOS version is less than 11, routes are not available so just return the workout data
        guard #available(iOS 11.0, *) else { return resultsHandler(workoutData) }
        
        // Get routes for the workout
        self.getRoutes(for:workout) { (routes, error) in
            
            // If an error occurred or there are no routes, just return the workout data
            guard error == nil, let routes = routes, routes.count > 0 else { return resultsHandler(workoutData) }
            
            var routeItems:Array<Dictionary<String, Any>> = []
            
            // Convert routes to JSON serializable form and fetch any associated locations
            routes.forEach { (route) in
                self.processRoute(route) { (routeData) in
                    // Add the route data to the list
                    routeItems.append(routeData)
                    
                    // If all routes have been processed, attach the routes to the workout and return the data
                    if (routeItems.count == routes.count) {
                        workoutData["routes"] = routeItems
                        return resultsHandler(workoutData)
                    }
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    func getRoutes(for workout:HKWorkout, resultsHandler: @escaping ([HKWorkoutRoute]?, Error?) -> Void) {
        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
        
        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
                                               predicate: runningObjectQuery,
                                               anchor: nil,
                                               limit: HKObjectQueryNoLimit)
        { (query, samples, deletedObjects, anchor, error) in
            
            guard error == nil else { return resultsHandler(nil, error) }
            
            guard let routes = samples as? [HKWorkoutRoute] else {
                return resultsHandler(nil, GetRoutesError(errorDescription: "The query returned unexpected results"))
            }
            
            return resultsHandler(routes, nil)
        }
        
        healthStore.execute(routeQuery)
    }
    
    /// Converts a `HKWorkoutRoute` to a JSON serializable form then fetches and attaches any associated locations.
    @available(iOS 11.0, *)
    func processRoute(_ route:HKWorkoutRoute, resultsHandler: @escaping (Dictionary<String, Any>) -> Void) {
        // Convert route to JSON serializable form
        var routeData = route.toJSONDictionary()
        
        // Get locations for the route
        self.getLocations(for:route) { (locations) in
            
            // Convert locations to JSON serializable form
            let locationItems = locations.map({ (location) in
                return location.toJSONDictionary()
            })
            
            // Add locations to the route
            routeData["locations"] = locationItems
            
            // Return the serializable route data with the locations
            return resultsHandler(routeData)
        }
    }
    
    /// Fetches the locations for a `HKWorkoutRoute`. Locations are returned in batches over time and the results handler will only be called when all locations have been fetched.
    @available(iOS 11.0, *)
    func getLocations(for route:HKWorkoutRoute, resultsHandler: @escaping ([CLLocation]) -> Void) {
        var routeLocations:[CLLocation] = []
        
        let query = HKWorkoutRouteQuery(route: route) { (query, maybeLocations, done, maybeError) in
            // May be called multiple times
            
            // If an error occurred or the locations are invalid, end execution of this block
            guard maybeError == nil, let locations = maybeLocations else {
                // If no more locations, end execution and return the results
                if (done){ return resultsHandler(routeLocations) }
                
                // Otherwise, end execution
                return
            }
            
            // Add locations to the locations array
            routeLocations.append(contentsOf: locations)
            
            // If no more locations, return the results
            if done { return resultsHandler(routeLocations) }
            
            // Uncomment to stop the query immediately
            // healthStore.stop(query)
        }
        
        healthStore.execute(query)
    }
}

struct GetRoutesError:LocalizedError {
    var errorDescription: String?
    var failureReason: String?
}

struct GetLocationsError:LocalizedError {
    var errorDescription: String?
    var failureReason: String?
}

func buildISO8601StringFromDate(_ date:Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
    return formatter.string(from:date)
}

func dateFromISO8601String(_ string:String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
    return formatter.date(from: string)
}

extension HKWorkout {
    func toJSONDictionary() -> Dictionary<String, Any> {
        return [
            "uuid":self.uuid.uuidString,
            "startDate":buildISO8601StringFromDate(self.startDate),
            "endDate":buildISO8601StringFromDate(self.endDate),
            "workoutActivityType":self.workoutActivityType.toString(),
            "totalDistance":self.totalDistance?.doubleValue(for: .meter()) ?? 0,
            "duration":self.duration
        ]
    }
}

extension HKWorkoutActivityType {
    func toString() -> String {
        switch self {
        case .americanFootball:return "americanFootball"
        case .archery: return "archery"
        case .australianFootball: return "australianFootball"
        case .badminton: return "badminton"
        //        case .barre: return "barre"
        case .baseball: return "baseball"
        case .basketball: return "basketball"
        case .bowling: return "bowling"
        case .boxing: return "boxing"
        //        case .cardioDance: return "cardioDance"
        case .climbing: return "climbing"
        //        case .cooldown: return "cooldown"
        //        case .coreTraining: return "coreTraining"
        case .cricket: return "cricket"
        //        case .crossCountrySkiing: return "crossCountrySkiing"
        case .crossTraining: return "crossTraining"
        case .curling: return "curling"
        case .cycling: return "cycling"
        //        case .dance: return "dance"
        //        case .danceInspiredTraining: return "danceInspiredTraining"
        //        case .discSports: return "discSports"
        //        case .downhillSkiing: return "downhillSkiing"
        case .elliptical: return "elliptical"
        case .equestrianSports: return "equestrianSports"
        case .fencing: return "fencing"
        case .fishing: return "fishing"
        //        case .fitnessGaming: return "fitnessGaming"
        //        case .flexibility: return "flexibility"
        case .functionalStrengthTraining: return "functionalStrengthTraining"
        case .golf: return "golf"
        case .gymnastics: return "gymnastics"
        //        case .handCycling: return "handCycling"
        case .handball: return "handball"
        //        case .highIntensityIntervalTraining: return "highIntensityIntervalTraining"
        case .hiking: return "hiking"
        case .hockey: return "hockey"
        case .hunting: return "hunting"
        //        case .jumpRope: return "jumpRope"
        //        case .kickboxing: return "kickboxing"
        case .lacrosse: return "lacrosse"
        case .martialArts: return "martialArts"
        case .mindAndBody: return "mindAndBody"
        //        case .mixedCardio: return "mixedCardio"
        //        case .mixedMetabolicCardioTraining: return "mixedMetabolicCardioTraining"
        case .other: return "other"
        case .paddleSports: return "paddleSports"
        //        case .pickleball: return "pickleball"
        //        case .pilates: return "pilates"
        case .play: return "play"
        case .preparationAndRecovery: return "preparationAndRecovery"
        case .racquetball: return "racquetball"
        case .rowing: return "rowing"
        case .rugby: return "rugby"
        case .running: return "running"
        case .sailing: return "sailing"
        case .skatingSports: return "skatingSports"
        case .snowSports: return "snowSports"
        //        case .snowboarding: return "snowboarding"
        case .soccer: return "soccer"
        //        case .socialDance: return "socialDance"
        case .softball: return "softball"
        case .squash: return "squash"
        case .stairClimbing: return "stairClimbing"
        //        case .stairs: return "stairs"
        //        case .stepTraining: return "stepTraining"
        case .surfingSports: return "surfingSports"
        case .swimming: return "swimming"
        case .tableTennis: return "tableTennis"
        //        case .taiChi: return "taiChi"
        case .tennis: return "tennis"
        case .trackAndField: return "trackAndField"
        case .traditionalStrengthTraining: return "traditionalStrengthTraining"
        case .volleyball: return "volleyball"
        case .walking: return "walking"
        case .waterFitness: return "waterFitness"
        case .waterPolo: return "waterPolo"
        case .waterSports: return "waterSports"
        //        case .wheelchairRunPace: return "wheelchairRunPace"
        //        case .wheelchairWalkPace: return "wheelchairWalkPace"
        case .wrestling: return "wrestling"
        case .yoga: return "yoga"
        default: return "other"
        }
    }
}

@available(iOS 11.0, *)
extension HKWorkoutRoute {
    func toJSONDictionary() -> Dictionary<String, Any> {
        return [
            "uuid":self.uuid.uuidString,
            "startDate":self.startDate,
            "endDate":self.endDate,
        ]
    }
}

extension CLLocation {
    func toJSONDictionary() -> Dictionary<String, Any?>{
        return [
            "coordinate":["latitude":self.coordinate.latitude, "longitude":self.coordinate.longitude],
            "horizontalAccuracy":self.horizontalAccuracy,
            "verticalAccuracy":self.verticalAccuracy,
            "speed":self.speed,
            "course":self.course,
        ]
    }
}
