from flask import Flask, request, jsonify

app = Flask(__name__)

@app.post("/v1/jarvis")
def jarvis():
    payload = request.get_json(force=True)
    messages = payload.get("messages", [])
    last = messages[-1]["content"] if messages else ""
    # Replace this block with your chosen AI provider.
    # Keep provider/API secrets on the server.
    return jsonify({
        "text": f"I heard: {last}. Connect your AI provider here for the full JARVIS brain.",
        "actions": []
    })

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
