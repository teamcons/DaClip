/*
 * Copyright (c) 2018 Dirli <litandrej85@gmail.com>
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


// The clipboard itself
class Services.ClipboardManager : GLib.Object {
    private Gtk.Clipboard clipboard = null;
    public signal void on_text_copied (string text);


    // Get clipboard
    public ClipboardManager () {
        clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
    }

    ~ClipboardManager () {
        clipboard.owner_change.disconnect (on_clipboard_event);
    }



    // Listen to cliboard events ?
    public virtual void start () {
        clipboard.owner_change.connect (on_clipboard_event);
    }


    // called when clipboard change
    private void on_clipboard_event () {

        // Get the gud shit
        string? text = request_text ();

        // Is either something or not
        bool text_available = (text != null && text != "") || clipboard.wait_is_text_available ();

        // if we got something
        if (text_available) {

            // Its not null
            if (text != null && text != "") {
                on_text_copied (text);
            }
        }


    }

    // idk
    private string? request_text () {
        string? result = clipboard.wait_for_text ();
        return result;
    }





}



// HMMN https://gist.github.com/voldyman/6ba4bf5fe888e85ba06f