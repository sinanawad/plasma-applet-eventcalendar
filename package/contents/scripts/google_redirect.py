#!/usr/bin/env python3
"""OAuth 2.0 loopback redirect flow for Google Calendar/Tasks authorization.

Starts a local HTTP server, opens the browser to Google's auth page, captures
the callback with the authorization code, exchanges it for tokens, and prints
the token JSON to stdout.
"""

import argparse
import json
import sys
import threading
import urllib.parse
import urllib.request
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler

SCOPES = 'https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/tasks'
TOKEN_URL = 'https://oauth2.googleapis.com/token'
AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth'
TIMEOUT_SECONDS = 300  # 5 minutes


class OAuthCallbackHandler(BaseHTTPRequestHandler):
    """Handles the OAuth redirect callback from Google."""

    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)

        if 'code' in params:
            self.server.auth_code = params['code'][0]
            self._send_response(
                200,
                '<html><body><h2>Authorization successful!</h2>'
                '<p>You can close this tab and return to the widget settings.</p>'
                '</body></html>'
            )
        elif 'error' in params:
            error = params['error'][0]
            self.server.auth_error = error
            self._send_response(
                400,
                f'<html><body><h2>Authorization failed</h2>'
                f'<p>Error: {error}</p></body></html>'
            )
        else:
            self._send_response(
                400,
                '<html><body><h2>Unexpected response</h2></body></html>'
            )
        # Signal the main thread to stop waiting
        self.server.got_response.set()

    def _send_response(self, code, body):
        self.send_response(code)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(body.encode('utf-8'))

    def log_message(self, format, *args):
        """Suppress request logging to keep stdout clean for JSON output."""
        pass


def exchange_code_for_tokens(code, client_id, client_secret, redirect_uri):
    """Exchange authorization code for access/refresh tokens."""
    data = urllib.parse.urlencode({
        'code': code,
        'client_id': client_id,
        'client_secret': client_secret,
        'redirect_uri': redirect_uri,
        'grant_type': 'authorization_code',
    }).encode('utf-8')

    req = urllib.request.Request(TOKEN_URL, data=data, method='POST')
    req.add_header('Content-Type', 'application/x-www-form-urlencoded')

    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode('utf-8'))


def main():
    parser = argparse.ArgumentParser(description='Google OAuth 2.0 loopback flow')
    parser.add_argument('--client_id', required=True)
    parser.add_argument('--client_secret', required=True)
    args = parser.parse_args()

    # Bind to localhost on an OS-assigned free port
    server = HTTPServer(('127.0.0.1', 0), OAuthCallbackHandler)
    server.auth_code = None
    server.auth_error = None
    server.got_response = threading.Event()
    port = server.server_address[1]

    redirect_uri = f'http://127.0.0.1:{port}/'

    # Build the authorization URL
    auth_params = urllib.parse.urlencode({
        'client_id': args.client_id,
        'redirect_uri': redirect_uri,
        'response_type': 'code',
        'scope': SCOPES,
        'access_type': 'offline',
        'prompt': 'consent',
    })
    auth_url = f'{AUTH_URL}?{auth_params}'

    # Start server in a background thread
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()

    # Open browser
    webbrowser.open(auth_url)

    # Wait for the callback (with timeout)
    server.got_response.wait(timeout=TIMEOUT_SECONDS)
    server.shutdown()

    if server.auth_error:
        print(f'Authorization error: {server.auth_error}', file=sys.stderr)
        sys.exit(1)

    if not server.auth_code:
        print('Timed out waiting for authorization.', file=sys.stderr)
        sys.exit(1)

    # Exchange the authorization code for tokens
    try:
        token_data = exchange_code_for_tokens(
            server.auth_code,
            args.client_id,
            args.client_secret,
            redirect_uri,
        )
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8', errors='replace')
        print(f'Token exchange failed ({e.code}): {body}', file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f'Token exchange failed: {e}', file=sys.stderr)
        sys.exit(1)

    # Print token JSON to stdout for the QML caller
    print(json.dumps(token_data))


if __name__ == '__main__':
    main()
