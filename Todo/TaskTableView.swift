import UIKit
import CoreData
import Foundation

var taskList = [Task]()

class TaskTableView: UITableViewController, UISearchBarDelegate {
    var firstLoad = true
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchText = ""
    var sortText = "tDate"
    
    var categoryList = [Category]()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCellID", for: indexPath) as! TaskCell
        searchBar.delegate = self
        
        let thisTask: Task!
        thisTask = taskList[indexPath.row]
        
        taskCell.task = thisTask
        
        let now = Date()
        if thisTask.tDate! < now {
            taskCell.dateL.textColor = UIColor.red
        }
        if thisTask.tCompleted {
            taskCell.dateL.textColor = UIColor.green
        }
        
        taskCell.titleL.text = thisTask.tName
        taskCell.descL.text =  thisTask.tDescription
        	
        
        if(thisTask.tDate != nil){
            let d =  self.dateToString(date: thisTask!.tDate!)
            taskCell.dateL.text = d
        }
        
        return taskCell
    }
    
    func fetchCategory() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = Category.fetchRequest() as! NSFetchRequest
        do {
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results
            {
                let task = result as! Category
                categoryList.append(task)
            }
        }
        catch
        {
            print("Fetch Failed")
        }
        
    }
    
    @IBAction func sortAction(_ sender: Any) {
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { [weak self] _ in
            self?.sortText =  "tDate"
            self?.fetchTasks()
            
        }        )        )
        
        
        alert.addAction(UIAlertAction(title: "Category", style: .default, handler: {
            _ in
            self.sortText = "tCategory"
            self.fetchTasks()
        } ))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func dateToString(date: Date)-> String! {
        if(date == nil) {return ""}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd h:mm a"
        return dateFormatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCategory()
        fetchTasks()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editTask", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editTask"){
            let indexPath =  tableView.indexPathForSelectedRow!
            let taskDetail = segue.destination as? TaskDetailVC
            let selectedTask : Task!
            selectedTask =  taskList[indexPath.row]
            taskDetail!.selectedTask = selectedTask
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    func fetchTasks(){
        taskList.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = Task.fetchRequest() as! NSFetchRequest
        let sort = NSSortDescriptor(key: "\(sortText)", ascending: false)
        request.sortDescriptors = [sort]
        if(searchText != "" || !searchText.isEmpty){
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "tName contains[c] '\(searchText)' OR tDescription contains[c]  '\(searchText)'  OR tCategory contains[c]  '\(searchText)'")
            request.predicate = predicate
        }
        do {
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results
            {
                let task = result as! Task
                taskList.append(task)
            }
        }
        catch
        {
            print("Fetch Failed")
        }
        
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        fetchTasks()
    }
}
