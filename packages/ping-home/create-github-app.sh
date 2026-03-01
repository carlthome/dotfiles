#!/usr/bin/env bash
# Create and install a GitHub App for Terraform CI authentication.
# Uses the GitHub App Manifest flow: auto-submits a pre-filled form, then
# exchanges a one-time code for the App ID and private key automatically.
set -euo pipefail

cd "$(dirname "$0")"

set -a
# shellcheck source=/dev/null
source .env
set +a

APP_SLUG=""

# Skip creation if the app is already configured; just re-open the install page.
if gh api "repos/${GITHUB_REPO}/actions/variables/GH_APP_ID" &>/dev/null; then
	echo "✓ GitHub App already configured (GH_APP_ID is set). Skipping creation."
	echo "  To recreate: gh variable delete GH_APP_ID --repo ${GITHUB_REPO}"
	APP_SLUG=$(gh api "repos/${GITHUB_REPO}/actions/variables/GH_APP_SLUG" --jq '.value' 2>/dev/null || true)
else
	TMP=$(mktemp -d)
	trap 'rm -rf "$TMP"' EXIT

	# Write the Ruby manifest server to a temp file (avoids heredoc escaping issues).
	# Uses only Ruby stdlib (socket, json, net/http) — available in macOS system Ruby.
	cat >"$TMP/server.rb" <<'RBEOF'
require 'json'
require 'net/http'
require 'securerandom'
require 'socket'
require 'uri'

github_repo = ENV.fetch('GITHUB_REPO')
repo_name   = github_repo.split('/')[1]
port        = 19876
state       = SecureRandom.hex(16)

manifest = JSON.generate(
  'name'                => "Terraform for #{repo_name}",
  'url'                 => "https://github.com/#{github_repo}",
  'hook_attributes'     => { 'active' => false, 'url' => 'https://example.com' },
  'redirect_url'        => "http://localhost:#{port}/callback",
  'public'              => false,
  'default_permissions' => { 'contents' => 'read', 'actions' => 'write', 'administration' => 'write', 'secrets' => 'write' },
  'default_events'      => []
)
manifest_html = manifest.gsub('&', '&amp;').gsub('"', '&quot;')

html = <<~HTML
  <!DOCTYPE html>
  <html><head><title>Creating GitHub App...</title></head>
  <body><p>Redirecting to GitHub to pre-fill your app...</p>
  <form id="f" method="post" action="https://github.com/settings/apps/new?state=#{state}">
    <input type="hidden" name="manifest" value="#{manifest_html}">
  </form>
  <script>document.getElementById('f').submit();</script>
  </body></html>
HTML

code = nil
server = TCPServer.new('localhost', port)
$stderr.puts "Waiting for GitHub callback on http://localhost:#{port} ..."
Thread.new { sleep 0.3; system('open', "http://localhost:#{port}") }

loop do
  client  = server.accept
  request = client.gets
  path    = request&.split(' ')&.[](1) || '/'

  # Drain remaining headers.
  loop { break if (line = client.gets).nil? || line.chomp.empty? }

  if path.start_with?('/callback')
    params = URI.decode_www_form(path.split('?')[1] || '')
    code   = params.to_h['code']
    body   = '<html><body><h2>Done! You can close this tab.</h2></body></html>'
    client.print "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: #{body.bytesize}\r\n\r\n#{body}"
    client.close
    break
  else
    client.print "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: #{html.bytesize}\r\n\r\n#{html}"
    client.close
  end
end

server.close
abort 'No code received from GitHub.' if code.nil?

uri = URI("https://api.github.com/app-manifests/#{code}/conversions")
req = Net::HTTP::Post.new(uri, 'Accept' => 'application/vnd.github+json')
res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
app = JSON.parse(res.body)

puts JSON.generate('id' => app['id'], 'slug' => app['slug'], 'pem' => app['pem'])
RBEOF

	echo "Opening browser to create GitHub App (form will be pre-filled)..."
	APP_JSON=$(/usr/bin/ruby "$TMP/server.rb")

	APP_ID=$(echo "$APP_JSON" | jq -r '.id')
	APP_SLUG=$(echo "$APP_JSON" | jq -r '.slug')
	PRIVATE_KEY=$(echo "$APP_JSON" | jq -r '.pem')

	echo "✓ Created app '${APP_SLUG}' (ID: ${APP_ID})"

	gh variable set GH_APP_ID --repo "$GITHUB_REPO" --body "$APP_ID"
	gh variable set GH_APP_SLUG --repo "$GITHUB_REPO" --body "$APP_SLUG"
	gh secret set GH_APP_PRIVATE_KEY --repo "$GITHUB_REPO" --body "$PRIVATE_KEY"

	echo "✓ GH_APP_ID, GH_APP_SLUG, and GH_APP_PRIVATE_KEY stored"
	echo ""
fi

if [ -n "$APP_SLUG" ]; then
	INSTALL_URL="https://github.com/settings/apps/${APP_SLUG}/installations"
	echo "Opening ${INSTALL_URL} to install the app on ${GITHUB_REPO}..."
	if command -v open &>/dev/null; then
		open "$INSTALL_URL"
	else
		echo "Navigate to: $INSTALL_URL"
	fi
else
	echo "Navigate to https://github.com/settings/apps to install the app on ${GITHUB_REPO}."
fi

read -rp "Press Enter once the app is installed on ${GITHUB_REPO}..."
echo "✓ Done!"
