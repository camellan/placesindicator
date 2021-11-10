 /*
 * Copyright (c) 2011-2018 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */
public class IndicatorPlaces : Wingpanel.Indicator {
    private Gtk.Image main_image;
    private Gtk.Image main_sd_image;
    private Gtk.Grid display_widget;
    private Gtk.Grid main_widget;
    private Gtk.Button main_button;
    private string label_name;
    private string r_label_name;
    private string icon_name;
    private string r_icon_name;
    private string uri_name;
    private string r_uri_name;
    private string user_home = GLib.Environment.get_home_dir ();
    private string config_dir;
    private string filename;
    private string app_arg;
    private int position = 0;
    private GLib.File file;
    private FileMonitor monitor;
    private VolumeMonitor volume_monitor;
    private Gtk.Separator r_separotor;


    public IndicatorPlaces () {
        Object (
            code_name : "wingpanel-indicator-places"
            //  display_name : _("Places Indicator"),
            //  description: _("Quick access to the default folder and custom bookmarks File Manager")
            );
    }

    construct {
        display_widget = new Gtk.Grid ();
        main_image = new Gtk.Image.from_icon_name ("system-file-manager-symbolic", Gtk.IconSize.MENU);
        main_sd_image = new Gtk.Image.from_icon_name ("media-removable-symbolic", Gtk.IconSize.MENU);
        main_image.margin_top = 4;
        main_image.margin_end = 5;
        main_sd_image.margin_top = 5;
        display_widget.add(main_image);
        main_widget = new Gtk.Grid ();
        // main_widget.row_spacing = 2;
        make_std_places ();
        make_user_places ();
        start_monitor ();
        detect_removable_devices ();
        this.visible = true;
    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        return main_widget;
    }

    public override void opened () {
    }

    public override void closed () {
    }

    public void detect_removable_devices () {
        main_sd_image.visible = false;

        volume_monitor = VolumeMonitor.get ();

        List<Drive> drives = volume_monitor.get_connected_drives ();
        foreach (Drive drive in drives) {
            bool type_drive = drive.is_removable();
            string[] kinds = drive.enumerate_identifiers ();
            foreach (unowned string kind in kinds) {
                if (type_drive && drive.get_identifier (kind) != "/dev/sr0"){
                    display_widget.add(main_sd_image);
                    main_sd_image.visible = true;
                } else {
                    main_sd_image.visible = false;
                    display_widget.remove(main_sd_image);
                }
            }
        }

        volume_monitor.volume_added.connect ((volume) => {
            r_label_name = volume.get_name ();
            // r_icon_name = volume.get_icon ().to_string ();
            // var mount = volume.get_mount ();
            // r_uri_name = mount.get_default_location ().get_path ();
            // print (r_uri_name );
            // make_button (r_label_name, r_icon_name, r_uri_name);
        });

        volume_monitor.drive_connected.connect ((drive) => {
            display_widget.add(main_sd_image);
            main_sd_image.visible = true;
        });

        volume_monitor.drive_disconnected.connect ((drive) => {
            List<Drive> drivess = volume_monitor.get_connected_drives ();
            foreach (Drive driven in drivess) {
                bool type_drive = driven.is_removable();
                string[] kinds = driven.enumerate_identifiers ();
                foreach (unowned string kind in kinds) {
                    if (type_drive && driven.get_identifier (kind) != "/dev/sr0") {
                        debug ("Connected removable devices: " + driven.get_identifier (kind) + "\n");
                        main_sd_image.visible = true;
                        display_widget.add(main_sd_image);
                        return;
                    } else {
                        main_sd_image.visible = false;
                        display_widget.remove(main_sd_image);
                        main_sd_image = new Gtk.Image.from_icon_name ("media-removable-symbolic", Gtk.IconSize.MENU);
                        main_sd_image.margin_top = 5;
                    }
                }
            }
        });

        volume_monitor.mount_added.connect ((mount) => {
            main_sd_image.visible = false;
            display_widget.remove(main_sd_image);
            main_sd_image = new Gtk.Image.from_icon_name ("media-removable-symbolic-active", Gtk.IconSize.MENU);
            main_sd_image.margin_top = 5;
            display_widget.add(main_sd_image);
            main_sd_image.visible = true;
            r_separotor = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            main_widget.attach (r_separotor, 0, position);
            position++;
            r_icon_name = mount.get_icon ().to_string ();
            r_uri_name = "file:" + mount.get_default_location ().get_path ();
            make_button (r_label_name, r_icon_name, r_uri_name);
        });

        volume_monitor.mount_pre_unmount.connect ((mount) => {
            main_sd_image.visible = false;
            display_widget.remove(main_sd_image);
            main_sd_image = new Gtk.Image.from_icon_name ("media-removable-symbolic-warning", Gtk.IconSize.MENU);
            main_sd_image.margin_top = 5;
            display_widget.add(main_sd_image);
            main_sd_image.visible = true;
        });

        volume_monitor.mount_removed.connect ((mount) => {
            main_sd_image.visible = false;
            display_widget.remove(main_sd_image);
            main_sd_image = new Gtk.Image.from_icon_name ("media-removable-symbolic-error", Gtk.IconSize.MENU);
            main_sd_image.margin_top = 5;
            display_widget.add(main_sd_image);
            main_sd_image.visible = true;
        });

    }

    public void update_menu () {
        int a = position;
        while (a != 5) {
            main_widget.remove_row (a);
            a--;
        }
        make_user_places ();
    }

