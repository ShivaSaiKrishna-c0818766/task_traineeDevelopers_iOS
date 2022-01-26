
import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {

}

extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var img: Data?
    @NSManaged public var relationship: Task?

}
