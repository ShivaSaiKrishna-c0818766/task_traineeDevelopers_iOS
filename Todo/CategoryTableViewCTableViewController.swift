import CoreData

import UIKit

class CategoryTableViewCTableViewController: UITableViewController {
    var categoryList = [Category]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCategory()
    }
    
    @IBAction func addAction(_ sender: Any) {
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first,
                let text = field.text, !text.isEmpty   else{
                    return
            }
            self?.createCategory(name: text)
        }))
        present(alert, animated: true)
    }
    
    func createCategory(name: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let cat = Category(context: context)
        cat.name = name
        cat.id = UUID()
        
        do {
            try context.save()
            categoryList.append(cat)
            tableView.reloadData()
        } catch  {
            print("Could not save!")
        }
    }
    
    func deleteCategory(item: Category){
        let i =  categoryList.firstIndex(of: item)!
        categoryList.remove(at: i)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if(item != nil){
            
            let fetchRequest = Task.fetchRequest() as! NSFetchRequest
            fetchRequest.predicate = NSPredicate(format: " tCategory = %@",item.name!)
            do {
                let results:NSArray = try context.fetch(fetchRequest) as NSArray
                for result in results
                {
                    context.delete(result as! NSManagedObject)
                }
            }
            catch
            {
                print("Fetch Failed")
            }
            
            
            context.delete(item);
            try! context.save()
        }
        tableView.reloadData()
    }
    
    func updateItem(item: Category) {
        let i =  categoryList.firstIndex(of: item)!
        categoryList[i] = item
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try! context.save()
        } catch  {
            
        }
        tableView.reloadData()
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
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let item =     categoryList[indexPath.row]
        let s = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        s.addTextField(configurationHandler: nil)
        s.textFields?.first?.text = item.name
        s.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let field = s.textFields?.first,
                let text = field.text, !text.isEmpty else{ return }
            item.name = text
            self?.updateItem(item: item)
        }))
        
        s.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            _ in
            self.deleteCategory(item: item)
        } ))
        
        self.present(s, animated: true)
    }
    // MARK: - Table view data source
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row].name
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
