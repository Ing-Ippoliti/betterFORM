/*
 * ====================================================================
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 *
 * Stripped down Version of http://svn.apache.org/repos/asf/httpcomponents/oac.hc3x/trunk/src/contrib/org/apache/commons/httpclient/contrib/ssl/AuthSSLProtocolSocketFactory.java with betterForm specific extensions.
 *
 * Original Header:
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 *
 * $HeadURL: http://svn.apache.org/repos/asf/httpcomponents/oac.hc3x/trunk/src/contrib/org/apache/commons/httpclient/contrib/ssl/AuthSSLProtocolSocketFactory.java $
 * $Revision: 608014 $
 * $Date: 2008-01-02 06:48:53 +0100 (Mi, 02. Jan 2008) $
 *
 * ====================================================================
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 *
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */

package de.betterform.connector.http.ssl;

import de.betterform.connector.http.AbstractHTTPConnector;
import de.betterform.xml.config.Config;
import de.betterform.xml.config.XFormsConfigException;

import org.apache.commons.httpclient.contrib.ssl.AuthSSLInitializationError;
import org.apache.commons.httpclient.contrib.ssl.AuthSSLX509TrustManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.net.ssl.*;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.*;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Enumeration;

import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.conn.scheme.SocketFactory;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.params.HttpConnectionParams;

/**
 * @author <a href="mailto:tobias.krebs@betterform.de">tobi</a>
 * @version $Id: KeyStoreSSLProtocolSocketFactory 08.10.2010 tobi $
 */
public class KeyStoreSSLProtocolSocketFactory {
    private static String keyStorePath = null;
    private static String keyStorePasswd = null;
    private SSLContext sslcontext = null;

    private static Log LOGGER = LogFactory.getLog(KeyStoreSSLProtocolSocketFactory.class);

    public KeyStoreSSLProtocolSocketFactory() {
        try {
            this.keyStorePath = Config.getInstance().getProperty(AbstractHTTPConnector.HTTPCLIENT_SSL_KEYSTORE_PATH, null);
            this.keyStorePasswd = Config.getInstance().getProperty(AbstractHTTPConnector.HTTPCLIENT_SSL_KEYSTORE_PASSWD , null);
        } catch (XFormsConfigException xfce) {
           LOGGER.warn(xfce.getLocalizedMessage(), xfce);
        }
    }

    private URL getKeyStoreURL() throws AuthSSLInitializationError {
        if (KeyStoreSSLProtocolSocketFactory.keyStorePath != null) {
            File keystore;

            if (KeyStoreSSLProtocolSocketFactory.keyStorePath.startsWith( File.separator)) {
                keystore = new File(KeyStoreSSLProtocolSocketFactory.keyStorePath);
            } else {
                keystore = new File(System.getProperty("user.home") + File.separator + KeyStoreSSLProtocolSocketFactory.keyStorePath);
            }
            try {
                return keystore.toURI().toURL();
            } catch (MalformedURLException murle) {
                LOGGER.error("Wrong Syntax in " + AbstractHTTPConnector.HTTPCLIENT_SSL_KEYSTORE_PATH, murle);
                throw new AuthSSLInitializationError("Wrong Syntax in " + AbstractHTTPConnector.HTTPCLIENT_SSL_KEYSTORE_PATH);
            }
        } else {
            throw new AuthSSLInitializationError("You must configure "+ AbstractHTTPConnector.HTTPCLIENT_SSL_KEYSTORE_PATH + " in betterform-config.xml!");
        }
    }

    private String getKeyStorePasswd() throws AuthSSLInitializationError {
        if (KeyStoreSSLProtocolSocketFactory.keyStorePasswd != null) {
            //TODO: Support encryption of passwd!
            return KeyStoreSSLProtocolSocketFactory.keyStorePasswd;
        }

        throw new AuthSSLInitializationError("You must configure "+ AbstractHTTPConnector.HTTPCLIENT_SSL_KEYSTORE_PASSWD + " in betterform-config.xml!");
    }

    public static KeyStore createKeyStore(final URL url, final String password)
        throws KeyStoreException, NoSuchAlgorithmException, CertificateException, IOException
    {
        if (url == null) {
            throw new IllegalArgumentException("Keystore url may not be null");
        }

        LOGGER.debug("Initializing key store");
        KeyStore keystore  = KeyStore.getInstance("jks");
        InputStream is = null;
        try {
        	is = url.openStream();
            keystore.load(is, password != null ? password.toCharArray(): null);
        } finally {
        	if (is != null) is.close();
        }
        return keystore;
    }

