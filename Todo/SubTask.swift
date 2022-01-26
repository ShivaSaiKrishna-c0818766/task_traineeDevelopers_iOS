import Foundation
import CoreData

@objc(SubTask)
public class SubTask: NSManagedObject {

}

extension SubTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubTask> {
        return NSFetchRequest<SubTask>(entityName: "SubTask")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var task: Task?

}
