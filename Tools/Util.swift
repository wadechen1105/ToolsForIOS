import Foundation

class TimerHandler {

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
