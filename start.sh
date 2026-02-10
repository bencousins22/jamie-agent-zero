#!/bin/bash
set -e

echo "🚀 Starting Agent Zero Enterprise..."
echo "📅 $(date)"

# Set defaults
export PORT="${PORT:-80}"
export API_PORT="${API_PORT:-50001}"
export AGENT_NAME="${AGENT_NAME:-Enterprise-Agent}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Create data directories
mkdir -p /app/data /app/logs
echo "✅ Data directories ready"

# Check for API keys
if [ -z "$OPENAI_API_KEY" ] && [ -z "$OPENROUTER_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  Warning: No AI Provider API Key set (OPENAI_API_KEY or OPENROUTER_API_KEY or ANTHROPIC_API_KEY)"
fi

# Start Nginx in background
echo "🌐 Starting Nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!
echo "✅ Nginx started (PID: $NGINX_PID)"

# Give Nginx time to start
sleep 2

# Configuration summary
echo ""
echo "════════════════════════════════════════════════"
echo "   Agent Zero Enterprise"
echo "════════════════════════════════════════════════"
echo "Port:           $PORT"
echo "API Port:       $API_PORT"
echo "Agent Name:     $AGENT_NAME"
echo "Log Level:      $LOG_LEVEL"
echo "════════════════════════════════════════════════"
echo ""

# Start Agent Zero
echo "🤖 Starting Agent Zero..."
cd /app

# Try different entry points
if [ -f "run_ui.py" ]; then
    echo "✅ Using run_ui.py"
    exec python run_ui.py --port=${API_PORT}
elif [ -f "run_ui.sh" ]; then
    echo "✅ Using run_ui.sh"
    chmod +x run_ui.sh
    exec ./run_ui.sh
elif [ -f "python/run_ui.py" ]; then
    echo "✅ Using python/run_ui.py"
    cd python
    exec python run_ui.py
elif [ -f "webui/server.py" ]; then
    echo "✅ Using webui/server.py"
    cd webui
    exec python server.py
elif [ -f "run.py" ]; then
    echo "✅ Using run.py"
    exec python run.py
elif [ -f "main.py" ]; then
    echo "✅ Using main.py"
    exec python main.py
else
    echo "❌ No entry point found. Available files:"
    ls -la /app/
    echo ""
    echo "Starting basic web server for healthcheck..."
    exec python3 -m http.server $API_PORT
fi
