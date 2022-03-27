FROM daggerok/jboss-eap-7.1:7.1.61-alpine
COPY ./target/helloworld-ws.war ${JBOSS_HOME}/standalone/deployments/