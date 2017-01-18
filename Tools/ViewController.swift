
import UIKit
import CoreLocation
import AudioToolbox

typealias Task = (_ cancel : Bool) -> Void
typealias Block = () -> ()

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

class Timer {

    let timerQueue = DispatchQueue(label: "com.acer.ios.halo.timer", attributes: [])
    func delayMainQueue(_ time: Int, task: Block?) -> Task? {
        return delay(onQueue: DispatchQueue.main, time, task: task)
    }

    func delay(_ time: Int, task: Block?) -> Task? {
        return delay(onQueue: timerQueue, time, task: task)
    }

    private func delay(onQueue queue: DispatchQueue, _ time: Int, task: Block?) ->  Task? {

        Log.d("delay function")
        let delayTime = Double(time) * Double(NSEC_PER_SEC)

        func dispatch_later(_ block: @escaping Block) {
            let delay = DispatchTime.now() + Double(Int64(delayTime)) / Double(NSEC_PER_SEC)
            queue.asyncAfter(deadline: delay, execute: block)
        }

        var closure: Block? = task
        var result: Task?

        let delayedClosure: Task = {
            cancel in
            if let internalClosure = closure {
                if (cancel == false) {
                    queue.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }

        result = delayedClosure

        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        return result
    }
    
    func cancel(_ task: Task?) {
        task?(true)
    }
    
}

let controllerLists: [UIViewController] = [NotificationViewController()]

public func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
    lockable.lock()
    criticalSection()
    lockable.unlock()
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return controllerLists.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.d("index row :\(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "cell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let name = String(describing: NotificationViewController.self)
        cell.textLabel?.text = "\(name)"

        return cell
    }

}

