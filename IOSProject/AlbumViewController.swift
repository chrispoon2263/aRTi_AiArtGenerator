//
//  AlbumViewController.swift
//  IOSProject
//
//  Created by Christopher Poon on 10/28/22.
//

import UIKit
import CoreData

let targetSize = CGSize(width: 100, height: 100)

var items: [UIImage] = []

protocol reloadView{
    func reloadCollectionView()
}

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, reloadView{
  
    var imageView: UIImageView!
    let cellIdentifier = "CellIdentifier"
    let imageSegueIdentifier = "ImageViewSegueIdentifier"
    var delegate:UIViewController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // set background image
        let backgroundImage = UIImage(named: "BG4")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = backgroundImage
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    // Populates cells in collectionVC with images
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
        
        var imageView:UIImageView=UIImageView(frame: CGRect(x:0, y:0, width:128, height:128))
        var img = items[indexPath.row]
        imageView.image = img
        imageView.contentMode = .scaleAspectFill
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Segue
        //print("You selected cell #\(indexPath.item)!")
        //selectedImage = items[indexPath.item]
        //currentIndex = indexPath.item
    }
    
    // Handles segue to ImageVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == imageSegueIdentifier,
           let destination = segue.destination as? ImageViewController,
           let imageIndex = collectionView.indexPathsForSelectedItems?.first?.row {
            destination.selectedImage = items[imageIndex]
            currentIndex = imageIndex
        }
    }
    
    // Formats collectionVC to have 3 cells in each row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

                let numCellsInRow = 3

                let collectionViewWidth = self.collectionView.bounds.width
                let extraSpace = CGFloat(numCellsInRow - 1) * flowLayout.minimumInteritemSpacing
                let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
                let width = Int((collectionViewWidth - extraSpace - inset) / CGFloat(numCellsInRow))

                return CGSize(width: width, height: width)
    }
    
    func reloadCollectionView(){
        self.collectionView.reloadData()
    }
    
    // Clears ALL Of CoreData for debugging
    func clearCoreData() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneratedImage")
        var fetchedResults:[NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                    print("\(result.value(forKey: "storedImage")!) has been deleted")
                }
            }
            saveContext()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
    }
    
    // Saves context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
