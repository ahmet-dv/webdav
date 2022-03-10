# HTTPS WebDAV

This image is based on the [Apache HTTP Server] image. It can be used on any architecture that the httpd image supports.

HTTPS is the only protocol enabled. Default authentication is Basic.

### Apache Server Configuration

When the container is first created, configuration files are copied to the /config path. The files can be freely modified. It may be necessary to restart the container after a change.

### Environment variables

Configuration path shall always be defined.

    CONFIGPATH : Volume bind for the configuration folder. (eg, /path/to/folder:/config)

Below environment variables are optional. If not defined, default values are used.

    SERVER_NAME : The default is "localhost".
    USERNAME : The default username is "webdav".
    PASSWORD : The default password is "webdav".

### Source Code

https://github.com/ahmet-dv/webdav

[Apache HTTP Server]: <https://hub.docker.com/_/httpd>
