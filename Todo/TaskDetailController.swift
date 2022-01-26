
import UIKit
import CoreData

import Foundation

class TaskDetailVC: UIViewController {
    
    @IBOutlet weak var titleTv: UITextField!
    @IBOutlet weak var descriptionTv: UITextView!
    
    let datePicker = UIDatePicker()
    @IBOutlet weak var taskduedate: UITextField!
    
    let pickerView  = UIPickerView()
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var completeSwitch: UISwitch!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var imagesTableView: UITableView!
    var selectedTask : Task? = nil
    
    var categoryList = [Category]()
    
    var subTaskList = [SubTask]()
    
    var imagesList = [Image]()
    
    var taskDate : Date? = nil
    
    @IBOutlet weak var deleteBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategory()
        pickDate()
        initTv()
        if(selectedTask != nil){
            titleTv.text =  selectedTask?.tName
            descriptionTv.text = selectedTask?.tDescription
            categoryTextField.text = selectedTask?.tCategory
            completeSwitch.setOn(selectedTask!.tCompleted, animated: true)
            
            if(selectedTask?.subtask != nil && selectedTask?.subtask!.count ?? 0 > 0){
                let set = selectedTask!.subtask as! NSMutableSet
                let arr = set.allObjects  as! [SubTask];
                subTaskList = arr
            }
            
            if(selectedTask?.images != nil && selectedTask?.images!.count ?? 0 > 0){
                let set = selectedTask!.images as! NSMutableSet
                let arr = set.allObjects  as! [Image];
                imagesList = arr
            }
            
            if(selectedTask!.tDate != nil){
                let d = dateToString(date: selectedTask!.tDate!)
                if(d != ""){
                    datePicker.date =  stringToDate(date: d! )
                    taskduedate.text =  "\( dateToString(date: selectedTask!.tDate!))"
                }
            }
        }else {
            deleteBtn.isHidden = true
            completeSwitch.setOn(false, animated: true)
        }
        
    }
    
    func initTv() {
        imagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "imagesCell")
        imagesTableView.delegate = self
        imagesTableView.dataSource = self
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "subtaskCell")
        tableView.delegate = self
        tableView.dataSource = self
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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func addImageAction(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func addSubtaskAction(_ sender: Any) {
        let alert = UIAlertController(title: "New SubTask", message: "Enter new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first,
                let text = field.text, !text.isEmpty   else{
                    return
            }
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }
    
    
    func createItem(name: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let sub = SubTask(context: context)
        sub.name = name
        sub.id = UUID()
        sub.completed = false
        completeSwitch.setOn(false, animated: true)
        subTaskList.append(sub)
        tableView.reloadData()
    }
    
    func deleteItem (item: SubTask){
        let i =  subTaskList.firstIndex(of: item)!
        subTaskList.remove(at: i)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if(item != nil){
            context.delete(item);
            try! context.save()
            
        }
        tableView.reloadData()
    }
    
    func updateItem(item: SubTask, name: String, completed: Bool) {
        let i =  subTaskList.firstIndex(of: item)!
        subTaskList[i].name = name
        subTaskList[i].completed = completed
        if(completed == false){
            completeSwitch.setOn(false, animated: true)
        }
        tableView.reloadData()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if(selectedTask != nil){
            context.delete(selectedTask!);
            try! context.save()
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func completeSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn{
            if subTaskList.count > 0 {
                for sub in subTaskList {
                    if sub.completed == false {
                        let alert = UIAlertController(title: "Error", message: "One or more SubTask is incomplete.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        present(alert, animated: true)
                        sender.isOn = false
                        break
                    }
                }
            }
            
        } else{
           
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if descriptionTv.text.isEmpty || (titleTv.text?.isEmpty ?? nil)! || categoryTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Fields", message: "Enter all details.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }

        
        if(selectedTask == nil){
            let task = Task(context: context)
            task.tName = titleTv.text
            task.tDescription = descriptionTv.text
            task.tCategory = categoryTextField.text
            task.tCompleted =  completeSwitch.isOn
            task.tDate = datePicker.date
            task.id = UUID()
            
            let subs =  NSSet(array: subTaskList)
            task.addToSubtask(subs)
            
            let imgs =  NSSet(array: imagesList)
            task.addToImages(imgs)
            
            do {
                try context.save()
                taskList.append(task)
                navigationController?.popViewController(animated: true)
            } catch  {
                print("Could not save!")
            }
        }else{ // edit
            
            let request = Task.fetchRequest() as! NSFetchRequest
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results
                {
                    let task = result as! Task
                    if(task ==  selectedTask){
                        task.tName = titleTv.text
                        task.tDescription = descriptionTv.text
                        task.tDate = datePicker.date
                        task.tCategory = categoryTextField.text
                        task.tCompleted =  completeSwitch.isOn
                        print(completeSwitch.isOn)
                        
                        let subs =  NSSet(array: subTaskList)
                        task.addToSubtask(subs)
                        
                        let imgs =  NSSet(array: imagesList)
                        task.addToImages(imgs)
                        
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            }
            catch
            {
                print("Could not update Task!")
            }
            
        }
        
    }
    
    
    // Add Subtasks
    
    // DateTime Picker
    
    func pickDate () {
        datePicker.setDate(Date(), animated: true)
        datePicker.minimumDate = Date()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            datePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        }
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClick))
        toolbar.setItems([doneBtn], animated: true)
        taskduedate.inputAccessoryView = toolbar
        
        taskduedate.inputView = datePicker
        
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextField.inputView = pickerView
        categoryTextField.textAlignment = .center
    }
    
    @objc func doneClick() {
        taskduedate.text = dateToString(date: datePicker.date)
    }
    
    func dateToString(date: Date)-> String! {
        if(date == nil) {return ""}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func stringToDate(date: String)-> Date! {
        if(date == nil) {return Date()}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd h:mm a"
        if let date = dateFormatter.date(from: date) {
            datePicker.date = date
            return date
        }
        return Date()
    }
    
    // Images
    
    func createImage(data: Data){
        // imageView.image  = UIImage(date: arr[0].img!)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let sub = Image(context: context)
        sub.img = data
        sub.id = UUID()
        imagesList.append(sub)
        imagesTableView.reloadData()
    }
    
    func deleteImage (item: Image){
        let i =  imagesList.firstIndex(of: item)!
        imagesList.remove(at: i)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if(item != nil){
            context.delete(item);
            try! context.save()
        }
        imagesTableView.reloadData()
    }
    
}

extension TaskDetailVC: UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == imagesTableView {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "imagesCell", for: indexPath)
            let item = imagesList[indexPath.row]
            
            if let img = UIImage(data: item.img!) {
                cell.imageView?.image = img
                imageView.image = img
            }
            
            //            cell.imageView?.image = UIImage(data: item.img!)
            return cell
        } else if tableView == self.tableView {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "subtaskCell", for: indexPath)
            
            //        let set = selectedTask!.subtask as! NSMutableSet
            //        let arr = set.allObjects  as! [SubTask];
            
            let item = subTaskList[indexPath.row]
            if item.completed {
                cell.textLabel?.layer.backgroundColor = UIColor.green.cgColor
            }
            cell.textLabel?.text = item.name ?? ""
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        let set = selectedTask!.subtask
        //        let arr = set?.allObjects //Swift Array
        //        return arr?.count ?? 0
        if tableView == imagesTableView {
            return imagesList.count
        }else {
            return subTaskList.count
        }
    }
}

