FROM httpd:2.4

RUN cp /usr/local/bin/httpd-foreground /custom-command

RUN unlink /usr/local/bin/httpd-foreground

CMD ["/custom-command"]

