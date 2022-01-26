import UIKit


class TaskCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var descL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    
    var task: Task? = nil

    func l() {
        let now = Date()
        if task!.tDate! < now {
            self.layer.backgroundColor = UIColor.red.cgColor
        }
    }
    
}
