FROM tomcat:8.5.24-jre8-alpine

ENV FORGEROCK_HOME /home/forgerock

ENV OPENAM_CONFIG_DIR "$FORGEROCK_HOME""/openam"
#ENV CATALINA_OPTS for performance and logging
ENV CATALINA_OPTS -server -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap \
  -Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true \
  -Dcom.sun.identity.util.debug.provider=com.sun.identity.shared.debug.impl.StdOutDebugProvider \
  -Dcom.sun.identity.shared.debug.file.format=\"%PREFIX% %MSG%\\n%STACKTRACE%\" \
  -Duser.home=$FORGEROCK_HOME \
  -Dcom.sun.identity.configuration.directory=$OPENAM_CONFIG_DIR
# Log files to be accessible
ENV UMASK="0002"
# Make sure the openam.war is downloaded and available at the work directory
COPY openam.war  /tmp/openam.war
# Make sure the Amster.zip is downloaded and available at the working directory
COPY Amster.zip /tmp/Amster.zip
COPY docker-entrypoint.sh ${FORGEROCK_HOME}/
# These are optional and prepared for OpenShift deployment
RUN apk add --no-cache su-exec unzip curl bash  \
  && rm -fr /usr/local/tomcat/webapps/* \
  && unzip -q /tmp/openam.war -d  "$CATALINA_HOME"/webapps/openam \
  #  Let's use bootstrap.properties rather than default location
  && echo "configuration.dir="$OPENAM_CONFIG_DIR"" >> "$CATALINA_HOME"/webapps/openam/WEB-INF/classes/bootstrap.properties \
  && rm /tmp/openam.war \
  # Add 'forgerock' to primary group 'root'. OpenShift's dynamic user also has 'root' as primary group.
  # By this the dynamic user has almost the same privs a 'forgerock'
  && adduser -s /bin/bash -h "$FORGEROCK_HOME" -u 11111 -G root -D forgerock \
  && mkdir -p "$OPENAM_CONFIG_DIR" \
  && chown -R forgerock:root "$CATALINA_HOME" \
  && chown -R forgerock:root  "$FORGEROCK_HOME" \
  && chown -R forgerock:root  "$OPENAM_CONFIG_DIR" \
  && chown -R forgerock:root  /usr/local \
  && chmod -R g=u "$CATALINA_HOME" \
  && chmod -R g=u "$FORGEROCK_HOME"

RUN mkdir -p "$FORGEROCK_HOME"/amster
RUN unzip -q /tmp/Amster.zip -d "$FORGEROCK_HOME"/amster
# USER forgerock
USER 11111
ENTRYPOINT ["/home/forgerock/docker-entrypoint.sh"]


