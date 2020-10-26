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
    
    @objc(getWorkouts:withRejecter:)
    func getWorkouts(resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        guard let store = healthStore else {
            reject("Not Intialised", "HealthKit Store is not initialised", nil)
            return
        }
        
        let sampleType = HKSampleType.workoutType()
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
            
            if let error = error {
                reject("Query Failed", error.localizedDescription, error)
                return
            }
            
            guard let samples = results as? [HKWorkout] else {
                reject("Unexpected results", "The query returned unexpected results", nil)
                return
            }
            
            var workouts:Array<Dictionary<String, Any>> = []
            for sample in samples {
                var activityName:String
                
                switch sample.workoutActivityType {
                case HKWorkoutActivityType.walking:
                    activityName = "Walking"
                case HKWorkoutActivityType.running:
                    activityName = "Running"
                default:
                    activityName = "Other"
                }
                
                workouts.append([
                    "uuid":sample.uuid.uuidString,
                    "startDate":self.buildISO8601StringFromDate(sample.startDate),
                    "endDate":self.buildISO8601StringFromDate(sample.endDate),
                    "activityName":activityName,
                    "distance":sample.totalDistance?.doubleValue(for: .meter()) ?? 0,
                    "duration":sample.duration
                ])
                
            }
            
            resolve(workouts)
        }
        
        store.execute(query)
    }
    
    func buildISO8601StringFromDate(_ date:Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        return formatter.string(from:date)
    }
}
