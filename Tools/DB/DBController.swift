import Foundation
import FMDB

class DBController: ParentViewController {
    override var className: String {
        return String(describing: DBController.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let db = createDB("company.db")
        createTable(db, "CREATE TABLE IF NOT EXISTS t_employee" +
            "(number integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL)")
    }
}
private let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DB", isDirectory: true)

public func createDB(_ name: String) -> FMDatabase {

    do {
        try FileManager.default.createDirectory(at: dbPath, withIntermediateDirectories: true, attributes: nil)
    } catch {}


    let path = dbPath.appendingPathComponent(name).path

    return FMDatabase(path: path)
}

public func createTable(_ db: FMDatabase, _ tableCmd: String) {

    if db.open() {
        guard db.executeStatements(tableCmd) else {
            Log.d("create table fail")
            return
        }

        Log.d("create table success")
    }
}
