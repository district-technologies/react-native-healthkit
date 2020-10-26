import HealthKit

@objc(Healthkit)
class Healthkit: NSObject {

    var healthStore:HKHealthStore?
    
    @objc(requestPermissions:withRejecter:)
    func requestPermissions(resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            reject("Health Data Unavailable", "Health Data Unavailable", nil)
            return
        }
        
        healthStore = HKHealthStore()
        
        let permissions = Set<HKObjectType>([HKObjectType.workoutType()])
        
        healthStore?.requestAuthorization(toShare: [], read: permissions, completion: { (success, error) in
            if let error = error {
                reject("Authorizarion failed", error.localizedDescription, error)
                return
            }
            resolve(true)
        })
    }
    
    @objc(getWorkouts:withResolver:withRejecter:)
    func getWorkouts(input:Dictionary<String, Any>, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        guard let store = healthStore else {
            reject("Not Intialised", "HealthKit Store is not initialised", nil)
            return
        }
        
        let sampleType = HKSampleType.workoutType()
        
        let startDate = input["startDate"] as? Double
        let endDate = input["endDate"] as? Double
        
        var start = Date()
        if let startDate = startDate {
            start = Date(timeIntervalSince1970: startDate / 1000)
        }
        
        var end = Date()
        if let endDate = endDate {
            end = Date(timeIntervalSince1970: endDate / 1000)
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
            
            if let error = error {
                reject("Query Failed", error.localizedDescription, error)
                return
            }
            
            guard let samples = results as? [HKWorkout] else {
                reject("Unexpected results", "The query returned unexpected results", nil)
                return
            }
            
            let workouts = samples.map { (workout) in
                return workout.toJSONDictionary()
            }
            
            resolve(workouts)
        }
        
        store.execute(query)
    }
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
        case .barre: return "barre"
        case .baseball: return "baseball"
        case .basketball: return "basketball"
        case .bowling: return "bowling"
        case .boxing: return "boxing"
        case .cardioDance: return "cardioDance"
        case .climbing: return "climbing"
        case .cooldown: return "cooldown"
        case .coreTraining: return "coreTraining"
        case .cricket: return "cricket"
        case .crossCountrySkiing: return "crossCountrySkiing"
        case .crossTraining: return "crossTraining"
        case .curling: return "curling"
        case .cycling: return "cycling"
        case .dance: return "dance"
        case .danceInspiredTraining: return "danceInspiredTraining"
        case .discSports: return "discSports"
        case .downhillSkiing: return "downhillSkiing"
        case .elliptical: return "elliptical"
        case .equestrianSports: return "equestrianSports"
        case .fencing: return "fencing"
        case .fishing: return "fishing"
        case .fitnessGaming: return "fitnessGaming"
        case .flexibility: return "flexibility"
        case .functionalStrengthTraining: return "functionalStrengthTraining"
        case .golf: return "golf"
        case .gymnastics: return "gymnastics"
        case .handCycling: return "handCycling"
        case .handball: return "handball"
        case .highIntensityIntervalTraining: return "highIntensityIntervalTraining"
        case .hiking: return "hiking"
        case .hockey: return "hockey"
        case .hunting: return "hunting"
        case .jumpRope: return "jumpRope"
        case .kickboxing: return "kickboxing"
        case .lacrosse: return "lacrosse"
        case .martialArts: return "martialArts"
        case .mindAndBody: return "mindAndBody"
        case .mixedCardio: return "mixedCardio"
        case .mixedMetabolicCardioTraining: return "mixedMetabolicCardioTraining"
        case .other: return "other"
        case .paddleSports: return "paddleSports"
        case .pickleball: return "pickleball"
        case .pilates: return "pilates"
        case .play: return "play"
        case .preparationAndRecovery: return "preparationAndRecovery"
        case .racquetball: return "racquetball"
        case .rowing: return "rowing"
        case .rugby: return "rugby"
        case .running: return "running"
        case .sailing: return "sailing"
        case .skatingSports: return "skatingSports"
        case .snowSports: return "snowSports"
        case .snowboarding: return "snowboarding"
        case .soccer: return "soccer"
        case .socialDance: return "socialDance"
        case .softball: return "softball"
        case .squash: return "squash"
        case .stairClimbing: return "stairClimbing"
        case .stairs: return "stairs"
        case .stepTraining: return "stepTraining"
        case .surfingSports: return "surfingSports"
        case .swimming: return "swimming"
        case .tableTennis: return "tableTennis"
        case .taiChi: return "taiChi"
        case .tennis: return "tennis"
        case .trackAndField: return "trackAndField"
        case .traditionalStrengthTraining: return "traditionalStrengthTraining"
        case .volleyball: return "volleyball"
        case .walking: return "walking"
        case .waterFitness: return "waterFitness"
        case .waterPolo: return "waterPolo"
        case .waterSports: return "waterSports"
        case .wheelchairRunPace: return "wheelchairRunPace"
        case .wheelchairWalkPace: return "wheelchairWalkPace"
        case .wrestling: return "wrestling"
        case .yoga: return "yoga"
        default: return "other"
        }
    }
}