    public void make_button (string label_name, string icon_name, string uri_name) {
        main_button = new Gtk.Button();
        main_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        var bbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        bbox.set_hexpand(true);
        bbox.spacing = 10;
        var blabel =  new Gtk.Label(label_name);
        blabel.halign = Gtk.Align.START;
        try {
            var icon = GLib.Icon.new_for_string (icon_name);
            var bimage = new Gtk.Image.from_gicon(icon, Gtk.IconSize.MENU);
            bbox.pack_start(bimage, false, false, 0);
        }
        catch (GLib.Error error) {
            warning ("Error opening icon: %s", error.message);
        }
        bbox.pack_start(blabel, false, false, 0);
        main_button.add(bbox);
        main_widget.attach (main_button, 0, position);
        position++;


        main_button.button_press_event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == 1) {
                try{
                    GLib.AppInfo.launch_default_for_uri (uri_name, null);
                    close();
                }
                catch (GLib.Error error) {
                    warning ("Error opening directory: %s", error.message);
                }
            }

            if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
                try {
                    app_arg = "\"" + Filename.from_uri(uri_name, null) + "\"";
                }
                catch (GLib.Error error) {
                    warning ("Error decode directory name: %s", error.message);
                    return false;
                }
                Gtk.Popover menu= new Gtk.Popover (bbox);
                var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
                var pop_button = new Gtk.ModelButton();
                pop_button.text = _("Open in Terminal");
                vbox.pack_start(pop_button, false, true, 10);
                vbox.show_all();
                menu.add(vbox);
                menu.set_position(Gtk.PositionType.LEFT);

                pop_button.button_press_event.connect ((b, ev) => {
                    debug("Open in Terminal " + app_arg);
                    try{
                        AppInfo ai = GLib.AppInfo.create_from_commandline (
                            "io.elementary.terminal -w " + app_arg,
                            "io.elementary.terminal", NONE);
                        ai.launch (null, null);
                        close();
                    }
                    catch (GLib.Error error) {
                        warning ("Error opening directory: %s", error.message);
                    }
                    return true;
                    });
                menu.show_all ();
            }
            return true;
            });
    }

    public void make_std_places () {
        label_name = _("Home Folder");
        icon_name = "go-home-symbolic";
        uri_name = "file:" + user_home;
        make_button (label_name, icon_name, uri_name);

        label_name = _("File System");
        icon_name = "drive-harddisk-symbolic";
        uri_name = "file:///";
        make_button (label_name, icon_name, uri_name);

        label_name = _("Recent");
        icon_name = "document-open-recent-symbolic";
        uri_name = "recent:///";
        make_button (label_name, icon_name, uri_name);

        label_name = _("Network");
        icon_name = "network-workgroup-symbolic";
        uri_name = "network:///";
        make_button (label_name, icon_name, uri_name);

        label_name = _("Trash");
        icon_name = "user-trash-symbolic";
        uri_name = "trash:///";
        make_button (label_name, icon_name, uri_name);

        main_widget.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, position);
        position++;
    }

    public void make_user_places () {
        config_dir = GLib.Path.build_filename (user_home, ".config");
        filename = GLib.Path.build_filename (config_dir, "gtk-3.0", "bookmarks", null);
        file = GLib.File.new_for_path (filename);

        if (!file.query_exists ()) {
            stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
        }

        try {
            var dis = new DataInputStream (file.read ());
            string line;

            while ((line = dis.read_line (null)) != null) {
                string path;
                string label;
                string book_path;
                path = line.split (" ")[0];
                // label = line.slice (line.index_of (" ") + 1, line.length);
                var file = File.new_for_uri (path);
                label = file.get_basename ();
                book_path = file.get_parse_name ();
                Icon _icon = get_user_icon (book_path);
                make_button (label, _icon.to_string (), path);
            }
        }
        catch (GLib.Error error) {
            warning ("%s", error.message);
        }
    }

    public GLib.Icon? get_user_icon (string path) {
        if (path[0:3] == "ssh" || path[0:3] == "ftp" || path[0:4] == "sftp"|| path[0:3] == "dav" || path[0:4] == "davs") {
            return new GLib.ThemedIcon ("folder-remote-symbolic");
            } else if (path[0:3] == "smb") {
                return new GLib.ThemedIcon ("network-server-symbolic");
            } else if (path[0:8] == "network:") {
                return new GLib.ThemedIcon ("network-workgroup-symbolic");
            } else if (path == GLib.Environment.get_home_dir ()) {
                return new GLib.ThemedIcon ("user-home-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DESKTOP)) {
                return new GLib.ThemedIcon ("user-desktop-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOCUMENTS)) {
                return new GLib.ThemedIcon ("folder-documents-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOWNLOAD)) {
                return new GLib.ThemedIcon ("folder-download-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.MUSIC)) {
                return new GLib.ThemedIcon ("folder-music-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PICTURES)) {
                return new GLib.ThemedIcon ("folder-pictures-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PUBLIC_SHARE)) {
                return new GLib.ThemedIcon ("folder-publicshare-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.TEMPLATES)) {
                return new GLib.ThemedIcon ("folder-templates-symbolic");
            } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.VIDEOS)) {
                return new GLib.ThemedIcon ("folder-videos-symbolic");
            } else if ((FileUtils.test (path, FileTest.IS_DIR)) == false) {
                return new GLib.ThemedIcon ("text-markdown-symbolic");
            } else {
                return new GLib.ThemedIcon ("folder-symbolic");
                }
            }

    public void start_monitor () {
        try {
            monitor = file.monitor (FileMonitorFlags.NONE, null);
            //debug ("Monitoring: %s\n", file.get_path ());
            monitor.changed.connect ((src, dest, event) => {
                if (event.to_string () == "G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT") {
                    //debug ("Bookmarks changed, updating menu...\n");
                    update_menu ();
                }
                });
        }
        catch (Error err) {
            print ("Error: %s\n", err.message);
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module,
                        Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Places Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new IndicatorPlaces ();
    return indicator;
}