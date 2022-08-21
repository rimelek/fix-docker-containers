FROM httpd:2.4

RUN unlink /usr/local/bin/httpd-foreground

RUN cp /usr/local/bin/httpd-foreground /custom-command

CMD ["/custom-command"]

