
import UIKit
import AudioToolbox

class TryCodeViewController: UIViewController {

    let lock = NSLock()

    private var _timeoutTask: Task?
    private var network: NetWorkHandler?
    //    var job: (() -> Bool)?

    func onChanged(_ status: NetworkStatus) {
        Log.d("net work: \(status)")

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let d1 = Date(timeIntervalSince1970:Date().timeIntervalSince1970)

        //        let d2 = Date(timeIntervalSince1970: 1475296000)

        let d3 = getCurrectMidnightTimeFormatToInt()
        let d2 = getTimeFormatToInt(TimeInterval(1475296000))

        Log.d("d3 \(d3), d2:\(d2)")

    }

    let convertDateFormat = "yyyyMdHHmm"

    func getTimeFormatToInt(_ timeInterval: TimeInterval) -> Int {
        let format = DateFormatter()
        format.dateFormat = convertDateFormat

        guard let time = Int(format.string(from: Date(timeIntervalSince1970: timeInterval))) else {
            return 0
        }

        return time
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ////////////// callback //////////////////
    let soundID: SystemSoundID = 1000
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.d("is new day? \(isNewDay())")
        //        let s = DispatchSemaphore(value: 0)
        //        let r = s.wait(timeout: .now() + 2)
        //        if r == .timedOut {
        //            Log.d("---timeout")
        //        } else {
        //            Log.d("====success")
        //        }
        //
        //        let q = DispatchQueue.global()
        //        q.async {
        //            self.test("two")
        //            s.signal()
        //        }



        //        await{  return String() }

        let q = DispatchQueue(label: "s")
        q.async {
            let t = self.test{
                sleep(5)
                Log.d("*****************")
            }

            Log.d("t:\(t)")
        }


    }

    func test(_ f :() -> Void) -> String {
        f()
        return "ok"
    }


    func await(_ function: () -> Any) -> Any {

        let q = DispatchQueue(label: "s")
        let group = DispatchGroup()
        Log.d("enter ====")
        let f = function()
        var result: Any?

        group.enter()
        q.async(group: group) {

            result = f
            sleep(3)
            group.leave()
            Log.d("12345 ====")
        }

        group.enter()
        q.async(group: group) {
            group.leave()
            Log.d("99999 ====")
        }


        let r = group.wait(timeout: .now() + 50)

        //        let s = DispatchSemaphore(value: 0)
        //        let r = s.wait(timeout: .now() + 1)
        //        let result = function()
        switch r {
        case .success:
            Log.d("success")
        default:
            Log.d("timeout")
            break
        }
        return String()
    }

    func isNewDay() -> Bool {
        let aDay_hrTomins = 2400 // mins

        let now = Date()
        let begin = Calendar.current.startOfDay(for: now)
        let format = DateFormatter()
        format.dateFormat = "yyMdHHmm"

        guard var nextDayMins = Int(format.string(from: begin)),
            let currentMins = Int(format.string(from: Date())) else {
                Log.w("convert to Int fail")
                return false
        }

        nextDayMins += aDay_hrTomins

        return nextDayMins <= currentMins
    }

    func try1() {



        var A = [4, 3, 2, 5, 7, 8, 9]
        let s = solitionForPermMissingElem(&A)

        print("ANS :\(s)")

        let g = 3
        let value = 19809101 / 10000


        var B: [UInt8] = [4, 3, 2, 5, 7, 8, 9]

        for i in 0..<B.count {
            B[i] = UInt8(100 + i)
        }

        print("B : \(B)")

        B = Array<UInt8>(B[0...g])

        print("drop: \(B.dropFirst(7)), B: \(B[0...g]), re: \(B.removeSubrange(0...2)), r\(B)")
        
        TowersOfHanoi(3, "A", "B", "C")
        
        
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? ""
        
        Log.d("country code: \(countryCode)")
        
        Log.d("58000.0? \(Int(Double("58000.0") ?? 0))")
        
        let countOfNotInTime = 37 / 2
        
        Log.d("has net work? \(network!.isReachable)), ....\(countOfNotInTime)")
        
        /*
         var test: [String] = []
         test[0] = "test" // fatal error: Index out of range
         */

    }
    
    /// "yyMdHHmm" to Int , ex: 1703150000
    func getCurrectMidnightTimeFormatToInt() -> Int {
        let aDay_hrTomins = 2400 // HHmm, next day format to Int
        
        let now = Date()
        let begin = Calendar.current.startOfDay(for: now)
        let format = DateFormatter()
        format.dateFormat = "yyyyMdHHmm"
        
        var saveDate = 0
        
        if let nextDayMins = Int(format.string(from: begin)) {
            saveDate = nextDayMins + aDay_hrTomins
        } else {
            Log.w("convert to Int fail")
        }
        
        return saveDate
    }
    
    
    func TowersOfHanoi(_ n: Int, _ A: Character, _ B: Character, _ C: Character) {
        if n == 1 {
            print("## Move sheet from \(A) to \(C)")
        } else {
            TowersOfHanoi(n - 1, A, C, B)
            TowersOfHanoi(1, A, B, C)
            TowersOfHanoi(n - 1, B, A, C)
        }
    }
    
    func solitionForPermMissingElem(_ A: inout [Int]) -> Int {
        
        A = A.sorted()
        let MAX = A.count + 1
        
        let min = A.isEmpty ? 0 : A[0]
        if min != 1 {
            return 1
        }
        
        for i in 1...A.count {
            let index = i - 1
            
            let missingVal = min + index
            if missingVal != A[index] {
                return missingVal
            }
        }
        
        return MAX
    }
    
}

class TestStatic {
    static let shard = TestStatic()
    let name = String("Test")!

    private init() {
        var i = 0
        DispatchQueue.global().async {
            while true {
                sleep(1)
                i += 1
                if i == 10 {
                    break
                }
            }
            Log.d("init Done, current T:\(Thread.current.description)")
        }

    }
    
}

