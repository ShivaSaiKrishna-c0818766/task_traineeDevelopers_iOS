import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {

}


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var tCategory: String?
    @NSManaged public var tCompleted: Bool
    @NSManaged public var tDate: Date?
    @NSManaged public var tDescription: String?
    @NSManaged public var tName: String?
    @NSManaged public var images: NSSet?
    @NSManaged public var subtask: NSSet?

}

// MARK: Generated accessors for images
extension Task {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for subtask
extension Task {

    @objc(addSubtaskObject:)
    @NSManaged public func addToSubtask(_ value: SubTask)

    @objc(removeSubtaskObject:)
    @NSManaged public func removeFromSubtask(_ value: SubTask)

    @objc(addSubtask:)
    @NSManaged public func addToSubtask(_ values: NSSet)

    @objc(removeSubtask:)
    @NSManaged public func removeFromSubtask(_ values: NSSet)

}
