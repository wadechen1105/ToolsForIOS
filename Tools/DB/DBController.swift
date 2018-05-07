import Foundation
import FMDB

class DBController: ParentViewController {
    private var migrationManager: FMDBMigrationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let database = createDB("company.db")

        guard let db = database else {
            return
        }

        createTable(db, "CREATE TABLE IF NOT EXISTS t_employee" +
            "(number integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL)")

        let cmd = "insert into t_employee (name, age, email) values (?, ?, ?)"
        let value1: [Any] = ["John", 23, "John@h.com"]
        let value2: [Any] = ["Kobe", 39, "Kobe@nba.com"]

        do {
            try upgradDB_m1(db)
            try db.executeUpdate(cmd, values: value1)
            try db.executeUpdate(cmd, values: value2)

            let r = try db.executeQuery("select * from t_employee", values: nil)

            while r.next() {
                print(r.string(forColumn: "name"))
                print(r.string(forColumn: "city"))
            }

        } catch {
            print("upgrade DB fail : \(error)")
        }

        db.close()
    }

    func upgradDB_m1(_ db: FMDatabase) throws {

        migrationManager = FMDBMigrationManager(database: db, migrationsBundle: Bundle.main)

        let m = Migrating(name: "add new column", version: 1, executeUpdate: "alter table t_employee add email text")
        let m2 = Migrating(name: "add new column city", version: 2, executeUpdate: "alter table t_employee add city text")

        migrationManager!.addMigration(m)
        migrationManager!.addMigration(m2)

        print("db current version: \(migrationManager!.currentVersion)")
        print("db origin version: \(migrationManager!.originVersion)")
        print("db all migrations: \(migrationManager!.migrations)")
        print("db has migration count: \(migrationManager!.migrations.count)")

        for mm in (migrationManager?.migrations)! {
            let m = mm as! Migrating
        }


        if migrationManager != nil, !migrationManager!.hasMigrationsTable {
            try migrationManager!.createMigrationsTable()
        }

        try migrationManager!.migrateDatabase(toVersion: UINT64_MAX, progress: nil)
    }

}

class Migrating: NSObject, FMDBMigrating {

    var name: String!
    var version: UInt64 = 0
    var update: String!

    convenience init(name: String, version: UInt64, executeUpdate: String) {
        self.init()
        self.name = name
        self.version = version
        self.update = executeUpdate

    }

    func migrateDatabase(_ database: FMDatabase!) throws {
        if version == 0 {
            //FMDBMigrationManager issue
            return
        }
        try database.executeUpdate(update, values: nil)
    }
}

private let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DB", isDirectory: true)


public func createDB(_ name: String) -> FMDatabase? {

    do {
        try FileManager.default.createDirectory(at: dbPath, withIntermediateDirectories: true, attributes: nil)
    } catch {}


    let path = dbPath.appendingPathComponent(name).path

    let db = FMDatabase(path: path)
    if db!.open() {
        return db!
    }

    return nil
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
