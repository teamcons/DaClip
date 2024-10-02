public class ClipboardManager : Object {
    private static Gtk.Clipboard monitor_clipboard;
    public delegate void MonitorFn();

    public static void attach_monitor_selection(MonitorFn fn) {
        monitor_clipboard = Gtk.Clipboard.get_for_display (Gdk.Display.get_default (),
                                                           Gdk.SELECTION_PRIMARY);
        monitor_clipboard.owner_change.connect ((ev) => {
            stdout.printf("%s\n", ev.get_event_type ().to_string());
            stdout.flush ();
            fn();
        });
    }

    public static string get_selected_text () {
        var clipboard = Gtk.Clipboard.get_for_display (Gdk.Display.get_default (),
                                                       Gdk.SELECTION_PRIMARY);
        string text = clipboard.wait_for_text ();
        return text;
    }
    
    public static string get_clipboard_text () {
        var clipboard = Gtk.Clipboard.get_for_display (Gdk.Display.get_default (),
                                                       Gdk.SELECTION_CLIPBOARD);
        string text = clipboard.wait_for_text ();
        return text;
    }
    public static void set_text (string text) {
        var clipboard = Gtk.Clipboard.get_for_display (Gdk.Display.get_default (),
                                                       Gdk.SELECTION_CLIPBOARD);
        clipboard.set_text (text, text.length);
    }
}

void main(string[] args) {
    Gtk.init (ref args);
    ClipboardManager.attach_monitor_selection(() => {
        print ("fn called \n");
        stdout.flush ();
    });
    Gtk.main ();
}