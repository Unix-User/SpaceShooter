#!/usr/bin/env python3

import argparse
import contextlib
import os
import socket
import subprocess
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path


# See cpython GH-17851 and GH-17864.
class DualStackServer(HTTPServer):
    def server_bind(self):
        # Suppress exception when protocol is IPv4.
        with contextlib.suppress(Exception):
            self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
        return super().server_bind()


class CORSRequestHandler(SimpleHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_cors_headers()
        self.end_headers()

    def end_headers(self):
        self.send_cors_headers()
        super().end_headers()
    
    def send_cors_headers(self):
        # Configuração básica do CORS
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Access-Control-Max-Age", "3600")
        
        # Headers específicos para SharedArrayBuffer e isolamento de origem
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        
        # Headers adicionais de segurança
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "SAMEORIGIN")
        
        # Permitir credenciais
        self.send_header("Access-Control-Allow-Credentials", "true")


def shell_open(url):
    if sys.platform == "win32":
        os.startfile(url)
    else:
        opener = "open" if sys.platform == "darwin" else "xdg-open"
        subprocess.call([opener, url])


def serve(root, port, run_browser):
    os.chdir(root)

    address = ("", port)
    httpd = DualStackServer(address, CORSRequestHandler)

    url = f"http://127.0.0.1:{port}"
    if run_browser:
        # Open the served page in the user's default browser.
        print(f"Opening the served URL in the default browser (use `--no-browser` or `-n` to disable this): {url}")
        shell_open(url)
    else:
        print(f"Serving at: {url}")

    try:
        print(f"Server started at {url}")
        print("Press Ctrl+C to stop")
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nKeyboard interrupt received, stopping server.")
    finally:
        # Clean-up server
        httpd.server_close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--port", help="port to listen on", default=8060, type=int)
    parser.add_argument(
        "-r", "--root", help="path to serve as root (relative to `platform/web/`)", default="../../bin", type=Path
    )
    browser_parser = parser.add_mutually_exclusive_group(required=False)
    browser_parser.add_argument(
        "-n", "--no-browser", help="don't open default web browser automatically", dest="browser", action="store_false"
    )
    parser.set_defaults(browser=True)
    args = parser.parse_args()

    # Change to the directory where the script is located,
    # so that the script can be run from any location.
    os.chdir(Path(__file__).resolve().parent)

    serve(args.root, args.port, args.browser)
