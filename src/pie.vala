/* 
Copyright (c) 2011 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

using GLib.Math;

namespace GnomePie {

    public class Pie : GLib.Object {

	    public bool               fade_in          {get; private set; default = true;}
	    public double             fading           {get; private set; default = 0.0;}
	    public Color              active_color     {get; private set; default = new Color();}
	    public Cairo.ImageSurface active_caption   {get; private set;}
	    public bool               has_active_slice {get; private set; default = false;}
	    
	    public signal void on_hide();
	    
	    private Slice[]    slices       {private get; private set;}
	    private int        quick_action {private get; private set;}
	    private Slice      active_slice {private get; private set;}
	    private Center     center       {private get; private set;}
	    private PieWindow  window       {private get; private set;}
	    
	    public Pie(string hotkey, int quick_action = -1) {
            this.center = new Center(this); 
		    this.slices = new Slice[0];
		    this.quick_action = quick_action;
		    this.window = new PieWindow(this, hotkey);
        }
	    
	    public int slice_count() {
	        return _slices.length;
	    }
	    
	    public void activate() {
	        if(fade_in && fading > 0.0) {
	        
        	    if(active_slice != null)
        	        active_slice.activate();
        	    else if (this.has_quick_action())
        	        _slices[quick_action].activate();
            	hide();
        	}
        }
        
        public void hide() {
            if (fading > 0) fade_in = false;
        }
        
        public void show() {
            window.show();
        }
        
        public bool draw(Cairo.Context ctx, double mouse_x, double mouse_y) {
            //##
            double mouse_x = 0.0;
	        double mouse_y = 0.0;
	        get_pointer(out mouse_x, out mouse_y);
	        mouse_x -= width_request*0.5;
	        mouse_y -= height_request*0.5;
	        
	        var ctx = Gdk.cairo_create(window);
            ctx.set_operator(Cairo.Operator.OVER);
            ctx.translate(width_request*0.5, height_request*0.5);
        
            //##
        
            if (fade_in) {
                fading += Settings.global.frame_time/Settings.global.theme.fade_in_time;
                if (fading > 1.0) 
                    fading = 1.0;
                
            } else {
                fading -= Settings.global.frame_time/Settings.global.theme.fade_out_time;
                if (fading < 0.0) {
                    fading = 0.0;
                    fade_in = true;
                    on_hide();
                }     
            }
        
		    double distance = sqrt(mouse_x*mouse_x + mouse_y*mouse_y);
		    double angle = 0.0;
		
		    if (distance > 0) {
		        angle = acos(mouse_x/distance);
			    if (mouse_y < 0) 
			        angle = 2*PI - angle;
		    }
		    if (distance < Settings.global.theme.active_radius && this.has_quick_action())
		        angle = 2.0*PI*quick_action/(double)slice_count();
		    
		    has_active_slice = distance > Settings.global.theme.active_radius || this.has_quick_action(); 

            // clear the window
            ctx.save();
            ctx.set_operator (Cairo.Operator.CLEAR);
            ctx.paint();
            ctx.restore();

            center.draw(ctx, angle, distance);
            
            active_slice = null;
		    
		    for (int s=0; s<_slices.length; ++s) {
			    _slices[s].draw(ctx, angle, distance);
			    
			    if(_slices[s].active) {
			        active_slice = _slices[s];
			        active_color = active_slice.color();
			        active_caption = active_slice.caption;
			    }
		    }
		    
		    if (active_slice == null && this.has_quick_action()) {
			    active_slice = _slices[quick_action];
			    active_color = active_slice.color();
			    active_caption = active_slice.caption;
			}
 
            return true;
        }
        
        public double activity() {
            return center.activity;
        }
        
        public void add_slice(Action action) {
            _slices += new Slice(action, this);
        } 
        
        public bool has_quick_action() {
            return 0 <= quick_action < _slices.length;
        }
    }
}
