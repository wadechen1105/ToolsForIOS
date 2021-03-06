
import UIKit
import CoreLocation
import AudioToolbox

typealias Task = (_ cancel : Bool) -> Void
typealias Block = () -> ()

let rootControllerLists: [UIViewController] = [ DeviceinfoViewController(),
                                                NotificationViewController(),
                                                DBController(),
                                                DownloadViewController(),
                                                CustomViewController(),
                                                BleViewController(),
                                                QRCodeViewController(),
                                                FileViewController() ]

public func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
    lockable.lock()
    criticalSection()
    lockable.unlock()
}

extension UIViewController {
    var titleName: String {
        let indexDot: Int = self.description.indexDistance(of: ".")!
        let indexＣolon: Int = self.description.indexDistance(of: ":")!
        return "\(String(self.description[indexDot + 1..<indexＣolon]))"
    }
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
        self.navigationItem.title = titleName
    }
    
}

class ViewController: ParentViewController, UITableViewDataSource, UITableViewDelegate {
    
    ////////////// callback //////////////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootControllerLists.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.d("index row :\(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: false)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(rootControllerLists[indexPath.row], animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = rootControllerLists[indexPath.row].titleName
        return cell
    }
    
}

class CustomViewController: UITableViewController {
    let cellName = "custom_ui_cell"
    
    let controllerLists: [UIViewController] = [CurveViewController()]
    
    override func viewDidLoad() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellName)
    }
    
    ////////////// callback //////////////////
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllerLists.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log.d("index row :\(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: false)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.controllerLists[indexPath.row], animated: true)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = cellName
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = "\(controllerLists[indexPath.row].description)"
        
        return cell
    }
    
}

//UI
extension UIAlertController {
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion);
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }
}

