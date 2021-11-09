project(
    'places',
    'vala', 'c',
    version: '1.0.0'
)

gettext_name = meson.project_name() + '-indicator'
i18n = import('i18n')

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

add_project_arguments('-DG_LOG_DOMAIN="placesindicator"', language:'c')

wingpanel_dep = dependency('wingpanel')
wingpanel_indicatorsdir = wingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir])

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name() + '-indicator')
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

shared_module(
    meson.project_name(),
    config_file,
    'src/PlacesIndicator.vala',
    dependencies: [
        dependency('glib-2.0', version: '>=2.32'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gmodule-2.0'),
        dependency('gtk+-3.0'),
        dependency('gee-0.8'),
        meson.get_compiler('vala').find_library('posix'),
        wingpanel_dep

    ],
    install: true,
    install_dir: wingpanel_indicatorsdir
)

subdir('po')
