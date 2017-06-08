
import UIKit
import CoreLocation
import AudioToolbox

typealias Task = (_ cancel : Bool) -> Void
typealias Block = () -> ()




let controllerLists: [UIViewController] = [NotificationViewController(),
                                           DBController()]

public func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
    lockable.lock()
    criticalSection()
    lockable.unlock()
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.deselectRow(at: indexPath, animated: false)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(controllerLists[indexPath.row], animated: true)

        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "cell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = "\(controllerLists[indexPath.row].className)"
        
        return cell
    }
    
}

