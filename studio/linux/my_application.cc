#include "my_application.h"

#include <flutter_linux/flutter_linux.h>

#include <sys/types.h>
#include <signal.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication
{
  GtkApplication parent_instance;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void on_close()
{
  // kill(0, SIGTERM);
  exit(0);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication *application)
{
  g_object_set(gtk_settings_get_default(),
               "gtk-application-prefer-dark-theme", TRUE,
               NULL);

  GtkWindow *window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  g_signal_connect(window, "delete_event", G_CALLBACK(on_close), NULL);

  // GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
  // gtk_widget_show(GTK_WIDGET(header_bar));
  // gtk_header_bar_set_title(header_bar, "studio");
  // gtk_header_bar_set_show_close_button(header_bar, TRUE);
  // gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  gtk_window_set_title(window, "Terminal Studio");
  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
  // gtk_widget_set_opacity (GTK_WIDGET(window), 0.5);

  g_autoptr(FlDartProject) project = fl_dart_project_new();

  FlView *view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

static void my_application_class_init(MyApplicationClass *klass)
{
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new()
{
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     nullptr));
}
