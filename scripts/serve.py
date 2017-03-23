#!/usr/bin/env python

import BaseHTTPServer, SimpleHTTPServer
import ssl
import os

DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

httpd = BaseHTTPServer.HTTPServer(('127.0.0.1', 4443), SimpleHTTPServer.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket (httpd.socket, certfile=DIR + '/ssl/server.pem', server_side=True)
httpd.serve_forever()
