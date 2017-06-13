
import UIKit
import CoreLocation
import AudioToolbox

typealias Task = (_ cancel : Bool) -> Void
typealias Block = () -> ()

let controllerLists: [UIViewController] = [NotificationViewController(),
                                           DBController(),
                                           DownloadViewController()]

public func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
    lockable.lock()
    criticalSection()
    lockable.unlock()
}

class ParentViewController: UIViewController {

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //fix This is the default "parallax" behavior triggered by the pushViewController:animated: method.
        // use the same background color with root navigation view controller
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = className
    }

}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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

