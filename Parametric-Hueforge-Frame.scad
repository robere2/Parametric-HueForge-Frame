// Parametric HueForge Frame Generator

/* [Features] */
// The bottom of the frame is what the picture sits in. This is required.
FrameBottom = true;
// The top of the frame has the border and holds the picture in place. This is required.
FrameTop = true;
// A hook allows you to hang the picture on a wall.
Hook = true;
// Legs allow you to stand up the picture on a flat surface.
Legs = true;

/* [Picture Settings] */
// Height of the picture (mm).
PictureHeight = 200; // [25:1:400]
// Width of the picture (mm).
PictureWidth = 200; // [25:1:400]
// Thickness of the picture (mm).
PictureDepth = 3; // [1:0.1:10]
// Extra space inside the frame (mm).
PictureTolerance = 0.25; // [0:0.05:2]


/* [Frame Settings] */
// Width of the border around the picture. Larger borders will cover more of the picture (mm).
Border = 12; //[12:1:30]
// Tolerance for the push-to-fit pins on the hook/legs, if enabled (mm).
PushFitTolerance= 0.05; // [0:0.01:1]
// Tolerance for the slide-to-fit keys that interlock the top and bottom of the frame (mm).
SlideFitTolerance= 0.20; // [0:0.01:0.4]

/* [Hook Settings] */
// Width of each tooth on the hook (mm).
HookToothSize = 5; // [3:1:10]
// Width of the entire hook (mm).
HookWidth = 30; // [20:1:50]
// Distance between the hook and the picture frame (mm).
HookDistance = 5; // [3:1:10]

/* [Legs Settings] */
// The length of the leg feet. This number should ideally be no less than a quarter of your picture height (mm).
LegLength = 50; // [25:1:100]
// Angle in degrees to rotate your picture towards a horizontal position (i.e. 0 is straight up, perpendicular with the floor).
LegAngle = 15; // [0:1:80]
// Space away from the edge of the picture frame to place the leg pin holes. This must not be more than half of the frame width (mm).
LegMargins = 10; // [0:1:150]

/* [Hidden] */
BackAndFrontDepth = 3; // Minimum: 2
WallsWidth = 7; // Minimum: 7 (smaller decreases strength of lid keys)

HookPinMargins = 2;
HookHeight = 10;
PinSize = 4;

LegWidth = 10; // Minimum: PinSize

TolerantWidth = PictureWidth + PictureTolerance;
TolerantHeight = PictureHeight + PictureTolerance;
TolerantDepth = PictureDepth + PictureTolerance;
    
module lid_key(negative) {
    
    TopPos = BackAndFrontDepth * 2 + TolerantDepth;
    RightPos = WallsWidth;
    KeyPositions = [[RightPos - 2, BackAndFrontDepth], [RightPos - 4, BackAndFrontDepth + 4]];
    
    if(negative) {        
        polygon([
            [0,0], 
            [0, TopPos],
            [2, TopPos],
            [2, KeyPositions[0][1]],
            KeyPositions[0],
            KeyPositions[1],
            [KeyPositions[1][0], TopPos],
            [RightPos, TopPos], 
            [RightPos, 0]
        ]);
    } else { 
        AngleDiff = SlideFitTolerance * sin(atan((KeyPositions[0][0] - KeyPositions[1][0]) / (KeyPositions[1][1] - KeyPositions[0][1])));
        polygon([
            [2 + SlideFitTolerance, KeyPositions[0][1] + SlideFitTolerance], 
            [2 + SlideFitTolerance, TopPos + SlideFitTolerance],
            [KeyPositions[1][0] - SlideFitTolerance, TopPos + SlideFitTolerance],
            [KeyPositions[1][0] - SlideFitTolerance, KeyPositions[1][1] - AngleDiff],
            [KeyPositions[0][0] - SlideFitTolerance - AngleDiff * 2, KeyPositions[0][1] + SlideFitTolerance]
        ]);
    }
}

