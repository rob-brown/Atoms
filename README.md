# Atoms

TODO: Make subspecs for the Atoms project: Smart Cells and Data Source Combinators

## Summary

An atom is an element that can't be subdivided any further and still retain it's chemical properties. Likewise, `Atoms` is a repository of highly-reusable objects that each provide a single feature. The repository includes several types of components. Each of the types can be imported specifically with CocoaPods.

## Components

### Smart Views

The smart views are designed to handle all the boilerplate of creating cells for table views and collection views. To use them, simply inherit from the appropriate class. Then implement a class method/function that handles the specific set up of your cell. For example:

```Swift
class MyCell: SmartTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    class func cell(tableView: UITableView, name: String) -> Self {
        let cell = self.cell(tableView)
        cell.titleLabel.text = name
        return cell
    }
}
```

### Data Sources Combinators

Combinators are objects that implement simple features. They can then be composed together to build up more complex features. Table view and collection view data sources frequently result in lots of boilerplate and duplicate code in view controllers. These combinators are designed to eliminate this problem and reduce the bulk in view controllers. The combinators are intended to work with the smart views, but the smart views aren't required. You may hook the combinators into your existing cell creation techniques. An example of using the combinators and smart views together is shown below:

```Swift
override func viewDidLoad() {
    super.viewDidLoad()
    let objects = []  // Get objects here
    let base = BaseDataSource(objects) { (view, indexPath, object) -> Any in
        return MyCell.cell(view as! UITableView, name: object as! String)
    }
    self.dataSource = ReorderableDataSource(base)
}
```

## License

`Atoms` is licensed under the MIT license, which is reproduced in its entirety here:

>Copyright (c) 2015 Robert Brown
>
>Permission is hereby granted, free of charge, to any person obtaining a copy
>of this software and associated documentation files (the "Software"), to deal
>in the Software without restriction, including without limitation the rights
>to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>copies of the Software, and to permit persons to whom the Software is
>furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in
>all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>THE SOFTWARE.
