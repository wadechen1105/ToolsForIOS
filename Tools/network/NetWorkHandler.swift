
import Foundation

protocol NetWorkCallback {
    func onChanged(_ status: NetworkStatus)
}

class NetWorkHandler: NSObject {

    private var internetReachability: Reachability?
    private var callback: NetWorkCallback?
    private var _networkStatus: NetworkStatus = NotReachable
    var networkSatus: NetworkStatus {
        return _networkStatus
    }

    var isReachable: Bool {
        switch _networkStatus {
        case NotReachable:
            return false
        case ReachableViaWiFi,
             ReachableViaWWAN :
            return true
        default:
            return false
        }
    }

    init(_ callback: NetWorkCallback) {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(_ :)),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        self.callback = callback
        self.internetReachability = Reachability.forInternetConnection()
        self.internetReachability!.startNotifier()
        _networkStatus = self.internetReachability!.currentReachabilityStatus()

    }

    @objc private func reachabilityChanged(_ note : Notification) {
        if let curReach = note.object as? Reachability {
            _networkStatus = curReach.currentReachabilityStatus()
            self.callback!.onChanged(_networkStatus)
        }
    }
    
}
