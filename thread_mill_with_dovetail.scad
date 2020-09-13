// REFINEMENT
$fn = 180;

// INPUT
bolt_height = 3;
bolt_radius = 10;

cutter_radius = 10;
cutter_angle = 60;

mm_per_thread = 1;

// DERIVED
cutter_height = tan(cutter_angle)*cutter_radius/2;
increment_deg = 360/$fn;
increment_z = increment_deg*mm_per_thread/360;
total_iterations = bolt_height / increment_z;
offset = sin(cutter_angle/2)*cutter_radius;

threadmill_height = tan(cutter_angle/2)*cutter_radius/2;

echo(cutter_height);
echo(threadmill_height);
// DEFINE CUTTERS

module dovetail() {
    translate([bolt_radius + cos(cutter_angle/2)*cutter_radius-1, 0, -offset]) {
        rotate(a=[0, cutter_angle/2, 0]) { 
            cylinder(cutter_height, cutter_radius, cutter_radius/2, false);
        }
    }
}

module threadmill() {
    translate([bolt_radius + cutter_radius-1, 0, 0]) {
            cylinder(threadmill_height, cutter_radius, cutter_radius/2, false);
        rotate([0,180,0]){
            cylinder(threadmill_height, cutter_radius, cutter_radius/2, false);
        }
    }
}

module dovetail_screw(start_deg, end_deg) {
// perform milling operations
    difference() {
        cylinder(bolt_height, bolt_radius, bolt_radius, false);
        union() {
            for(i = [1: total_iterations]) {
                translate([0,0,i*increment_z]) {
                    rotate(a=[0,0,i*increment_deg]) {
                        if (i*increment_deg % 360 < end_deg && i*increment_deg % 360 > start_deg) {
                            dovetail();
                        }
                    }
                }
            }
        }
    }
}

module threadmill_screw(start_deg, end_deg) {
    difference() {
        cylinder(bolt_height, bolt_radius, bolt_radius, false);
        union() {
            for(i = [1: total_iterations]) {
                translate([0,0,i*increment_z]) {
                    rotate(a=[0,0,i*increment_deg]) {
                        if (i*increment_deg % 360 < end_deg && i*increment_deg % 360 > start_deg) {
                            threadmill();
                        }
                    }
                }
            }
        }
    }
}

module show_difference(start_deg, end_deg) {
    difference() {
        dovetail_screw(start_deg, end_deg);
        threadmill_screw(start_deg, end_deg);
    }
}

module show_side_by_side(start_deg, end_deg) {
    dovetail_screw(start_deg, end_deg);
    translate([-bolt_radius*2 + 1, 0, -mm_per_thread/2]) {
        rotate([0, 0, 180]) {
            threadmill_screw(start_deg, end_deg);
        }
    }
}

show_side_by_side(150, 210);