    private static TrustManager[] createTrustManagers(final KeyStore keystore)
        throws KeyStoreException, NoSuchAlgorithmException
    {
        if (keystore == null) {
            throw new IllegalArgumentException("Keystore may not be null");
        }
        LOGGER.debug("Initializing trust manager");
        TrustManagerFactory tmfactory = TrustManagerFactory.getInstance(
            TrustManagerFactory.getDefaultAlgorithm());
        tmfactory.init(keystore);
        TrustManager[] trustmanagers = tmfactory.getTrustManagers();
        for (int i = 0; i < trustmanagers.length; i++) {
            if (trustmanagers[i] instanceof X509TrustManager) {
                trustmanagers[i] = new AuthSSLX509TrustManager(
                    (X509TrustManager)trustmanagers[i]);
            }
        }
        return trustmanagers;
    }

    private SSLContext createSSLContext() {
        try {
            TrustManager[] trustmanagers = null;
            if (getKeyStoreURL() != null) {
                KeyStore keystore = createKeyStore(getKeyStoreURL(), getKeyStorePasswd());
                if (LOGGER.isTraceEnabled()) {
                    Enumeration aliases = keystore.aliases();
                    while (aliases.hasMoreElements()) {
                        String alias = (String)aliases.nextElement();
                        LOGGER.trace("Trusted certificate '" + alias + "':");
                        Certificate trustedcert = keystore.getCertificate(alias);
                        if (trustedcert != null && trustedcert instanceof X509Certificate) {
                            X509Certificate cert = (X509Certificate)trustedcert;
                            LOGGER.trace("  Subject DN: " + cert.getSubjectDN());
                            LOGGER.trace("  Signature Algorithm: " + cert.getSigAlgName());
                            LOGGER.trace("  Valid from: " + cert.getNotBefore() );
                            LOGGER.trace("  Valid until: " + cert.getNotAfter());
                            LOGGER.trace("  Issuer: " + cert.getIssuerDN());
                        }
                    }
                }
                trustmanagers = createTrustManagers(keystore);
            }
            SSLContext sslcontext = SSLContext.getInstance("SSL");
            sslcontext.init(null, trustmanagers, null);
            return sslcontext;
        } catch (NoSuchAlgorithmException e) {
            LOGGER.error(e.getMessage(), e);
            throw new AuthSSLInitializationError("Unsupported algorithm exception: " + e.getMessage());
        } catch (KeyStoreException e) {
            LOGGER.error(e.getMessage(), e);
            throw new AuthSSLInitializationError("Keystore exception: " + e.getMessage());
        } catch (GeneralSecurityException e) {
            LOGGER.error(e.getMessage(), e);
            throw new AuthSSLInitializationError("Key management exception: " + e.getMessage());
        } catch (IOException e) {
            LOGGER.error(e.getMessage(), e);
            throw new AuthSSLInitializationError("I/O error reading keystore/truststore file: " + e.getMessage());
        }
    }

    private SSLContext getSSLContext() {
        if (this.sslcontext == null) {
            this.sslcontext = createSSLContext();
        }
        return this.sslcontext;
    }


    /**
     * Attempts to get a new socket connection to the given host within the given time limit.
     * <p>
     * To circumvent the limitations of older JREs that do not support connect timeout a
     * controller thread is executed. The controller thread attempts to create a new socket
     * within the given limit of time. If socket constructor does not return until the

     * </p>
     *
     * @param host the host name/IP
     * @param port the port on the host
     * @param localAddress the local host name/IP to bind the socket to
     * @param localPort the port on the local machine

     *
     * @return Socket a new socket
     *
     * @throws IOException if an I/O error occurs while creating the socket
     * @throws java.net.UnknownHostException if the IP address of the host cannot be
     * determined
     */
    public Socket createSocket(
        final String host,
        final int port,
        final InetAddress localAddress,
        final int localPort,
        final HttpConnectionParams params
    ) throws IOException, UnknownHostException, ConnectTimeoutException {
        if (params == null) {
            throw new IllegalArgumentException("Parameters may not be null");
        }
        int timeout = 0;//params.getConnectionTimeout(params);
        SSLSocketFactory socketfactory = new SSLSocketFactory(getSSLContext());
            Socket socket = socketfactory.createSocket();
            SocketAddress localaddr = new InetSocketAddress(localAddress, localPort);
            SocketAddress remoteaddr = new InetSocketAddress(host, port);
            socket.bind(localaddr);
            if (timeout == 0) {
                socket.connect(remoteaddr, timeout);
            } else {
                socket.connect(remoteaddr);
            }
            return socket;
    }

    public Socket createSocket(
        String host,
        int port,
        InetAddress clientHost,
        int clientPort)
        throws IOException, UnknownHostException
   {
       return getSSLContext().getSocketFactory().createSocket(
            host,
            port,
            clientHost,
            clientPort
        );
    }


    public Socket createSocket(String host, int port)
        throws IOException, UnknownHostException
    {
        return getSSLContext().getSocketFactory().createSocket(
            host,
            port
        );
    }


    public Socket createSocket(
        Socket socket,
        String host,
        int port,
        boolean autoClose)
        throws IOException, UnknownHostException
    {
        return getSSLContext().getSocketFactory().createSocket(
            socket,
            host,
            port,
            autoClose
        );
    }
}