module frame_bottom() {
    // Back
    translate([WallsWidth, WallsWidth, 0])
        difference() {
            cube([TolerantWidth, TolerantHeight, BackAndFrontDepth]);
            // Pin holes for hook, if enabled
            if(Hook) {
                translate([TolerantWidth / 2 - HookWidth / 2 + HookPinMargins - PushFitTolerance / 2, TolerantHeight - Border - 10 - PushFitTolerance / 2, -1])
                    cube([PinSize + PushFitTolerance, PinSize + PushFitTolerance, BackAndFrontDepth + 2]);
                translate([TolerantWidth / 2 + HookWidth / 2 - HookPinMargins - PinSize - PushFitTolerance / 2, TolerantHeight - Border - 10 - PushFitTolerance / 2, -1])
                    cube([PinSize + PushFitTolerance, PinSize + PushFitTolerance, BackAndFrontDepth + 2]);
            }
            
            // Pin holes for legs, if enabled
            if(Legs) {
                translate([LegMargins - PushFitTolerance / 2, 10 - PushFitTolerance / 2, -1])
                    cube([PinSize + PushFitTolerance, PinSize + PushFitTolerance, BackAndFrontDepth + 2]);
                translate([TolerantWidth - LegMargins - PinSize - PushFitTolerance / 2, 10 - PushFitTolerance / 2, -1])
                    cube([PinSize + PushFitTolerance, PinSize + PushFitTolerance, BackAndFrontDepth + 2]);
            }
        }
    
    // Bottom wall
    cube([TolerantWidth + WallsWidth * 2, WallsWidth, TolerantDepth + BackAndFrontDepth * 2]);
    
    
    // Left wall
    rotate([90, 0, 180])
        translate([-WallsWidth, 0, WallsWidth])
            linear_extrude(TolerantHeight)
            lid_key(true);
        
    // Right wall
    rotate([90, 0, 0])
        translate([TolerantWidth + WallsWidth, 0, -TolerantHeight - WallsWidth])
            linear_extrude(TolerantHeight)
            lid_key(true);
}

module frame_top() {
    module frame_top_side() {
        // Border top
        cube([WallsWidth + SlideFitTolerance, TolerantHeight, BackAndFrontDepth - SlideFitTolerance]);
        // Spacer
        translate([WallsWidth + SlideFitTolerance, 0, 0])
            cube([Border - WallsWidth - SlideFitTolerance, TolerantHeight, BackAndFrontDepth * 2]);
        // Slide key
        rotate([90, 180, 0])
            translate([-WallsWidth, -BackAndFrontDepth * 3 - TolerantDepth, -TolerantHeight])
                linear_extrude(TolerantHeight)
                lid_key(false);
    }
    
    // Frame top sides
    translate([0, WallsWidth, 0]) {        
        frame_top_side();
        rotate([0, 0, 180])
            translate([-TolerantWidth - WallsWidth * 2, -TolerantHeight, 0])
                frame_top_side();
    }
    
    // Bottom border
    translate([0, TolerantHeight - Border + WallsWidth * 2, 0])
        cube([TolerantWidth + WallsWidth * 2, Border, BackAndFrontDepth - SlideFitTolerance]);
    
    // Top wall and border
    cube([TolerantWidth + WallsWidth * 2, Border, BackAndFrontDepth - SlideFitTolerance]);
    cube([TolerantWidth + WallsWidth * 2, WallsWidth, TolerantDepth + BackAndFrontDepth * 3]);
}

module hook() {
    // Base
    translate([0, HookToothSize / 2, 0])
        cube([HookWidth, HookHeight, 2]);
    
    // Teeth
    ToothSpareSpace = HookWidth % HookToothSize;
    for(i = [ToothSpareSpace / 2:HookToothSize:HookWidth - HookToothSize])
        linear_extrude(height = 2, convexity = 10, twist = 0)
            polygon(points=[[i,HookToothSize / 2],[i + HookToothSize / 2,0],[i + HookToothSize,HookToothSize / 2]], paths=[[0,1,2]]);
    
