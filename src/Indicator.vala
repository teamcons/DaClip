/*
 * Copyright (c) 2024 Stella Ménier <stella.menier@gmx.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */



 // Create indicator
namespace Workspaces {
    public class Indicator : Wingpanel.Indicator {
        private Widgets.Popover? main_widget = null;
        private Services.ClipboardManager clipboard_manager;
        private bool close_popover;


        // Defining the indicator
        public Indicator () {
            Object (code_name : "daclip-indicator");

            Gtk.IconTheme.get_default().add_resource_path("/io/elementary/desktop/wingpanel/daclip");

            close_popover = true;

            ws_manager = new Services.WorkspacesManager ();

            ws_manager.screen.active_workspace_changed.connect (() => {
                int current_ws = ws_manager.current_ws;
                if (current_ws > -1) {
                    panel_label.newval (current_ws);
                    if (close_popover && main_widget != null) {
                        main_widget.ws_box.selected = current_ws;
                    }
                }
            });

            this.visible = true;
        }



        // Popover generation
        public override Gtk.Widget? get_widget () {
            if (main_widget == null) {
                var current_ws = ws_manager.current_ws;
                if (current_ws < 0) {
                    return null;
                }

                main_widget = new Widgets.Popover (current_ws, ws_manager.ws_count);

                ws_manager.screen.workspace_created.connect (() => {
                    main_widget.add_ws_btn (ws_manager.ws_count);
                });

                ws_manager.screen.workspace_destroyed.connect ((space) => {
                    main_widget.remove_ws_btn (space.get_number ());
                });
            }

            return main_widget;
        }




        // Changed state of popover
        private void on_changed_mode () {
            ws_manager.screen.get_workspace (main_widget.ws_box.selected).activate ((uint32) now_dt.to_unix ());
            close ();
        }

        public override void opened () {
            close_popover = false;
            main_widget.ws_box.mode_changed.connect (on_changed_mode);
        }

        public override void closed () {
            main_widget.ws_box.mode_changed.disconnect (on_changed_mode);
            close_popover = true;
        }
    }
}




// Connect Indicator
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Workspaces Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new Workspaces.Indicator ();
    return indicator;
}
