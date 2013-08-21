////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011-2013 by Simon Schneegans                                //
//                                                                            //
// This program is free software: you can redistribute it and/or modify it    //
// under the terms of the GNU General Public License as published by the Free //
// Software Foundation, either version 3 of the License, or (at your option)  //
// any later version.                                                         //
//                                                                            //
// This program is distributed in the hope that it will be useful, but        //
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY //
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License   //
// for more details.                                                          //
//                                                                            //
// You should have received a copy of the GNU General Public License along    //
// with this program.  If not, see <http://www.gnu.org/licenses/>.            //
////////////////////////////////////////////////////////////////////////////////

namespace GnomePie {

////////////////////////////////////////////////////////////////////////////////
// A base class storing a set of Actions. Derived classes may define          //
// how these Actions are created. This base class serves for custom           //
// actions, defined by the user.                                              //
////////////////////////////////////////////////////////////////////////////////

public class ActionGroup : GLib.Object {

  //////////////////////////////////////////////////////////////////////////////
  //                          public interface                                //
  //////////////////////////////////////////////////////////////////////////////

  ///////////////////////////// public members /////////////////////////////////

  // A list of all stored actions.
  public Gee.ArrayList<Action?> actions { get; private set; }

  // The ID of the pie to which this group is attached.
  public string parent_id { get; construct set; }

  //////////////////////////// public methods //////////////////////////////////

  // construct block -----------------------------------------------------------
  construct {
    this.actions = new Gee.ArrayList<Action?>();
  }

  // C'tor, initializes all members. -------------------------------------------
  public ActionGroup(string parent_id) {
    GLib.Object(parent_id : parent_id);
  }

  // This one is called, when the ActionGroup is deleted. ----------------------
  public virtual void on_remove() {}

  // Adds a new Action to the group. -------------------------------------------
  public void add_action(Action new_action) {
    this.actions.add(new_action);
  }

  // Removes all Actions from the group. ---------------------------------------
  public void delete_all() {
    actions.clear();
  }

  // Makes all contained Slices no Quick Actions. ------------------------------
  public void disable_quickactions() {
    foreach (var action in actions) {
      action.is_quickaction = false;
    }
  }

  // Returns true, if one o the contained Slices is a Quick Action -------------
  public bool has_quickaction() {
    foreach (var action in actions) {
      if (action.is_quickaction) {
        return true;
      }
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  public virtual void serialize(Json.Builder builder) {

    foreach (var action in actions) {
      action.serialize(builder);
    }
  }
}

}