    // Pins
    translate([HookPinMargins, (HookHeight - PinSize) / 2 + HookToothSize / 2, 0]) {
        cube([PinSize, PinSize, HookDistance + BackAndFrontDepth]);
    }
    translate([HookWidth - HookPinMargins - PinSize, (HookHeight - PinSize) / 2 + HookToothSize / 2, 0]) {
        cube([PinSize, PinSize, HookDistance + BackAndFrontDepth]);
    }
    
    // Pins Standoffs
    translate([HookPinMargins - 1, (HookHeight - PinSize) / 2 - 1 + HookToothSize / 2, 0]) {
        cube([PinSize + 2, PinSize + 2, HookDistance]);
    }
    translate([HookWidth - HookPinMargins - PinSize - 1, (HookHeight - PinSize) / 2 - 1 + HookToothSize / 2, 0]) {
        cube([PinSize + 2, PinSize + 2, HookDistance]);
    }
    
}

module legs() {
    for(i = [1:1:2]) {
        // Foot
        translate([(LegWidth + 10) * (i - 1), 2, 0]) {
            cube([LegWidth, LegLength, 2]);
        }
        // Joint
        translate([(LegWidth + 10) * (i - 1), 2, 2]) {
            rotate([90, 0, 90])
                    cylinder(LegWidth, 2, 2, $fn=50);
        }
        // Leg
        translate([(LegWidth + 10) * (i - 1), 2 + 2, 2]) {
            rotate([90 - LegAngle, 0, 0]) {
                cube([LegWidth, 30, 4]);
                // Pin
                translate([LegWidth / 2 - PinSize / 2, 10, 4])
                    cube([PinSize, PinSize, BackAndFrontDepth]);
            }
        }
        
    }
    
}

// Calculate translation amounts to center all objects around 0,0 (approximate).
// The amount to translate depends on which features are enabled.
FrameTopYOffset = FrameTop ? -TolerantHeight / 2 : 0;
FrameBottomYOffset = FrameBottom ? -TolerantHeight / 2 : 0;
FramesYOffset = FrameTopYOffset + FrameBottomYOffset + (FrameTopYOffset && FrameBottomYOffset ? - WallsWidth * 2 : 0);
FramesXOffset = FrameTop || FrameBottom ? -(TolerantWidth + WallsWidth * 2) / 2 : 0;
HookXOffset = Hook ? -(HookWidth) / 2 : 0;
LegsXOffset = Legs ? -((LegWidth) * 2 + 10) / 2 : 0;
HookLegsXOffset = min(HookXOffset, LegsXOffset) - (FrameTop || FrameBottom ?  WallsWidth * 0.75 : 0);

translate([FramesXOffset + HookLegsXOffset, FramesYOffset, 0]) {
    
        
    if(FrameBottom) {
            frame_bottom();
    }

    if(FrameTop) {
            if(FrameBottom) {
                translate([0, TolerantHeight + WallsWidth * 3, 0])
                    frame_top();
            } else {
                frame_top();
            }
    }
    
    // Center hook and legs along X axis (approximately) based on whether top and/or bottom frame are enabled
    HookLegsYOffset = (FrameTop ? TolerantHeight / 2 : 0) + (FrameBottom ? TolerantHeight / 2 : 0) + (FrameTop && FrameBottom ? WallsWidth * 2 : 0);
    translate([0, HookLegsYOffset, 0]) {

        if(Hook)
            if(FrameBottom || FrameTop) {
                translate([TolerantWidth + WallsWidth * 2 + 10, 0, 0])
                    hook();
            } else {
                hook();
            }
            
        if(Legs)
            if((FrameBottom || FrameTop) && Hook) {
                translate([TolerantWidth + WallsWidth * 2 + 10, HookToothSize + HookHeight + 20, 0])
                    legs();
            } else if(FrameBottom || FrameTop) {
                translate([TolerantWidth + WallsWidth * 2 + 10, 0, 0])
                    legs();
            } else if(Hook) {
                translate([0, HookToothSize + HookHeight + 20, 0])
                    legs();
            } else {
                legs();
            }

    }
}