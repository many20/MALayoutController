# Why MALayoutManager?

---

My goal was to make a class that can store the frame propertys of the view hierarchy of a view or a nib file as a layout and to switch between this layouts. 

with this class you can do:

- store the frame propertys from a view hierarchy or from a nib file
- switch the layout of the current view
- modify the layouts in the LayoutManager

Full **ARC** support   
support for ios 4.0   

# TODO

---

- the modify methods are not fully implemented


# How to use
---

### generate it:

    layoutManager = [[MALayoutManager alloc] initLayoutWithName:@"portraiLayout" fromView:self.view withBaseView:NO]; 
    [layoutManager addLayoutWithName:@"landscapeLayout" fromNib:@"iPhone_landscapeLayout"];
   
### change layout:

    [layoutManager changeToLayoutWithName:@"landscapeLayout"];
    or
    [layoutManager changeToLayoutWithName:@"portraiLayout"];
    
# LICENSE

---

Copyright 2012 Mario Adrian  
Released under the MIT Licenses

 
    