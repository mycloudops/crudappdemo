rom tomcat:8.0

COPY target/crudApp.war CATALINA_BASE/webapps

Expose 8080

CMD ["catalina.sh", "run"]