extension TaskDetailVC: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(tableView == self.tableView){
            let item =     subTaskList[indexPath.row]
            
            let alert = UIAlertController(title: "Edit SubTask", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                
                let s = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
                s.addTextField(configurationHandler: nil)
                s.textFields?.first?.text = item.name
                s.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
                    guard let field = alert.textFields?.first,
                        let text = field.text, !text.isEmpty   else{
                            return
                    }
                    
                    self?.updateItem(item: item, name: text, completed: item.completed)
                }        )        )
                
                s.addAction(UIAlertAction(title: item.completed ? "Not Completed" : "Completed", style: .cancel, handler: {
                    _ in
                    self?.updateItem(item: item, name: item.name!, completed: item.completed ? false : true)
                } ))
                
                self?.present(s, animated: true)
            }        )        )
            
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                _ in self.deleteItem(item: item)
            } ))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true)
        } else if tableView == imagesTableView {
            let item =    imagesList[indexPath.row]
            let alert = UIAlertController(title: "Delete Image", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.deleteImage(item: item)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            if let img = UIImage(data: item.img!) {
                imageView.image = img
            }
        }
    }
}


//extension NSSet {
//    func toArray<SubTask>() -> [SubTask] {
//        let array = self.map({ $0 as! SubTask})
//        return array
//    }
//}

extension TaskDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
            let  _ = self.imageView.image?.jpegData(compressionQuality: 0.75) // jpg
            if let png = imageView.image?.pngData() {
                createImage(data: png)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TaskDetailVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryList[row].name
        categoryTextField.resignFirstResponder()
    }
}
